import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Everything the app needs to reach a server, persisted in the platform
/// keystore / keychain.
class ServerConfig {
  ServerConfig({
    required this.serverUrl,
    this.apiEndpoint,
    this.accessToken,
    this.deviceId,
  });

  final String serverUrl;
  final String? apiEndpoint;
  final String? accessToken;
  final String? deviceId;

  ServerConfig copyWith({
    String? serverUrl,
    String? apiEndpoint,
    String? accessToken,
    String? deviceId,
  }) =>
      ServerConfig(
        serverUrl: serverUrl ?? this.serverUrl,
        apiEndpoint: apiEndpoint ?? this.apiEndpoint,
        accessToken: accessToken ?? this.accessToken,
        deviceId: deviceId ?? this.deviceId,
      );

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'apiEndpoint': apiEndpoint,
        'accessToken': accessToken,
        'deviceId': deviceId,
      };

  static ServerConfig? fromJson(Map<String, dynamic> j) {
    final url = j['serverUrl'] as String?;
    if (url == null) return null;
    return ServerConfig(
      serverUrl: url,
      apiEndpoint: j['apiEndpoint'] as String?,
      accessToken: j['accessToken'] as String?,
      deviceId: j['deviceId'] as String?,
    );
  }
}

class SecureStore {
  SecureStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _kServerConfig = 'immich.server_config';

  static const AndroidOptions _android = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static final provider = Provider<SecureStore>(
    (ref) => SecureStore(const FlutterSecureStorage(aOptions: _android)),
  );

  Future<ServerConfig?> readServerConfig() async {
    final raw = await _storage.read(key: _kServerConfig);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ServerConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeServerConfig(ServerConfig c) =>
      _storage.write(key: _kServerConfig, value: jsonEncode(c.toJson()));

  Future<void> clearServerConfig() => _storage.delete(key: _kServerConfig);
}
