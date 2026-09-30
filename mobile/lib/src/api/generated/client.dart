// ---------------------------------------------------------------------------
// GENERATED FILE - do not edit by hand.
// Source: immich-app/immich open-api/immich-openapi-specs.json (3.2.0)
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'models.dart';

typedef Json = Map<String, dynamic>;

/// Thrown for every non-2xx answer from an Immich server.
class ImmichApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic body;
  const ImmichApiException(this.message, {this.statusCode, this.body});
  @override
  String toString() => 'ImmichApiException($statusCode): $message';
}

/// Typed, dependency-free client for the Immich REST API.
///
/// Every method mirrors one operation of the published OpenAPI document;
/// `baseUrl` must include the `/api` prefix (e.g. `https://host/api`).
class ImmichApiClient {
  final Dio _dio;
  String baseUrl;
  String? accessToken;

  ImmichApiClient({
    required this.baseUrl,
    this.accessToken,
    Dio? dio,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 120),
  }) : _dio = dio ??
            Dio(BaseOptions(
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          responseType: ResponseType.json,
        ));

  Dio get dio => _dio;

  Options _opts({ResponseType? responseType, Map<String, dynamic>? extra}) => Options(
    responseType: responseType,
    extra: extra,
  );

  Future<Response<dynamic>> _request(
    String method,
    String path,
    {Map<String, dynamic>? queryParameters,
    dynamic data,
    ResponseType? responseType,
    Options? options,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken}) async {
    final params =
        Map<String, dynamic>.from(queryParameters ?? const {});
    params.removeWhere((k, v) => v == null);
    try {
      return await _dio.fetch<dynamic>(
        RequestOptions(
          method: method,
          path: path,
          baseUrl: baseUrl,
          queryParameters: params,
          data: data,
          responseType: responseType ?? ResponseType.json,
          onSendProgress: onSendProgress,
          cancelToken: cancelToken,
          headers: {
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } on DioException catch (e) {
      throw ImmichApiException(
        e.response?.data is Map ? (e.response!.data['message']?.toString() ??
            e.message ??
            'request failed') : (e.message ?? 'request failed'),
        statusCode: e.response?.statusCode,
        body: e.response?.data,
      );
    }
  }

  /// Raw bytes of any authenticated Immich path (thumbnails, originals...).
  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final res = await _request('GET', path,
        queryParameters: queryParameters,
        responseType: ResponseType.bytes,
        options: options,
        cancelToken: cancelToken);
    final d = res.data;
    if (d is Uint8List) return d;
    if (d is List<int>) return Uint8List.fromList(d);
    throw const ImmichApiException('expected binary response');
  }

  /// Downloads to a file, reporting progress in [0..1].
  Future<void> downloadToFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: (queryParameters ?? const {})
          .map((k, v) => MapEntry(k, v?.toString())),
    );
    try {
      await _dio.downloadUri(uri, savePath,
          cancelToken: cancelToken,
          onReceiveProgress: onProgress,
          options: Options(headers: {
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          }));
    } on DioException catch (e) {
      throw ImmichApiException(e.message ?? 'download failed',
          statusCode: e.response?.statusCode);
    }
  }

  /// Uploads one asset (multipart/form-data, mirrors `POST /assets`).
  Future<AssetMediaResponseDto> uploadAsset(
    Uint8List bytes, {
    required String filename,
    required DateTime fileCreatedAt,
    required DateTime fileModifiedAt,
    String? assetDataContentType,
    String? deviceAssetId,
    String? deviceId,
    String? duration,
    bool? isFavorite,
    bool? isArchived,
    String? livePhotoVideoId,
    String? sidecarData,
    double? latitude,
    double? longitude,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final form = FormData.fromMap({
      'assetData': MultipartFile.fromBytes(bytes,
          filename: filename,
          contentType: assetDataContentType == null
              ? null
              : DioMediaType.parse(assetDataContentType)),
      'deviceAssetId': deviceAssetId ?? 'flutter-$filename',
      'deviceId': deviceId ?? 'flutter',
      'fileCreatedAt': fileCreatedAt.toUtc().toIso8601String(),
      'fileModifiedAt': fileModifiedAt.toUtc().toIso8601String(),
      'filename': filename,
      if (duration != null) 'duration': duration,
      if (isFavorite != null) 'isFavorite': isFavorite ? 'true' : 'false',
      if (isArchived != null) 'isArchived': isArchived ? 'true' : 'false',
      if (livePhotoVideoId != null) 'livePhotoVideoId': livePhotoVideoId,
      if (sidecarData != null)
        'sidecarData': MultipartFile.fromBytes(utf8.encode(sidecarData),
            filename: 'sidecar.xmp'),
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    });
    final res = await _request('POST', '/assets',
        data: form,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken);
    return AssetMediaResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<LoginResponseDto> login({
    LoginCredentialDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/login',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LoginResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LoginResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<LogoutResponseDto> logout() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/logout',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LogoutResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LogoutResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<ValidateAccessTokenResponseDto> validateAccessToken() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/validateToken',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ValidateAccessTokenResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ValidateAccessTokenResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<AuthStatusResponseDto> getAuthStatus() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/auth/status',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AuthStatusResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AuthStatusResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserAdminResponseDto> changePassword({
    ChangePasswordDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/change-password',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserAdminResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserAdminResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserAdminResponseDto> signUpAdmin({
    SignUpDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/admin-sign-up',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserAdminResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserAdminResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> setupPinCode({
    PinCodeSetupDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/pin-code',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> changePinCode({
    PinCodeChangeDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/auth/pin-code',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> resetPinCode({
    PinCodeResetDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/auth/pin-code',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> lockAuthSession() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/session/lock',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> unlockAuthSession({
    SessionUnlockDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/auth/session/unlock',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<OAuthAuthorizeResponseDto> startOAuth({
    OAuthConfigDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/oauth/authorize',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return OAuthAuthorizeResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return OAuthAuthorizeResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<LoginResponseDto> finishOAuth({
    OAuthCallbackDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/oauth/callback',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LoginResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LoginResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserAdminResponseDto> linkOAuthAccount({
    OAuthCallbackDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/oauth/link',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserAdminResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserAdminResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserAdminResponseDto> unlinkOAuthAccount() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/oauth/unlink',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserAdminResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserAdminResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> redirectOAuthToMobile() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/oauth/mobile-redirect',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<ServerPingResponse> pingServer() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/ping',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ServerPingResponse.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ServerPingResponse.fromJson((raw as Map<String, dynamic>?));
  }

  Future<ServerAboutResponseDto> getAboutInfo() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/about',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ServerAboutResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ServerAboutResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<ServerVersionResponseDto> getServerVersion() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/version',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ServerVersionResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ServerVersionResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<ServerMediaTypesResponseDto> getSupportedMediaTypes() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/media-types',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ServerMediaTypesResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ServerMediaTypesResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<ServerStatsResponseDto> getServerStatistics() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/statistics',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ServerStatsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ServerStatsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<ServerStorageResponseDto> getStorage() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/storage',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ServerStorageResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ServerStorageResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<LicenseResponseDto> getServerLicense() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/license',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LicenseResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LicenseResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<VersionCheckStateResponseDto> getVersionCheck() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/version-check',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return VersionCheckStateResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return VersionCheckStateResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<ServerVersionHistoryResponseDto>> getVersionHistory() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/server/version-history',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => ServerVersionHistoryResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => ServerVersionHistoryResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<ServerVersionHistoryResponseDto>;
  }

  Future<UserAdminResponseDto> getMyUser() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/users/me',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserAdminResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserAdminResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserPreferencesResponseDto> getMyPreferences() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/users/me/preferences',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserPreferencesResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserPreferencesResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserPreferencesResponseDto> updateMyPreferences({
    UserPreferencesUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/users/me/preferences',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserPreferencesResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserPreferencesResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<CalendarHeatmapResponseDto> getMyCalendarHeatmap({
    String? from_,
    String? to,
    CalendarHeatmapType? type,
  }) async {
    final query = <String, dynamic>{
      if (from_ != null) 'from': from_,
      if (to != null) 'to': to,
      if (type != null) 'type': type.value,
    };
    final res = await _request(
      "GET",
      '/users/me/calendar-heatmap',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return CalendarHeatmapResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return CalendarHeatmapResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserResponseDto> getUser({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/users/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<UserResponseDto>> searchUsers() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/users',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => UserResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => UserResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<UserResponseDto>;
  }

  Future<void> deleteProfileImage() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/users/profile-image',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> getProfileImage({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/users/${id}/profile-image',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<UserConfigDto> getUserConfig() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/config',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserConfigDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserConfigDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<UserConfigDto> getUserConfigDefaults() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/config/defaults',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return UserConfigDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return UserConfigDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<OnboardingResponseDto> getUserOnboarding() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/users/me/onboarding',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return OnboardingResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return OnboardingResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<OnboardingResponseDto> setUserOnboarding({
    OnboardingDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/users/me/onboarding',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return OnboardingResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return OnboardingResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteUserLicense() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/users/me/license',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<LicenseResponseDto> setUserLicense({
    LicenseKeyDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/users/me/license',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LicenseResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LicenseResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<SessionResponseDto>> getSessions() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/sessions',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => SessionResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => SessionResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<SessionResponseDto>;
  }

  Future<void> deleteSession({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/sessions/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> deleteAllSessions() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/sessions',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<SessionCreateResponseDto> createSession({
    SessionCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/sessions',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return SessionCreateResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return SessionCreateResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<ApiKeyResponseDto>> getApiKeys() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/api-keys',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => ApiKeyResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => ApiKeyResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<ApiKeyResponseDto>;
  }

  Future<ApiKeyCreateResponseDto> createApiKey({
    ApiKeyCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/api-keys',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ApiKeyCreateResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ApiKeyCreateResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<ApiKeyResponseDto> updateApiKey({
    required String id,
    ApiKeyUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/api-keys/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ApiKeyResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ApiKeyResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteApiKey({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/api-keys/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<AssetBulkUploadCheckResponseDto> checkBulkUpload({
    AssetBulkUploadCheckDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/assets/bulk-upload-check',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetBulkUploadCheckResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetBulkUploadCheckResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<AssetResponseDto> getAssetInfo({
    required String id,
    String? key,
    String? slug,
  }) async {
    final query = <String, dynamic>{
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "GET",
      '/assets/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<AssetResponseDto> updateAsset({
    required String id,
    UpdateAssetDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/assets/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteAssets({
    AssetBulkDeleteDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/assets',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<AssetStatsResponseDto> getAssetStatistics({
    bool? isFavorite,
    bool? isTrashed,
    AssetVisibility? visibility,
  }) async {
    final query = <String, dynamic>{
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isTrashed != null) 'isTrashed': isTrashed,
      if (visibility != null) 'visibility': visibility.value,
    };
    final res = await _request(
      "GET",
      '/assets/statistics',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetStatsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetStatsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> runAssetJobs({
    AssetJobsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/assets/jobs',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> downloadAsset({
    required String id,
    bool? edited,
    String? key,
    String? slug,
  }) async {
    final query = <String, dynamic>{
      if (edited != null) 'edited': edited,
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "GET",
      '/assets/${id}/original',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> viewAsset({
    required String id,
    bool? edited,
    String? key,
    AssetMediaSize? size,
    String? slug,
  }) async {
    final query = <String, dynamic>{
      if (edited != null) 'edited': edited,
      if (key != null) 'key': key,
      if (size != null) 'size': size.value,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "GET",
      '/assets/${id}/thumbnail',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> playAssetVideo({
    required String id,
    String? key,
    String? slug,
  }) async {
    final query = <String, dynamic>{
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "GET",
      '/assets/${id}/video/playback',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<AssetMetadataResponseDto>> getAssetMetadata({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/assets/${id}/metadata',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetMetadataResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetMetadataResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetMetadataResponseDto>;
  }

  Future<List<AssetOcrResponseDto>> getAssetOcr({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/assets/${id}/ocr',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetOcrResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetOcrResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetOcrResponseDto>;
  }

  Future<AssetEditsResponseDto> editAsset({
    required String id,
    AssetEditsCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/assets/${id}/edits',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetEditsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetEditsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<AssetEditsResponseDto> getAssetEdits({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/assets/${id}/edits',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetEditsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetEditsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> removeAssetEdits({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/assets/${id}/edits',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> copyAsset({
    AssetCopyDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/assets/copy',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<AssetMetadataBulkResponseDto>> updateBulkAssetMetadata({
    AssetMetadataBulkUpsertDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/assets/metadata',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetMetadataBulkResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetMetadataBulkResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetMetadataBulkResponseDto>;
  }

  Future<AssetMetadataResponseDto> getAssetMetadataByKey({
    required String id,
    required String key,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/assets/${id}/metadata/${key}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetMetadataResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetMetadataResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteAssetMetadata({
    required String id,
    required String key,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/assets/${id}/metadata/${key}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> updateAssets({
    AssetBulkUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/assets',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<TimeBucketsResponseDto>> getTimeBuckets({
    String? albumId,
    String? bbox,
    bool? isFavorite,
    bool? isTrashed,
    String? key,
    AssetOrder? order,
    AssetOrderBy? orderBy,
    String? personId,
    String? slug,
    String? tagId,
    String? userId,
    AssetVisibility? visibility,
    bool? withCoordinates,
    bool? withPartners,
    bool? withStacked,
  }) async {
    final query = <String, dynamic>{
      if (albumId != null) 'albumId': albumId,
      if (bbox != null) 'bbox': bbox,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isTrashed != null) 'isTrashed': isTrashed,
      if (key != null) 'key': key,
      if (order != null) 'order': order.value,
      if (orderBy != null) 'orderBy': orderBy.value,
      if (personId != null) 'personId': personId,
      if (slug != null) 'slug': slug,
      if (tagId != null) 'tagId': tagId,
      if (userId != null) 'userId': userId,
      if (visibility != null) 'visibility': visibility.value,
      if (withCoordinates != null) 'withCoordinates': withCoordinates,
      if (withPartners != null) 'withPartners': withPartners,
      if (withStacked != null) 'withStacked': withStacked,
    };
    final res = await _request(
      "GET",
      '/timeline/buckets',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => TimeBucketsResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => TimeBucketsResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<TimeBucketsResponseDto>;
  }

  Future<TimeBucketAssetResponseDto> getTimeBucket({
    String? albumId,
    String? bbox,
    bool? isFavorite,
    bool? isTrashed,
    String? key,
    AssetOrder? order,
    AssetOrderBy? orderBy,
    String? personId,
    String? slug,
    String? tagId,
    String? timeBucket,
    String? userId,
    AssetVisibility? visibility,
    bool? withCoordinates,
    bool? withPartners,
    bool? withStacked,
  }) async {
    final query = <String, dynamic>{
      if (albumId != null) 'albumId': albumId,
      if (bbox != null) 'bbox': bbox,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isTrashed != null) 'isTrashed': isTrashed,
      if (key != null) 'key': key,
      if (order != null) 'order': order.value,
      if (orderBy != null) 'orderBy': orderBy.value,
      if (personId != null) 'personId': personId,
      if (slug != null) 'slug': slug,
      if (tagId != null) 'tagId': tagId,
      if (timeBucket != null) 'timeBucket': timeBucket,
      if (userId != null) 'userId': userId,
      if (visibility != null) 'visibility': visibility.value,
      if (withCoordinates != null) 'withCoordinates': withCoordinates,
      if (withPartners != null) 'withPartners': withPartners,
      if (withStacked != null) 'withStacked': withStacked,
    };
    final res = await _request(
      "GET",
      '/timeline/bucket',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return TimeBucketAssetResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return TimeBucketAssetResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<SearchResponseDto> searchAssets({
    String? key,
    String? slug,
    MetadataSearchDto? body,
  }) async {
    final query = <String, dynamic>{
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "POST",
      '/search/metadata',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return SearchResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return SearchResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<SearchResponseDto> searchSmart({
    SmartSearchDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/search/smart',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return SearchResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return SearchResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<AssetResponseDto>> searchRandom({
    RandomSearchDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/search/random',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetResponseDto>;
  }

  Future<List<String>> getSearchSuggestions({
    String? country,
    bool? includeNull,
    String? lensModel,
    String? make,
    String? model,
    String? state,
    SearchSuggestionType? type,
  }) async {
    final query = <String, dynamic>{
      if (country != null) 'country': country,
      if (includeNull != null) 'includeNull': includeNull,
      if (lensModel != null) 'lensModel': lensModel,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (state != null) 'state': state,
      if (type != null) 'type': type.value,
    };
    final res = await _request(
      "GET",
      '/search/suggestions',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.where((e) => e != null).map((e) => e.toString()).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.where((e) => e != null).map((e) => e.toString()).toList();
    }
    return <Never>[] as List<String>;
  }

  Future<List<SearchExploreResponseDto>> getExploreData() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/search/explore',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => SearchExploreResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => SearchExploreResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<SearchExploreResponseDto>;
  }

  Future<List<PersonResponseDto>> searchPerson({
    String? name,
    bool? withHidden,
  }) async {
    final query = <String, dynamic>{
      if (name != null) 'name': name,
      if (withHidden != null) 'withHidden': withHidden,
    };
    final res = await _request(
      "GET",
      '/search/person',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => PersonResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => PersonResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<PersonResponseDto>;
  }

  Future<List<PlacesResponseDto>> searchPlaces({
    String? name,
  }) async {
    final query = <String, dynamic>{
      if (name != null) 'name': name,
    };
    final res = await _request(
      "GET",
      '/search/places',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => PlacesResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => PlacesResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<PlacesResponseDto>;
  }

  Future<List<AssetResponseDto>> getAssetsByCity() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/search/cities',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetResponseDto>;
  }

  Future<SearchStatisticsResponseDto> searchAssetStatistics({
    StatisticsSearchDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/search/statistics',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return SearchStatisticsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return SearchStatisticsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<AlbumResponseDto>> getAllAlbums({
    String? assetId,
    String? id,
    bool? isOwned,
    bool? isShared,
    String? name,
  }) async {
    final query = <String, dynamic>{
      if (assetId != null) 'assetId': assetId,
      if (id != null) 'id': id,
      if (isOwned != null) 'isOwned': isOwned,
      if (isShared != null) 'isShared': isShared,
      if (name != null) 'name': name,
    };
    final res = await _request(
      "GET",
      '/albums',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AlbumResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AlbumResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AlbumResponseDto>;
  }

  Future<AlbumResponseDto> createAlbum({
    CreateAlbumDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/albums',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AlbumResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AlbumResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<AlbumResponseDto> getAlbumInfo({
    required String id,
    String? key,
    String? slug,
  }) async {
    final query = <String, dynamic>{
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "GET",
      '/albums/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AlbumResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AlbumResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<AlbumResponseDto> updateAlbumInfo({
    required String id,
    UpdateAlbumDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PATCH",
      '/albums/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AlbumResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AlbumResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteAlbum({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/albums/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<BulkIdResponseDto>> addAssetsToAlbum({
    required String id,
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/albums/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<List<BulkIdResponseDto>> removeAssetFromAlbum({
    required String id,
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/albums/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<AlbumResponseDto> addUsersToAlbum({
    required String id,
    AddUsersDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/albums/${id}/users',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AlbumResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AlbumResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> removeUserFromAlbum({
    required String id,
    required String userId,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/albums/${id}/user/${userId}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> updateAlbumUser({
    required String id,
    required String userId,
    UpdateAlbumUserDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/albums/${id}/user/${userId}',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<AlbumStatisticsResponseDto> getAlbumStatistics() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/albums/statistics',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AlbumStatisticsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AlbumStatisticsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<MapMarkerResponseDto>> getAlbumMapMarkers({
    required String id,
    String? key,
    String? slug,
  }) async {
    final query = <String, dynamic>{
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "GET",
      '/albums/${id}/map-markers',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => MapMarkerResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => MapMarkerResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<MapMarkerResponseDto>;
  }

  Future<AlbumsAddAssetsResponseDto> addAssetsToAlbums({
    AlbumsAddAssetsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/albums/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AlbumsAddAssetsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AlbumsAddAssetsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<PeopleResponseDto> getAllPeople({
    String? closestAssetId,
    String? closestPersonId,
    int? page,
    int? size,
    bool? withHidden,
  }) async {
    final query = <String, dynamic>{
      if (closestAssetId != null) 'closestAssetId': closestAssetId,
      if (closestPersonId != null) 'closestPersonId': closestPersonId,
      if (page != null) 'page': page,
      if (size != null) 'size': size,
      if (withHidden != null) 'withHidden': withHidden,
    };
    final res = await _request(
      "GET",
      '/people',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PeopleResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PeopleResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<PersonResponseDto> createPerson({
    PersonCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/people',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PersonResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PersonResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<PersonResponseDto> updatePerson({
    required String id,
    PersonUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/people/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PersonResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PersonResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<BulkIdResponseDto>> updatePeople({
    PeopleUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/people',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<void> deletePerson({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/people/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> deletePeople({
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/people',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<PersonResponseDto> getPerson({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/people/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PersonResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PersonResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> getPersonThumbnail({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/people/${id}/thumbnail',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<PersonStatisticsResponseDto> getPersonStatistics({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/people/${id}/statistics',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PersonStatisticsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PersonStatisticsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<BulkIdResponseDto>> mergePeople({
    MergePersonDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/people/merge',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<List<PersonResponseDto>> reassignFaces({
    required String id,
    AssetFaceUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/people/${id}/reassign',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => PersonResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => PersonResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<PersonResponseDto>;
  }

  Future<PersonResponseDto> reassignFacesById({
    required String id,
    FaceDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/faces/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PersonResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PersonResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<AssetFaceResponseDto>> getFaces({
    String? id,
  }) async {
    final query = <String, dynamic>{
      if (id != null) 'id': id,
    };
    final res = await _request(
      "GET",
      '/faces',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetFaceResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetFaceResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetFaceResponseDto>;
  }

  Future<void> createFace({
    AssetFaceCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/faces',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> deleteFace({
    required String id,
    AssetFaceDeleteDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/faces/${id}',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<PartnerResponseDto>> getPartners({
    PartnerDirection? direction,
  }) async {
    final query = <String, dynamic>{
      if (direction != null) 'direction': direction.value,
    };
    final res = await _request(
      "GET",
      '/partners',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => PartnerResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => PartnerResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<PartnerResponseDto>;
  }

  Future<PartnerResponseDto> createPartner({
    PartnerCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/partners',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PartnerResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PartnerResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<PartnerResponseDto> updatePartner({
    required String id,
    PartnerUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/partners/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return PartnerResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return PartnerResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> removePartner({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/partners/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<MemoryResponseDto>> searchMemories({
    String? for_,
    String? id,
    bool? isSaved,
    bool? isTrashed,
    bool? isUpcoming,
    MemorySearchOrder? order,
    int? page,
    int? size,
    MemoryType? type,
  }) async {
    final query = <String, dynamic>{
      if (for_ != null) 'for': for_,
      if (id != null) 'id': id,
      if (isSaved != null) 'isSaved': isSaved,
      if (isTrashed != null) 'isTrashed': isTrashed,
      if (isUpcoming != null) 'isUpcoming': isUpcoming,
      if (order != null) 'order': order.value,
      if (page != null) 'page': page,
      if (size != null) 'size': size,
      if (type != null) 'type': type.value,
    };
    final res = await _request(
      "GET",
      '/memories',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => MemoryResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => MemoryResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<MemoryResponseDto>;
  }

  Future<MemoryResponseDto> createMemory({
    MemoryCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/memories',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return MemoryResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return MemoryResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<MemoryResponseDto> getMemory({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/memories/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return MemoryResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return MemoryResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<MemoryResponseDto> updateMemory({
    required String id,
    MemoryUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/memories/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return MemoryResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return MemoryResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteMemory({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/memories/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<BulkIdResponseDto>> addMemoryAssets({
    required String id,
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/memories/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<List<BulkIdResponseDto>> removeMemoryAssets({
    required String id,
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/memories/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<MemoryStatisticsResponseDto> memoriesStatistics({
    String? for_,
    String? id,
    bool? isSaved,
    bool? isTrashed,
    bool? isUpcoming,
    MemorySearchOrder? order,
    int? page,
    int? size,
    MemoryType? type,
  }) async {
    final query = <String, dynamic>{
      if (for_ != null) 'for': for_,
      if (id != null) 'id': id,
      if (isSaved != null) 'isSaved': isSaved,
      if (isTrashed != null) 'isTrashed': isTrashed,
      if (isUpcoming != null) 'isUpcoming': isUpcoming,
      if (order != null) 'order': order.value,
      if (page != null) 'page': page,
      if (size != null) 'size': size,
      if (type != null) 'type': type.value,
    };
    final res = await _request(
      "GET",
      '/memories/statistics',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return MemoryStatisticsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return MemoryStatisticsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<TrashResponseDto> restoreAssets({
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/trash/restore/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return TrashResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return TrashResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<TrashResponseDto> restoreTrash() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/trash/restore',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return TrashResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return TrashResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<TrashResponseDto> emptyTrash() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/trash/empty',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return TrashResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return TrashResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<SharedLinkResponseDto> createSharedLink({
    SharedLinkCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/shared-links',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return SharedLinkResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return SharedLinkResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<SharedLinkResponseDto>> getAllSharedLinks({
    String? albumId,
    String? id,
  }) async {
    final query = <String, dynamic>{
      if (albumId != null) 'albumId': albumId,
      if (id != null) 'id': id,
    };
    final res = await _request(
      "GET",
      '/shared-links',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => SharedLinkResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => SharedLinkResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<SharedLinkResponseDto>;
  }

  Future<SharedLinkResponseDto> getSharedLinkById({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/shared-links/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return SharedLinkResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return SharedLinkResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<SharedLinkResponseDto> updateSharedLink({
    required String id,
    SharedLinkEditDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PATCH",
      '/shared-links/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return SharedLinkResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return SharedLinkResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> removeSharedLink({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/shared-links/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<AssetIdsResponseDto>> addSharedLinkAssets({
    required String id,
    AssetIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/shared-links/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetIdsResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetIdsResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetIdsResponseDto>;
  }

  Future<List<AssetIdsResponseDto>> removeSharedLinkAssets({
    required String id,
    AssetIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/shared-links/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetIdsResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetIdsResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetIdsResponseDto>;
  }

  Future<List<ActivityResponseDto>> getActivities({
    String? albumId,
    String? assetId,
    ReactionLevel? level,
    ReactionType? type,
    String? userId,
  }) async {
    final query = <String, dynamic>{
      if (albumId != null) 'albumId': albumId,
      if (assetId != null) 'assetId': assetId,
      if (level != null) 'level': level.value,
      if (type != null) 'type': type.value,
      if (userId != null) 'userId': userId,
    };
    final res = await _request(
      "GET",
      '/activities',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => ActivityResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => ActivityResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<ActivityResponseDto>;
  }

  Future<ActivityResponseDto> createActivity({
    ActivityCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/activities',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ActivityResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ActivityResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteActivity({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/activities/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<ActivityStatisticsResponseDto> getActivityStatistics({
    String? albumId,
    String? assetId,
  }) async {
    final query = <String, dynamic>{
      if (albumId != null) 'albumId': albumId,
      if (assetId != null) 'assetId': assetId,
    };
    final res = await _request(
      "GET",
      '/activities/statistics',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return ActivityStatisticsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return ActivityStatisticsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<MapMarkerResponseDto>> getMapMarkers({
    String? fileCreatedAfter,
    String? fileCreatedBefore,
    bool? isArchived,
    bool? isFavorite,
    bool? withPartners,
    bool? withSharedAlbums,
  }) async {
    final query = <String, dynamic>{
      if (fileCreatedAfter != null) 'fileCreatedAfter': fileCreatedAfter,
      if (fileCreatedBefore != null) 'fileCreatedBefore': fileCreatedBefore,
      if (isArchived != null) 'isArchived': isArchived,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (withPartners != null) 'withPartners': withPartners,
      if (withSharedAlbums != null) 'withSharedAlbums': withSharedAlbums,
    };
    final res = await _request(
      "GET",
      '/map/markers',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => MapMarkerResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => MapMarkerResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<MapMarkerResponseDto>;
  }

  Future<List<MapReverseGeocodeResponseDto>> reverseGeocode({
    double? lat,
    double? lon,
  }) async {
    final query = <String, dynamic>{
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
    final res = await _request(
      "GET",
      '/map/reverse-geocode',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => MapReverseGeocodeResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => MapReverseGeocodeResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<MapReverseGeocodeResponseDto>;
  }

  Future<List<TagResponseDto>> getAllTags() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/tags',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => TagResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => TagResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<TagResponseDto>;
  }

  Future<TagResponseDto> createTag({
    TagCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/tags',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return TagResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return TagResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<TagResponseDto> getTagById({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/tags/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return TagResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return TagResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteTag({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/tags/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<BulkIdResponseDto>> tagAssets({
    required String id,
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/tags/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<List<BulkIdResponseDto>> untagAssets({
    required String id,
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/tags/${id}/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<List<TagResponseDto>> upsertTags({
    TagUpsertDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/tags',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => TagResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => TagResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<TagResponseDto>;
  }

  Future<TagBulkAssetsResponseDto> bulkTagAssets({
    TagBulkAssetsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/tags/assets',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return TagBulkAssetsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return TagBulkAssetsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<List<StackResponseDto>> searchStacks({
    String? primaryAssetId,
  }) async {
    final query = <String, dynamic>{
      if (primaryAssetId != null) 'primaryAssetId': primaryAssetId,
    };
    final res = await _request(
      "GET",
      '/stacks',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => StackResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => StackResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<StackResponseDto>;
  }

  Future<StackResponseDto> createStack({
    StackCreateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/stacks',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return StackResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return StackResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<StackResponseDto> getStack({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/stacks/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return StackResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return StackResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteStack({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/stacks/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> deleteStacks({
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/stacks',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> removeAssetFromStack({
    required String assetId,
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/stacks/${id}/assets/${assetId}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<DuplicateResponseDto>> getAssetDuplicates() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/duplicates',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => DuplicateResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => DuplicateResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<DuplicateResponseDto>;
  }

  Future<void> deleteDuplicate({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/duplicates/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> deleteDuplicates({
    BulkIdsDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/duplicates',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<BulkIdResponseDto>> resolveDuplicates({
    DuplicateResolveDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/duplicates/resolve',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => BulkIdResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<BulkIdResponseDto>;
  }

  Future<List<LibraryResponseDto>> getAllLibraries() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/libraries',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => LibraryResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => LibraryResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<LibraryResponseDto>;
  }

  Future<LibraryResponseDto> getLibrary({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/libraries/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LibraryResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LibraryResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<LibraryStatsResponseDto> getLibraryStatistics({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/libraries/${id}/statistics',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LibraryStatsResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LibraryStatsResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> scanLibrary({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/libraries/${id}/scan',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<LibraryResponseDto> createLibrary({
    CreateLibraryDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/libraries',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return LibraryResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return LibraryResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> downloadArchive({
    String? key,
    String? slug,
    DownloadArchiveDto? body,
  }) async {
    final query = <String, dynamic>{
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "POST",
      '/download/archive',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<DownloadResponseDto> getDownloadInfo({
    String? key,
    String? slug,
    DownloadInfoDto? body,
  }) async {
    final query = <String, dynamic>{
      if (key != null) 'key': key,
      if (slug != null) 'slug': slug,
    };
    final res = await _request(
      "POST",
      '/download/info',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return DownloadResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return DownloadResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> getSyncStream({
    SyncStreamDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/sync/stream',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> sendSyncAck({
    SyncAckSetDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "POST",
      '/sync/ack',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<SyncAckDto>> getSyncAck() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/sync/ack',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => SyncAckDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => SyncAckDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<SyncAckDto>;
  }

  Future<void> deleteSyncAck({
    SyncAckDeleteDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/sync/ack',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<AssetFileResponseDto>> searchAssetFiles({
    String? assetId,
    bool? isEdited,
    bool? isProgressive,
    bool? isTransparent,
    AssetFileType? type,
  }) async {
    final query = <String, dynamic>{
      if (assetId != null) 'assetId': assetId,
      if (isEdited != null) 'isEdited': isEdited,
      if (isProgressive != null) 'isProgressive': isProgressive,
      if (isTransparent != null) 'isTransparent': isTransparent,
      if (type != null) 'type': type.value,
    };
    final res = await _request(
      "GET",
      '/asset-files',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetFileResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetFileResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetFileResponseDto>;
  }

  Future<AssetFileResponseDto> getAssetFile({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/asset-files/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return AssetFileResponseDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return AssetFileResponseDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> downloadAssetFile({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/asset-files/${id}/download',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<NotificationDto>> getNotifications({
    String? id,
    NotificationLevel? level,
    NotificationType? type,
    bool? unread,
  }) async {
    final query = <String, dynamic>{
      if (id != null) 'id': id,
      if (level != null) 'level': level.value,
      if (type != null) 'type': type.value,
      if (unread != null) 'unread': unread,
    };
    final res = await _request(
      "GET",
      '/notifications',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => NotificationDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => NotificationDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<NotificationDto>;
  }

  Future<NotificationDto> getNotification({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/notifications/${id}',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List<int>) {
      return NotificationDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return NotificationDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<NotificationDto> updateNotification({
    required String id,
    NotificationUpdateDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/notifications/${id}',
      queryParameters: query,
      data: body?.toJson(),
    );
    final raw = res.data;
    if (raw is List<int>) {
      return NotificationDto.fromJson(jsonDecode(utf8.decode(raw)) as Map<String, dynamic>);
    }
    return NotificationDto.fromJson((raw as Map<String, dynamic>?));
  }

  Future<void> deleteNotification({
    required String id,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/notifications/${id}',
      queryParameters: query,
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> updateNotifications({
    NotificationUpdateAllDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "PUT",
      '/notifications',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<void> deleteNotifications({
    NotificationDeleteAllDto? body,
  }) async {
    const query = <String, dynamic>{};
    final res = await _request(
      "DELETE",
      '/notifications',
      queryParameters: query,
      data: body?.toJson(),
      responseType: ResponseType.plain,
    );
    return;
  }

  Future<List<String>> getUniqueOriginalPaths() async {
    const query = <String, dynamic>{};
    final res = await _request(
      "GET",
      '/view/folder/unique-paths',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.where((e) => e != null).map((e) => e.toString()).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.where((e) => e != null).map((e) => e.toString()).toList();
    }
    return <Never>[] as List<String>;
  }

  Future<List<AssetResponseDto>> getAssetsByOriginalPath({
    String? path,
  }) async {
    final query = <String, dynamic>{
      if (path != null) 'path': path,
    };
    final res = await _request(
      "GET",
      '/view/folder',
      queryParameters: query,
    );
    final raw = res.data;
    if (raw is List) {
      return raw.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      return items.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).toList();
    }
    return <Never>[] as List<AssetResponseDto>;
  }

}