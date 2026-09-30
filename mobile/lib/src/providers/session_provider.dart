import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/client.dart';
import '../api/generated/models.dart';
import '../services/secure_storage.dart';

/// Server capability flags derived from `/server/features`-shaped endpoints.
/// The public spec exposes these through `/users/me/config` and the OAuth
/// status endpoint, so they are aggregated here instead of a single call.
class ServerCapabilities {
  ServerCapabilities({
    this.oauthEnabled = false,
    this.oauthButtonText,
    this.smartSearch = true,
    this.facialRecognition = false,
    this.map = true,
    this.trash = true,
    this.passwordLogin = true,
    this.loginPageMessage,
    this.externalDomain,
  });

  final bool oauthEnabled;
  final String? oauthButtonText;
  final bool smartSearch;
  final bool facialRecognition;
  final bool map;
  final bool trash;
  final bool passwordLogin;
  final String? loginPageMessage;
  final String? externalDomain;
}

/// Session snapshot exposed to the UI.
class SessionState {
  SessionState({
    this.config,
    this.user,
    this.serverVersion,
    this.capabilities,
    this.error,
    this.isLoading = false,
  });

  final ServerConfig? config;
  final UserAdminResponseDto? user;
  final ServerVersionResponseDto? serverVersion;
  final ServerCapabilities? capabilities;
  final String? error;
  final bool isLoading;

  bool get isLoggedIn => user != null && config?.accessToken != null;

  SessionState copyWith({
    ServerConfig? config,
    UserAdminResponseDto? user,
    ServerVersionResponseDto? serverVersion,
    ServerCapabilities? capabilities,
    String? error,
    bool? isLoading,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      SessionState(
        config: config ?? this.config,
        user: clearUser ? null : (user ?? this.user),
        serverVersion: serverVersion ?? this.serverVersion,
        capabilities: capabilities ?? this.capabilities,
        error: clearError ? null : (error ?? this.error),
        isLoading: isLoading ?? this.isLoading,
      );
}

/// Discovers the API root the way the official app does: `/.well-known/immich`
/// first, then `<url>/api`, and finally the bare `<url>`.
class ServerDiscovery {
  ServerDiscovery({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static String normalize(String input) {
    var url = input.trim();
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Returns the API root (e.g. `https://host/api`).
  Future<String> resolve(String rawUrl) async {
    final base = normalize(rawUrl);
    final candidates = <String>[];

    // 1. Explicit well-known document.
    try {
      final res = await _dio
          .get<String>(
        '$base/.well-known/immich',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          validateStatus: (s) => s != null && s < 500,
        ),
      ).timeout(const Duration(seconds: 8));
      final body = res.data;
      if (body != null && body.isNotEmpty) {
        final doc = jsonDecode(body) as Map<String, dynamic>;
        final api = doc['api'] as String?;
        if (api != null && api.isNotEmpty) {
          candidates.add(api.startsWith('http') ? api : '$base$api');
        }
      }
    } catch (_) {
      // Not fatal: fall through to the conventional locations.
    }

    candidates.addAll(['$base/api', base]);

    for (final c in candidates) {
      if (await _ping(c)) return c;
    }
    throw ImmichApiException(
      'Could not reach an Immich server at $base. Check the URL and network.',
      statusCode: 0,
    );
  }

  Future<bool> _ping(String endpoint) async {
    try {
      final res = await _dio
          .get<Map<String, dynamic>>(
        '$endpoint/server/ping',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          validateStatus: (s) => s != null && s < 500,
        ),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return false;
      final data = res.data;
      return data != null && (data['res'] == 'pong' || data['res'] == true);
    } catch (_) {
      return false;
    }
  }
}

final serverDiscoveryProvider =
    Provider<ServerDiscovery>((ref) => ServerDiscovery());

/// Controller for login / logout / session restore.
class SessionController extends StateNotifier<SessionState> {
  SessionController(this._store, this._discovery)
      : super(SessionState(isLoading: true)) {
    restore();
  }

  final SecureStore _store;
  final ServerDiscovery _discovery;

  ImmichApiClient? _client;

  /// The active API client, or null while logged out.
  ImmichApiClient? get client => _client;

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, clearError: true);
    ServerConfig? cfg;
    try {
      cfg = await _store.readServerConfig();
    } catch (e) {
      // Storage must never wedge the login screen: fall through logged out.
      state = SessionState(isLoading: false, error: e.toString());
      return;
    }
    if (cfg == null || cfg.accessToken == null) {
      state = SessionState(isLoading: false);
      return;
    }
    try {
      final api = cfg.apiEndpoint ??
          '${ServerDiscovery.normalize(cfg.serverUrl)}/api';
      _client = ImmichApiClient(
        baseUrl: api,
        accessToken: cfg.accessToken!,
      );
      final user = await _client!.getMyUser();
      state = SessionState(config: cfg, user: user, isLoading: false);
      unawaited(_loadServerInfo());
    } on ImmichApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _store.clearServerConfig();
        _client = null;
        state = SessionState(isLoading: false, error: 'Session expired');
      } else {
        // Keep the session; the server may just be unreachable offline.
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadServerInfo() async {
    final c = _client;
    if (c == null) return;
    try {
      ServerVersionResponseDto? version;
      UserConfigDto? config;
      try {
        version = await c.getServerVersion();
      } catch (_) {
        version = null;
      }
      try {
        config = await c.getUserConfig();
      } catch (_) {
        config = null;
      }
      state = state.copyWith(
        serverVersion: version,
        capabilities: ServerCapabilities(
          oauthEnabled: config?.oauth?.enabled ?? false,
          oauthButtonText: config?.oauth?.buttonText,
          smartSearch: config?.machineLearning?.clip?.enabled ?? true,
          facialRecognition:
              config?.machineLearning?.facialRecognition?.enabled ?? false,
          map: config?.map?.enabled ?? true,
          trash: config?.trash?.enabled ?? true,
          passwordLogin: config?.passwordLogin?.enabled ?? true,
          loginPageMessage: config?.server?.loginPageMessage,
          externalDomain: config?.server?.externalDomain,
        ),
      );
    } catch (_) {
      // Non-fatal: some endpoints are only available on newer servers.
    }
  }

  /// Full login flow: discover endpoint → authenticate → persist → load user.
  Future<void> login({
    required String serverUrl,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiEndpoint = await _discovery.resolve(serverUrl);
      final client = ImmichApiClient(baseUrl: apiEndpoint);
      final res = await client.login(
        body: LoginCredentialDto(email: email, password: password),
      );
      await _persistAndLoad(
        apiEndpoint: apiEndpoint,
        serverUrl: serverUrl,
        accessToken: res.accessToken!,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is ImmichApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  /// Login with an API key pasted by the user.
  Future<void> loginWithApiKey({
    required String serverUrl,
    required String apiKey,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiEndpoint = await _discovery.resolve(serverUrl);
      await _persistAndLoad(
        apiEndpoint: apiEndpoint,
        serverUrl: serverUrl,
        accessToken: apiKey,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> _persistAndLoad({
    required String apiEndpoint,
    required String serverUrl,
    required String accessToken,
  }) async {
    final deviceId = 'immich-z-${Platform.operatingSystem}';
    final cfg = ServerConfig(
      serverUrl: ServerDiscovery.normalize(serverUrl),
      apiEndpoint: apiEndpoint,
      accessToken: accessToken,
      deviceId: deviceId,
    );
    _client = ImmichApiClient(baseUrl: apiEndpoint, accessToken: accessToken);
    final user = await _client!.getMyUser();
    await _store.writeServerConfig(cfg);
    state = SessionState(config: cfg, user: user, isLoading: false);
    unawaited(_loadServerInfo());
  }

  Future<void> logout() async {
    try {
      await _client?.logout();
    } catch (_) {
      // Ignore: we clear local state regardless.
    }
    await _store.clearServerConfig();
    _client = null;
    state = SessionState(isLoading: false);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(
    ref.watch(SecureStore.provider),
    ref.watch(serverDiscoveryProvider),
  );
});

/// Convenience: the live client, or null when logged out.
final apiClientProvider = Provider<ImmichApiClient?>((ref) {
  return ref.watch(sessionProvider.notifier).client;
});
