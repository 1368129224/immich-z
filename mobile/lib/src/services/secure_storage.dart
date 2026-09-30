import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _prefsPrefix = 'secure_fallback.';

  Future<String?> _readRaw(String key) async {
    try {
      final v = await _storage.read(key: key);
      if (v != null) return v;
    } on PlatformException catch (e) {
      debugPrint('SecureStore: keychain read failed, trying prefs: $e');
    } catch (e) {
      debugPrint('SecureStore: secure read failed, trying prefs: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_prefsPrefix$key');
    } catch (e) {
      debugPrint('SecureStore: prefs read failed: $e');
      return null;
    }
  }

  Future<void> _writeRaw(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      // Keychain works: drop any stale prefs mirror.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('$_prefsPrefix$key');
      } catch (_) {}
      return;
    } on PlatformException catch (e) {
      debugPrint('SecureStore: keychain write failed, using prefs: $e');
    } catch (e) {
      debugPrint('SecureStore: secure write failed, using prefs: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsPrefix$key', value);
  }

  Future<void> _deleteRaw(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('SecureStore: secure delete failed: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefsPrefix$key');
    } catch (_) {}
  }

  Future<ServerConfig?> readServerConfig() async {
    final raw = await _readRaw(_kServerConfig);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ServerConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeServerConfig(ServerConfig c) =>
      _writeRaw(_kServerConfig, jsonEncode(c.toJson()));

  Future<void> clearServerConfig() => _deleteRaw(_kServerConfig);
}
