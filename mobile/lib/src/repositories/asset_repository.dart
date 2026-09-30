import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../api/generated/client.dart';
import '../api/generated/models.dart';

/// A single asset as the timeline renders it, coming straight from the
/// `/timeline/bucket` parallel-array response.
class TimelineAsset {
  TimelineAsset({
    required this.id,
    required this.createdAt,
    required this.isImage,
    this.isFavorite = false,
    this.isTrashed = false,
    this.ownerId,
    this.duration,
    this.fileCreatedAt,
    this.localOffsetHours,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.livePhotoVideoId,
    this.projectionType,
    this.ratio,
    this.thumbhash,
    this.visibility,
    this.stack,
    this.remote,
  });

  final String id;
  final DateTime createdAt;
  final bool isImage;
  final bool isFavorite;
  final bool isTrashed;
  final String? ownerId;
  final String? duration;
  final DateTime? fileCreatedAt;
  final int? localOffsetHours;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? livePhotoVideoId;
  final String? projectionType;
  final double? ratio;
  final String? thumbhash;
  final String? visibility;

  /// Number of stacked siblings, when the asset is part of a stack.
  final int? stack;

  /// The richer `/assets/{id}` payload, once loaded.
  AssetResponseDto? remote;

  bool get isVideo => !isImage;

  /// Merges the fuller asset payload into the lighter timeline record.
  void merge(AssetResponseDto dto) {
    remote = dto;
  }

  static TimelineAsset fromBucket(Map<String, dynamic> j, List<dynamic> row) {
    return TimelineAsset(
      id: j['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isImage: j['isImage'] == true,
      isFavorite: j['isFavorite'] == true,
      isTrashed: j['isTrashed'] == true,
      ownerId: j['ownerId']?.toString(),
      duration: j['duration']?.toString(),
    );
  }
}

/// Serves the home timeline: bucket listing, then per-bucket assets.
class TimelineRepository {
  TimelineRepository(this._client);

  final ImmichApiClient _client;

  /// Bucket listing, newest first. `visibility` selects timeline vs archive.
  Future<List<TimeBucketsResponseDto>> buckets({
    AssetVisibility? visibility,
    bool? isFavorite,
    bool? isTrashed,
    String? albumId,
    String? personId,
    bool? withStacked,
    bool? withPartners,
    String? userId,
    String? tagId,
    bool? withCoordinates,
    String? bbox,
    AssetOrder order = AssetOrder.desc,
    AssetOrderBy orderBy = AssetOrderBy.takenAt,
  }) =>
      _client.getTimeBuckets(
        visibility: visibility,
        isFavorite: isFavorite,
        isTrashed: isTrashed,
        albumId: albumId,
        personId: personId,
        withStacked: withStacked,
        withPartners: withPartners,
        userId: userId,
        tagId: tagId,
        withCoordinates: withCoordinates,
        bbox: bbox,
        order: order,
        orderBy: orderBy,
      );

  /// Assets inside one bucket.
  Future<TimeBucketAssetResponseDto> bucket({
    required DateTime timeBucket,
    AssetVisibility? visibility,
    bool? isFavorite,
    bool? isTrashed,
    String? albumId,
    String? personId,
    String? userId,
    String? tagId,
    bool? withPartners,
    bool? withStacked,
    bool? withCoordinates,
    String? bbox,
    AssetOrder order = AssetOrder.desc,
    AssetOrderBy orderBy = AssetOrderBy.takenAt,
  }) =>
      _client.getTimeBucket(
        timeBucket: timeBucket.toUtc().toIso8601String(),
        visibility: visibility,
        isFavorite: isFavorite,
        isTrashed: isTrashed,
        albumId: albumId,
        personId: personId,
        userId: userId,
        tagId: tagId,
        withPartners: withPartners,
        withStacked: withStacked,
        withCoordinates: withCoordinates,
        bbox: bbox,
        order: order,
        orderBy: orderBy,
      );
}

/// Repository for asset details and bulk mutations.
class AssetRepository {
  AssetRepository(this._client);

  final ImmichApiClient _client;

  Future<AssetResponseDto> get(String id) => _client.getAssetInfo(id: id);

  Future<AssetResponseDto> update(
    String id,
    UpdateAssetDto body,
  ) =>
      _client.updateAsset(id: id, body: body);

  Future<void> delete(List<String> ids, {bool force = false}) =>
      _client.deleteAssets(body: AssetBulkDeleteDto(ids: ids, force: force));

  Future<TrashResponseDto> restore(List<String> ids) =>
      _client.restoreAssets(body: BulkIdsDto(ids: ids));

  Future<TrashResponseDto> emptyTrash() => _client.emptyTrash();

  Future<void> favorite(List<String> ids, bool value) => _client
      .updateAssets(body: AssetBulkUpdateDto(ids: ids, isFavorite: value))
      .catchError((_) {});

  Future<void> archive(List<String> ids, bool value) => _client
      .updateAssets(
        body: AssetBulkUpdateDto(
          ids: ids,
          visibility:
              value ? AssetVisibility.archive : AssetVisibility.timeline,
        ),
      )
      .catchError((_) {});

  Future<void> setDescription(List<String> ids, String? description) => _client
      .updateAssets(
          body: AssetBulkUpdateDto(ids: ids, description: description))
      .catchError((_) {});

  Future<void> setRating(List<String> ids, int? rating) => _client
      .updateAssets(body: AssetBulkUpdateDto(ids: ids, rating: rating))
      .catchError((_) {});

  Future<void> setLocation(
    List<String> ids, {
    required double latitude,
    required double longitude,
  }) =>
      _client
          .updateAssets(
            body: AssetBulkUpdateDto(
              ids: ids,
              latitude: latitude,
              longitude: longitude,
            ),
          )
          .catchError((_) {});

  Future<void> setDateTime(
    List<String> ids, {
    DateTime? dateTimeOriginal,
    String? timeZone,
  }) =>
      _client
          .updateAssets(
            body: AssetBulkUpdateDto(
              ids: ids,
              dateTimeOriginal: dateTimeOriginal?.toIso8601String(),
              timeZone: timeZone,
            ),
          )
          .catchError((_) {});

  Future<void> tag(String tagId, List<String> ids) =>
      _client.tagAssets(id: tagId, body: BulkIdsDto(ids: ids));

  Future<void> untag(String tagId, List<String> ids) =>
      _client.untagAssets(id: tagId, body: BulkIdsDto(ids: ids));

  Future<AssetStatsResponseDto> statistics({
    bool? isArchived,
    bool? isFavorite,
    bool? isTrashed,
  }) =>
      _client.getAssetStatistics(
        visibility: isArchived == true ? AssetVisibility.archive : null,
        isFavorite: isFavorite,
        isTrashed: isTrashed,
      );

  Future<List<DuplicateResponseDto>> duplicates([String? id]) =>
      _client.getAssetDuplicates();

  Future<Uint8List> thumbnail(
    String id, {
    String size = 'thumbnail',
  }) =>
      _client.getBytes(
        '/assets/$id/thumbnail',
        queryParameters: {'size': size},
      );

  Future<Uint8List> original(String id) =>
      _client.getBytes('/assets/$id/original');

  /// HLS playlist for video playback.
  String videoPlaylist(String id) =>
      '${_client.baseUrl}/assets/$id/video/stream/main.m3u8';

  String videoPlaybackUrl(String id) =>
      '${_client.baseUrl}/assets/$id/video/playback';

  String thumbnailUrl(String id, {String size = 'thumbnail'}) =>
      '${_client.baseUrl}/assets/$id/thumbnail?size=$size';

  String originalUrl(String id) => '${_client.baseUrl}/assets/$id/original';
}

/// The bucket endpoint returns *parallel arrays* rather than objects, so the
/// row at index `i` is built by reading `i` from every array.
List<TimelineAsset> flattenBucket(TimeBucketAssetResponseDto bucket) {
  final ids = bucket.id;
  if (ids == null) return [];
  final out = <TimelineAsset>[];
  for (var i = 0; i < ids.length; i++) {
    out.add(
      TimelineAsset(
        id: ids[i],
        createdAt: _date(bucket.fileCreatedAt, i) ??
            _date(bucket.createdAt, i) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        isImage: _flag(bucket.isImage, i, fallback: true),
        isFavorite: _flag(bucket.isFavorite, i),
        isTrashed: _flag(bucket.isTrashed, i),
        ownerId: _str(bucket.ownerId, i),
        duration: _dur(bucket.duration, i),
        localOffsetHours: _num(bucket.localOffsetHours, i)?.round(),
        latitude: _num(bucket.latitude, i),
        longitude: _num(bucket.longitude, i),
        city: _str(bucket.city, i),
        country: _str(bucket.country, i),
        livePhotoVideoId: _str(bucket.livePhotoVideoId, i),
        projectionType: _str(bucket.projectionType, i),
        ratio: _num(bucket.ratio, i),
        thumbhash: _str(bucket.thumbhash, i),
        visibility: _visibility(bucket.visibility, i),
        stack: _stackCount(bucket.stack, i),
      ),
    );
  }
  return out.sortedByCompare<DateTime>(
    (a) => a.createdAt,
    (a, b) => b.compareTo(a),
  );
}

DateTime? _date(List<String>? list, int i) {
  final v = _str(list, i);
  return v == null ? null : DateTime.tryParse(v);
}

String? _str(List<String>? list, int i) =>
    (list != null && i < list.length && list[i].isNotEmpty) ? list[i] : null;

double? _num(List<double>? list, int i) =>
    (list != null && i < list.length) ? list[i] : null;

String? _dur(List<int>? list, int i) =>
    (list != null && i < list.length) ? list[i].toString() : null;

bool _flag(List<bool>? list, int i, {bool fallback = false}) =>
    (list != null && i < list.length) ? list[i] : fallback;

String? _visibility(List<AssetVisibility>? list, int i) {
  if (list == null || i >= list.length) return null;
  return list[i].value;
}

int? _stackCount(List<List<String>>? list, int i) =>
    (list != null && i < list.length) ? list[i].length : null;
