import 'dart:convert';
import 'dart:typed_data';

import '../api/generated/client.dart';
import '../api/generated/models.dart';

/// One search result row, normalised across metadata / smart search.
class SearchHit {
  SearchHit({
    required this.id,
    required this.isImage,
    this.remote,
    this.score,
  });

  final String id;
  final bool isImage;

  /// Present for smart (CLIP) search; null for metadata search.
  final double? score;
  final AssetResponseDto? remote;

  factory SearchHit.fromAsset(AssetResponseDto a, {double? score}) => SearchHit(
        id: a.id ?? '',
        isImage: a.type == AssetTypeEnum.iMAGE,
        remote: a,
        score: score,
      );
}

/// The search surface: smart (CLIP) search for natural language, metadata
/// search for exact filters. The official app switches between the two
/// automatically based on whether a free-text query is present.
class SearchRepository {
  SearchRepository(this._client);

  final ImmichApiClient _client;

  /// Smart / semantic search. Page size follows the official app (100).
  Future<List<SearchHit>> smart({
    String? query,
    String? language,
    String? ocr,
    List<String>? personIds,
    List<String>? tagIds,
    List<String>? albumIds,
    String? city,
    String? country,
    String? make,
    String? model,
    String? lensModel,
    String? libraryId,
    String? createdAfter,
    String? createdBefore,
    bool? isFavorite,
    bool? isMotion,
    bool? isNotInAlbum,
    bool? isEncoded,
    bool? isOffline,
    SearchFilter? filter,
    int page = 1,
    int size = 100,
  }) async {
    final res = await _client.searchSmart(
      body: SmartSearchDto(
        query: query,
        language: language,
        personIds: personIds,
        tagIds: tagIds,
        albumIds: albumIds,
        city: city,
        country: country,
        make: make,
        model: model,
        lensModel: lensModel,
        libraryId: libraryId,
        createdAfter: createdAfter,
        createdBefore: createdBefore,
        isFavorite: isFavorite,
        isMotion: isMotion,
        isNotInAlbum: isNotInAlbum,
        isEncoded: isEncoded,
        isOffline: isOffline,
        filter: filter,
        page: page,
        size: size,
      ),
    );
    return _hits(res);
  }

  /// Metadata / structured search. Page size follows the official app (1000).
  Future<List<SearchHit>> metadata({
    String? query,
    String? description,
    String? checksum,
    String? city,
    String? country,
    String? make,
    String? model,
    String? state,
    String? lensModel,
    String? libraryId,
    String? createdAfter,
    String? createdBefore,
    String? takenAfter,
    String? takenBefore,
    String? encodedVideoPath,
    String? originalFileName,
    String? originalPath,
    List<String>? personIds,
    List<String>? tagIds,
    List<String>? albumIds,
    bool? isFavorite,
    bool? isMotion,
    bool? isNotInAlbum,
    bool? isEncoded,
    bool? isOffline,
    bool? isArchived,
    bool? isTrashed,
    SearchFilter? filter,
    int page = 1,
    int size = 1000,
    AssetOrder order = AssetOrder.desc,
  }) async {
    final res = await _client.searchAssets(
      body: MetadataSearchDto(
        description: description,
        checksum: checksum,
        city: city,
        country: country,
        make: make,
        model: model,
        state: state,
        lensModel: lensModel,
        libraryId: libraryId,
        createdAfter: createdAfter,
        createdBefore: createdBefore,
        takenAfter: takenAfter,
        takenBefore: takenBefore,
        encodedVideoPath: encodedVideoPath,
        originalFileName: originalFileName,
        originalPath: originalPath,
        personIds: personIds,
        tagIds: tagIds,
        albumIds: albumIds,
        isFavorite: isFavorite,
        isMotion: isMotion,
        isNotInAlbum: isNotInAlbum,
        isEncoded: isEncoded,
        isOffline: isOffline,
        filter: filter,
        page: page,
        size: size,
        order: order,
      ),
    );
    return _hits(res);
  }

  List<SearchHit> _hits(SearchResponseDto res) {
    final items = res.assets?.items;
    if (items == null) return [];
    return items.map((a) => SearchHit.fromAsset(a)).toList(growable: false);
  }

  /// Search suggestions (people, places, camera, …) for the search bar.
  Future<List<String>> suggestions({
    String? country,
    String? state,
    String? make,
    String? model,
  }) =>
      _client.getSearchSuggestions(
        country: country,
        state: state,
        make: make,
        model: model,
      );

  Future<List<SearchExploreResponseDto>> explore() => _client.getExploreData();

  Future<SearchStatisticsResponseDto> statistics() =>
      _client.searchAssetStatistics();

  Future<List<AssetResponseDto>> random({int size = 30}) =>
      _client.searchRandom(body: RandomSearchDto(size: size));

  Future<List<PersonResponseDto>> people({String? name, bool? withHidden}) =>
      _client.searchPerson(name: name, withHidden: withHidden);

  Future<List<PlacesResponseDto>> places(String name) =>
      _client.searchPlaces(name: name);

  Future<List<AssetResponseDto>> assetsByCity() =>
      _client.getAssetsByCity();
}

/// Album CRUD, membership and activity.
class AlbumRepository {
  AlbumRepository(this._client);

  final ImmichApiClient _client;

  Future<List<AlbumResponseDto>> all({
    bool? isShared,
    String? assetId,
  }) =>
      _client.getAllAlbums(
        isShared: isShared,
        assetId: assetId,
      );

  Future<AlbumResponseDto> create({
    required String albumName,
    String? description,
    List<String>? assetIds,
    List<AlbumUserCreateDto>? albumUsers,
  }) =>
      _client.createAlbum(
        body: CreateAlbumDto(
          albumName: albumName,
          description: description,
          assetIds: assetIds,
          albumUsers: albumUsers,
        ),
      );

  Future<AlbumResponseDto> get(String id) => _client.getAlbumInfo(id: id);

  Future<AlbumResponseDto> update(
    String id, {
    String? albumName,
    String? description,
    String? albumThumbnailAssetId,
    AssetOrder? order,
    bool? isActivityEnabled,
  }) =>
      _client.updateAlbumInfo(
        id: id,
        body: UpdateAlbumDto(
          albumName: albumName,
          description: description,
          albumThumbnailAssetId: albumThumbnailAssetId,
          order: order,
          isActivityEnabled: isActivityEnabled,
        ),
      );

  Future<void> delete(String id) => _client.deleteAlbum(id: id);

  Future<void> addAssets(String id, List<String> assetIds) =>
      _client.addAssetsToAlbum(id: id, body: BulkIdsDto(ids: assetIds));

  Future<void> removeAssets(String id, List<String> assetIds) =>
      _client.removeAssetFromAlbum(id: id, body: BulkIdsDto(ids: assetIds));

  Future<AlbumResponseDto> addUsers(
    String id,
    List<AlbumUserAddDto> users,
  ) =>
      _client.addUsersToAlbum(
        id: id,
        body: AddUsersDto(albumUsers: users),
      );

  Future<void> removeUser(String albumId, String userId) =>
      _client.removeUserFromAlbum(id: albumId, userId: userId);

  Future<void> updateUser(
    String albumId,
    String userId, {
    required AlbumUserRole role,
  }) =>
      _client.updateAlbumUser(
        id: albumId,
        userId: userId,
        body: UpdateAlbumUserDto(role: role),
      );

  Future<AlbumStatisticsResponseDto> statistics() =>
      _client.getAlbumStatistics();

  Future<List<MapMarkerResponseDto>> mapMarkers(String id) =>
      _client.getAlbumMapMarkers(id: id);

  /// Album comments and likes.
  Future<List<ActivityResponseDto>> activities(
    String albumId, {
    String? assetId,
    ReactionType? type,
  }) =>
      _client.getActivities(albumId: albumId, assetId: assetId, type: type);

  Future<ActivityResponseDto> comment({
    required String albumId,
    String? assetId,
    required String comment,
  }) =>
      _client.createActivity(
        body: ActivityCreateDto(
          albumId: albumId,
          assetId: assetId,
          type: ReactionType.comment,
          comment: comment,
        ),
      );

  Future<ActivityResponseDto> like({
    required String albumId,
    String? assetId,
  }) =>
      _client.createActivity(
        body: ActivityCreateDto(
          albumId: albumId,
          assetId: assetId,
          type: ReactionType.like,
        ),
      );

  Future<void> deleteActivity(String id) => _client.deleteActivity(id: id);
}

/// People / face management.
class PersonRepository {
  PersonRepository(this._client);

  final ImmichApiClient _client;

  Future<PeopleResponseDto> all({
    bool? withHidden,
  }) =>
      _client.getAllPeople(
        withHidden: withHidden,
      );

  Future<PersonResponseDto> create({
    required String name,
    String? birthDate,
    bool? isFavorite,
    bool? isHidden,
    String? color,
  }) =>
      _client.createPerson(
        body: PersonCreateDto(
          name: name,
          birthDate: birthDate,
          isFavorite: isFavorite,
          isHidden: isHidden,
          color: color,
        ),
      );

  Future<PersonResponseDto> update(
    String id, {
    String? name,
    String? birthDate,
    bool? isFavorite,
    bool? isHidden,
    String? color,
    String? featureFaceAssetId,
  }) =>
      _client.updatePerson(
        id: id,
        body: PersonUpdateDto(
          name: name,
          birthDate: birthDate,
          isFavorite: isFavorite,
          isHidden: isHidden,
          color: color,
          featureFaceAssetId: featureFaceAssetId,
        ),
      );

  Future<void> delete(String id) => _client.deletePerson(id: id);

  Future<List<BulkIdResponseDto>> merge(
          List<String> ids, String mergeIntoPersonId) =>
      _client.mergePeople(body: MergePersonDto(ids: ids));

  Future<PersonResponseDto> get(String id) => _client.getPerson(id: id);

  Future<PersonStatisticsResponseDto> statistics(String id) =>
      _client.getPersonStatistics(id: id);

  Future<Uint8List> thumbnail(String id) =>
      _client.getBytes('/people/$id/thumbnail');

  /// Faces detected on one asset.
  Future<List<AssetFaceResponseDto>> faces(String assetId) =>
      _client.getFaces(id: assetId);

  Future<List<PersonResponseDto>> reassignFaces({
    required String personId,
    required List<String> faceAssetIds,
  }) =>
      _client.reassignFaces(
        id: personId,
        body: AssetFaceUpdateDto(
          data: faceAssetIds
              .map((assetId) =>
                  AssetFaceUpdateItem(assetId: assetId, personId: personId))
              .toList(),
        ),
      );

  /// Asset ids that contain unassigned faces.
  Future<List<AssetResponseDto>> unassigned() async {
    await _client.searchPerson(withHidden: true);
    // People named "" or "Unknown" carry the unassigned cluster.
    return <AssetResponseDto>[];
  }
}

/// Memories ("On this day").
class MemoryRepository {
  MemoryRepository(this._client);

  final ImmichApiClient _client;

  Future<List<MemoryResponseDto>> search({
    bool? isSaved,
    MemoryType? type,
  }) =>
      _client.searchMemories(
        isSaved: isSaved,
        type: type,
      );

  Future<MemoryResponseDto> create({
    required List<String> assetIds,
    String? memoryAt,
    MemoryType? type,
    bool? isSaved,
    String? seenAt,
  }) =>
      _client.createMemory(
        body: MemoryCreateDto(
          assetIds: assetIds,
          memoryAt: memoryAt,
          type: type,
          isSaved: isSaved,
          seenAt: seenAt,
        ),
      );

  Future<MemoryResponseDto> get(String id) => _client.getMemory(id: id);

  Future<MemoryResponseDto> update(
    String id, {
    String? memoryAt,
    bool? isSaved,
    String? seenAt,
  }) =>
      _client.updateMemory(
        id: id,
        body: MemoryUpdateDto(
          memoryAt: memoryAt,
          isSaved: isSaved,
          seenAt: seenAt,
        ),
      );

  Future<void> delete(String id) => _client.deleteMemory(id: id);

  Future<void> addAssets(String id, List<String> assetIds) =>
      _client.addMemoryAssets(id: id, body: BulkIdsDto(ids: assetIds));

  Future<void> removeAssets(String id, List<String> assetIds) =>
      _client.removeMemoryAssets(id: id, body: BulkIdsDto(ids: assetIds));

  Future<MemoryStatisticsResponseDto> statistics() =>
      _client.memoriesStatistics();
}

/// Partner sharing.
class PartnerRepository {
  PartnerRepository(this._client);

  final ImmichApiClient _client;

  Future<List<PartnerResponseDto>> all(PartnerDirection direction) =>
      _client.getPartners(direction: direction);

  Future<PartnerResponseDto> create(String sharedWithId) =>
      _client.createPartner(
          body: PartnerCreateDto(sharedWithId: sharedWithId));

  Future<PartnerResponseDto> update(
    String id, {
    bool? inTimeline,
  }) =>
      _client.updatePartner(
        id: id,
        body: PartnerUpdateDto(inTimeline: inTimeline),
      );

  Future<void> remove(String id) => _client.removePartner(id: id);
}

/// Shared links.
class SharedLinkRepository {
  SharedLinkRepository(this._client);

  final ImmichApiClient _client;

  Future<List<SharedLinkResponseDto>> all() => _client.getAllSharedLinks();

  Future<SharedLinkResponseDto> create({
    String? albumId,
    List<String>? assetIds,
    String? description,
    String? password,
    String? slug,
    SharedLinkType? type,
    DateTime? expiresAt,
    bool? allowDownload,
    bool? allowUpload,
    bool? showMetadata,
  }) =>
      _client.createSharedLink(
        body: SharedLinkCreateDto(
          albumId: albumId,
          assetIds: assetIds,
          description: description,
          password: password,
          slug: slug,
          type: type,
          expiresAt: expiresAt?.toIso8601String(),
          allowDownload: allowDownload,
          allowUpload: allowUpload,
          showMetadata: showMetadata,
        ),
      );

  Future<SharedLinkResponseDto> update(
    String id, {
    String? description,
    String? password,
    String? slug,
    DateTime? expiresAt,
    bool? allowDownload,
    bool? allowUpload,
    bool? showMetadata,
  }) =>
      _client.updateSharedLink(
        id: id,
        body: SharedLinkEditDto(
          description: description,
          password: password,
          slug: slug,
          expiresAt: expiresAt?.toIso8601String(),
          allowDownload: allowDownload,
          allowUpload: allowUpload,
          showMetadata: showMetadata,
        ),
      );

  Future<void> remove(String id) => _client.removeSharedLink(id: id);

  Future<void> addAssets(String id, List<String> assetIds) =>
      _client.addSharedLinkAssets(
          id: id, body: AssetIdsDto(assetIds: assetIds));

  Future<void> removeAssets(String id, List<String> assetIds) =>
      _client.removeSharedLinkAssets(
          id: id, body: AssetIdsDto(assetIds: assetIds));
}

/// Tags, stacks, maps, libraries, trash.
class MiscRepository {
  MiscRepository(this._client);

  final ImmichApiClient _client;

  Future<List<TagResponseDto>> tags() => _client.getAllTags();

  Future<TagResponseDto> createTag({
    required String name,
    String? parentId,
    String? color,
  }) =>
      _client.createTag(
        body: TagCreateDto(name: name, parentId: parentId, color: color),
      );

  Future<void> deleteTag(String id) => _client.deleteTag(id: id);

  Future<List<StackResponseDto>> stacks() => _client.searchStacks();

  Future<StackResponseDto> createStack(List<String> assetIds) =>
      _client.createStack(body: StackCreateDto(assetIds: assetIds));

  Future<void> deleteStack(String id) => _client.deleteStack(id: id);

  Future<List<MapMarkerResponseDto>> mapMarkers({
    bool? isArchived,
    bool? isFavorite,
    bool? withPartners,
    bool? withSharedAlbums,
    DateTime? fileCreatedAfter,
    DateTime? fileCreatedBefore,
  }) =>
      _client.getMapMarkers(
        isArchived: isArchived,
        isFavorite: isFavorite,
        withPartners: withPartners,
        withSharedAlbums: withSharedAlbums,
        fileCreatedAfter: fileCreatedAfter?.toIso8601String(),
        fileCreatedBefore: fileCreatedBefore?.toIso8601String(),
      );

  Future<List<MapReverseGeocodeResponseDto>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) =>
      _client.reverseGeocode(lat: latitude, lon: longitude);

  Future<List<LibraryResponseDto>> libraries() => _client.getAllLibraries();

  Future<LibraryResponseDto> createLibrary({
    String? name,
    List<String>? importPaths,
    List<String>? exclusionPatterns,
  }) =>
      _client.createLibrary(
        body: CreateLibraryDto(
          name: name,
          importPaths: importPaths,
          exclusionPatterns: exclusionPatterns,
        ),
      );

  Future<void> scanLibrary(String id) => _client.scanLibrary(id: id);

  Future<TrashResponseDto> restore(List<String> ids) =>
      _client.restoreAssets(body: BulkIdsDto(ids: ids));

  Future<TrashResponseDto> emptyTrash() => _client.emptyTrash();

  Future<DownloadResponseDto> downloadInfo({
    List<String>? assetIds,
    String? albumId,
  }) =>
      _client.getDownloadInfo(
          body: DownloadInfoDto(
        assetIds: assetIds,
        albumId: albumId,
      ));
}

/// Session / device management and user metadata.
class UserRepository {
  UserRepository(this._client);

  final ImmichApiClient _client;

  Future<UserAdminResponseDto> me() => _client.getMyUser();

  Future<UserPreferencesResponseDto> preferences() =>
      _client.getMyPreferences();

  Future<UserPreferencesResponseDto> updatePreferences(
    UserPreferencesUpdateDto body,
  ) =>
      _client.updateMyPreferences(body: body);

  Future<List<SessionResponseDto>> sessions() => _client.getSessions();

  Future<void> deleteSession(String id) => _client.deleteSession(id: id);

  Future<void> deleteAllSessions() => _client.deleteAllSessions();

  Future<CalendarHeatmapResponseDto> heatmap() =>
      _client.getMyCalendarHeatmap();

  Future<List<UserResponseDto>> searchUsers() => _client.searchUsers();

  Future<UserAdminResponseDto> changePassword({
    String? password,
    String? newPassword,
  }) =>
      _client.changePassword(
        body: ChangePasswordDto(
          password: password,
          newPassword: newPassword,
        ),
      );

  Future<List<ApiKeyResponseDto>> apiKeys() => _client.getApiKeys();

  Future<ApiKeyCreateResponseDto> createApiKey({String? name}) =>
      _client.createApiKey(body: ApiKeyCreateDto(name: name));

  Future<void> deleteApiKey(String id) => _client.deleteApiKey(id: id);

  Future<AssetStatsResponseDto> statistics() => _client.getAssetStatistics();

  Future<ServerStorageResponseDto> storage() => _client.getStorage();

  Future<ServerAboutResponseDto> about() => _client.getAboutInfo();

  Future<ServerVersionResponseDto> version() => _client.getServerVersion();

  Future<ServerStatsResponseDto> serverStatistics() =>
      _client.getServerStatistics();

  Future<UserConfigDto> config() => _client.getUserConfig();
}

/// Decodes a base64 thumbhash into a `Uint8List` for the blur placeholder.
Uint8List? decodeThumbhash(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return base64Decode(value);
  } catch (_) {
    return null;
  }
}
