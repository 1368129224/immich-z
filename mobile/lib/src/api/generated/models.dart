// ---------------------------------------------------------------------------
// GENERATED FILE - do not edit by hand.
// Source: immich-app/immich open-api/immich-openapi-specs.json (3.2.0)
// Regenerate with: python3 tools/generate_api.py
// ---------------------------------------------------------------------------

import 'dart:convert';

/// Marker for server versions whose payloads this client understands.
const String kGeneratedFromImmichVersion = "3.2.0";

enum AlbumUserRole {
  swaggerGeneratedUnknown,
  editor,
  owner,
  viewer,
}

extension AlbumUserRoleExt on AlbumUserRole {
  String get value {
    switch (this) {
      case AlbumUserRole.editor:
        return "editor";
      case AlbumUserRole.owner:
        return "owner";
      case AlbumUserRole.viewer:
        return "viewer";
      case AlbumUserRole.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AlbumUserRole _albumUserRoleFromJson(String? v) {
  switch (v) {
    case "editor":
      return AlbumUserRole.editor;
    case "owner":
      return AlbumUserRole.owner;
    case "viewer":
      return AlbumUserRole.viewer;
  }
  return AlbumUserRole.swaggerGeneratedUnknown;
}

enum AssetEditAction {
  swaggerGeneratedUnknown,
  crop,
  rotate,
  mirror,
}

extension AssetEditActionExt on AssetEditAction {
  String get value {
    switch (this) {
      case AssetEditAction.crop:
        return "crop";
      case AssetEditAction.rotate:
        return "rotate";
      case AssetEditAction.mirror:
        return "mirror";
      case AssetEditAction.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetEditAction _assetEditActionFromJson(String? v) {
  switch (v) {
    case "crop":
      return AssetEditAction.crop;
    case "rotate":
      return AssetEditAction.rotate;
    case "mirror":
      return AssetEditAction.mirror;
  }
  return AssetEditAction.swaggerGeneratedUnknown;
}

enum AssetFileType {
  swaggerGeneratedUnknown,
  fullsize,
  preview,
  thumbnail,
  sidecar,
  encoded_video,
}

extension AssetFileTypeExt on AssetFileType {
  String get value {
    switch (this) {
      case AssetFileType.fullsize:
        return "fullsize";
      case AssetFileType.preview:
        return "preview";
      case AssetFileType.thumbnail:
        return "thumbnail";
      case AssetFileType.sidecar:
        return "sidecar";
      case AssetFileType.encoded_video:
        return "encoded_video";
      case AssetFileType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetFileType _assetFileTypeFromJson(String? v) {
  switch (v) {
    case "fullsize":
      return AssetFileType.fullsize;
    case "preview":
      return AssetFileType.preview;
    case "thumbnail":
      return AssetFileType.thumbnail;
    case "sidecar":
      return AssetFileType.sidecar;
    case "encoded_video":
      return AssetFileType.encoded_video;
  }
  return AssetFileType.swaggerGeneratedUnknown;
}

enum AssetIdErrorReason {
  swaggerGeneratedUnknown,
  duplicate,
  no_permission,
  not_found,
}

extension AssetIdErrorReasonExt on AssetIdErrorReason {
  String get value {
    switch (this) {
      case AssetIdErrorReason.duplicate:
        return "duplicate";
      case AssetIdErrorReason.no_permission:
        return "no_permission";
      case AssetIdErrorReason.not_found:
        return "not_found";
      case AssetIdErrorReason.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetIdErrorReason _assetIdErrorReasonFromJson(String? v) {
  switch (v) {
    case "duplicate":
      return AssetIdErrorReason.duplicate;
    case "no_permission":
      return AssetIdErrorReason.no_permission;
    case "not_found":
      return AssetIdErrorReason.not_found;
  }
  return AssetIdErrorReason.swaggerGeneratedUnknown;
}

enum AssetJobName {
  swaggerGeneratedUnknown,
  refresh_faces,
  refresh_metadata,
  regenerate_thumbnail,
  transcode_video,
}

extension AssetJobNameExt on AssetJobName {
  String get value {
    switch (this) {
      case AssetJobName.refresh_faces:
        return "refresh-faces";
      case AssetJobName.refresh_metadata:
        return "refresh-metadata";
      case AssetJobName.regenerate_thumbnail:
        return "regenerate-thumbnail";
      case AssetJobName.transcode_video:
        return "transcode-video";
      case AssetJobName.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetJobName _assetJobNameFromJson(String? v) {
  switch (v) {
    case "refresh-faces":
      return AssetJobName.refresh_faces;
    case "refresh-metadata":
      return AssetJobName.refresh_metadata;
    case "regenerate-thumbnail":
      return AssetJobName.regenerate_thumbnail;
    case "transcode-video":
      return AssetJobName.transcode_video;
  }
  return AssetJobName.swaggerGeneratedUnknown;
}

enum AssetMediaSize {
  swaggerGeneratedUnknown,
  original,
  fullsize,
  preview,
  thumbnail,
}

extension AssetMediaSizeExt on AssetMediaSize {
  String get value {
    switch (this) {
      case AssetMediaSize.original:
        return "original";
      case AssetMediaSize.fullsize:
        return "fullsize";
      case AssetMediaSize.preview:
        return "preview";
      case AssetMediaSize.thumbnail:
        return "thumbnail";
      case AssetMediaSize.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetMediaSize _assetMediaSizeFromJson(String? v) {
  switch (v) {
    case "original":
      return AssetMediaSize.original;
    case "fullsize":
      return AssetMediaSize.fullsize;
    case "preview":
      return AssetMediaSize.preview;
    case "thumbnail":
      return AssetMediaSize.thumbnail;
  }
  return AssetMediaSize.swaggerGeneratedUnknown;
}

enum AssetMediaStatus {
  swaggerGeneratedUnknown,
  created,
  duplicate,
}

extension AssetMediaStatusExt on AssetMediaStatus {
  String get value {
    switch (this) {
      case AssetMediaStatus.created:
        return "created";
      case AssetMediaStatus.duplicate:
        return "duplicate";
      case AssetMediaStatus.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetMediaStatus _assetMediaStatusFromJson(String? v) {
  switch (v) {
    case "created":
      return AssetMediaStatus.created;
    case "duplicate":
      return AssetMediaStatus.duplicate;
  }
  return AssetMediaStatus.swaggerGeneratedUnknown;
}

enum AssetOrder {
  swaggerGeneratedUnknown,
  asc,
  desc,
}

extension AssetOrderExt on AssetOrder {
  String get value {
    switch (this) {
      case AssetOrder.asc:
        return "asc";
      case AssetOrder.desc:
        return "desc";
      case AssetOrder.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetOrder _assetOrderFromJson(String? v) {
  switch (v) {
    case "asc":
      return AssetOrder.asc;
    case "desc":
      return AssetOrder.desc;
  }
  return AssetOrder.swaggerGeneratedUnknown;
}

enum AssetOrderBy {
  swaggerGeneratedUnknown,
  takenAt,
  createdAt,
}

extension AssetOrderByExt on AssetOrderBy {
  String get value {
    switch (this) {
      case AssetOrderBy.takenAt:
        return "takenAt";
      case AssetOrderBy.createdAt:
        return "createdAt";
      case AssetOrderBy.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetOrderBy _assetOrderByFromJson(String? v) {
  switch (v) {
    case "takenAt":
      return AssetOrderBy.takenAt;
    case "createdAt":
      return AssetOrderBy.createdAt;
  }
  return AssetOrderBy.swaggerGeneratedUnknown;
}

enum AssetRejectReason {
  swaggerGeneratedUnknown,
  duplicate,
  unsupported_format,
}

extension AssetRejectReasonExt on AssetRejectReason {
  String get value {
    switch (this) {
      case AssetRejectReason.duplicate:
        return "duplicate";
      case AssetRejectReason.unsupported_format:
        return "unsupported-format";
      case AssetRejectReason.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetRejectReason _assetRejectReasonFromJson(String? v) {
  switch (v) {
    case "duplicate":
      return AssetRejectReason.duplicate;
    case "unsupported-format":
      return AssetRejectReason.unsupported_format;
  }
  return AssetRejectReason.swaggerGeneratedUnknown;
}

enum AssetTypeEnum {
  swaggerGeneratedUnknown,
  iMAGE,
  vIDEO,
  aUDIO,
  oTHER,
}

extension AssetTypeEnumExt on AssetTypeEnum {
  String get value {
    switch (this) {
      case AssetTypeEnum.iMAGE:
        return "IMAGE";
      case AssetTypeEnum.vIDEO:
        return "VIDEO";
      case AssetTypeEnum.aUDIO:
        return "AUDIO";
      case AssetTypeEnum.oTHER:
        return "OTHER";
      case AssetTypeEnum.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetTypeEnum _assetTypeEnumFromJson(String? v) {
  switch (v) {
    case "IMAGE":
      return AssetTypeEnum.iMAGE;
    case "VIDEO":
      return AssetTypeEnum.vIDEO;
    case "AUDIO":
      return AssetTypeEnum.aUDIO;
    case "OTHER":
      return AssetTypeEnum.oTHER;
  }
  return AssetTypeEnum.swaggerGeneratedUnknown;
}

enum AssetUploadAction {
  swaggerGeneratedUnknown,
  accept,
  reject,
}

extension AssetUploadActionExt on AssetUploadAction {
  String get value {
    switch (this) {
      case AssetUploadAction.accept:
        return "accept";
      case AssetUploadAction.reject:
        return "reject";
      case AssetUploadAction.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetUploadAction _assetUploadActionFromJson(String? v) {
  switch (v) {
    case "accept":
      return AssetUploadAction.accept;
    case "reject":
      return AssetUploadAction.reject;
  }
  return AssetUploadAction.swaggerGeneratedUnknown;
}

enum AssetVisibility {
  swaggerGeneratedUnknown,
  archive,
  timeline,
  hidden,
  locked,
}

extension AssetVisibilityExt on AssetVisibility {
  String get value {
    switch (this) {
      case AssetVisibility.archive:
        return "archive";
      case AssetVisibility.timeline:
        return "timeline";
      case AssetVisibility.hidden:
        return "hidden";
      case AssetVisibility.locked:
        return "locked";
      case AssetVisibility.swaggerGeneratedUnknown:
        return '';
    }
  }

}

AssetVisibility _assetVisibilityFromJson(String? v) {
  switch (v) {
    case "archive":
      return AssetVisibility.archive;
    case "timeline":
      return AssetVisibility.timeline;
    case "hidden":
      return AssetVisibility.hidden;
    case "locked":
      return AssetVisibility.locked;
  }
  return AssetVisibility.swaggerGeneratedUnknown;
}

enum BulkIdErrorReason {
  swaggerGeneratedUnknown,
  duplicate,
  no_permission,
  not_found,
  unknown,
  validation,
}

extension BulkIdErrorReasonExt on BulkIdErrorReason {
  String get value {
    switch (this) {
      case BulkIdErrorReason.duplicate:
        return "duplicate";
      case BulkIdErrorReason.no_permission:
        return "no_permission";
      case BulkIdErrorReason.not_found:
        return "not_found";
      case BulkIdErrorReason.unknown:
        return "unknown";
      case BulkIdErrorReason.validation:
        return "validation";
      case BulkIdErrorReason.swaggerGeneratedUnknown:
        return '';
    }
  }

}

BulkIdErrorReason _bulkIdErrorReasonFromJson(String? v) {
  switch (v) {
    case "duplicate":
      return BulkIdErrorReason.duplicate;
    case "no_permission":
      return BulkIdErrorReason.no_permission;
    case "not_found":
      return BulkIdErrorReason.not_found;
    case "unknown":
      return BulkIdErrorReason.unknown;
    case "validation":
      return BulkIdErrorReason.validation;
  }
  return BulkIdErrorReason.swaggerGeneratedUnknown;
}

enum CalendarHeatmapType {
  swaggerGeneratedUnknown,
  upload,
  taken,
}

extension CalendarHeatmapTypeExt on CalendarHeatmapType {
  String get value {
    switch (this) {
      case CalendarHeatmapType.upload:
        return "Upload";
      case CalendarHeatmapType.taken:
        return "Taken";
      case CalendarHeatmapType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

CalendarHeatmapType _calendarHeatmapTypeFromJson(String? v) {
  switch (v) {
    case "Upload":
      return CalendarHeatmapType.upload;
    case "Taken":
      return CalendarHeatmapType.taken;
  }
  return CalendarHeatmapType.swaggerGeneratedUnknown;
}

enum HlsVideoResolution {
  swaggerGeneratedUnknown,
  n480,
  n720,
  n1080,
  n1440,
  n2160,
}

extension HlsVideoResolutionExt on HlsVideoResolution {
  String get value {
    switch (this) {
      case HlsVideoResolution.n480:
        return "480";
      case HlsVideoResolution.n720:
        return "720";
      case HlsVideoResolution.n1080:
        return "1080";
      case HlsVideoResolution.n1440:
        return "1440";
      case HlsVideoResolution.n2160:
        return "2160";
      case HlsVideoResolution.swaggerGeneratedUnknown:
        return '';
    }
  }

}

HlsVideoResolution _hlsVideoResolutionFromJson(String? v) {
  switch (v) {
    case "480":
      return HlsVideoResolution.n480;
    case "720":
      return HlsVideoResolution.n720;
    case "1080":
      return HlsVideoResolution.n1080;
    case "1440":
      return HlsVideoResolution.n1440;
    case "2160":
      return HlsVideoResolution.n2160;
  }
  return HlsVideoResolution.swaggerGeneratedUnknown;
}

enum MemorySearchOrder {
  swaggerGeneratedUnknown,
  asc,
  desc,
  random,
}

extension MemorySearchOrderExt on MemorySearchOrder {
  String get value {
    switch (this) {
      case MemorySearchOrder.asc:
        return "asc";
      case MemorySearchOrder.desc:
        return "desc";
      case MemorySearchOrder.random:
        return "random";
      case MemorySearchOrder.swaggerGeneratedUnknown:
        return '';
    }
  }

}

MemorySearchOrder _memorySearchOrderFromJson(String? v) {
  switch (v) {
    case "asc":
      return MemorySearchOrder.asc;
    case "desc":
      return MemorySearchOrder.desc;
    case "random":
      return MemorySearchOrder.random;
  }
  return MemorySearchOrder.swaggerGeneratedUnknown;
}

enum MemoryType {
  swaggerGeneratedUnknown,
  on_this_day,
  birthday,
}

extension MemoryTypeExt on MemoryType {
  String get value {
    switch (this) {
      case MemoryType.on_this_day:
        return "on_this_day";
      case MemoryType.birthday:
        return "birthday";
      case MemoryType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

MemoryType _memoryTypeFromJson(String? v) {
  switch (v) {
    case "on_this_day":
      return MemoryType.on_this_day;
    case "birthday":
      return MemoryType.birthday;
  }
  return MemoryType.swaggerGeneratedUnknown;
}

enum MirrorAxis {
  swaggerGeneratedUnknown,
  horizontal,
  vertical,
}

extension MirrorAxisExt on MirrorAxis {
  String get value {
    switch (this) {
      case MirrorAxis.horizontal:
        return "horizontal";
      case MirrorAxis.vertical:
        return "vertical";
      case MirrorAxis.swaggerGeneratedUnknown:
        return '';
    }
  }

}

MirrorAxis _mirrorAxisFromJson(String? v) {
  switch (v) {
    case "horizontal":
      return MirrorAxis.horizontal;
    case "vertical":
      return MirrorAxis.vertical;
  }
  return MirrorAxis.swaggerGeneratedUnknown;
}

enum NotificationLevel {
  swaggerGeneratedUnknown,
  success,
  error,
  warning,
  info,
}

extension NotificationLevelExt on NotificationLevel {
  String get value {
    switch (this) {
      case NotificationLevel.success:
        return "success";
      case NotificationLevel.error:
        return "error";
      case NotificationLevel.warning:
        return "warning";
      case NotificationLevel.info:
        return "info";
      case NotificationLevel.swaggerGeneratedUnknown:
        return '';
    }
  }

}

NotificationLevel _notificationLevelFromJson(String? v) {
  switch (v) {
    case "success":
      return NotificationLevel.success;
    case "error":
      return NotificationLevel.error;
    case "warning":
      return NotificationLevel.warning;
    case "info":
      return NotificationLevel.info;
  }
  return NotificationLevel.swaggerGeneratedUnknown;
}

enum NotificationType {
  swaggerGeneratedUnknown,
  jobFailed,
  backupFailed,
  systemMessage,
  albumInvite,
  albumUpdate,
  clusterGroupRequest,
  custom,
}

extension NotificationTypeExt on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.jobFailed:
        return "JobFailed";
      case NotificationType.backupFailed:
        return "BackupFailed";
      case NotificationType.systemMessage:
        return "SystemMessage";
      case NotificationType.albumInvite:
        return "AlbumInvite";
      case NotificationType.albumUpdate:
        return "AlbumUpdate";
      case NotificationType.clusterGroupRequest:
        return "ClusterGroupRequest";
      case NotificationType.custom:
        return "Custom";
      case NotificationType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

NotificationType _notificationTypeFromJson(String? v) {
  switch (v) {
    case "JobFailed":
      return NotificationType.jobFailed;
    case "BackupFailed":
      return NotificationType.backupFailed;
    case "SystemMessage":
      return NotificationType.systemMessage;
    case "AlbumInvite":
      return NotificationType.albumInvite;
    case "AlbumUpdate":
      return NotificationType.albumUpdate;
    case "ClusterGroupRequest":
      return NotificationType.clusterGroupRequest;
    case "Custom":
      return NotificationType.custom;
  }
  return NotificationType.swaggerGeneratedUnknown;
}

enum PartnerDirection {
  swaggerGeneratedUnknown,
  shared_by,
  shared_with,
}

extension PartnerDirectionExt on PartnerDirection {
  String get value {
    switch (this) {
      case PartnerDirection.shared_by:
        return "shared-by";
      case PartnerDirection.shared_with:
        return "shared-with";
      case PartnerDirection.swaggerGeneratedUnknown:
        return '';
    }
  }

}

PartnerDirection _partnerDirectionFromJson(String? v) {
  switch (v) {
    case "shared-by":
      return PartnerDirection.shared_by;
    case "shared-with":
      return PartnerDirection.shared_with;
  }
  return PartnerDirection.swaggerGeneratedUnknown;
}

enum Permission {
  swaggerGeneratedUnknown,
  all,
  activity_create,
  activity_read,
  activity_update,
  activity_delete,
  activity_statistics,
  apiKey_create,
  apiKey_read,
  apiKey_update,
  apiKey_delete,
  apiKey_rotate,
  asset_read,
  asset_update,
  asset_delete,
  asset_statistics,
  asset_share,
  asset_view,
  asset_download,
  asset_upload,
  asset_copy,
  asset_derive,
  assetFile_read,
  assetFile_delete,
  assetFile_download,
  asset_edit_get,
  asset_edit_create,
  asset_edit_delete,
  album_create,
  album_read,
  album_update,
  album_delete,
  album_statistics,
  album_share,
  album_download,
  albumAsset_create,
  albumAsset_delete,
  albumUser_create,
  albumUser_update,
  albumUser_delete,
  auth_changePassword,
  authDevice_delete,
  archive_read,
  backup_list,
  backup_download,
  backup_upload,
  backup_delete,
  clusterGroup_read,
  clusterGroup_leave,
  clusterGroupRequest_create,
  clusterGroupRequest_read,
  clusterGroupRequest_delete,
  adminConfig_read,
  adminConfig_update,
  userConfig_read,
  duplicate_read,
  duplicate_delete,
  face_create,
  face_read,
  face_update,
  face_delete,
  folder_read,
  job_create,
  job_read,
  library_create,
  library_read,
  library_update,
  library_delete,
  library_statistics,
  timeline_read,
  timeline_download,
  maintenance,
  map_read,
  map_search,
  memory_create,
  memory_read,
  memory_update,
  memory_delete,
  memory_statistics,
  memoryAsset_create,
  memoryAsset_delete,
  notification_create,
  notification_read,
  notification_update,
  notification_delete,
  partner_create,
  partner_read,
  partner_update,
  partner_delete,
  person_create,
  person_read,
  person_update,
  person_delete,
  person_statistics,
  person_merge,
  person_reassign,
  pinCode_create,
  pinCode_update,
  pinCode_delete,
  plugin_create,
  plugin_read,
  plugin_update,
  plugin_delete,
  server_about,
  server_apkLinks,
  server_storage,
  server_statistics,
  server_versionCheck,
  serverLicense_read,
  serverLicense_update,
  serverLicense_delete,
  session_create,
  session_read,
  session_update,
  session_delete,
  session_lock,
  sharedLink_create,
  sharedLink_read,
  sharedLink_update,
  sharedLink_delete,
  stack_create,
  stack_read,
  stack_update,
  stack_delete,
  sync_stream,
  syncCheckpoint_read,
  syncCheckpoint_update,
  syncCheckpoint_delete,
  systemConfig_read,
  systemConfig_update,
  systemMetadata_read,
  systemMetadata_update,
  tag_create,
  tag_read,
  tag_update,
  tag_delete,
  tag_asset,
  user_read,
  user_update,
  userLicense_create,
  userLicense_read,
  userLicense_update,
  userLicense_delete,
  userOnboarding_read,
  userOnboarding_update,
  userOnboarding_delete,
  userPreference_read,
  userPreference_update,
  userProfileImage_create,
  userProfileImage_read,
  userProfileImage_update,
  userProfileImage_delete,
  queue_read,
  queue_update,
  queueJob_create,
  queueJob_read,
  queueJob_update,
  queueJob_delete,
  workflow_create,
  workflow_read,
  workflow_update,
  workflow_delete,
  workflow_logs,
  adminUser_create,
  adminUser_read,
  adminUser_update,
  adminUser_delete,
  adminSession_read,
  adminAuth_unlinkAll,
}

extension PermissionExt on Permission {
  String get value {
    switch (this) {
      case Permission.all:
        return "all";
      case Permission.activity_create:
        return "activity.create";
      case Permission.activity_read:
        return "activity.read";
      case Permission.activity_update:
        return "activity.update";
      case Permission.activity_delete:
        return "activity.delete";
      case Permission.activity_statistics:
        return "activity.statistics";
      case Permission.apiKey_create:
        return "apiKey.create";
      case Permission.apiKey_read:
        return "apiKey.read";
      case Permission.apiKey_update:
        return "apiKey.update";
      case Permission.apiKey_delete:
        return "apiKey.delete";
      case Permission.apiKey_rotate:
        return "apiKey.rotate";
      case Permission.asset_read:
        return "asset.read";
      case Permission.asset_update:
        return "asset.update";
      case Permission.asset_delete:
        return "asset.delete";
      case Permission.asset_statistics:
        return "asset.statistics";
      case Permission.asset_share:
        return "asset.share";
      case Permission.asset_view:
        return "asset.view";
      case Permission.asset_download:
        return "asset.download";
      case Permission.asset_upload:
        return "asset.upload";
      case Permission.asset_copy:
        return "asset.copy";
      case Permission.asset_derive:
        return "asset.derive";
      case Permission.assetFile_read:
        return "assetFile.read";
      case Permission.assetFile_delete:
        return "assetFile.delete";
      case Permission.assetFile_download:
        return "assetFile.download";
      case Permission.asset_edit_get:
        return "asset.edit.get";
      case Permission.asset_edit_create:
        return "asset.edit.create";
      case Permission.asset_edit_delete:
        return "asset.edit.delete";
      case Permission.album_create:
        return "album.create";
      case Permission.album_read:
        return "album.read";
      case Permission.album_update:
        return "album.update";
      case Permission.album_delete:
        return "album.delete";
      case Permission.album_statistics:
        return "album.statistics";
      case Permission.album_share:
        return "album.share";
      case Permission.album_download:
        return "album.download";
      case Permission.albumAsset_create:
        return "albumAsset.create";
      case Permission.albumAsset_delete:
        return "albumAsset.delete";
      case Permission.albumUser_create:
        return "albumUser.create";
      case Permission.albumUser_update:
        return "albumUser.update";
      case Permission.albumUser_delete:
        return "albumUser.delete";
      case Permission.auth_changePassword:
        return "auth.changePassword";
      case Permission.authDevice_delete:
        return "authDevice.delete";
      case Permission.archive_read:
        return "archive.read";
      case Permission.backup_list:
        return "backup.list";
      case Permission.backup_download:
        return "backup.download";
      case Permission.backup_upload:
        return "backup.upload";
      case Permission.backup_delete:
        return "backup.delete";
      case Permission.clusterGroup_read:
        return "clusterGroup.read";
      case Permission.clusterGroup_leave:
        return "clusterGroup.leave";
      case Permission.clusterGroupRequest_create:
        return "clusterGroupRequest.create";
      case Permission.clusterGroupRequest_read:
        return "clusterGroupRequest.read";
      case Permission.clusterGroupRequest_delete:
        return "clusterGroupRequest.delete";
      case Permission.adminConfig_read:
        return "adminConfig.read";
      case Permission.adminConfig_update:
        return "adminConfig.update";
      case Permission.userConfig_read:
        return "userConfig.read";
      case Permission.duplicate_read:
        return "duplicate.read";
      case Permission.duplicate_delete:
        return "duplicate.delete";
      case Permission.face_create:
        return "face.create";
      case Permission.face_read:
        return "face.read";
      case Permission.face_update:
        return "face.update";
      case Permission.face_delete:
        return "face.delete";
      case Permission.folder_read:
        return "folder.read";
      case Permission.job_create:
        return "job.create";
      case Permission.job_read:
        return "job.read";
      case Permission.library_create:
        return "library.create";
      case Permission.library_read:
        return "library.read";
      case Permission.library_update:
        return "library.update";
      case Permission.library_delete:
        return "library.delete";
      case Permission.library_statistics:
        return "library.statistics";
      case Permission.timeline_read:
        return "timeline.read";
      case Permission.timeline_download:
        return "timeline.download";
      case Permission.maintenance:
        return "maintenance";
      case Permission.map_read:
        return "map.read";
      case Permission.map_search:
        return "map.search";
      case Permission.memory_create:
        return "memory.create";
      case Permission.memory_read:
        return "memory.read";
      case Permission.memory_update:
        return "memory.update";
      case Permission.memory_delete:
        return "memory.delete";
      case Permission.memory_statistics:
        return "memory.statistics";
      case Permission.memoryAsset_create:
        return "memoryAsset.create";
      case Permission.memoryAsset_delete:
        return "memoryAsset.delete";
      case Permission.notification_create:
        return "notification.create";
      case Permission.notification_read:
        return "notification.read";
      case Permission.notification_update:
        return "notification.update";
      case Permission.notification_delete:
        return "notification.delete";
      case Permission.partner_create:
        return "partner.create";
      case Permission.partner_read:
        return "partner.read";
      case Permission.partner_update:
        return "partner.update";
      case Permission.partner_delete:
        return "partner.delete";
      case Permission.person_create:
        return "person.create";
      case Permission.person_read:
        return "person.read";
      case Permission.person_update:
        return "person.update";
      case Permission.person_delete:
        return "person.delete";
      case Permission.person_statistics:
        return "person.statistics";
      case Permission.person_merge:
        return "person.merge";
      case Permission.person_reassign:
        return "person.reassign";
      case Permission.pinCode_create:
        return "pinCode.create";
      case Permission.pinCode_update:
        return "pinCode.update";
      case Permission.pinCode_delete:
        return "pinCode.delete";
      case Permission.plugin_create:
        return "plugin.create";
      case Permission.plugin_read:
        return "plugin.read";
      case Permission.plugin_update:
        return "plugin.update";
      case Permission.plugin_delete:
        return "plugin.delete";
      case Permission.server_about:
        return "server.about";
      case Permission.server_apkLinks:
        return "server.apkLinks";
      case Permission.server_storage:
        return "server.storage";
      case Permission.server_statistics:
        return "server.statistics";
      case Permission.server_versionCheck:
        return "server.versionCheck";
      case Permission.serverLicense_read:
        return "serverLicense.read";
      case Permission.serverLicense_update:
        return "serverLicense.update";
      case Permission.serverLicense_delete:
        return "serverLicense.delete";
      case Permission.session_create:
        return "session.create";
      case Permission.session_read:
        return "session.read";
      case Permission.session_update:
        return "session.update";
      case Permission.session_delete:
        return "session.delete";
      case Permission.session_lock:
        return "session.lock";
      case Permission.sharedLink_create:
        return "sharedLink.create";
      case Permission.sharedLink_read:
        return "sharedLink.read";
      case Permission.sharedLink_update:
        return "sharedLink.update";
      case Permission.sharedLink_delete:
        return "sharedLink.delete";
      case Permission.stack_create:
        return "stack.create";
      case Permission.stack_read:
        return "stack.read";
      case Permission.stack_update:
        return "stack.update";
      case Permission.stack_delete:
        return "stack.delete";
      case Permission.sync_stream:
        return "sync.stream";
      case Permission.syncCheckpoint_read:
        return "syncCheckpoint.read";
      case Permission.syncCheckpoint_update:
        return "syncCheckpoint.update";
      case Permission.syncCheckpoint_delete:
        return "syncCheckpoint.delete";
      case Permission.systemConfig_read:
        return "systemConfig.read";
      case Permission.systemConfig_update:
        return "systemConfig.update";
      case Permission.systemMetadata_read:
        return "systemMetadata.read";
      case Permission.systemMetadata_update:
        return "systemMetadata.update";
      case Permission.tag_create:
        return "tag.create";
      case Permission.tag_read:
        return "tag.read";
      case Permission.tag_update:
        return "tag.update";
      case Permission.tag_delete:
        return "tag.delete";
      case Permission.tag_asset:
        return "tag.asset";
      case Permission.user_read:
        return "user.read";
      case Permission.user_update:
        return "user.update";
      case Permission.userLicense_create:
        return "userLicense.create";
      case Permission.userLicense_read:
        return "userLicense.read";
      case Permission.userLicense_update:
        return "userLicense.update";
      case Permission.userLicense_delete:
        return "userLicense.delete";
      case Permission.userOnboarding_read:
        return "userOnboarding.read";
      case Permission.userOnboarding_update:
        return "userOnboarding.update";
      case Permission.userOnboarding_delete:
        return "userOnboarding.delete";
      case Permission.userPreference_read:
        return "userPreference.read";
      case Permission.userPreference_update:
        return "userPreference.update";
      case Permission.userProfileImage_create:
        return "userProfileImage.create";
      case Permission.userProfileImage_read:
        return "userProfileImage.read";
      case Permission.userProfileImage_update:
        return "userProfileImage.update";
      case Permission.userProfileImage_delete:
        return "userProfileImage.delete";
      case Permission.queue_read:
        return "queue.read";
      case Permission.queue_update:
        return "queue.update";
      case Permission.queueJob_create:
        return "queueJob.create";
      case Permission.queueJob_read:
        return "queueJob.read";
      case Permission.queueJob_update:
        return "queueJob.update";
      case Permission.queueJob_delete:
        return "queueJob.delete";
      case Permission.workflow_create:
        return "workflow.create";
      case Permission.workflow_read:
        return "workflow.read";
      case Permission.workflow_update:
        return "workflow.update";
      case Permission.workflow_delete:
        return "workflow.delete";
      case Permission.workflow_logs:
        return "workflow.logs";
      case Permission.adminUser_create:
        return "adminUser.create";
      case Permission.adminUser_read:
        return "adminUser.read";
      case Permission.adminUser_update:
        return "adminUser.update";
      case Permission.adminUser_delete:
        return "adminUser.delete";
      case Permission.adminSession_read:
        return "adminSession.read";
      case Permission.adminAuth_unlinkAll:
        return "adminAuth.unlinkAll";
      case Permission.swaggerGeneratedUnknown:
        return '';
    }
  }

}

Permission _permissionFromJson(String? v) {
  switch (v) {
    case "all":
      return Permission.all;
    case "activity.create":
      return Permission.activity_create;
    case "activity.read":
      return Permission.activity_read;
    case "activity.update":
      return Permission.activity_update;
    case "activity.delete":
      return Permission.activity_delete;
    case "activity.statistics":
      return Permission.activity_statistics;
    case "apiKey.create":
      return Permission.apiKey_create;
    case "apiKey.read":
      return Permission.apiKey_read;
    case "apiKey.update":
      return Permission.apiKey_update;
    case "apiKey.delete":
      return Permission.apiKey_delete;
    case "apiKey.rotate":
      return Permission.apiKey_rotate;
    case "asset.read":
      return Permission.asset_read;
    case "asset.update":
      return Permission.asset_update;
    case "asset.delete":
      return Permission.asset_delete;
    case "asset.statistics":
      return Permission.asset_statistics;
    case "asset.share":
      return Permission.asset_share;
    case "asset.view":
      return Permission.asset_view;
    case "asset.download":
      return Permission.asset_download;
    case "asset.upload":
      return Permission.asset_upload;
    case "asset.copy":
      return Permission.asset_copy;
    case "asset.derive":
      return Permission.asset_derive;
    case "assetFile.read":
      return Permission.assetFile_read;
    case "assetFile.delete":
      return Permission.assetFile_delete;
    case "assetFile.download":
      return Permission.assetFile_download;
    case "asset.edit.get":
      return Permission.asset_edit_get;
    case "asset.edit.create":
      return Permission.asset_edit_create;
    case "asset.edit.delete":
      return Permission.asset_edit_delete;
    case "album.create":
      return Permission.album_create;
    case "album.read":
      return Permission.album_read;
    case "album.update":
      return Permission.album_update;
    case "album.delete":
      return Permission.album_delete;
    case "album.statistics":
      return Permission.album_statistics;
    case "album.share":
      return Permission.album_share;
    case "album.download":
      return Permission.album_download;
    case "albumAsset.create":
      return Permission.albumAsset_create;
    case "albumAsset.delete":
      return Permission.albumAsset_delete;
    case "albumUser.create":
      return Permission.albumUser_create;
    case "albumUser.update":
      return Permission.albumUser_update;
    case "albumUser.delete":
      return Permission.albumUser_delete;
    case "auth.changePassword":
      return Permission.auth_changePassword;
    case "authDevice.delete":
      return Permission.authDevice_delete;
    case "archive.read":
      return Permission.archive_read;
    case "backup.list":
      return Permission.backup_list;
    case "backup.download":
      return Permission.backup_download;
    case "backup.upload":
      return Permission.backup_upload;
    case "backup.delete":
      return Permission.backup_delete;
    case "clusterGroup.read":
      return Permission.clusterGroup_read;
    case "clusterGroup.leave":
      return Permission.clusterGroup_leave;
    case "clusterGroupRequest.create":
      return Permission.clusterGroupRequest_create;
    case "clusterGroupRequest.read":
      return Permission.clusterGroupRequest_read;
    case "clusterGroupRequest.delete":
      return Permission.clusterGroupRequest_delete;
    case "adminConfig.read":
      return Permission.adminConfig_read;
    case "adminConfig.update":
      return Permission.adminConfig_update;
    case "userConfig.read":
      return Permission.userConfig_read;
    case "duplicate.read":
      return Permission.duplicate_read;
    case "duplicate.delete":
      return Permission.duplicate_delete;
    case "face.create":
      return Permission.face_create;
    case "face.read":
      return Permission.face_read;
    case "face.update":
      return Permission.face_update;
    case "face.delete":
      return Permission.face_delete;
    case "folder.read":
      return Permission.folder_read;
    case "job.create":
      return Permission.job_create;
    case "job.read":
      return Permission.job_read;
    case "library.create":
      return Permission.library_create;
    case "library.read":
      return Permission.library_read;
    case "library.update":
      return Permission.library_update;
    case "library.delete":
      return Permission.library_delete;
    case "library.statistics":
      return Permission.library_statistics;
    case "timeline.read":
      return Permission.timeline_read;
    case "timeline.download":
      return Permission.timeline_download;
    case "maintenance":
      return Permission.maintenance;
    case "map.read":
      return Permission.map_read;
    case "map.search":
      return Permission.map_search;
    case "memory.create":
      return Permission.memory_create;
    case "memory.read":
      return Permission.memory_read;
    case "memory.update":
      return Permission.memory_update;
    case "memory.delete":
      return Permission.memory_delete;
    case "memory.statistics":
      return Permission.memory_statistics;
    case "memoryAsset.create":
      return Permission.memoryAsset_create;
    case "memoryAsset.delete":
      return Permission.memoryAsset_delete;
    case "notification.create":
      return Permission.notification_create;
    case "notification.read":
      return Permission.notification_read;
    case "notification.update":
      return Permission.notification_update;
    case "notification.delete":
      return Permission.notification_delete;
    case "partner.create":
      return Permission.partner_create;
    case "partner.read":
      return Permission.partner_read;
    case "partner.update":
      return Permission.partner_update;
    case "partner.delete":
      return Permission.partner_delete;
    case "person.create":
      return Permission.person_create;
    case "person.read":
      return Permission.person_read;
    case "person.update":
      return Permission.person_update;
    case "person.delete":
      return Permission.person_delete;
    case "person.statistics":
      return Permission.person_statistics;
    case "person.merge":
      return Permission.person_merge;
    case "person.reassign":
      return Permission.person_reassign;
    case "pinCode.create":
      return Permission.pinCode_create;
    case "pinCode.update":
      return Permission.pinCode_update;
    case "pinCode.delete":
      return Permission.pinCode_delete;
    case "plugin.create":
      return Permission.plugin_create;
    case "plugin.read":
      return Permission.plugin_read;
    case "plugin.update":
      return Permission.plugin_update;
    case "plugin.delete":
      return Permission.plugin_delete;
    case "server.about":
      return Permission.server_about;
    case "server.apkLinks":
      return Permission.server_apkLinks;
    case "server.storage":
      return Permission.server_storage;
    case "server.statistics":
      return Permission.server_statistics;
    case "server.versionCheck":
      return Permission.server_versionCheck;
    case "serverLicense.read":
      return Permission.serverLicense_read;
    case "serverLicense.update":
      return Permission.serverLicense_update;
    case "serverLicense.delete":
      return Permission.serverLicense_delete;
    case "session.create":
      return Permission.session_create;
    case "session.read":
      return Permission.session_read;
    case "session.update":
      return Permission.session_update;
    case "session.delete":
      return Permission.session_delete;
    case "session.lock":
      return Permission.session_lock;
    case "sharedLink.create":
      return Permission.sharedLink_create;
    case "sharedLink.read":
      return Permission.sharedLink_read;
    case "sharedLink.update":
      return Permission.sharedLink_update;
    case "sharedLink.delete":
      return Permission.sharedLink_delete;
    case "stack.create":
      return Permission.stack_create;
    case "stack.read":
      return Permission.stack_read;
    case "stack.update":
      return Permission.stack_update;
    case "stack.delete":
      return Permission.stack_delete;
    case "sync.stream":
      return Permission.sync_stream;
    case "syncCheckpoint.read":
      return Permission.syncCheckpoint_read;
    case "syncCheckpoint.update":
      return Permission.syncCheckpoint_update;
    case "syncCheckpoint.delete":
      return Permission.syncCheckpoint_delete;
    case "systemConfig.read":
      return Permission.systemConfig_read;
    case "systemConfig.update":
      return Permission.systemConfig_update;
    case "systemMetadata.read":
      return Permission.systemMetadata_read;
    case "systemMetadata.update":
      return Permission.systemMetadata_update;
    case "tag.create":
      return Permission.tag_create;
    case "tag.read":
      return Permission.tag_read;
    case "tag.update":
      return Permission.tag_update;
    case "tag.delete":
      return Permission.tag_delete;
    case "tag.asset":
      return Permission.tag_asset;
    case "user.read":
      return Permission.user_read;
    case "user.update":
      return Permission.user_update;
    case "userLicense.create":
      return Permission.userLicense_create;
    case "userLicense.read":
      return Permission.userLicense_read;
    case "userLicense.update":
      return Permission.userLicense_update;
    case "userLicense.delete":
      return Permission.userLicense_delete;
    case "userOnboarding.read":
      return Permission.userOnboarding_read;
    case "userOnboarding.update":
      return Permission.userOnboarding_update;
    case "userOnboarding.delete":
      return Permission.userOnboarding_delete;
    case "userPreference.read":
      return Permission.userPreference_read;
    case "userPreference.update":
      return Permission.userPreference_update;
    case "userProfileImage.create":
      return Permission.userProfileImage_create;
    case "userProfileImage.read":
      return Permission.userProfileImage_read;
    case "userProfileImage.update":
      return Permission.userProfileImage_update;
    case "userProfileImage.delete":
      return Permission.userProfileImage_delete;
    case "queue.read":
      return Permission.queue_read;
    case "queue.update":
      return Permission.queue_update;
    case "queueJob.create":
      return Permission.queueJob_create;
    case "queueJob.read":
      return Permission.queueJob_read;
    case "queueJob.update":
      return Permission.queueJob_update;
    case "queueJob.delete":
      return Permission.queueJob_delete;
    case "workflow.create":
      return Permission.workflow_create;
    case "workflow.read":
      return Permission.workflow_read;
    case "workflow.update":
      return Permission.workflow_update;
    case "workflow.delete":
      return Permission.workflow_delete;
    case "workflow.logs":
      return Permission.workflow_logs;
    case "adminUser.create":
      return Permission.adminUser_create;
    case "adminUser.read":
      return Permission.adminUser_read;
    case "adminUser.update":
      return Permission.adminUser_update;
    case "adminUser.delete":
      return Permission.adminUser_delete;
    case "adminSession.read":
      return Permission.adminSession_read;
    case "adminAuth.unlinkAll":
      return Permission.adminAuth_unlinkAll;
  }
  return Permission.swaggerGeneratedUnknown;
}

enum ReactionLevel {
  swaggerGeneratedUnknown,
  album,
  asset,
}

extension ReactionLevelExt on ReactionLevel {
  String get value {
    switch (this) {
      case ReactionLevel.album:
        return "album";
      case ReactionLevel.asset:
        return "asset";
      case ReactionLevel.swaggerGeneratedUnknown:
        return '';
    }
  }

}

ReactionLevel _reactionLevelFromJson(String? v) {
  switch (v) {
    case "album":
      return ReactionLevel.album;
    case "asset":
      return ReactionLevel.asset;
  }
  return ReactionLevel.swaggerGeneratedUnknown;
}

enum ReactionType {
  swaggerGeneratedUnknown,
  comment,
  like,
}

extension ReactionTypeExt on ReactionType {
  String get value {
    switch (this) {
      case ReactionType.comment:
        return "comment";
      case ReactionType.like:
        return "like";
      case ReactionType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

ReactionType _reactionTypeFromJson(String? v) {
  switch (v) {
    case "comment":
      return ReactionType.comment;
    case "like":
      return ReactionType.like;
  }
  return ReactionType.swaggerGeneratedUnknown;
}

enum SearchOrderField {
  swaggerGeneratedUnknown,
  fileCreatedAt,
  localDateTime,
  fileSizeInBytes,
  rating,
}

extension SearchOrderFieldExt on SearchOrderField {
  String get value {
    switch (this) {
      case SearchOrderField.fileCreatedAt:
        return "fileCreatedAt";
      case SearchOrderField.localDateTime:
        return "localDateTime";
      case SearchOrderField.fileSizeInBytes:
        return "fileSizeInBytes";
      case SearchOrderField.rating:
        return "rating";
      case SearchOrderField.swaggerGeneratedUnknown:
        return '';
    }
  }

}

SearchOrderField _searchOrderFieldFromJson(String? v) {
  switch (v) {
    case "fileCreatedAt":
      return SearchOrderField.fileCreatedAt;
    case "localDateTime":
      return SearchOrderField.localDateTime;
    case "fileSizeInBytes":
      return SearchOrderField.fileSizeInBytes;
    case "rating":
      return SearchOrderField.rating;
  }
  return SearchOrderField.swaggerGeneratedUnknown;
}

enum SearchSuggestionType {
  swaggerGeneratedUnknown,
  country,
  state,
  city,
  camera_make,
  camera_model,
  camera_lens_model,
}

extension SearchSuggestionTypeExt on SearchSuggestionType {
  String get value {
    switch (this) {
      case SearchSuggestionType.country:
        return "country";
      case SearchSuggestionType.state:
        return "state";
      case SearchSuggestionType.city:
        return "city";
      case SearchSuggestionType.camera_make:
        return "camera-make";
      case SearchSuggestionType.camera_model:
        return "camera-model";
      case SearchSuggestionType.camera_lens_model:
        return "camera-lens-model";
      case SearchSuggestionType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

SearchSuggestionType _searchSuggestionTypeFromJson(String? v) {
  switch (v) {
    case "country":
      return SearchSuggestionType.country;
    case "state":
      return SearchSuggestionType.state;
    case "city":
      return SearchSuggestionType.city;
    case "camera-make":
      return SearchSuggestionType.camera_make;
    case "camera-model":
      return SearchSuggestionType.camera_model;
    case "camera-lens-model":
      return SearchSuggestionType.camera_lens_model;
  }
  return SearchSuggestionType.swaggerGeneratedUnknown;
}

enum SharedLinkType {
  swaggerGeneratedUnknown,
  aLBUM,
  iNDIVIDUAL,
}

extension SharedLinkTypeExt on SharedLinkType {
  String get value {
    switch (this) {
      case SharedLinkType.aLBUM:
        return "ALBUM";
      case SharedLinkType.iNDIVIDUAL:
        return "INDIVIDUAL";
      case SharedLinkType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

SharedLinkType _sharedLinkTypeFromJson(String? v) {
  switch (v) {
    case "ALBUM":
      return SharedLinkType.aLBUM;
    case "INDIVIDUAL":
      return SharedLinkType.iNDIVIDUAL;
  }
  return SharedLinkType.swaggerGeneratedUnknown;
}

enum SourceType {
  swaggerGeneratedUnknown,
  machine_learning,
  exif,
  manual,
}

extension SourceTypeExt on SourceType {
  String get value {
    switch (this) {
      case SourceType.machine_learning:
        return "machine-learning";
      case SourceType.exif:
        return "exif";
      case SourceType.manual:
        return "manual";
      case SourceType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

SourceType _sourceTypeFromJson(String? v) {
  switch (v) {
    case "machine-learning":
      return SourceType.machine_learning;
    case "exif":
      return SourceType.exif;
    case "manual":
      return SourceType.manual;
  }
  return SourceType.swaggerGeneratedUnknown;
}

enum SyncEntityType {
  swaggerGeneratedUnknown,
  authUserV1,
  authUserV2,
  userV1,
  userDeleteV1,
  assetV1,
  assetV2,
  assetDeleteV1,
  assetExifV1,
  assetEditV1,
  assetEditDeleteV1,
  assetMetadataV1,
  assetMetadataDeleteV1,
  assetOcrV1,
  assetOcrDeleteV1,
  partnerV1,
  partnerDeleteV1,
  partnerAssetV1,
  partnerAssetV2,
  partnerAssetBackfillV1,
  partnerAssetBackfillV2,
  partnerAssetDeleteV1,
  partnerAssetExifV1,
  partnerAssetExifBackfillV1,
  partnerStackBackfillV1,
  partnerStackDeleteV1,
  partnerStackV1,
  albumV1,
  albumV2,
  albumDeleteV1,
  albumUserV1,
  albumUserBackfillV1,
  albumUserDeleteV1,
  albumAssetCreateV1,
  albumAssetCreateV2,
  albumAssetUpdateV1,
  albumAssetUpdateV2,
  albumAssetBackfillV1,
  albumAssetBackfillV2,
  albumAssetExifCreateV1,
  albumAssetExifUpdateV1,
  albumAssetExifBackfillV1,
  albumToAssetV1,
  albumToAssetDeleteV1,
  albumToAssetBackfillV1,
  memoryV1,
  memoryDeleteV1,
  memoryToAssetV1,
  memoryToAssetDeleteV1,
  stackV1,
  stackDeleteV1,
  personV1,
  personDeleteV1,
  assetFaceV1,
  assetFaceV2,
  assetFaceV3,
  assetFaceDeleteV1,
  userMetadataV1,
  userMetadataDeleteV1,
  syncAckV1,
  syncResetV1,
  syncCompleteV1,
}

extension SyncEntityTypeExt on SyncEntityType {
  String get value {
    switch (this) {
      case SyncEntityType.authUserV1:
        return "AuthUserV1";
      case SyncEntityType.authUserV2:
        return "AuthUserV2";
      case SyncEntityType.userV1:
        return "UserV1";
      case SyncEntityType.userDeleteV1:
        return "UserDeleteV1";
      case SyncEntityType.assetV1:
        return "AssetV1";
      case SyncEntityType.assetV2:
        return "AssetV2";
      case SyncEntityType.assetDeleteV1:
        return "AssetDeleteV1";
      case SyncEntityType.assetExifV1:
        return "AssetExifV1";
      case SyncEntityType.assetEditV1:
        return "AssetEditV1";
      case SyncEntityType.assetEditDeleteV1:
        return "AssetEditDeleteV1";
      case SyncEntityType.assetMetadataV1:
        return "AssetMetadataV1";
      case SyncEntityType.assetMetadataDeleteV1:
        return "AssetMetadataDeleteV1";
      case SyncEntityType.assetOcrV1:
        return "AssetOcrV1";
      case SyncEntityType.assetOcrDeleteV1:
        return "AssetOcrDeleteV1";
      case SyncEntityType.partnerV1:
        return "PartnerV1";
      case SyncEntityType.partnerDeleteV1:
        return "PartnerDeleteV1";
      case SyncEntityType.partnerAssetV1:
        return "PartnerAssetV1";
      case SyncEntityType.partnerAssetV2:
        return "PartnerAssetV2";
      case SyncEntityType.partnerAssetBackfillV1:
        return "PartnerAssetBackfillV1";
      case SyncEntityType.partnerAssetBackfillV2:
        return "PartnerAssetBackfillV2";
      case SyncEntityType.partnerAssetDeleteV1:
        return "PartnerAssetDeleteV1";
      case SyncEntityType.partnerAssetExifV1:
        return "PartnerAssetExifV1";
      case SyncEntityType.partnerAssetExifBackfillV1:
        return "PartnerAssetExifBackfillV1";
      case SyncEntityType.partnerStackBackfillV1:
        return "PartnerStackBackfillV1";
      case SyncEntityType.partnerStackDeleteV1:
        return "PartnerStackDeleteV1";
      case SyncEntityType.partnerStackV1:
        return "PartnerStackV1";
      case SyncEntityType.albumV1:
        return "AlbumV1";
      case SyncEntityType.albumV2:
        return "AlbumV2";
      case SyncEntityType.albumDeleteV1:
        return "AlbumDeleteV1";
      case SyncEntityType.albumUserV1:
        return "AlbumUserV1";
      case SyncEntityType.albumUserBackfillV1:
        return "AlbumUserBackfillV1";
      case SyncEntityType.albumUserDeleteV1:
        return "AlbumUserDeleteV1";
      case SyncEntityType.albumAssetCreateV1:
        return "AlbumAssetCreateV1";
      case SyncEntityType.albumAssetCreateV2:
        return "AlbumAssetCreateV2";
      case SyncEntityType.albumAssetUpdateV1:
        return "AlbumAssetUpdateV1";
      case SyncEntityType.albumAssetUpdateV2:
        return "AlbumAssetUpdateV2";
      case SyncEntityType.albumAssetBackfillV1:
        return "AlbumAssetBackfillV1";
      case SyncEntityType.albumAssetBackfillV2:
        return "AlbumAssetBackfillV2";
      case SyncEntityType.albumAssetExifCreateV1:
        return "AlbumAssetExifCreateV1";
      case SyncEntityType.albumAssetExifUpdateV1:
        return "AlbumAssetExifUpdateV1";
      case SyncEntityType.albumAssetExifBackfillV1:
        return "AlbumAssetExifBackfillV1";
      case SyncEntityType.albumToAssetV1:
        return "AlbumToAssetV1";
      case SyncEntityType.albumToAssetDeleteV1:
        return "AlbumToAssetDeleteV1";
      case SyncEntityType.albumToAssetBackfillV1:
        return "AlbumToAssetBackfillV1";
      case SyncEntityType.memoryV1:
        return "MemoryV1";
      case SyncEntityType.memoryDeleteV1:
        return "MemoryDeleteV1";
      case SyncEntityType.memoryToAssetV1:
        return "MemoryToAssetV1";
      case SyncEntityType.memoryToAssetDeleteV1:
        return "MemoryToAssetDeleteV1";
      case SyncEntityType.stackV1:
        return "StackV1";
      case SyncEntityType.stackDeleteV1:
        return "StackDeleteV1";
      case SyncEntityType.personV1:
        return "PersonV1";
      case SyncEntityType.personDeleteV1:
        return "PersonDeleteV1";
      case SyncEntityType.assetFaceV1:
        return "AssetFaceV1";
      case SyncEntityType.assetFaceV2:
        return "AssetFaceV2";
      case SyncEntityType.assetFaceV3:
        return "AssetFaceV3";
      case SyncEntityType.assetFaceDeleteV1:
        return "AssetFaceDeleteV1";
      case SyncEntityType.userMetadataV1:
        return "UserMetadataV1";
      case SyncEntityType.userMetadataDeleteV1:
        return "UserMetadataDeleteV1";
      case SyncEntityType.syncAckV1:
        return "SyncAckV1";
      case SyncEntityType.syncResetV1:
        return "SyncResetV1";
      case SyncEntityType.syncCompleteV1:
        return "SyncCompleteV1";
      case SyncEntityType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

SyncEntityType _syncEntityTypeFromJson(String? v) {
  switch (v) {
    case "AuthUserV1":
      return SyncEntityType.authUserV1;
    case "AuthUserV2":
      return SyncEntityType.authUserV2;
    case "UserV1":
      return SyncEntityType.userV1;
    case "UserDeleteV1":
      return SyncEntityType.userDeleteV1;
    case "AssetV1":
      return SyncEntityType.assetV1;
    case "AssetV2":
      return SyncEntityType.assetV2;
    case "AssetDeleteV1":
      return SyncEntityType.assetDeleteV1;
    case "AssetExifV1":
      return SyncEntityType.assetExifV1;
    case "AssetEditV1":
      return SyncEntityType.assetEditV1;
    case "AssetEditDeleteV1":
      return SyncEntityType.assetEditDeleteV1;
    case "AssetMetadataV1":
      return SyncEntityType.assetMetadataV1;
    case "AssetMetadataDeleteV1":
      return SyncEntityType.assetMetadataDeleteV1;
    case "AssetOcrV1":
      return SyncEntityType.assetOcrV1;
    case "AssetOcrDeleteV1":
      return SyncEntityType.assetOcrDeleteV1;
    case "PartnerV1":
      return SyncEntityType.partnerV1;
    case "PartnerDeleteV1":
      return SyncEntityType.partnerDeleteV1;
    case "PartnerAssetV1":
      return SyncEntityType.partnerAssetV1;
    case "PartnerAssetV2":
      return SyncEntityType.partnerAssetV2;
    case "PartnerAssetBackfillV1":
      return SyncEntityType.partnerAssetBackfillV1;
    case "PartnerAssetBackfillV2":
      return SyncEntityType.partnerAssetBackfillV2;
    case "PartnerAssetDeleteV1":
      return SyncEntityType.partnerAssetDeleteV1;
    case "PartnerAssetExifV1":
      return SyncEntityType.partnerAssetExifV1;
    case "PartnerAssetExifBackfillV1":
      return SyncEntityType.partnerAssetExifBackfillV1;
    case "PartnerStackBackfillV1":
      return SyncEntityType.partnerStackBackfillV1;
    case "PartnerStackDeleteV1":
      return SyncEntityType.partnerStackDeleteV1;
    case "PartnerStackV1":
      return SyncEntityType.partnerStackV1;
    case "AlbumV1":
      return SyncEntityType.albumV1;
    case "AlbumV2":
      return SyncEntityType.albumV2;
    case "AlbumDeleteV1":
      return SyncEntityType.albumDeleteV1;
    case "AlbumUserV1":
      return SyncEntityType.albumUserV1;
    case "AlbumUserBackfillV1":
      return SyncEntityType.albumUserBackfillV1;
    case "AlbumUserDeleteV1":
      return SyncEntityType.albumUserDeleteV1;
    case "AlbumAssetCreateV1":
      return SyncEntityType.albumAssetCreateV1;
    case "AlbumAssetCreateV2":
      return SyncEntityType.albumAssetCreateV2;
    case "AlbumAssetUpdateV1":
      return SyncEntityType.albumAssetUpdateV1;
    case "AlbumAssetUpdateV2":
      return SyncEntityType.albumAssetUpdateV2;
    case "AlbumAssetBackfillV1":
      return SyncEntityType.albumAssetBackfillV1;
    case "AlbumAssetBackfillV2":
      return SyncEntityType.albumAssetBackfillV2;
    case "AlbumAssetExifCreateV1":
      return SyncEntityType.albumAssetExifCreateV1;
    case "AlbumAssetExifUpdateV1":
      return SyncEntityType.albumAssetExifUpdateV1;
    case "AlbumAssetExifBackfillV1":
      return SyncEntityType.albumAssetExifBackfillV1;
    case "AlbumToAssetV1":
      return SyncEntityType.albumToAssetV1;
    case "AlbumToAssetDeleteV1":
      return SyncEntityType.albumToAssetDeleteV1;
    case "AlbumToAssetBackfillV1":
      return SyncEntityType.albumToAssetBackfillV1;
    case "MemoryV1":
      return SyncEntityType.memoryV1;
    case "MemoryDeleteV1":
      return SyncEntityType.memoryDeleteV1;
    case "MemoryToAssetV1":
      return SyncEntityType.memoryToAssetV1;
    case "MemoryToAssetDeleteV1":
      return SyncEntityType.memoryToAssetDeleteV1;
    case "StackV1":
      return SyncEntityType.stackV1;
    case "StackDeleteV1":
      return SyncEntityType.stackDeleteV1;
    case "PersonV1":
      return SyncEntityType.personV1;
    case "PersonDeleteV1":
      return SyncEntityType.personDeleteV1;
    case "AssetFaceV1":
      return SyncEntityType.assetFaceV1;
    case "AssetFaceV2":
      return SyncEntityType.assetFaceV2;
    case "AssetFaceV3":
      return SyncEntityType.assetFaceV3;
    case "AssetFaceDeleteV1":
      return SyncEntityType.assetFaceDeleteV1;
    case "UserMetadataV1":
      return SyncEntityType.userMetadataV1;
    case "UserMetadataDeleteV1":
      return SyncEntityType.userMetadataDeleteV1;
    case "SyncAckV1":
      return SyncEntityType.syncAckV1;
    case "SyncResetV1":
      return SyncEntityType.syncResetV1;
    case "SyncCompleteV1":
      return SyncEntityType.syncCompleteV1;
  }
  return SyncEntityType.swaggerGeneratedUnknown;
}

enum SyncRequestType {
  swaggerGeneratedUnknown,
  albumsV1,
  albumsV2,
  albumUsersV1,
  albumToAssetsV1,
  albumAssetsV1,
  albumAssetsV2,
  albumAssetExifsV1,
  assetsV1,
  assetsV2,
  assetExifsV1,
  assetEditsV1,
  assetMetadataV1,
  assetOcrV1,
  authUsersV1,
  authUsersV2,
  memoriesV1,
  memoryToAssetsV1,
  partnersV1,
  partnerAssetsV1,
  partnerAssetsV2,
  partnerAssetExifsV1,
  partnerStacksV1,
  stacksV1,
  usersV1,
  peopleV1,
  assetFacesV1,
  assetFacesV2,
  assetFacesV3,
  userMetadataV1,
}

extension SyncRequestTypeExt on SyncRequestType {
  String get value {
    switch (this) {
      case SyncRequestType.albumsV1:
        return "AlbumsV1";
      case SyncRequestType.albumsV2:
        return "AlbumsV2";
      case SyncRequestType.albumUsersV1:
        return "AlbumUsersV1";
      case SyncRequestType.albumToAssetsV1:
        return "AlbumToAssetsV1";
      case SyncRequestType.albumAssetsV1:
        return "AlbumAssetsV1";
      case SyncRequestType.albumAssetsV2:
        return "AlbumAssetsV2";
      case SyncRequestType.albumAssetExifsV1:
        return "AlbumAssetExifsV1";
      case SyncRequestType.assetsV1:
        return "AssetsV1";
      case SyncRequestType.assetsV2:
        return "AssetsV2";
      case SyncRequestType.assetExifsV1:
        return "AssetExifsV1";
      case SyncRequestType.assetEditsV1:
        return "AssetEditsV1";
      case SyncRequestType.assetMetadataV1:
        return "AssetMetadataV1";
      case SyncRequestType.assetOcrV1:
        return "AssetOcrV1";
      case SyncRequestType.authUsersV1:
        return "AuthUsersV1";
      case SyncRequestType.authUsersV2:
        return "AuthUsersV2";
      case SyncRequestType.memoriesV1:
        return "MemoriesV1";
      case SyncRequestType.memoryToAssetsV1:
        return "MemoryToAssetsV1";
      case SyncRequestType.partnersV1:
        return "PartnersV1";
      case SyncRequestType.partnerAssetsV1:
        return "PartnerAssetsV1";
      case SyncRequestType.partnerAssetsV2:
        return "PartnerAssetsV2";
      case SyncRequestType.partnerAssetExifsV1:
        return "PartnerAssetExifsV1";
      case SyncRequestType.partnerStacksV1:
        return "PartnerStacksV1";
      case SyncRequestType.stacksV1:
        return "StacksV1";
      case SyncRequestType.usersV1:
        return "UsersV1";
      case SyncRequestType.peopleV1:
        return "PeopleV1";
      case SyncRequestType.assetFacesV1:
        return "AssetFacesV1";
      case SyncRequestType.assetFacesV2:
        return "AssetFacesV2";
      case SyncRequestType.assetFacesV3:
        return "AssetFacesV3";
      case SyncRequestType.userMetadataV1:
        return "UserMetadataV1";
      case SyncRequestType.swaggerGeneratedUnknown:
        return '';
    }
  }

}

SyncRequestType _syncRequestTypeFromJson(String? v) {
  switch (v) {
    case "AlbumsV1":
      return SyncRequestType.albumsV1;
    case "AlbumsV2":
      return SyncRequestType.albumsV2;
    case "AlbumUsersV1":
      return SyncRequestType.albumUsersV1;
    case "AlbumToAssetsV1":
      return SyncRequestType.albumToAssetsV1;
    case "AlbumAssetsV1":
      return SyncRequestType.albumAssetsV1;
    case "AlbumAssetsV2":
      return SyncRequestType.albumAssetsV2;
    case "AlbumAssetExifsV1":
      return SyncRequestType.albumAssetExifsV1;
    case "AssetsV1":
      return SyncRequestType.assetsV1;
    case "AssetsV2":
      return SyncRequestType.assetsV2;
    case "AssetExifsV1":
      return SyncRequestType.assetExifsV1;
    case "AssetEditsV1":
      return SyncRequestType.assetEditsV1;
    case "AssetMetadataV1":
      return SyncRequestType.assetMetadataV1;
    case "AssetOcrV1":
      return SyncRequestType.assetOcrV1;
    case "AuthUsersV1":
      return SyncRequestType.authUsersV1;
    case "AuthUsersV2":
      return SyncRequestType.authUsersV2;
    case "MemoriesV1":
      return SyncRequestType.memoriesV1;
    case "MemoryToAssetsV1":
      return SyncRequestType.memoryToAssetsV1;
    case "PartnersV1":
      return SyncRequestType.partnersV1;
    case "PartnerAssetsV1":
      return SyncRequestType.partnerAssetsV1;
    case "PartnerAssetsV2":
      return SyncRequestType.partnerAssetsV2;
    case "PartnerAssetExifsV1":
      return SyncRequestType.partnerAssetExifsV1;
    case "PartnerStacksV1":
      return SyncRequestType.partnerStacksV1;
    case "StacksV1":
      return SyncRequestType.stacksV1;
    case "UsersV1":
      return SyncRequestType.usersV1;
    case "PeopleV1":
      return SyncRequestType.peopleV1;
    case "AssetFacesV1":
      return SyncRequestType.assetFacesV1;
    case "AssetFacesV2":
      return SyncRequestType.assetFacesV2;
    case "AssetFacesV3":
      return SyncRequestType.assetFacesV3;
    case "UserMetadataV1":
      return SyncRequestType.userMetadataV1;
  }
  return SyncRequestType.swaggerGeneratedUnknown;
}

enum UserAvatarColor {
  swaggerGeneratedUnknown,
  primary,
  pink,
  red,
  yellow,
  blue,
  green,
  purple,
  orange,
  gray,
  amber,
}

extension UserAvatarColorExt on UserAvatarColor {
  String get value {
    switch (this) {
      case UserAvatarColor.primary:
        return "primary";
      case UserAvatarColor.pink:
        return "pink";
      case UserAvatarColor.red:
        return "red";
      case UserAvatarColor.yellow:
        return "yellow";
      case UserAvatarColor.blue:
        return "blue";
      case UserAvatarColor.green:
        return "green";
      case UserAvatarColor.purple:
        return "purple";
      case UserAvatarColor.orange:
        return "orange";
      case UserAvatarColor.gray:
        return "gray";
      case UserAvatarColor.amber:
        return "amber";
      case UserAvatarColor.swaggerGeneratedUnknown:
        return '';
    }
  }

}

UserAvatarColor _userAvatarColorFromJson(String? v) {
  switch (v) {
    case "primary":
      return UserAvatarColor.primary;
    case "pink":
      return UserAvatarColor.pink;
    case "red":
      return UserAvatarColor.red;
    case "yellow":
      return UserAvatarColor.yellow;
    case "blue":
      return UserAvatarColor.blue;
    case "green":
      return UserAvatarColor.green;
    case "purple":
      return UserAvatarColor.purple;
    case "orange":
      return UserAvatarColor.orange;
    case "gray":
      return UserAvatarColor.gray;
    case "amber":
      return UserAvatarColor.amber;
  }
  return UserAvatarColor.swaggerGeneratedUnknown;
}

enum UserStatus {
  swaggerGeneratedUnknown,
  active,
  removing,
  deleted,
}

extension UserStatusExt on UserStatus {
  String get value {
    switch (this) {
      case UserStatus.active:
        return "active";
      case UserStatus.removing:
        return "removing";
      case UserStatus.deleted:
        return "deleted";
      case UserStatus.swaggerGeneratedUnknown:
        return '';
    }
  }

}

UserStatus _userStatusFromJson(String? v) {
  switch (v) {
    case "active":
      return UserStatus.active;
    case "removing":
      return UserStatus.removing;
    case "deleted":
      return UserStatus.deleted;
  }
  return UserStatus.swaggerGeneratedUnknown;
}

enum VideoCodec {
  swaggerGeneratedUnknown,
  h264,
  hevc,
  vp9,
  av1,
}

extension VideoCodecExt on VideoCodec {
  String get value {
    switch (this) {
      case VideoCodec.h264:
        return "h264";
      case VideoCodec.hevc:
        return "hevc";
      case VideoCodec.vp9:
        return "vp9";
      case VideoCodec.av1:
        return "av1";
      case VideoCodec.swaggerGeneratedUnknown:
        return '';
    }
  }

}

VideoCodec _videoCodecFromJson(String? v) {
  switch (v) {
    case "h264":
      return VideoCodec.h264;
    case "hevc":
      return VideoCodec.hevc;
    case "vp9":
      return VideoCodec.vp9;
    case "av1":
      return VideoCodec.av1;
  }
  return VideoCodec.swaggerGeneratedUnknown;
}

/// Alias for [UserLicense].
typedef LicenseResponseDto = UserLicense;

class ActivityCreateDto {
  final String? albumId;
  final String? assetId;
  final String? comment;
  final ReactionType? type;

  const ActivityCreateDto({
    this.albumId,
    this.assetId,
    this.comment,
    this.type,
  });

  factory ActivityCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActivityCreateDto();
    return ActivityCreateDto(
      albumId: json["albumId"]?.toString(),
      assetId: json["assetId"]?.toString(),
      comment: json["comment"]?.toString(),
      type: _reactionTypeFromJson(json["type"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumId != null) "albumId": albumId,
    if (assetId != null) "assetId": assetId,
    if (comment != null) "comment": comment,
    if (type != null) "type": type?.value,
  };

  ActivityCreateDto copyWith({
    String? albumId,
    String? assetId,
    String? comment,
    ReactionType? type,
  }) {
    return ActivityCreateDto(
      albumId: albumId ?? this.albumId,
      assetId: assetId ?? this.assetId,
      comment: comment ?? this.comment,
      type: type ?? this.type,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ActivityResponseDto {
  final String? assetId;
  final String? comment;
  final String? createdAt;
  final String? id;
  final ReactionType? type;
  final UserResponseDto? user;

  const ActivityResponseDto({
    this.assetId,
    this.comment,
    this.createdAt,
    this.id,
    this.type,
    this.user,
  });

  factory ActivityResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActivityResponseDto();
    return ActivityResponseDto(
      assetId: json["assetId"]?.toString(),
      comment: json["comment"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      id: json["id"]?.toString(),
      type: _reactionTypeFromJson(json["type"]?.toString()),
      user: UserResponseDto.fromJson((json["user"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (comment != null) "comment": comment,
    if (createdAt != null) "createdAt": createdAt,
    if (id != null) "id": id,
    if (type != null) "type": type?.value,
    if (user != null) "user": user?.toJson(),
  };

  ActivityResponseDto copyWith({
    String? assetId,
    String? comment,
    String? createdAt,
    String? id,
    ReactionType? type,
    UserResponseDto? user,
  }) {
    return ActivityResponseDto(
      assetId: assetId ?? this.assetId,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      type: type ?? this.type,
      user: user ?? this.user,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ActivityStatisticsResponseDto {
  final int? comments;
  final int? likes;

  const ActivityStatisticsResponseDto({
    this.comments,
    this.likes,
  });

  factory ActivityStatisticsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ActivityStatisticsResponseDto();
    return ActivityStatisticsResponseDto(
      comments: (json["comments"] as num?)?.toInt(),
      likes: (json["likes"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (comments != null) "comments": comments,
    if (likes != null) "likes": likes,
  };

  ActivityStatisticsResponseDto copyWith({
    int? comments,
    int? likes,
  }) {
    return ActivityStatisticsResponseDto(
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AddUsersDto {
  final List<AlbumUserAddDto>? albumUsers;

  const AddUsersDto({
    this.albumUsers,
  });

  factory AddUsersDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AddUsersDto();
    return AddUsersDto(
      albumUsers: ((json["albumUsers"] as List<dynamic>?)?.map((e) => AlbumUserAddDto.fromJson((e as Map<String, dynamic>?))).whereType<AlbumUserAddDto>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumUsers != null) "albumUsers": albumUsers?.map((e) => e?.toJson()).toList(),
  };

  AddUsersDto copyWith({
    List<AlbumUserAddDto>? albumUsers,
  }) {
    return AddUsersDto(
      albumUsers: albumUsers ?? this.albumUsers,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumResponseDto {
  final String? albumName;
  final String? albumThumbnailAssetId;
  final List<AlbumUserResponseDto>? albumUsers;
  final int? assetCount;
  final List<ContributorCountResponseDto>? contributorCounts;
  final String? createdAt;
  final String? description;
  final String? endDate;
  final bool? hasSharedLink;
  final String? id;
  final bool? isActivityEnabled;
  final String? lastModifiedAssetTimestamp;
  final AssetOrder? order;
  final bool? shared;
  final String? startDate;
  final String? updatedAt;

  const AlbumResponseDto({
    this.albumName,
    this.albumThumbnailAssetId,
    this.albumUsers,
    this.assetCount,
    this.contributorCounts,
    this.createdAt,
    this.description,
    this.endDate,
    this.hasSharedLink,
    this.id,
    this.isActivityEnabled,
    this.lastModifiedAssetTimestamp,
    this.order,
    this.shared,
    this.startDate,
    this.updatedAt,
  });

  factory AlbumResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumResponseDto();
    return AlbumResponseDto(
      albumName: json["albumName"]?.toString(),
      albumThumbnailAssetId: json["albumThumbnailAssetId"]?.toString(),
      albumUsers: ((json["albumUsers"] as List<dynamic>?)?.map((e) => AlbumUserResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AlbumUserResponseDto>().toList()),
      assetCount: (json["assetCount"] as num?)?.toInt(),
      contributorCounts: ((json["contributorCounts"] as List<dynamic>?)?.map((e) => ContributorCountResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<ContributorCountResponseDto>().toList()),
      createdAt: json["createdAt"]?.toString(),
      description: json["description"]?.toString(),
      endDate: json["endDate"]?.toString(),
      hasSharedLink: (json["hasSharedLink"] as bool?),
      id: json["id"]?.toString(),
      isActivityEnabled: (json["isActivityEnabled"] as bool?),
      lastModifiedAssetTimestamp: json["lastModifiedAssetTimestamp"]?.toString(),
      order: _assetOrderFromJson(json["order"]?.toString()),
      shared: (json["shared"] as bool?),
      startDate: json["startDate"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumName != null) "albumName": albumName,
    if (albumThumbnailAssetId != null) "albumThumbnailAssetId": albumThumbnailAssetId,
    if (albumUsers != null) "albumUsers": albumUsers?.map((e) => e?.toJson()).toList(),
    if (assetCount != null) "assetCount": assetCount,
    if (contributorCounts != null) "contributorCounts": contributorCounts?.map((e) => e?.toJson()).toList(),
    if (createdAt != null) "createdAt": createdAt,
    if (description != null) "description": description,
    if (endDate != null) "endDate": endDate,
    if (hasSharedLink != null) "hasSharedLink": hasSharedLink,
    if (id != null) "id": id,
    if (isActivityEnabled != null) "isActivityEnabled": isActivityEnabled,
    if (lastModifiedAssetTimestamp != null) "lastModifiedAssetTimestamp": lastModifiedAssetTimestamp,
    if (order != null) "order": order?.value,
    if (shared != null) "shared": shared,
    if (startDate != null) "startDate": startDate,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  AlbumResponseDto copyWith({
    String? albumName,
    String? albumThumbnailAssetId,
    List<AlbumUserResponseDto>? albumUsers,
    int? assetCount,
    List<ContributorCountResponseDto>? contributorCounts,
    String? createdAt,
    String? description,
    String? endDate,
    bool? hasSharedLink,
    String? id,
    bool? isActivityEnabled,
    String? lastModifiedAssetTimestamp,
    AssetOrder? order,
    bool? shared,
    String? startDate,
    String? updatedAt,
  }) {
    return AlbumResponseDto(
      albumName: albumName ?? this.albumName,
      albumThumbnailAssetId: albumThumbnailAssetId ?? this.albumThumbnailAssetId,
      albumUsers: albumUsers ?? this.albumUsers,
      assetCount: assetCount ?? this.assetCount,
      contributorCounts: contributorCounts ?? this.contributorCounts,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      endDate: endDate ?? this.endDate,
      hasSharedLink: hasSharedLink ?? this.hasSharedLink,
      id: id ?? this.id,
      isActivityEnabled: isActivityEnabled ?? this.isActivityEnabled,
      lastModifiedAssetTimestamp: lastModifiedAssetTimestamp ?? this.lastModifiedAssetTimestamp,
      order: order ?? this.order,
      shared: shared ?? this.shared,
      startDate: startDate ?? this.startDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumStatisticsResponseDto {
  final int? notShared;
  final int? owned;
  final int? shared;

  const AlbumStatisticsResponseDto({
    this.notShared,
    this.owned,
    this.shared,
  });

  factory AlbumStatisticsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumStatisticsResponseDto();
    return AlbumStatisticsResponseDto(
      notShared: (json["notShared"] as num?)?.toInt(),
      owned: (json["owned"] as num?)?.toInt(),
      shared: (json["shared"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (notShared != null) "notShared": notShared,
    if (owned != null) "owned": owned,
    if (shared != null) "shared": shared,
  };

  AlbumStatisticsResponseDto copyWith({
    int? notShared,
    int? owned,
    int? shared,
  }) {
    return AlbumStatisticsResponseDto(
      notShared: notShared ?? this.notShared,
      owned: owned ?? this.owned,
      shared: shared ?? this.shared,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumUserAddDto {
  final AlbumUserRole? role;
  final String? userId;

  const AlbumUserAddDto({
    this.role,
    this.userId,
  });

  factory AlbumUserAddDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumUserAddDto();
    return AlbumUserAddDto(
      role: _albumUserRoleFromJson(json["role"]?.toString()),
      userId: json["userId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (role != null) "role": role?.value,
    if (userId != null) "userId": userId,
  };

  AlbumUserAddDto copyWith({
    AlbumUserRole? role,
    String? userId,
  }) {
    return AlbumUserAddDto(
      role: role ?? this.role,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumUserCreateDto {
  final AlbumUserRole? role;
  final String? userId;

  const AlbumUserCreateDto({
    this.role,
    this.userId,
  });

  factory AlbumUserCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumUserCreateDto();
    return AlbumUserCreateDto(
      role: _albumUserRoleFromJson(json["role"]?.toString()),
      userId: json["userId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (role != null) "role": role?.value,
    if (userId != null) "userId": userId,
  };

  AlbumUserCreateDto copyWith({
    AlbumUserRole? role,
    String? userId,
  }) {
    return AlbumUserCreateDto(
      role: role ?? this.role,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumUserResponseDto {
  final AlbumUserRole? role;
  final UserResponseDto? user;

  const AlbumUserResponseDto({
    this.role,
    this.user,
  });

  factory AlbumUserResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumUserResponseDto();
    return AlbumUserResponseDto(
      role: _albumUserRoleFromJson(json["role"]?.toString()),
      user: UserResponseDto.fromJson((json["user"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (role != null) "role": role?.value,
    if (user != null) "user": user?.toJson(),
  };

  AlbumUserResponseDto copyWith({
    AlbumUserRole? role,
    UserResponseDto? user,
  }) {
    return AlbumUserResponseDto(
      role: role ?? this.role,
      user: user ?? this.user,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumsAddAssetsDto {
  final List<String>? albumIds;
  final List<String>? assetIds;

  const AlbumsAddAssetsDto({
    this.albumIds,
    this.assetIds,
  });

  factory AlbumsAddAssetsDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumsAddAssetsDto();
    return AlbumsAddAssetsDto(
      albumIds: ((json["albumIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumIds != null) "albumIds": albumIds,
    if (assetIds != null) "assetIds": assetIds,
  };

  AlbumsAddAssetsDto copyWith({
    List<String>? albumIds,
    List<String>? assetIds,
  }) {
    return AlbumsAddAssetsDto(
      albumIds: albumIds ?? this.albumIds,
      assetIds: assetIds ?? this.assetIds,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumsAddAssetsResponseDto {
  final BulkIdErrorReason? error;
  final bool? success;

  const AlbumsAddAssetsResponseDto({
    this.error,
    this.success,
  });

  factory AlbumsAddAssetsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumsAddAssetsResponseDto();
    return AlbumsAddAssetsResponseDto(
      error: _bulkIdErrorReasonFromJson(json["error"]?.toString()),
      success: (json["success"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (error != null) "error": error?.value,
    if (success != null) "success": success,
  };

  AlbumsAddAssetsResponseDto copyWith({
    BulkIdErrorReason? error,
    bool? success,
  }) {
    return AlbumsAddAssetsResponseDto(
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumsResponse {
  final AssetOrder? defaultAssetOrder;

  const AlbumsResponse({
    this.defaultAssetOrder,
  });

  factory AlbumsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumsResponse();
    return AlbumsResponse(
      defaultAssetOrder: _assetOrderFromJson(json["defaultAssetOrder"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (defaultAssetOrder != null) "defaultAssetOrder": defaultAssetOrder?.value,
  };

  AlbumsResponse copyWith({
    AssetOrder? defaultAssetOrder,
  }) {
    return AlbumsResponse(
      defaultAssetOrder: defaultAssetOrder ?? this.defaultAssetOrder,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AlbumsUpdate {
  final AssetOrder? defaultAssetOrder;

  const AlbumsUpdate({
    this.defaultAssetOrder,
  });

  factory AlbumsUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AlbumsUpdate();
    return AlbumsUpdate(
      defaultAssetOrder: _assetOrderFromJson(json["defaultAssetOrder"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (defaultAssetOrder != null) "defaultAssetOrder": defaultAssetOrder?.value,
  };

  AlbumsUpdate copyWith({
    AssetOrder? defaultAssetOrder,
  }) {
    return AlbumsUpdate(
      defaultAssetOrder: defaultAssetOrder ?? this.defaultAssetOrder,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ApiKeyCreateDto {
  final String? name;
  final List<Permission>? permissions;

  const ApiKeyCreateDto({
    this.name,
    this.permissions,
  });

  factory ApiKeyCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiKeyCreateDto();
    return ApiKeyCreateDto(
      name: json["name"]?.toString(),
      permissions: ((json["permissions"] as List<dynamic>?)?.map((e) => _permissionFromJson(e?.toString())).whereType<Permission>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) "name": name,
    if (permissions != null) "permissions": permissions?.map((e) => e?.value).toList(),
  };

  ApiKeyCreateDto copyWith({
    String? name,
    List<Permission>? permissions,
  }) {
    return ApiKeyCreateDto(
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ApiKeyCreateResponseDto {
  final ApiKeyResponseDto? apiKey;
  final String? createdAt;
  final String? id;
  final String? name;
  final List<Permission>? permissions;
  final String? secret;
  final String? updatedAt;

  const ApiKeyCreateResponseDto({
    this.apiKey,
    this.createdAt,
    this.id,
    this.name,
    this.permissions,
    this.secret,
    this.updatedAt,
  });

  factory ApiKeyCreateResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiKeyCreateResponseDto();
    return ApiKeyCreateResponseDto(
      apiKey: ApiKeyResponseDto.fromJson((json["apiKey"] as Map<String, dynamic>?)),
      createdAt: json["createdAt"]?.toString(),
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      permissions: ((json["permissions"] as List<dynamic>?)?.map((e) => _permissionFromJson(e?.toString())).whereType<Permission>().toList()),
      secret: json["secret"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (apiKey != null) "apiKey": apiKey?.toJson(),
    if (createdAt != null) "createdAt": createdAt,
    if (id != null) "id": id,
    if (name != null) "name": name,
    if (permissions != null) "permissions": permissions?.map((e) => e?.value).toList(),
    if (secret != null) "secret": secret,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  ApiKeyCreateResponseDto copyWith({
    ApiKeyResponseDto? apiKey,
    String? createdAt,
    String? id,
    String? name,
    List<Permission>? permissions,
    String? secret,
    String? updatedAt,
  }) {
    return ApiKeyCreateResponseDto(
      apiKey: apiKey ?? this.apiKey,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      secret: secret ?? this.secret,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ApiKeyResponseDto {
  final String? createdAt;
  final String? id;
  final String? name;
  final List<Permission>? permissions;
  final String? updatedAt;

  const ApiKeyResponseDto({
    this.createdAt,
    this.id,
    this.name,
    this.permissions,
    this.updatedAt,
  });

  factory ApiKeyResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiKeyResponseDto();
    return ApiKeyResponseDto(
      createdAt: json["createdAt"]?.toString(),
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      permissions: ((json["permissions"] as List<dynamic>?)?.map((e) => _permissionFromJson(e?.toString())).whereType<Permission>().toList()),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (createdAt != null) "createdAt": createdAt,
    if (id != null) "id": id,
    if (name != null) "name": name,
    if (permissions != null) "permissions": permissions?.map((e) => e?.value).toList(),
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  ApiKeyResponseDto copyWith({
    String? createdAt,
    String? id,
    String? name,
    List<Permission>? permissions,
    String? updatedAt,
  }) {
    return ApiKeyResponseDto(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ApiKeyUpdateDto {
  final String? name;
  final List<Permission>? permissions;

  const ApiKeyUpdateDto({
    this.name,
    this.permissions,
  });

  factory ApiKeyUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiKeyUpdateDto();
    return ApiKeyUpdateDto(
      name: json["name"]?.toString(),
      permissions: ((json["permissions"] as List<dynamic>?)?.map((e) => _permissionFromJson(e?.toString())).whereType<Permission>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) "name": name,
    if (permissions != null) "permissions": permissions?.map((e) => e?.value).toList(),
  };

  ApiKeyUpdateDto copyWith({
    String? name,
    List<Permission>? permissions,
  }) {
    return ApiKeyUpdateDto(
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetBulkDeleteDto {
  final bool? force;
  final List<String>? ids;

  const AssetBulkDeleteDto({
    this.force,
    this.ids,
  });

  factory AssetBulkDeleteDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetBulkDeleteDto();
    return AssetBulkDeleteDto(
      force: (json["force"] as bool?),
      ids: ((json["ids"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (force != null) "force": force,
    if (ids != null) "ids": ids,
  };

  AssetBulkDeleteDto copyWith({
    bool? force,
    List<String>? ids,
  }) {
    return AssetBulkDeleteDto(
      force: force ?? this.force,
      ids: ids ?? this.ids,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetBulkUpdateDto {
  final String? dateTimeOriginal;
  final int? dateTimeRelative;
  final String? description;
  final String? duplicateId;
  final List<String>? ids;
  final bool? isFavorite;
  final double? latitude;
  final double? longitude;
  final int? rating;
  final String? timeZone;
  final AssetVisibility? visibility;

  const AssetBulkUpdateDto({
    this.dateTimeOriginal,
    this.dateTimeRelative,
    this.description,
    this.duplicateId,
    this.ids,
    this.isFavorite,
    this.latitude,
    this.longitude,
    this.rating,
    this.timeZone,
    this.visibility,
  });

  factory AssetBulkUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetBulkUpdateDto();
    return AssetBulkUpdateDto(
      dateTimeOriginal: json["dateTimeOriginal"]?.toString(),
      dateTimeRelative: (json["dateTimeRelative"] as num?)?.toInt(),
      description: json["description"]?.toString(),
      duplicateId: json["duplicateId"]?.toString(),
      ids: ((json["ids"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      isFavorite: (json["isFavorite"] as bool?),
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      rating: (json["rating"] as num?)?.toInt(),
      timeZone: json["timeZone"]?.toString(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (dateTimeOriginal != null) "dateTimeOriginal": dateTimeOriginal,
    if (dateTimeRelative != null) "dateTimeRelative": dateTimeRelative,
    if (description != null) "description": description,
    if (duplicateId != null) "duplicateId": duplicateId,
    if (ids != null) "ids": ids,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (latitude != null) "latitude": latitude,
    if (longitude != null) "longitude": longitude,
    if (rating != null) "rating": rating,
    if (timeZone != null) "timeZone": timeZone,
    if (visibility != null) "visibility": visibility?.value,
  };

  AssetBulkUpdateDto copyWith({
    String? dateTimeOriginal,
    int? dateTimeRelative,
    String? description,
    String? duplicateId,
    List<String>? ids,
    bool? isFavorite,
    double? latitude,
    double? longitude,
    int? rating,
    String? timeZone,
    AssetVisibility? visibility,
  }) {
    return AssetBulkUpdateDto(
      dateTimeOriginal: dateTimeOriginal ?? this.dateTimeOriginal,
      dateTimeRelative: dateTimeRelative ?? this.dateTimeRelative,
      description: description ?? this.description,
      duplicateId: duplicateId ?? this.duplicateId,
      ids: ids ?? this.ids,
      isFavorite: isFavorite ?? this.isFavorite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      timeZone: timeZone ?? this.timeZone,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetBulkUploadCheckDto {
  final List<AssetBulkUploadCheckItem>? assets;

  const AssetBulkUploadCheckDto({
    this.assets,
  });

  factory AssetBulkUploadCheckDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetBulkUploadCheckDto();
    return AssetBulkUploadCheckDto(
      assets: ((json["assets"] as List<dynamic>?)?.map((e) => AssetBulkUploadCheckItem.fromJson((e as Map<String, dynamic>?))).whereType<AssetBulkUploadCheckItem>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assets != null) "assets": assets?.map((e) => e?.toJson()).toList(),
  };

  AssetBulkUploadCheckDto copyWith({
    List<AssetBulkUploadCheckItem>? assets,
  }) {
    return AssetBulkUploadCheckDto(
      assets: assets ?? this.assets,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetBulkUploadCheckItem {
  final String? checksum;
  final String? id;

  const AssetBulkUploadCheckItem({
    this.checksum,
    this.id,
  });

  factory AssetBulkUploadCheckItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetBulkUploadCheckItem();
    return AssetBulkUploadCheckItem(
      checksum: json["checksum"]?.toString(),
      id: json["id"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (checksum != null) "checksum": checksum,
    if (id != null) "id": id,
  };

  AssetBulkUploadCheckItem copyWith({
    String? checksum,
    String? id,
  }) {
    return AssetBulkUploadCheckItem(
      checksum: checksum ?? this.checksum,
      id: id ?? this.id,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetBulkUploadCheckResponseDto {
  final List<AssetBulkUploadCheckResult>? results;

  const AssetBulkUploadCheckResponseDto({
    this.results,
  });

  factory AssetBulkUploadCheckResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetBulkUploadCheckResponseDto();
    return AssetBulkUploadCheckResponseDto(
      results: ((json["results"] as List<dynamic>?)?.map((e) => AssetBulkUploadCheckResult.fromJson((e as Map<String, dynamic>?))).whereType<AssetBulkUploadCheckResult>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (results != null) "results": results?.map((e) => e?.toJson()).toList(),
  };

  AssetBulkUploadCheckResponseDto copyWith({
    List<AssetBulkUploadCheckResult>? results,
  }) {
    return AssetBulkUploadCheckResponseDto(
      results: results ?? this.results,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetBulkUploadCheckResult {
  final AssetUploadAction? action;
  final String? assetId;
  final String? id;
  final bool? isTrashed;
  final AssetRejectReason? reason;

  const AssetBulkUploadCheckResult({
    this.action,
    this.assetId,
    this.id,
    this.isTrashed,
    this.reason,
  });

  factory AssetBulkUploadCheckResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetBulkUploadCheckResult();
    return AssetBulkUploadCheckResult(
      action: _assetUploadActionFromJson(json["action"]?.toString()),
      assetId: json["assetId"]?.toString(),
      id: json["id"]?.toString(),
      isTrashed: (json["isTrashed"] as bool?),
      reason: _assetRejectReasonFromJson(json["reason"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (action != null) "action": action?.value,
    if (assetId != null) "assetId": assetId,
    if (id != null) "id": id,
    if (isTrashed != null) "isTrashed": isTrashed,
    if (reason != null) "reason": reason?.value,
  };

  AssetBulkUploadCheckResult copyWith({
    AssetUploadAction? action,
    String? assetId,
    String? id,
    bool? isTrashed,
    AssetRejectReason? reason,
  }) {
    return AssetBulkUploadCheckResult(
      action: action ?? this.action,
      assetId: assetId ?? this.assetId,
      id: id ?? this.id,
      isTrashed: isTrashed ?? this.isTrashed,
      reason: reason ?? this.reason,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetCopyDto {
  final bool? albums;
  final bool? favorite;
  final bool? sharedLinks;
  final bool? sidecar;
  final String? sourceId;
  final bool? stack;
  final String? targetId;

  const AssetCopyDto({
    this.albums,
    this.favorite,
    this.sharedLinks,
    this.sidecar,
    this.sourceId,
    this.stack,
    this.targetId,
  });

  factory AssetCopyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetCopyDto();
    return AssetCopyDto(
      albums: (json["albums"] as bool?),
      favorite: (json["favorite"] as bool?),
      sharedLinks: (json["sharedLinks"] as bool?),
      sidecar: (json["sidecar"] as bool?),
      sourceId: json["sourceId"]?.toString(),
      stack: (json["stack"] as bool?),
      targetId: json["targetId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albums != null) "albums": albums,
    if (favorite != null) "favorite": favorite,
    if (sharedLinks != null) "sharedLinks": sharedLinks,
    if (sidecar != null) "sidecar": sidecar,
    if (sourceId != null) "sourceId": sourceId,
    if (stack != null) "stack": stack,
    if (targetId != null) "targetId": targetId,
  };

  AssetCopyDto copyWith({
    bool? albums,
    bool? favorite,
    bool? sharedLinks,
    bool? sidecar,
    String? sourceId,
    bool? stack,
    String? targetId,
  }) {
    return AssetCopyDto(
      albums: albums ?? this.albums,
      favorite: favorite ?? this.favorite,
      sharedLinks: sharedLinks ?? this.sharedLinks,
      sidecar: sidecar ?? this.sidecar,
      sourceId: sourceId ?? this.sourceId,
      stack: stack ?? this.stack,
      targetId: targetId ?? this.targetId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetEditActionItemDto {
  final AssetEditAction? action;
  final dynamic? parameters;

  const AssetEditActionItemDto({
    this.action,
    this.parameters,
  });

  factory AssetEditActionItemDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetEditActionItemDto();
    return AssetEditActionItemDto(
      action: _assetEditActionFromJson(json["action"]?.toString()),
      parameters: json["parameters"],
    );
  }

  Map<String, dynamic> toJson() => {
    if (action != null) "action": action?.value,
    if (parameters != null) "parameters": parameters,
  };

  AssetEditActionItemDto copyWith({
    AssetEditAction? action,
    dynamic? parameters,
  }) {
    return AssetEditActionItemDto(
      action: action ?? this.action,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetEditActionItemResponseDto {
  final AssetEditAction? action;
  final String? id;
  final dynamic? parameters;

  const AssetEditActionItemResponseDto({
    this.action,
    this.id,
    this.parameters,
  });

  factory AssetEditActionItemResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetEditActionItemResponseDto();
    return AssetEditActionItemResponseDto(
      action: _assetEditActionFromJson(json["action"]?.toString()),
      id: json["id"]?.toString(),
      parameters: json["parameters"],
    );
  }

  Map<String, dynamic> toJson() => {
    if (action != null) "action": action?.value,
    if (id != null) "id": id,
    if (parameters != null) "parameters": parameters,
  };

  AssetEditActionItemResponseDto copyWith({
    AssetEditAction? action,
    String? id,
    dynamic? parameters,
  }) {
    return AssetEditActionItemResponseDto(
      action: action ?? this.action,
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetEditsCreateDto {
  final List<AssetEditActionItemDto>? edits;

  const AssetEditsCreateDto({
    this.edits,
  });

  factory AssetEditsCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetEditsCreateDto();
    return AssetEditsCreateDto(
      edits: ((json["edits"] as List<dynamic>?)?.map((e) => AssetEditActionItemDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetEditActionItemDto>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (edits != null) "edits": edits?.map((e) => e?.toJson()).toList(),
  };

  AssetEditsCreateDto copyWith({
    List<AssetEditActionItemDto>? edits,
  }) {
    return AssetEditsCreateDto(
      edits: edits ?? this.edits,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetEditsResponseDto {
  final String? assetId;
  final List<AssetEditActionItemResponseDto>? edits;

  const AssetEditsResponseDto({
    this.assetId,
    this.edits,
  });

  factory AssetEditsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetEditsResponseDto();
    return AssetEditsResponseDto(
      assetId: json["assetId"]?.toString(),
      edits: ((json["edits"] as List<dynamic>?)?.map((e) => AssetEditActionItemResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetEditActionItemResponseDto>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (edits != null) "edits": edits?.map((e) => e?.toJson()).toList(),
  };

  AssetEditsResponseDto copyWith({
    String? assetId,
    List<AssetEditActionItemResponseDto>? edits,
  }) {
    return AssetEditsResponseDto(
      assetId: assetId ?? this.assetId,
      edits: edits ?? this.edits,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetFaceCreateDto {
  final String? assetId;
  final int? height;
  final int? imageHeight;
  final int? imageWidth;
  final String? personId;
  final int? width;
  final int? x;
  final int? y;

  const AssetFaceCreateDto({
    this.assetId,
    this.height,
    this.imageHeight,
    this.imageWidth,
    this.personId,
    this.width,
    this.x,
    this.y,
  });

  factory AssetFaceCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetFaceCreateDto();
    return AssetFaceCreateDto(
      assetId: json["assetId"]?.toString(),
      height: (json["height"] as num?)?.toInt(),
      imageHeight: (json["imageHeight"] as num?)?.toInt(),
      imageWidth: (json["imageWidth"] as num?)?.toInt(),
      personId: json["personId"]?.toString(),
      width: (json["width"] as num?)?.toInt(),
      x: (json["x"] as num?)?.toInt(),
      y: (json["y"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (height != null) "height": height,
    if (imageHeight != null) "imageHeight": imageHeight,
    if (imageWidth != null) "imageWidth": imageWidth,
    if (personId != null) "personId": personId,
    if (width != null) "width": width,
    if (x != null) "x": x,
    if (y != null) "y": y,
  };

  AssetFaceCreateDto copyWith({
    String? assetId,
    int? height,
    int? imageHeight,
    int? imageWidth,
    String? personId,
    int? width,
    int? x,
    int? y,
  }) {
    return AssetFaceCreateDto(
      assetId: assetId ?? this.assetId,
      height: height ?? this.height,
      imageHeight: imageHeight ?? this.imageHeight,
      imageWidth: imageWidth ?? this.imageWidth,
      personId: personId ?? this.personId,
      width: width ?? this.width,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetFaceDeleteDto {
  final bool? force;

  const AssetFaceDeleteDto({
    this.force,
  });

  factory AssetFaceDeleteDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetFaceDeleteDto();
    return AssetFaceDeleteDto(
      force: (json["force"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (force != null) "force": force,
  };

  AssetFaceDeleteDto copyWith({
    bool? force,
  }) {
    return AssetFaceDeleteDto(
      force: force ?? this.force,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetFaceResponseDto {
  final int? boundingBoxX1;
  final int? boundingBoxX2;
  final int? boundingBoxY1;
  final int? boundingBoxY2;
  final String? id;
  final int? imageHeight;
  final int? imageWidth;
  final PersonResponseDto? person;
  final SourceType? sourceType;

  const AssetFaceResponseDto({
    this.boundingBoxX1,
    this.boundingBoxX2,
    this.boundingBoxY1,
    this.boundingBoxY2,
    this.id,
    this.imageHeight,
    this.imageWidth,
    this.person,
    this.sourceType,
  });

  factory AssetFaceResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetFaceResponseDto();
    return AssetFaceResponseDto(
      boundingBoxX1: (json["boundingBoxX1"] as num?)?.toInt(),
      boundingBoxX2: (json["boundingBoxX2"] as num?)?.toInt(),
      boundingBoxY1: (json["boundingBoxY1"] as num?)?.toInt(),
      boundingBoxY2: (json["boundingBoxY2"] as num?)?.toInt(),
      id: json["id"]?.toString(),
      imageHeight: (json["imageHeight"] as num?)?.toInt(),
      imageWidth: (json["imageWidth"] as num?)?.toInt(),
      person: PersonResponseDto.fromJson((json["person"] as Map<String, dynamic>?)),
      sourceType: _sourceTypeFromJson(json["sourceType"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (boundingBoxX1 != null) "boundingBoxX1": boundingBoxX1,
    if (boundingBoxX2 != null) "boundingBoxX2": boundingBoxX2,
    if (boundingBoxY1 != null) "boundingBoxY1": boundingBoxY1,
    if (boundingBoxY2 != null) "boundingBoxY2": boundingBoxY2,
    if (id != null) "id": id,
    if (imageHeight != null) "imageHeight": imageHeight,
    if (imageWidth != null) "imageWidth": imageWidth,
    if (person != null) "person": person?.toJson(),
    if (sourceType != null) "sourceType": sourceType?.value,
  };

  AssetFaceResponseDto copyWith({
    int? boundingBoxX1,
    int? boundingBoxX2,
    int? boundingBoxY1,
    int? boundingBoxY2,
    String? id,
    int? imageHeight,
    int? imageWidth,
    PersonResponseDto? person,
    SourceType? sourceType,
  }) {
    return AssetFaceResponseDto(
      boundingBoxX1: boundingBoxX1 ?? this.boundingBoxX1,
      boundingBoxX2: boundingBoxX2 ?? this.boundingBoxX2,
      boundingBoxY1: boundingBoxY1 ?? this.boundingBoxY1,
      boundingBoxY2: boundingBoxY2 ?? this.boundingBoxY2,
      id: id ?? this.id,
      imageHeight: imageHeight ?? this.imageHeight,
      imageWidth: imageWidth ?? this.imageWidth,
      person: person ?? this.person,
      sourceType: sourceType ?? this.sourceType,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetFaceUpdateDto {
  final List<AssetFaceUpdateItem>? data;

  const AssetFaceUpdateDto({
    this.data,
  });

  factory AssetFaceUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetFaceUpdateDto();
    return AssetFaceUpdateDto(
      data: ((json["data"] as List<dynamic>?)?.map((e) => AssetFaceUpdateItem.fromJson((e as Map<String, dynamic>?))).whereType<AssetFaceUpdateItem>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (data != null) "data": data?.map((e) => e?.toJson()).toList(),
  };

  AssetFaceUpdateDto copyWith({
    List<AssetFaceUpdateItem>? data,
  }) {
    return AssetFaceUpdateDto(
      data: data ?? this.data,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetFaceUpdateItem {
  final String? assetId;
  final String? personId;

  const AssetFaceUpdateItem({
    this.assetId,
    this.personId,
  });

  factory AssetFaceUpdateItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetFaceUpdateItem();
    return AssetFaceUpdateItem(
      assetId: json["assetId"]?.toString(),
      personId: json["personId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (personId != null) "personId": personId,
  };

  AssetFaceUpdateItem copyWith({
    String? assetId,
    String? personId,
  }) {
    return AssetFaceUpdateItem(
      assetId: assetId ?? this.assetId,
      personId: personId ?? this.personId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetFileResponseDto {
  final String? createdAt;
  final String? id;
  final bool? isEdited;
  final bool? isProgressive;
  final bool? isTransparent;
  final String? path;
  final AssetFileType? type;
  final String? updatedAt;

  const AssetFileResponseDto({
    this.createdAt,
    this.id,
    this.isEdited,
    this.isProgressive,
    this.isTransparent,
    this.path,
    this.type,
    this.updatedAt,
  });

  factory AssetFileResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetFileResponseDto();
    return AssetFileResponseDto(
      createdAt: json["createdAt"]?.toString(),
      id: json["id"]?.toString(),
      isEdited: (json["isEdited"] as bool?),
      isProgressive: (json["isProgressive"] as bool?),
      isTransparent: (json["isTransparent"] as bool?),
      path: json["path"]?.toString(),
      type: _assetFileTypeFromJson(json["type"]?.toString()),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (createdAt != null) "createdAt": createdAt,
    if (id != null) "id": id,
    if (isEdited != null) "isEdited": isEdited,
    if (isProgressive != null) "isProgressive": isProgressive,
    if (isTransparent != null) "isTransparent": isTransparent,
    if (path != null) "path": path,
    if (type != null) "type": type?.value,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  AssetFileResponseDto copyWith({
    String? createdAt,
    String? id,
    bool? isEdited,
    bool? isProgressive,
    bool? isTransparent,
    String? path,
    AssetFileType? type,
    String? updatedAt,
  }) {
    return AssetFileResponseDto(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      isEdited: isEdited ?? this.isEdited,
      isProgressive: isProgressive ?? this.isProgressive,
      isTransparent: isTransparent ?? this.isTransparent,
      path: path ?? this.path,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetIdsDto {
  final List<String>? assetIds;

  const AssetIdsDto({
    this.assetIds,
  });

  factory AssetIdsDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetIdsDto();
    return AssetIdsDto(
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetIds != null) "assetIds": assetIds,
  };

  AssetIdsDto copyWith({
    List<String>? assetIds,
  }) {
    return AssetIdsDto(
      assetIds: assetIds ?? this.assetIds,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetIdsResponseDto {
  final String? assetId;
  final AssetIdErrorReason? error;
  final bool? success;

  const AssetIdsResponseDto({
    this.assetId,
    this.error,
    this.success,
  });

  factory AssetIdsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetIdsResponseDto();
    return AssetIdsResponseDto(
      assetId: json["assetId"]?.toString(),
      error: _assetIdErrorReasonFromJson(json["error"]?.toString()),
      success: (json["success"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (error != null) "error": error?.value,
    if (success != null) "success": success,
  };

  AssetIdsResponseDto copyWith({
    String? assetId,
    AssetIdErrorReason? error,
    bool? success,
  }) {
    return AssetIdsResponseDto(
      assetId: assetId ?? this.assetId,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetJobsDto {
  final List<String>? assetIds;
  final AssetJobName? name;

  const AssetJobsDto({
    this.assetIds,
    this.name,
  });

  factory AssetJobsDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetJobsDto();
    return AssetJobsDto(
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      name: _assetJobNameFromJson(json["name"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetIds != null) "assetIds": assetIds,
    if (name != null) "name": name?.value,
  };

  AssetJobsDto copyWith({
    List<String>? assetIds,
    AssetJobName? name,
  }) {
    return AssetJobsDto(
      assetIds: assetIds ?? this.assetIds,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetMediaCreateDto {
  final List<int>? assetData;
  final int? duration;
  final String? fileCreatedAt;
  final String? fileModifiedAt;
  final String? filename;
  final bool? isFavorite;
  final String? livePhotoVideoId;
  final List<AssetMetadataUpsertItemDto>? metadata;
  final List<int>? sidecarData;
  final AssetVisibility? visibility;

  const AssetMediaCreateDto({
    this.assetData,
    this.duration,
    this.fileCreatedAt,
    this.fileModifiedAt,
    this.filename,
    this.isFavorite,
    this.livePhotoVideoId,
    this.metadata,
    this.sidecarData,
    this.visibility,
  });

  factory AssetMediaCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetMediaCreateDto();
    return AssetMediaCreateDto(
      assetData: (json["assetData"] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      duration: (json["duration"] as num?)?.toInt(),
      fileCreatedAt: json["fileCreatedAt"]?.toString(),
      fileModifiedAt: json["fileModifiedAt"]?.toString(),
      filename: json["filename"]?.toString(),
      isFavorite: (json["isFavorite"] as bool?),
      livePhotoVideoId: json["livePhotoVideoId"]?.toString(),
      metadata: ((json["metadata"] as List<dynamic>?)?.map((e) => AssetMetadataUpsertItemDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetMetadataUpsertItemDto>().toList()),
      sidecarData: (json["sidecarData"] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetData != null) "assetData": assetData,
    if (duration != null) "duration": duration,
    if (fileCreatedAt != null) "fileCreatedAt": fileCreatedAt,
    if (fileModifiedAt != null) "fileModifiedAt": fileModifiedAt,
    if (filename != null) "filename": filename,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (livePhotoVideoId != null) "livePhotoVideoId": livePhotoVideoId,
    if (metadata != null) "metadata": metadata?.map((e) => e?.toJson()).toList(),
    if (sidecarData != null) "sidecarData": sidecarData,
    if (visibility != null) "visibility": visibility?.value,
  };

  AssetMediaCreateDto copyWith({
    List<int>? assetData,
    int? duration,
    String? fileCreatedAt,
    String? fileModifiedAt,
    String? filename,
    bool? isFavorite,
    String? livePhotoVideoId,
    List<AssetMetadataUpsertItemDto>? metadata,
    List<int>? sidecarData,
    AssetVisibility? visibility,
  }) {
    return AssetMediaCreateDto(
      assetData: assetData ?? this.assetData,
      duration: duration ?? this.duration,
      fileCreatedAt: fileCreatedAt ?? this.fileCreatedAt,
      fileModifiedAt: fileModifiedAt ?? this.fileModifiedAt,
      filename: filename ?? this.filename,
      isFavorite: isFavorite ?? this.isFavorite,
      livePhotoVideoId: livePhotoVideoId ?? this.livePhotoVideoId,
      metadata: metadata ?? this.metadata,
      sidecarData: sidecarData ?? this.sidecarData,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetMediaResponseDto {
  final String? id;
  final AssetMediaStatus? status;

  const AssetMediaResponseDto({
    this.id,
    this.status,
  });

  factory AssetMediaResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetMediaResponseDto();
    return AssetMediaResponseDto(
      id: json["id"]?.toString(),
      status: _assetMediaStatusFromJson(json["status"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) "id": id,
    if (status != null) "status": status?.value,
  };

  AssetMediaResponseDto copyWith({
    String? id,
    AssetMediaStatus? status,
  }) {
    return AssetMediaResponseDto(
      id: id ?? this.id,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetMetadataBulkResponseDto {
  final String? assetId;
  final String? key;
  final String? updatedAt;
  final Map<String, dynamic>? value;

  const AssetMetadataBulkResponseDto({
    this.assetId,
    this.key,
    this.updatedAt,
    this.value,
  });

  factory AssetMetadataBulkResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetMetadataBulkResponseDto();
    return AssetMetadataBulkResponseDto(
      assetId: json["assetId"]?.toString(),
      key: json["key"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
      value: (json["value"] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (key != null) "key": key,
    if (updatedAt != null) "updatedAt": updatedAt,
    if (value != null) "value": value,
  };

  AssetMetadataBulkResponseDto copyWith({
    String? assetId,
    String? key,
    String? updatedAt,
    Map<String, dynamic>? value,
  }) {
    return AssetMetadataBulkResponseDto(
      assetId: assetId ?? this.assetId,
      key: key ?? this.key,
      updatedAt: updatedAt ?? this.updatedAt,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetMetadataBulkUpsertDto {
  final List<AssetMetadataBulkUpsertItemDto>? items;

  const AssetMetadataBulkUpsertDto({
    this.items,
  });

  factory AssetMetadataBulkUpsertDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetMetadataBulkUpsertDto();
    return AssetMetadataBulkUpsertDto(
      items: ((json["items"] as List<dynamic>?)?.map((e) => AssetMetadataBulkUpsertItemDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetMetadataBulkUpsertItemDto>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (items != null) "items": items?.map((e) => e?.toJson()).toList(),
  };

  AssetMetadataBulkUpsertDto copyWith({
    List<AssetMetadataBulkUpsertItemDto>? items,
  }) {
    return AssetMetadataBulkUpsertDto(
      items: items ?? this.items,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetMetadataBulkUpsertItemDto {
  final String? assetId;
  final String? key;
  final Map<String, dynamic>? value;

  const AssetMetadataBulkUpsertItemDto({
    this.assetId,
    this.key,
    this.value,
  });

  factory AssetMetadataBulkUpsertItemDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetMetadataBulkUpsertItemDto();
    return AssetMetadataBulkUpsertItemDto(
      assetId: json["assetId"]?.toString(),
      key: json["key"]?.toString(),
      value: (json["value"] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (key != null) "key": key,
    if (value != null) "value": value,
  };

  AssetMetadataBulkUpsertItemDto copyWith({
    String? assetId,
    String? key,
    Map<String, dynamic>? value,
  }) {
    return AssetMetadataBulkUpsertItemDto(
      assetId: assetId ?? this.assetId,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetMetadataResponseDto {
  final String? key;
  final String? updatedAt;
  final Map<String, dynamic>? value;

  const AssetMetadataResponseDto({
    this.key,
    this.updatedAt,
    this.value,
  });

  factory AssetMetadataResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetMetadataResponseDto();
    return AssetMetadataResponseDto(
      key: json["key"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
      value: (json["value"] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (key != null) "key": key,
    if (updatedAt != null) "updatedAt": updatedAt,
    if (value != null) "value": value,
  };

  AssetMetadataResponseDto copyWith({
    String? key,
    String? updatedAt,
    Map<String, dynamic>? value,
  }) {
    return AssetMetadataResponseDto(
      key: key ?? this.key,
      updatedAt: updatedAt ?? this.updatedAt,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetMetadataUpsertItemDto {
  final String? key;
  final Map<String, dynamic>? value;

  const AssetMetadataUpsertItemDto({
    this.key,
    this.value,
  });

  factory AssetMetadataUpsertItemDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetMetadataUpsertItemDto();
    return AssetMetadataUpsertItemDto(
      key: json["key"]?.toString(),
      value: (json["value"] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (key != null) "key": key,
    if (value != null) "value": value,
  };

  AssetMetadataUpsertItemDto copyWith({
    String? key,
    Map<String, dynamic>? value,
  }) {
    return AssetMetadataUpsertItemDto(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetOcrResponseDto {
  final String? assetId;
  final double? boxScore;
  final String? id;
  final String? text;
  final double? textScore;
  final double? x1;
  final double? x2;
  final double? x3;
  final double? x4;
  final double? y1;
  final double? y2;
  final double? y3;
  final double? y4;

  const AssetOcrResponseDto({
    this.assetId,
    this.boxScore,
    this.id,
    this.text,
    this.textScore,
    this.x1,
    this.x2,
    this.x3,
    this.x4,
    this.y1,
    this.y2,
    this.y3,
    this.y4,
  });

  factory AssetOcrResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetOcrResponseDto();
    return AssetOcrResponseDto(
      assetId: json["assetId"]?.toString(),
      boxScore: (json["boxScore"] as num?)?.toDouble(),
      id: json["id"]?.toString(),
      text: json["text"]?.toString(),
      textScore: (json["textScore"] as num?)?.toDouble(),
      x1: (json["x1"] as num?)?.toDouble(),
      x2: (json["x2"] as num?)?.toDouble(),
      x3: (json["x3"] as num?)?.toDouble(),
      x4: (json["x4"] as num?)?.toDouble(),
      y1: (json["y1"] as num?)?.toDouble(),
      y2: (json["y2"] as num?)?.toDouble(),
      y3: (json["y3"] as num?)?.toDouble(),
      y4: (json["y4"] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetId != null) "assetId": assetId,
    if (boxScore != null) "boxScore": boxScore,
    if (id != null) "id": id,
    if (text != null) "text": text,
    if (textScore != null) "textScore": textScore,
    if (x1 != null) "x1": x1,
    if (x2 != null) "x2": x2,
    if (x3 != null) "x3": x3,
    if (x4 != null) "x4": x4,
    if (y1 != null) "y1": y1,
    if (y2 != null) "y2": y2,
    if (y3 != null) "y3": y3,
    if (y4 != null) "y4": y4,
  };

  AssetOcrResponseDto copyWith({
    String? assetId,
    double? boxScore,
    String? id,
    String? text,
    double? textScore,
    double? x1,
    double? x2,
    double? x3,
    double? x4,
    double? y1,
    double? y2,
    double? y3,
    double? y4,
  }) {
    return AssetOcrResponseDto(
      assetId: assetId ?? this.assetId,
      boxScore: boxScore ?? this.boxScore,
      id: id ?? this.id,
      text: text ?? this.text,
      textScore: textScore ?? this.textScore,
      x1: x1 ?? this.x1,
      x2: x2 ?? this.x2,
      x3: x3 ?? this.x3,
      x4: x4 ?? this.x4,
      y1: y1 ?? this.y1,
      y2: y2 ?? this.y2,
      y3: y3 ?? this.y3,
      y4: y4 ?? this.y4,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetResponseDto {
  final String? checksum;
  final String? createdAt;
  final String? duplicateId;
  final int? duration;
  final ExifResponseDto? exifInfo;
  final String? fileCreatedAt;
  final String? fileModifiedAt;
  final bool? hasMetadata;
  final int? height;
  final String? id;
  final bool? isArchived;
  final bool? isEdited;
  final bool? isFavorite;
  final bool? isOffline;
  final bool? isTrashed;
  final String? libraryId;
  final String? livePhotoVideoId;
  final String? localDateTime;
  final String? originalFileName;
  final String? originalMimeType;
  final String? originalPath;
  final UserResponseDto? owner;
  final String? ownerId;
  final List<PersonResponseDto>? people;
  final bool? resized;
  final AssetStackResponseDto? stack;
  final List<TagResponseDto>? tags;
  final String? thumbhash;
  final AssetTypeEnum? type;
  final String? updatedAt;
  final AssetVisibility? visibility;
  final int? width;

  const AssetResponseDto({
    this.checksum,
    this.createdAt,
    this.duplicateId,
    this.duration,
    this.exifInfo,
    this.fileCreatedAt,
    this.fileModifiedAt,
    this.hasMetadata,
    this.height,
    this.id,
    this.isArchived,
    this.isEdited,
    this.isFavorite,
    this.isOffline,
    this.isTrashed,
    this.libraryId,
    this.livePhotoVideoId,
    this.localDateTime,
    this.originalFileName,
    this.originalMimeType,
    this.originalPath,
    this.owner,
    this.ownerId,
    this.people,
    this.resized,
    this.stack,
    this.tags,
    this.thumbhash,
    this.type,
    this.updatedAt,
    this.visibility,
    this.width,
  });

  factory AssetResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetResponseDto();
    return AssetResponseDto(
      checksum: json["checksum"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      duplicateId: json["duplicateId"]?.toString(),
      duration: (json["duration"] as num?)?.toInt(),
      exifInfo: ExifResponseDto.fromJson((json["exifInfo"] as Map<String, dynamic>?)),
      fileCreatedAt: json["fileCreatedAt"]?.toString(),
      fileModifiedAt: json["fileModifiedAt"]?.toString(),
      hasMetadata: (json["hasMetadata"] as bool?),
      height: (json["height"] as num?)?.toInt(),
      id: json["id"]?.toString(),
      isArchived: (json["isArchived"] as bool?),
      isEdited: (json["isEdited"] as bool?),
      isFavorite: (json["isFavorite"] as bool?),
      isOffline: (json["isOffline"] as bool?),
      isTrashed: (json["isTrashed"] as bool?),
      libraryId: json["libraryId"]?.toString(),
      livePhotoVideoId: json["livePhotoVideoId"]?.toString(),
      localDateTime: json["localDateTime"]?.toString(),
      originalFileName: json["originalFileName"]?.toString(),
      originalMimeType: json["originalMimeType"]?.toString(),
      originalPath: json["originalPath"]?.toString(),
      owner: UserResponseDto.fromJson((json["owner"] as Map<String, dynamic>?)),
      ownerId: json["ownerId"]?.toString(),
      people: ((json["people"] as List<dynamic>?)?.map((e) => PersonResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<PersonResponseDto>().toList()),
      resized: (json["resized"] as bool?),
      stack: AssetStackResponseDto.fromJson((json["stack"] as Map<String, dynamic>?)),
      tags: ((json["tags"] as List<dynamic>?)?.map((e) => TagResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<TagResponseDto>().toList()),
      thumbhash: json["thumbhash"]?.toString(),
      type: _assetTypeEnumFromJson(json["type"]?.toString()),
      updatedAt: json["updatedAt"]?.toString(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
      width: (json["width"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (checksum != null) "checksum": checksum,
    if (createdAt != null) "createdAt": createdAt,
    if (duplicateId != null) "duplicateId": duplicateId,
    if (duration != null) "duration": duration,
    if (exifInfo != null) "exifInfo": exifInfo?.toJson(),
    if (fileCreatedAt != null) "fileCreatedAt": fileCreatedAt,
    if (fileModifiedAt != null) "fileModifiedAt": fileModifiedAt,
    if (hasMetadata != null) "hasMetadata": hasMetadata,
    if (height != null) "height": height,
    if (id != null) "id": id,
    if (isArchived != null) "isArchived": isArchived,
    if (isEdited != null) "isEdited": isEdited,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isOffline != null) "isOffline": isOffline,
    if (isTrashed != null) "isTrashed": isTrashed,
    if (libraryId != null) "libraryId": libraryId,
    if (livePhotoVideoId != null) "livePhotoVideoId": livePhotoVideoId,
    if (localDateTime != null) "localDateTime": localDateTime,
    if (originalFileName != null) "originalFileName": originalFileName,
    if (originalMimeType != null) "originalMimeType": originalMimeType,
    if (originalPath != null) "originalPath": originalPath,
    if (owner != null) "owner": owner?.toJson(),
    if (ownerId != null) "ownerId": ownerId,
    if (people != null) "people": people?.map((e) => e?.toJson()).toList(),
    if (resized != null) "resized": resized,
    if (stack != null) "stack": stack?.toJson(),
    if (tags != null) "tags": tags?.map((e) => e?.toJson()).toList(),
    if (thumbhash != null) "thumbhash": thumbhash,
    if (type != null) "type": type?.value,
    if (updatedAt != null) "updatedAt": updatedAt,
    if (visibility != null) "visibility": visibility?.value,
    if (width != null) "width": width,
  };

  AssetResponseDto copyWith({
    String? checksum,
    String? createdAt,
    String? duplicateId,
    int? duration,
    ExifResponseDto? exifInfo,
    String? fileCreatedAt,
    String? fileModifiedAt,
    bool? hasMetadata,
    int? height,
    String? id,
    bool? isArchived,
    bool? isEdited,
    bool? isFavorite,
    bool? isOffline,
    bool? isTrashed,
    String? libraryId,
    String? livePhotoVideoId,
    String? localDateTime,
    String? originalFileName,
    String? originalMimeType,
    String? originalPath,
    UserResponseDto? owner,
    String? ownerId,
    List<PersonResponseDto>? people,
    bool? resized,
    AssetStackResponseDto? stack,
    List<TagResponseDto>? tags,
    String? thumbhash,
    AssetTypeEnum? type,
    String? updatedAt,
    AssetVisibility? visibility,
    int? width,
  }) {
    return AssetResponseDto(
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      duplicateId: duplicateId ?? this.duplicateId,
      duration: duration ?? this.duration,
      exifInfo: exifInfo ?? this.exifInfo,
      fileCreatedAt: fileCreatedAt ?? this.fileCreatedAt,
      fileModifiedAt: fileModifiedAt ?? this.fileModifiedAt,
      hasMetadata: hasMetadata ?? this.hasMetadata,
      height: height ?? this.height,
      id: id ?? this.id,
      isArchived: isArchived ?? this.isArchived,
      isEdited: isEdited ?? this.isEdited,
      isFavorite: isFavorite ?? this.isFavorite,
      isOffline: isOffline ?? this.isOffline,
      isTrashed: isTrashed ?? this.isTrashed,
      libraryId: libraryId ?? this.libraryId,
      livePhotoVideoId: livePhotoVideoId ?? this.livePhotoVideoId,
      localDateTime: localDateTime ?? this.localDateTime,
      originalFileName: originalFileName ?? this.originalFileName,
      originalMimeType: originalMimeType ?? this.originalMimeType,
      originalPath: originalPath ?? this.originalPath,
      owner: owner ?? this.owner,
      ownerId: ownerId ?? this.ownerId,
      people: people ?? this.people,
      resized: resized ?? this.resized,
      stack: stack ?? this.stack,
      tags: tags ?? this.tags,
      thumbhash: thumbhash ?? this.thumbhash,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      visibility: visibility ?? this.visibility,
      width: width ?? this.width,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetStackResponseDto {
  final int? assetCount;
  final String? id;
  final String? primaryAssetId;

  const AssetStackResponseDto({
    this.assetCount,
    this.id,
    this.primaryAssetId,
  });

  factory AssetStackResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetStackResponseDto();
    return AssetStackResponseDto(
      assetCount: (json["assetCount"] as num?)?.toInt(),
      id: json["id"]?.toString(),
      primaryAssetId: json["primaryAssetId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetCount != null) "assetCount": assetCount,
    if (id != null) "id": id,
    if (primaryAssetId != null) "primaryAssetId": primaryAssetId,
  };

  AssetStackResponseDto copyWith({
    int? assetCount,
    String? id,
    String? primaryAssetId,
  }) {
    return AssetStackResponseDto(
      assetCount: assetCount ?? this.assetCount,
      id: id ?? this.id,
      primaryAssetId: primaryAssetId ?? this.primaryAssetId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AssetStatsResponseDto {
  final int? images;
  final int? total;
  final int? videos;

  const AssetStatsResponseDto({
    this.images,
    this.total,
    this.videos,
  });

  factory AssetStatsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetStatsResponseDto();
    return AssetStatsResponseDto(
      images: (json["images"] as num?)?.toInt(),
      total: (json["total"] as num?)?.toInt(),
      videos: (json["videos"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (images != null) "images": images,
    if (total != null) "total": total,
    if (videos != null) "videos": videos,
  };

  AssetStatsResponseDto copyWith({
    int? images,
    int? total,
    int? videos,
  }) {
    return AssetStatsResponseDto(
      images: images ?? this.images,
      total: total ?? this.total,
      videos: videos ?? this.videos,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AuthStatusResponseDto {
  final String? expiresAt;
  final bool? isElevated;
  final bool? password;
  final bool? pinCode;
  final String? pinExpiresAt;

  const AuthStatusResponseDto({
    this.expiresAt,
    this.isElevated,
    this.password,
    this.pinCode,
    this.pinExpiresAt,
  });

  factory AuthStatusResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AuthStatusResponseDto();
    return AuthStatusResponseDto(
      expiresAt: json["expiresAt"]?.toString(),
      isElevated: (json["isElevated"] as bool?),
      password: (json["password"] as bool?),
      pinCode: (json["pinCode"] as bool?),
      pinExpiresAt: json["pinExpiresAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (expiresAt != null) "expiresAt": expiresAt,
    if (isElevated != null) "isElevated": isElevated,
    if (password != null) "password": password,
    if (pinCode != null) "pinCode": pinCode,
    if (pinExpiresAt != null) "pinExpiresAt": pinExpiresAt,
  };

  AuthStatusResponseDto copyWith({
    String? expiresAt,
    bool? isElevated,
    bool? password,
    bool? pinCode,
    String? pinExpiresAt,
  }) {
    return AuthStatusResponseDto(
      expiresAt: expiresAt ?? this.expiresAt,
      isElevated: isElevated ?? this.isElevated,
      password: password ?? this.password,
      pinCode: pinCode ?? this.pinCode,
      pinExpiresAt: pinExpiresAt ?? this.pinExpiresAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class AvatarUpdate {
  final UserAvatarColor? color;

  const AvatarUpdate({
    this.color,
  });

  factory AvatarUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AvatarUpdate();
    return AvatarUpdate(
      color: _userAvatarColorFromJson(json["color"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (color != null) "color": color?.value,
  };

  AvatarUpdate copyWith({
    UserAvatarColor? color,
  }) {
    return AvatarUpdate(
      color: color ?? this.color,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class BoolFilter {
  final bool? eq;

  const BoolFilter({
    this.eq,
  });

  factory BoolFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BoolFilter();
    return BoolFilter(
      eq: (json["eq"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
  };

  BoolFilter copyWith({
    bool? eq,
  }) {
    return BoolFilter(
      eq: eq ?? this.eq,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class BulkIdResponseDto {
  final BulkIdErrorReason? error;
  final String? errorMessage;
  final String? id;
  final bool? success;

  const BulkIdResponseDto({
    this.error,
    this.errorMessage,
    this.id,
    this.success,
  });

  factory BulkIdResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BulkIdResponseDto();
    return BulkIdResponseDto(
      error: _bulkIdErrorReasonFromJson(json["error"]?.toString()),
      errorMessage: json["errorMessage"]?.toString(),
      id: json["id"]?.toString(),
      success: (json["success"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (error != null) "error": error?.value,
    if (errorMessage != null) "errorMessage": errorMessage,
    if (id != null) "id": id,
    if (success != null) "success": success,
  };

  BulkIdResponseDto copyWith({
    BulkIdErrorReason? error,
    String? errorMessage,
    String? id,
    bool? success,
  }) {
    return BulkIdResponseDto(
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
      id: id ?? this.id,
      success: success ?? this.success,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class BulkIdsDto {
  final List<String>? ids;

  const BulkIdsDto({
    this.ids,
  });

  factory BulkIdsDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BulkIdsDto();
    return BulkIdsDto(
      ids: ((json["ids"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ids != null) "ids": ids,
  };

  BulkIdsDto copyWith({
    List<String>? ids,
  }) {
    return BulkIdsDto(
      ids: ids ?? this.ids,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CalendarHeatmapResponseDto {
  final String? from_;
  final List<Map<String, dynamic>>? series;
  final String? to;
  final int? totalCount;

  const CalendarHeatmapResponseDto({
    this.from_,
    this.series,
    this.to,
    this.totalCount,
  });

  factory CalendarHeatmapResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CalendarHeatmapResponseDto();
    return CalendarHeatmapResponseDto(
      from_: json["from"]?.toString(),
      series: ((json["series"] as List<dynamic>?)?.map((e) => (e as Map<String, dynamic>?)).whereType<Map<String, dynamic>>().toList()),
      to: json["to"]?.toString(),
      totalCount: (json["totalCount"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (from_ != null) "from": from_,
    if (series != null) "series": series?.map((e) => e).toList(),
    if (to != null) "to": to,
    if (totalCount != null) "totalCount": totalCount,
  };

  CalendarHeatmapResponseDto copyWith({
    String? from_,
    List<Map<String, dynamic>>? series,
    String? to,
    int? totalCount,
  }) {
    return CalendarHeatmapResponseDto(
      from_: from_ ?? this.from_,
      series: series ?? this.series,
      to: to ?? this.to,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CastResponse {
  final bool? gCastEnabled;

  const CastResponse({
    this.gCastEnabled,
  });

  factory CastResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CastResponse();
    return CastResponse(
      gCastEnabled: (json["gCastEnabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (gCastEnabled != null) "gCastEnabled": gCastEnabled,
  };

  CastResponse copyWith({
    bool? gCastEnabled,
  }) {
    return CastResponse(
      gCastEnabled: gCastEnabled ?? this.gCastEnabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CastUpdate {
  final bool? gCastEnabled;

  const CastUpdate({
    this.gCastEnabled,
  });

  factory CastUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CastUpdate();
    return CastUpdate(
      gCastEnabled: (json["gCastEnabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (gCastEnabled != null) "gCastEnabled": gCastEnabled,
  };

  CastUpdate copyWith({
    bool? gCastEnabled,
  }) {
    return CastUpdate(
      gCastEnabled: gCastEnabled ?? this.gCastEnabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ChangePasswordDto {
  final bool? invalidateSessions;
  final String? newPassword;
  final String? password;

  const ChangePasswordDto({
    this.invalidateSessions,
    this.newPassword,
    this.password,
  });

  factory ChangePasswordDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChangePasswordDto();
    return ChangePasswordDto(
      invalidateSessions: (json["invalidateSessions"] as bool?),
      newPassword: json["newPassword"]?.toString(),
      password: json["password"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (invalidateSessions != null) "invalidateSessions": invalidateSessions,
    if (newPassword != null) "newPassword": newPassword,
    if (password != null) "password": password,
  };

  ChangePasswordDto copyWith({
    bool? invalidateSessions,
    String? newPassword,
    String? password,
  }) {
    return ChangePasswordDto(
      invalidateSessions: invalidateSessions ?? this.invalidateSessions,
      newPassword: newPassword ?? this.newPassword,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ContributorCountResponseDto {
  final int? assetCount;
  final String? userId;

  const ContributorCountResponseDto({
    this.assetCount,
    this.userId,
  });

  factory ContributorCountResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ContributorCountResponseDto();
    return ContributorCountResponseDto(
      assetCount: (json["assetCount"] as num?)?.toInt(),
      userId: json["userId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetCount != null) "assetCount": assetCount,
    if (userId != null) "userId": userId,
  };

  ContributorCountResponseDto copyWith({
    int? assetCount,
    String? userId,
  }) {
    return ContributorCountResponseDto(
      assetCount: assetCount ?? this.assetCount,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CreateAlbumDto {
  final String? albumName;
  final List<AlbumUserCreateDto>? albumUsers;
  final List<String>? assetIds;
  final String? description;

  const CreateAlbumDto({
    this.albumName,
    this.albumUsers,
    this.assetIds,
    this.description,
  });

  factory CreateAlbumDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CreateAlbumDto();
    return CreateAlbumDto(
      albumName: json["albumName"]?.toString(),
      albumUsers: ((json["albumUsers"] as List<dynamic>?)?.map((e) => AlbumUserCreateDto.fromJson((e as Map<String, dynamic>?))).whereType<AlbumUserCreateDto>().toList()),
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      description: json["description"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumName != null) "albumName": albumName,
    if (albumUsers != null) "albumUsers": albumUsers?.map((e) => e?.toJson()).toList(),
    if (assetIds != null) "assetIds": assetIds,
    if (description != null) "description": description,
  };

  CreateAlbumDto copyWith({
    String? albumName,
    List<AlbumUserCreateDto>? albumUsers,
    List<String>? assetIds,
    String? description,
  }) {
    return CreateAlbumDto(
      albumName: albumName ?? this.albumName,
      albumUsers: albumUsers ?? this.albumUsers,
      assetIds: assetIds ?? this.assetIds,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CreateLibraryDto {
  final List<String>? exclusionPatterns;
  final List<String>? importPaths;
  final String? name;
  final String? ownerId;

  const CreateLibraryDto({
    this.exclusionPatterns,
    this.importPaths,
    this.name,
    this.ownerId,
  });

  factory CreateLibraryDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CreateLibraryDto();
    return CreateLibraryDto(
      exclusionPatterns: ((json["exclusionPatterns"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      importPaths: ((json["importPaths"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      name: json["name"]?.toString(),
      ownerId: json["ownerId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (exclusionPatterns != null) "exclusionPatterns": exclusionPatterns,
    if (importPaths != null) "importPaths": importPaths,
    if (name != null) "name": name,
    if (ownerId != null) "ownerId": ownerId,
  };

  CreateLibraryDto copyWith({
    List<String>? exclusionPatterns,
    List<String>? importPaths,
    String? name,
    String? ownerId,
  }) {
    return CreateLibraryDto(
      exclusionPatterns: exclusionPatterns ?? this.exclusionPatterns,
      importPaths: importPaths ?? this.importPaths,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CreateProfileImageDto {
  final List<int>? file;

  const CreateProfileImageDto({
    this.file,
  });

  factory CreateProfileImageDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CreateProfileImageDto();
    return CreateProfileImageDto(
      file: (json["file"] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (file != null) "file": file,
  };

  CreateProfileImageDto copyWith({
    List<int>? file,
  }) {
    return CreateProfileImageDto(
      file: file ?? this.file,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CreateProfileImageResponseDto {
  final String? profileChangedAt;
  final String? profileImagePath;
  final String? userId;

  const CreateProfileImageResponseDto({
    this.profileChangedAt,
    this.profileImagePath,
    this.userId,
  });

  factory CreateProfileImageResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CreateProfileImageResponseDto();
    return CreateProfileImageResponseDto(
      profileChangedAt: json["profileChangedAt"]?.toString(),
      profileImagePath: json["profileImagePath"]?.toString(),
      userId: json["userId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (profileChangedAt != null) "profileChangedAt": profileChangedAt,
    if (profileImagePath != null) "profileImagePath": profileImagePath,
    if (userId != null) "userId": userId,
  };

  CreateProfileImageResponseDto copyWith({
    String? profileChangedAt,
    String? profileImagePath,
    String? userId,
  }) {
    return CreateProfileImageResponseDto(
      profileChangedAt: profileChangedAt ?? this.profileChangedAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class CropParameters {
  final int? height;
  final int? width;
  final int? x;
  final int? y;

  const CropParameters({
    this.height,
    this.width,
    this.x,
    this.y,
  });

  factory CropParameters.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CropParameters();
    return CropParameters(
      height: (json["height"] as num?)?.toInt(),
      width: (json["width"] as num?)?.toInt(),
      x: (json["x"] as num?)?.toInt(),
      y: (json["y"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (height != null) "height": height,
    if (width != null) "width": width,
    if (x != null) "x": x,
    if (y != null) "y": y,
  };

  CropParameters copyWith({
    int? height,
    int? width,
    int? x,
    int? y,
  }) {
    return CropParameters(
      height: height ?? this.height,
      width: width ?? this.width,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DateFilter {
  final String? eq;
  final String? gt;
  final String? gte;
  final String? lt;
  final String? lte;
  final String? ne;

  const DateFilter({
    this.eq,
    this.gt,
    this.gte,
    this.lt,
    this.lte,
    this.ne,
  });

  factory DateFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DateFilter();
    return DateFilter(
      eq: json["eq"]?.toString(),
      gt: json["gt"]?.toString(),
      gte: json["gte"]?.toString(),
      lt: json["lt"]?.toString(),
      lte: json["lte"]?.toString(),
      ne: json["ne"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (gt != null) "gt": gt,
    if (gte != null) "gte": gte,
    if (lt != null) "lt": lt,
    if (lte != null) "lte": lte,
    if (ne != null) "ne": ne,
  };

  DateFilter copyWith({
    String? eq,
    String? gt,
    String? gte,
    String? lt,
    String? lte,
    String? ne,
  }) {
    return DateFilter(
      eq: eq ?? this.eq,
      gt: gt ?? this.gt,
      gte: gte ?? this.gte,
      lt: lt ?? this.lt,
      lte: lte ?? this.lte,
      ne: ne ?? this.ne,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DateFilterNullable {
  final String? eq;
  final String? gt;
  final String? gte;
  final String? lt;
  final String? lte;
  final String? ne;

  const DateFilterNullable({
    this.eq,
    this.gt,
    this.gte,
    this.lt,
    this.lte,
    this.ne,
  });

  factory DateFilterNullable.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DateFilterNullable();
    return DateFilterNullable(
      eq: json["eq"]?.toString(),
      gt: json["gt"]?.toString(),
      gte: json["gte"]?.toString(),
      lt: json["lt"]?.toString(),
      lte: json["lte"]?.toString(),
      ne: json["ne"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (gt != null) "gt": gt,
    if (gte != null) "gte": gte,
    if (lt != null) "lt": lt,
    if (lte != null) "lte": lte,
    if (ne != null) "ne": ne,
  };

  DateFilterNullable copyWith({
    String? eq,
    String? gt,
    String? gte,
    String? lt,
    String? lte,
    String? ne,
  }) {
    return DateFilterNullable(
      eq: eq ?? this.eq,
      gt: gt ?? this.gt,
      gte: gte ?? this.gte,
      lt: lt ?? this.lt,
      lte: lte ?? this.lte,
      ne: ne ?? this.ne,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DownloadArchiveDto {
  final String? archiveName;
  final List<String>? assetIds;
  final bool? edited;

  const DownloadArchiveDto({
    this.archiveName,
    this.assetIds,
    this.edited,
  });

  factory DownloadArchiveDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DownloadArchiveDto();
    return DownloadArchiveDto(
      archiveName: json["archiveName"]?.toString(),
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      edited: (json["edited"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (archiveName != null) "archiveName": archiveName,
    if (assetIds != null) "assetIds": assetIds,
    if (edited != null) "edited": edited,
  };

  DownloadArchiveDto copyWith({
    String? archiveName,
    List<String>? assetIds,
    bool? edited,
  }) {
    return DownloadArchiveDto(
      archiveName: archiveName ?? this.archiveName,
      assetIds: assetIds ?? this.assetIds,
      edited: edited ?? this.edited,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DownloadArchiveInfo {
  final List<String>? assetIds;
  final int? size;

  const DownloadArchiveInfo({
    this.assetIds,
    this.size,
  });

  factory DownloadArchiveInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DownloadArchiveInfo();
    return DownloadArchiveInfo(
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      size: (json["size"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetIds != null) "assetIds": assetIds,
    if (size != null) "size": size,
  };

  DownloadArchiveInfo copyWith({
    List<String>? assetIds,
    int? size,
  }) {
    return DownloadArchiveInfo(
      assetIds: assetIds ?? this.assetIds,
      size: size ?? this.size,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DownloadInfoDto {
  final String? albumId;
  final int? archiveSize;
  final List<String>? assetIds;
  final String? userId;

  const DownloadInfoDto({
    this.albumId,
    this.archiveSize,
    this.assetIds,
    this.userId,
  });

  factory DownloadInfoDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DownloadInfoDto();
    return DownloadInfoDto(
      albumId: json["albumId"]?.toString(),
      archiveSize: (json["archiveSize"] as num?)?.toInt(),
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      userId: json["userId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumId != null) "albumId": albumId,
    if (archiveSize != null) "archiveSize": archiveSize,
    if (assetIds != null) "assetIds": assetIds,
    if (userId != null) "userId": userId,
  };

  DownloadInfoDto copyWith({
    String? albumId,
    int? archiveSize,
    List<String>? assetIds,
    String? userId,
  }) {
    return DownloadInfoDto(
      albumId: albumId ?? this.albumId,
      archiveSize: archiveSize ?? this.archiveSize,
      assetIds: assetIds ?? this.assetIds,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DownloadResponse {
  final int? archiveSize;
  final bool? includeEmbeddedVideos;

  const DownloadResponse({
    this.archiveSize,
    this.includeEmbeddedVideos,
  });

  factory DownloadResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DownloadResponse();
    return DownloadResponse(
      archiveSize: (json["archiveSize"] as num?)?.toInt(),
      includeEmbeddedVideos: (json["includeEmbeddedVideos"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (archiveSize != null) "archiveSize": archiveSize,
    if (includeEmbeddedVideos != null) "includeEmbeddedVideos": includeEmbeddedVideos,
  };

  DownloadResponse copyWith({
    int? archiveSize,
    bool? includeEmbeddedVideos,
  }) {
    return DownloadResponse(
      archiveSize: archiveSize ?? this.archiveSize,
      includeEmbeddedVideos: includeEmbeddedVideos ?? this.includeEmbeddedVideos,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DownloadResponseDto {
  final List<DownloadArchiveInfo>? archives;
  final int? totalSize;

  const DownloadResponseDto({
    this.archives,
    this.totalSize,
  });

  factory DownloadResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DownloadResponseDto();
    return DownloadResponseDto(
      archives: ((json["archives"] as List<dynamic>?)?.map((e) => DownloadArchiveInfo.fromJson((e as Map<String, dynamic>?))).whereType<DownloadArchiveInfo>().toList()),
      totalSize: (json["totalSize"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (archives != null) "archives": archives?.map((e) => e?.toJson()).toList(),
    if (totalSize != null) "totalSize": totalSize,
  };

  DownloadResponseDto copyWith({
    List<DownloadArchiveInfo>? archives,
    int? totalSize,
  }) {
    return DownloadResponseDto(
      archives: archives ?? this.archives,
      totalSize: totalSize ?? this.totalSize,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DownloadUpdate {
  final int? archiveSize;
  final bool? includeEmbeddedVideos;

  const DownloadUpdate({
    this.archiveSize,
    this.includeEmbeddedVideos,
  });

  factory DownloadUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DownloadUpdate();
    return DownloadUpdate(
      archiveSize: (json["archiveSize"] as num?)?.toInt(),
      includeEmbeddedVideos: (json["includeEmbeddedVideos"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (archiveSize != null) "archiveSize": archiveSize,
    if (includeEmbeddedVideos != null) "includeEmbeddedVideos": includeEmbeddedVideos,
  };

  DownloadUpdate copyWith({
    int? archiveSize,
    bool? includeEmbeddedVideos,
  }) {
    return DownloadUpdate(
      archiveSize: archiveSize ?? this.archiveSize,
      includeEmbeddedVideos: includeEmbeddedVideos ?? this.includeEmbeddedVideos,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DuplicateResolveDto {
  final List<DuplicateResolveGroupDto>? groups;

  const DuplicateResolveDto({
    this.groups,
  });

  factory DuplicateResolveDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DuplicateResolveDto();
    return DuplicateResolveDto(
      groups: ((json["groups"] as List<dynamic>?)?.map((e) => DuplicateResolveGroupDto.fromJson((e as Map<String, dynamic>?))).whereType<DuplicateResolveGroupDto>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (groups != null) "groups": groups?.map((e) => e?.toJson()).toList(),
  };

  DuplicateResolveDto copyWith({
    List<DuplicateResolveGroupDto>? groups,
  }) {
    return DuplicateResolveDto(
      groups: groups ?? this.groups,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DuplicateResolveGroupDto {
  final String? duplicateId;
  final List<String>? keepAssetIds;
  final List<String>? trashAssetIds;

  const DuplicateResolveGroupDto({
    this.duplicateId,
    this.keepAssetIds,
    this.trashAssetIds,
  });

  factory DuplicateResolveGroupDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DuplicateResolveGroupDto();
    return DuplicateResolveGroupDto(
      duplicateId: json["duplicateId"]?.toString(),
      keepAssetIds: ((json["keepAssetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      trashAssetIds: ((json["trashAssetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (duplicateId != null) "duplicateId": duplicateId,
    if (keepAssetIds != null) "keepAssetIds": keepAssetIds,
    if (trashAssetIds != null) "trashAssetIds": trashAssetIds,
  };

  DuplicateResolveGroupDto copyWith({
    String? duplicateId,
    List<String>? keepAssetIds,
    List<String>? trashAssetIds,
  }) {
    return DuplicateResolveGroupDto(
      duplicateId: duplicateId ?? this.duplicateId,
      keepAssetIds: keepAssetIds ?? this.keepAssetIds,
      trashAssetIds: trashAssetIds ?? this.trashAssetIds,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class DuplicateResponseDto {
  final List<AssetResponseDto>? assets;
  final String? duplicateId;
  final List<String>? suggestedKeepAssetIds;

  const DuplicateResponseDto({
    this.assets,
    this.duplicateId,
    this.suggestedKeepAssetIds,
  });

  factory DuplicateResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DuplicateResponseDto();
    return DuplicateResponseDto(
      assets: ((json["assets"] as List<dynamic>?)?.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetResponseDto>().toList()),
      duplicateId: json["duplicateId"]?.toString(),
      suggestedKeepAssetIds: ((json["suggestedKeepAssetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assets != null) "assets": assets?.map((e) => e?.toJson()).toList(),
    if (duplicateId != null) "duplicateId": duplicateId,
    if (suggestedKeepAssetIds != null) "suggestedKeepAssetIds": suggestedKeepAssetIds,
  };

  DuplicateResponseDto copyWith({
    List<AssetResponseDto>? assets,
    String? duplicateId,
    List<String>? suggestedKeepAssetIds,
  }) {
    return DuplicateResponseDto(
      assets: assets ?? this.assets,
      duplicateId: duplicateId ?? this.duplicateId,
      suggestedKeepAssetIds: suggestedKeepAssetIds ?? this.suggestedKeepAssetIds,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class EmailNotificationsResponse {
  final bool? albumInvite;
  final bool? albumUpdate;
  final bool? enabled;

  const EmailNotificationsResponse({
    this.albumInvite,
    this.albumUpdate,
    this.enabled,
  });

  factory EmailNotificationsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EmailNotificationsResponse();
    return EmailNotificationsResponse(
      albumInvite: (json["albumInvite"] as bool?),
      albumUpdate: (json["albumUpdate"] as bool?),
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumInvite != null) "albumInvite": albumInvite,
    if (albumUpdate != null) "albumUpdate": albumUpdate,
    if (enabled != null) "enabled": enabled,
  };

  EmailNotificationsResponse copyWith({
    bool? albumInvite,
    bool? albumUpdate,
    bool? enabled,
  }) {
    return EmailNotificationsResponse(
      albumInvite: albumInvite ?? this.albumInvite,
      albumUpdate: albumUpdate ?? this.albumUpdate,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class EmailNotificationsUpdate {
  final bool? albumInvite;
  final bool? albumUpdate;
  final bool? enabled;

  const EmailNotificationsUpdate({
    this.albumInvite,
    this.albumUpdate,
    this.enabled,
  });

  factory EmailNotificationsUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EmailNotificationsUpdate();
    return EmailNotificationsUpdate(
      albumInvite: (json["albumInvite"] as bool?),
      albumUpdate: (json["albumUpdate"] as bool?),
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumInvite != null) "albumInvite": albumInvite,
    if (albumUpdate != null) "albumUpdate": albumUpdate,
    if (enabled != null) "enabled": enabled,
  };

  EmailNotificationsUpdate copyWith({
    bool? albumInvite,
    bool? albumUpdate,
    bool? enabled,
  }) {
    return EmailNotificationsUpdate(
      albumInvite: albumInvite ?? this.albumInvite,
      albumUpdate: albumUpdate ?? this.albumUpdate,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class EnumFilterAssetType {
  final AssetTypeEnum? eq;
  final List<AssetTypeEnum>? in_;
  final AssetTypeEnum? ne;
  final List<AssetTypeEnum>? notIn;

  const EnumFilterAssetType({
    this.eq,
    this.in_,
    this.ne,
    this.notIn,
  });

  factory EnumFilterAssetType.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EnumFilterAssetType();
    return EnumFilterAssetType(
      eq: _assetTypeEnumFromJson(json["eq"]?.toString()),
      in_: ((json["in"] as List<dynamic>?)?.map((e) => _assetTypeEnumFromJson(e?.toString())).whereType<AssetTypeEnum>().toList()),
      ne: _assetTypeEnumFromJson(json["ne"]?.toString()),
      notIn: ((json["notIn"] as List<dynamic>?)?.map((e) => _assetTypeEnumFromJson(e?.toString())).whereType<AssetTypeEnum>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq?.value,
    if (in_ != null) "in": in_?.map((e) => e?.value).toList(),
    if (ne != null) "ne": ne?.value,
    if (notIn != null) "notIn": notIn?.map((e) => e?.value).toList(),
  };

  EnumFilterAssetType copyWith({
    AssetTypeEnum? eq,
    List<AssetTypeEnum>? in_,
    AssetTypeEnum? ne,
    List<AssetTypeEnum>? notIn,
  }) {
    return EnumFilterAssetType(
      eq: eq ?? this.eq,
      in_: in_ ?? this.in_,
      ne: ne ?? this.ne,
      notIn: notIn ?? this.notIn,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class EnumFilterAssetVisibility {
  final AssetVisibility? eq;
  final List<AssetVisibility>? in_;
  final AssetVisibility? ne;
  final List<AssetVisibility>? notIn;

  const EnumFilterAssetVisibility({
    this.eq,
    this.in_,
    this.ne,
    this.notIn,
  });

  factory EnumFilterAssetVisibility.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EnumFilterAssetVisibility();
    return EnumFilterAssetVisibility(
      eq: _assetVisibilityFromJson(json["eq"]?.toString()),
      in_: ((json["in"] as List<dynamic>?)?.map((e) => _assetVisibilityFromJson(e?.toString())).whereType<AssetVisibility>().toList()),
      ne: _assetVisibilityFromJson(json["ne"]?.toString()),
      notIn: ((json["notIn"] as List<dynamic>?)?.map((e) => _assetVisibilityFromJson(e?.toString())).whereType<AssetVisibility>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq?.value,
    if (in_ != null) "in": in_?.map((e) => e?.value).toList(),
    if (ne != null) "ne": ne?.value,
    if (notIn != null) "notIn": notIn?.map((e) => e?.value).toList(),
  };

  EnumFilterAssetVisibility copyWith({
    AssetVisibility? eq,
    List<AssetVisibility>? in_,
    AssetVisibility? ne,
    List<AssetVisibility>? notIn,
  }) {
    return EnumFilterAssetVisibility(
      eq: eq ?? this.eq,
      in_: in_ ?? this.in_,
      ne: ne ?? this.ne,
      notIn: notIn ?? this.notIn,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ExifResponseDto {
  final String? city;
  final String? country;
  final String? dateTimeOriginal;
  final String? description;
  final int? exifImageHeight;
  final int? exifImageWidth;
  final String? exposureTime;
  final double? fNumber;
  final int? fileSizeInByte;
  final double? focalLength;
  final int? iso;
  final double? latitude;
  final String? lensModel;
  final double? longitude;
  final String? make;
  final String? model;
  final String? modifyDate;
  final String? orientation;
  final String? projectionType;
  final int? rating;
  final String? state;
  final String? timeZone;

  const ExifResponseDto({
    this.city,
    this.country,
    this.dateTimeOriginal,
    this.description,
    this.exifImageHeight,
    this.exifImageWidth,
    this.exposureTime,
    this.fNumber,
    this.fileSizeInByte,
    this.focalLength,
    this.iso,
    this.latitude,
    this.lensModel,
    this.longitude,
    this.make,
    this.model,
    this.modifyDate,
    this.orientation,
    this.projectionType,
    this.rating,
    this.state,
    this.timeZone,
  });

  factory ExifResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExifResponseDto();
    return ExifResponseDto(
      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      dateTimeOriginal: json["dateTimeOriginal"]?.toString(),
      description: json["description"]?.toString(),
      exifImageHeight: (json["exifImageHeight"] as num?)?.toInt(),
      exifImageWidth: (json["exifImageWidth"] as num?)?.toInt(),
      exposureTime: json["exposureTime"]?.toString(),
      fNumber: (json["fNumber"] as num?)?.toDouble(),
      fileSizeInByte: (json["fileSizeInByte"] as num?)?.toInt(),
      focalLength: (json["focalLength"] as num?)?.toDouble(),
      iso: (json["iso"] as num?)?.toInt(),
      latitude: (json["latitude"] as num?)?.toDouble(),
      lensModel: json["lensModel"]?.toString(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      make: json["make"]?.toString(),
      model: json["model"]?.toString(),
      modifyDate: json["modifyDate"]?.toString(),
      orientation: json["orientation"]?.toString(),
      projectionType: json["projectionType"]?.toString(),
      rating: (json["rating"] as num?)?.toInt(),
      state: json["state"]?.toString(),
      timeZone: json["timeZone"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (city != null) "city": city,
    if (country != null) "country": country,
    if (dateTimeOriginal != null) "dateTimeOriginal": dateTimeOriginal,
    if (description != null) "description": description,
    if (exifImageHeight != null) "exifImageHeight": exifImageHeight,
    if (exifImageWidth != null) "exifImageWidth": exifImageWidth,
    if (exposureTime != null) "exposureTime": exposureTime,
    if (fNumber != null) "fNumber": fNumber,
    if (fileSizeInByte != null) "fileSizeInByte": fileSizeInByte,
    if (focalLength != null) "focalLength": focalLength,
    if (iso != null) "iso": iso,
    if (latitude != null) "latitude": latitude,
    if (lensModel != null) "lensModel": lensModel,
    if (longitude != null) "longitude": longitude,
    if (make != null) "make": make,
    if (model != null) "model": model,
    if (modifyDate != null) "modifyDate": modifyDate,
    if (orientation != null) "orientation": orientation,
    if (projectionType != null) "projectionType": projectionType,
    if (rating != null) "rating": rating,
    if (state != null) "state": state,
    if (timeZone != null) "timeZone": timeZone,
  };

  ExifResponseDto copyWith({
    String? city,
    String? country,
    String? dateTimeOriginal,
    String? description,
    int? exifImageHeight,
    int? exifImageWidth,
    String? exposureTime,
    double? fNumber,
    int? fileSizeInByte,
    double? focalLength,
    int? iso,
    double? latitude,
    String? lensModel,
    double? longitude,
    String? make,
    String? model,
    String? modifyDate,
    String? orientation,
    String? projectionType,
    int? rating,
    String? state,
    String? timeZone,
  }) {
    return ExifResponseDto(
      city: city ?? this.city,
      country: country ?? this.country,
      dateTimeOriginal: dateTimeOriginal ?? this.dateTimeOriginal,
      description: description ?? this.description,
      exifImageHeight: exifImageHeight ?? this.exifImageHeight,
      exifImageWidth: exifImageWidth ?? this.exifImageWidth,
      exposureTime: exposureTime ?? this.exposureTime,
      fNumber: fNumber ?? this.fNumber,
      fileSizeInByte: fileSizeInByte ?? this.fileSizeInByte,
      focalLength: focalLength ?? this.focalLength,
      iso: iso ?? this.iso,
      latitude: latitude ?? this.latitude,
      lensModel: lensModel ?? this.lensModel,
      longitude: longitude ?? this.longitude,
      make: make ?? this.make,
      model: model ?? this.model,
      modifyDate: modifyDate ?? this.modifyDate,
      orientation: orientation ?? this.orientation,
      projectionType: projectionType ?? this.projectionType,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      timeZone: timeZone ?? this.timeZone,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class FaceDto {
  final String? id;

  const FaceDto({
    this.id,
  });

  factory FaceDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FaceDto();
    return FaceDto(
      id: json["id"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) "id": id,
  };

  FaceDto copyWith({
    String? id,
  }) {
    return FaceDto(
      id: id ?? this.id,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class FoldersResponse {
  final bool? enabled;
  final bool? sidebarWeb;

  const FoldersResponse({
    this.enabled,
    this.sidebarWeb,
  });

  factory FoldersResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FoldersResponse();
    return FoldersResponse(
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  FoldersResponse copyWith({
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return FoldersResponse(
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class FoldersUpdate {
  final bool? enabled;
  final bool? sidebarWeb;

  const FoldersUpdate({
    this.enabled,
    this.sidebarWeb,
  });

  factory FoldersUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FoldersUpdate();
    return FoldersUpdate(
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  FoldersUpdate copyWith({
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return FoldersUpdate(
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class IdFilter {
  final String? eq;
  final String? ne;

  const IdFilter({
    this.eq,
    this.ne,
  });

  factory IdFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const IdFilter();
    return IdFilter(
      eq: json["eq"]?.toString(),
      ne: json["ne"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (ne != null) "ne": ne,
  };

  IdFilter copyWith({
    String? eq,
    String? ne,
  }) {
    return IdFilter(
      eq: eq ?? this.eq,
      ne: ne ?? this.ne,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class IdFilterNullable {
  final String? eq;
  final String? ne;

  const IdFilterNullable({
    this.eq,
    this.ne,
  });

  factory IdFilterNullable.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const IdFilterNullable();
    return IdFilterNullable(
      eq: json["eq"]?.toString(),
      ne: json["ne"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (ne != null) "ne": ne,
  };

  IdFilterNullable copyWith({
    String? eq,
    String? ne,
  }) {
    return IdFilterNullable(
      eq: eq ?? this.eq,
      ne: ne ?? this.ne,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class IdsFilter {
  final List<String>? all;
  final List<String>? any;
  final List<String>? none;

  const IdsFilter({
    this.all,
    this.any,
    this.none,
  });

  factory IdsFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const IdsFilter();
    return IdsFilter(
      all: ((json["all"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      any: ((json["any"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      none: ((json["none"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (all != null) "all": all,
    if (any != null) "any": any,
    if (none != null) "none": none,
  };

  IdsFilter copyWith({
    List<String>? all,
    List<String>? any,
    List<String>? none,
  }) {
    return IdsFilter(
      all: all ?? this.all,
      any: any ?? this.any,
      none: none ?? this.none,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class LibraryResponseDto {
  final int? assetCount;
  final String? createdAt;
  final List<String>? exclusionPatterns;
  final String? id;
  final List<String>? importPaths;
  final String? name;
  final String? ownerId;
  final String? refreshedAt;
  final String? updatedAt;

  const LibraryResponseDto({
    this.assetCount,
    this.createdAt,
    this.exclusionPatterns,
    this.id,
    this.importPaths,
    this.name,
    this.ownerId,
    this.refreshedAt,
    this.updatedAt,
  });

  factory LibraryResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LibraryResponseDto();
    return LibraryResponseDto(
      assetCount: (json["assetCount"] as num?)?.toInt(),
      createdAt: json["createdAt"]?.toString(),
      exclusionPatterns: ((json["exclusionPatterns"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      id: json["id"]?.toString(),
      importPaths: ((json["importPaths"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      name: json["name"]?.toString(),
      ownerId: json["ownerId"]?.toString(),
      refreshedAt: json["refreshedAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetCount != null) "assetCount": assetCount,
    if (createdAt != null) "createdAt": createdAt,
    if (exclusionPatterns != null) "exclusionPatterns": exclusionPatterns,
    if (id != null) "id": id,
    if (importPaths != null) "importPaths": importPaths,
    if (name != null) "name": name,
    if (ownerId != null) "ownerId": ownerId,
    if (refreshedAt != null) "refreshedAt": refreshedAt,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  LibraryResponseDto copyWith({
    int? assetCount,
    String? createdAt,
    List<String>? exclusionPatterns,
    String? id,
    List<String>? importPaths,
    String? name,
    String? ownerId,
    String? refreshedAt,
    String? updatedAt,
  }) {
    return LibraryResponseDto(
      assetCount: assetCount ?? this.assetCount,
      createdAt: createdAt ?? this.createdAt,
      exclusionPatterns: exclusionPatterns ?? this.exclusionPatterns,
      id: id ?? this.id,
      importPaths: importPaths ?? this.importPaths,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      refreshedAt: refreshedAt ?? this.refreshedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class LibraryStatsResponseDto {
  final int? photos;
  final int? total;
  final int? usage;
  final int? videos;

  const LibraryStatsResponseDto({
    this.photos,
    this.total,
    this.usage,
    this.videos,
  });

  factory LibraryStatsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LibraryStatsResponseDto();
    return LibraryStatsResponseDto(
      photos: (json["photos"] as num?)?.toInt(),
      total: (json["total"] as num?)?.toInt(),
      usage: (json["usage"] as num?)?.toInt(),
      videos: (json["videos"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (photos != null) "photos": photos,
    if (total != null) "total": total,
    if (usage != null) "usage": usage,
    if (videos != null) "videos": videos,
  };

  LibraryStatsResponseDto copyWith({
    int? photos,
    int? total,
    int? usage,
    int? videos,
  }) {
    return LibraryStatsResponseDto(
      photos: photos ?? this.photos,
      total: total ?? this.total,
      usage: usage ?? this.usage,
      videos: videos ?? this.videos,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class LicenseKeyDto {
  final String? activationKey;
  final String? licenseKey;

  const LicenseKeyDto({
    this.activationKey,
    this.licenseKey,
  });

  factory LicenseKeyDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LicenseKeyDto();
    return LicenseKeyDto(
      activationKey: json["activationKey"]?.toString(),
      licenseKey: json["licenseKey"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (activationKey != null) "activationKey": activationKey,
    if (licenseKey != null) "licenseKey": licenseKey,
  };

  LicenseKeyDto copyWith({
    String? activationKey,
    String? licenseKey,
  }) {
    return LicenseKeyDto(
      activationKey: activationKey ?? this.activationKey,
      licenseKey: licenseKey ?? this.licenseKey,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class LoginCredentialDto {
  final String? email;
  final String? password;

  const LoginCredentialDto({
    this.email,
    this.password,
  });

  factory LoginCredentialDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LoginCredentialDto();
    return LoginCredentialDto(
      email: json["email"]?.toString(),
      password: json["password"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (email != null) "email": email,
    if (password != null) "password": password,
  };

  LoginCredentialDto copyWith({
    String? email,
    String? password,
  }) {
    return LoginCredentialDto(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class LoginResponseDto {
  final String? accessToken;
  final bool? isAdmin;
  final bool? isOnboarded;
  final String? name;
  final String? profileImagePath;
  final bool? shouldChangePassword;
  final String? userEmail;
  final String? userId;

  const LoginResponseDto({
    this.accessToken,
    this.isAdmin,
    this.isOnboarded,
    this.name,
    this.profileImagePath,
    this.shouldChangePassword,
    this.userEmail,
    this.userId,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LoginResponseDto();
    return LoginResponseDto(
      accessToken: json["accessToken"]?.toString(),
      isAdmin: (json["isAdmin"] as bool?),
      isOnboarded: (json["isOnboarded"] as bool?),
      name: json["name"]?.toString(),
      profileImagePath: json["profileImagePath"]?.toString(),
      shouldChangePassword: (json["shouldChangePassword"] as bool?),
      userEmail: json["userEmail"]?.toString(),
      userId: json["userId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (accessToken != null) "accessToken": accessToken,
    if (isAdmin != null) "isAdmin": isAdmin,
    if (isOnboarded != null) "isOnboarded": isOnboarded,
    if (name != null) "name": name,
    if (profileImagePath != null) "profileImagePath": profileImagePath,
    if (shouldChangePassword != null) "shouldChangePassword": shouldChangePassword,
    if (userEmail != null) "userEmail": userEmail,
    if (userId != null) "userId": userId,
  };

  LoginResponseDto copyWith({
    String? accessToken,
    bool? isAdmin,
    bool? isOnboarded,
    String? name,
    String? profileImagePath,
    bool? shouldChangePassword,
    String? userEmail,
    String? userId,
  }) {
    return LoginResponseDto(
      accessToken: accessToken ?? this.accessToken,
      isAdmin: isAdmin ?? this.isAdmin,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      name: name ?? this.name,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      shouldChangePassword: shouldChangePassword ?? this.shouldChangePassword,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class LogoutResponseDto {
  final String? redirectUri;
  final bool? successful;

  const LogoutResponseDto({
    this.redirectUri,
    this.successful,
  });

  factory LogoutResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LogoutResponseDto();
    return LogoutResponseDto(
      redirectUri: json["redirectUri"]?.toString(),
      successful: (json["successful"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (redirectUri != null) "redirectUri": redirectUri,
    if (successful != null) "successful": successful,
  };

  LogoutResponseDto copyWith({
    String? redirectUri,
    bool? successful,
  }) {
    return LogoutResponseDto(
      redirectUri: redirectUri ?? this.redirectUri,
      successful: successful ?? this.successful,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MapMarkerResponseDto {
  final String? city;
  final String? country;
  final String? id;
  final double? lat;
  final double? lon;
  final String? state;

  const MapMarkerResponseDto({
    this.city,
    this.country,
    this.id,
    this.lat,
    this.lon,
    this.state,
  });

  factory MapMarkerResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MapMarkerResponseDto();
    return MapMarkerResponseDto(
      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      id: json["id"]?.toString(),
      lat: (json["lat"] as num?)?.toDouble(),
      lon: (json["lon"] as num?)?.toDouble(),
      state: json["state"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (city != null) "city": city,
    if (country != null) "country": country,
    if (id != null) "id": id,
    if (lat != null) "lat": lat,
    if (lon != null) "lon": lon,
    if (state != null) "state": state,
  };

  MapMarkerResponseDto copyWith({
    String? city,
    String? country,
    String? id,
    double? lat,
    double? lon,
    String? state,
  }) {
    return MapMarkerResponseDto(
      city: city ?? this.city,
      country: country ?? this.country,
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      state: state ?? this.state,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MapReverseGeocodeResponseDto {
  final String? city;
  final String? country;
  final String? state;

  const MapReverseGeocodeResponseDto({
    this.city,
    this.country,
    this.state,
  });

  factory MapReverseGeocodeResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MapReverseGeocodeResponseDto();
    return MapReverseGeocodeResponseDto(
      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      state: json["state"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (city != null) "city": city,
    if (country != null) "country": country,
    if (state != null) "state": state,
  };

  MapReverseGeocodeResponseDto copyWith({
    String? city,
    String? country,
    String? state,
  }) {
    return MapReverseGeocodeResponseDto(
      city: city ?? this.city,
      country: country ?? this.country,
      state: state ?? this.state,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MemoriesResponse {
  final int? duration;
  final bool? enabled;
  final bool? sidebarWeb;

  const MemoriesResponse({
    this.duration,
    this.enabled,
    this.sidebarWeb,
  });

  factory MemoriesResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemoriesResponse();
    return MemoriesResponse(
      duration: (json["duration"] as num?)?.toInt(),
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (duration != null) "duration": duration,
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  MemoriesResponse copyWith({
    int? duration,
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return MemoriesResponse(
      duration: duration ?? this.duration,
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MemoriesUpdate {
  final int? duration;
  final bool? enabled;
  final bool? sidebarWeb;

  const MemoriesUpdate({
    this.duration,
    this.enabled,
    this.sidebarWeb,
  });

  factory MemoriesUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemoriesUpdate();
    return MemoriesUpdate(
      duration: (json["duration"] as num?)?.toInt(),
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (duration != null) "duration": duration,
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  MemoriesUpdate copyWith({
    int? duration,
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return MemoriesUpdate(
      duration: duration ?? this.duration,
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MemoryCreateDto {
  final List<String>? assetIds;
  final MemoryDataDto? data;
  final String? hideAt;
  final bool? isSaved;
  final String? memoryAt;
  final String? seenAt;
  final String? showAt;
  final MemoryType? type;

  const MemoryCreateDto({
    this.assetIds,
    this.data,
    this.hideAt,
    this.isSaved,
    this.memoryAt,
    this.seenAt,
    this.showAt,
    this.type,
  });

  factory MemoryCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemoryCreateDto();
    return MemoryCreateDto(
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      data: MemoryDataDto.fromJson((json["data"] as Map<String, dynamic>?)),
      hideAt: json["hideAt"]?.toString(),
      isSaved: (json["isSaved"] as bool?),
      memoryAt: json["memoryAt"]?.toString(),
      seenAt: json["seenAt"]?.toString(),
      showAt: json["showAt"]?.toString(),
      type: _memoryTypeFromJson(json["type"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetIds != null) "assetIds": assetIds,
    if (data != null) "data": data?.toJson(),
    if (hideAt != null) "hideAt": hideAt,
    if (isSaved != null) "isSaved": isSaved,
    if (memoryAt != null) "memoryAt": memoryAt,
    if (seenAt != null) "seenAt": seenAt,
    if (showAt != null) "showAt": showAt,
    if (type != null) "type": type?.value,
  };

  MemoryCreateDto copyWith({
    List<String>? assetIds,
    MemoryDataDto? data,
    String? hideAt,
    bool? isSaved,
    String? memoryAt,
    String? seenAt,
    String? showAt,
    MemoryType? type,
  }) {
    return MemoryCreateDto(
      assetIds: assetIds ?? this.assetIds,
      data: data ?? this.data,
      hideAt: hideAt ?? this.hideAt,
      isSaved: isSaved ?? this.isSaved,
      memoryAt: memoryAt ?? this.memoryAt,
      seenAt: seenAt ?? this.seenAt,
      showAt: showAt ?? this.showAt,
      type: type ?? this.type,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MemoryDataDto {
  final String? personId;
  final String? personName;
  final int? year;

  const MemoryDataDto({
    this.personId,
    this.personName,
    this.year,
  });

  factory MemoryDataDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemoryDataDto();
    return MemoryDataDto(
      personId: json["personId"]?.toString(),
      personName: json["personName"]?.toString(),
      year: (json["year"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (personId != null) "personId": personId,
    if (personName != null) "personName": personName,
    if (year != null) "year": year,
  };

  MemoryDataDto copyWith({
    String? personId,
    String? personName,
    int? year,
  }) {
    return MemoryDataDto(
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
      year: year ?? this.year,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MemoryResponseDto {
  final List<AssetResponseDto>? assets;
  final String? createdAt;
  final MemoryDataDto? data;
  final String? deletedAt;
  final String? hideAt;
  final String? id;
  final bool? isSaved;
  final String? memoryAt;
  final String? ownerId;
  final String? seenAt;
  final String? showAt;
  final MemoryType? type;
  final String? updatedAt;

  const MemoryResponseDto({
    this.assets,
    this.createdAt,
    this.data,
    this.deletedAt,
    this.hideAt,
    this.id,
    this.isSaved,
    this.memoryAt,
    this.ownerId,
    this.seenAt,
    this.showAt,
    this.type,
    this.updatedAt,
  });

  factory MemoryResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemoryResponseDto();
    return MemoryResponseDto(
      assets: ((json["assets"] as List<dynamic>?)?.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetResponseDto>().toList()),
      createdAt: json["createdAt"]?.toString(),
      data: MemoryDataDto.fromJson((json["data"] as Map<String, dynamic>?)),
      deletedAt: json["deletedAt"]?.toString(),
      hideAt: json["hideAt"]?.toString(),
      id: json["id"]?.toString(),
      isSaved: (json["isSaved"] as bool?),
      memoryAt: json["memoryAt"]?.toString(),
      ownerId: json["ownerId"]?.toString(),
      seenAt: json["seenAt"]?.toString(),
      showAt: json["showAt"]?.toString(),
      type: _memoryTypeFromJson(json["type"]?.toString()),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assets != null) "assets": assets?.map((e) => e?.toJson()).toList(),
    if (createdAt != null) "createdAt": createdAt,
    if (data != null) "data": data?.toJson(),
    if (deletedAt != null) "deletedAt": deletedAt,
    if (hideAt != null) "hideAt": hideAt,
    if (id != null) "id": id,
    if (isSaved != null) "isSaved": isSaved,
    if (memoryAt != null) "memoryAt": memoryAt,
    if (ownerId != null) "ownerId": ownerId,
    if (seenAt != null) "seenAt": seenAt,
    if (showAt != null) "showAt": showAt,
    if (type != null) "type": type?.value,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  MemoryResponseDto copyWith({
    List<AssetResponseDto>? assets,
    String? createdAt,
    MemoryDataDto? data,
    String? deletedAt,
    String? hideAt,
    String? id,
    bool? isSaved,
    String? memoryAt,
    String? ownerId,
    String? seenAt,
    String? showAt,
    MemoryType? type,
    String? updatedAt,
  }) {
    return MemoryResponseDto(
      assets: assets ?? this.assets,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      deletedAt: deletedAt ?? this.deletedAt,
      hideAt: hideAt ?? this.hideAt,
      id: id ?? this.id,
      isSaved: isSaved ?? this.isSaved,
      memoryAt: memoryAt ?? this.memoryAt,
      ownerId: ownerId ?? this.ownerId,
      seenAt: seenAt ?? this.seenAt,
      showAt: showAt ?? this.showAt,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MemoryStatisticsResponseDto {
  final int? total;

  const MemoryStatisticsResponseDto({
    this.total,
  });

  factory MemoryStatisticsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemoryStatisticsResponseDto();
    return MemoryStatisticsResponseDto(
      total: (json["total"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (total != null) "total": total,
  };

  MemoryStatisticsResponseDto copyWith({
    int? total,
  }) {
    return MemoryStatisticsResponseDto(
      total: total ?? this.total,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MemoryUpdateDto {
  final bool? isSaved;
  final String? memoryAt;
  final String? seenAt;

  const MemoryUpdateDto({
    this.isSaved,
    this.memoryAt,
    this.seenAt,
  });

  factory MemoryUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemoryUpdateDto();
    return MemoryUpdateDto(
      isSaved: (json["isSaved"] as bool?),
      memoryAt: json["memoryAt"]?.toString(),
      seenAt: json["seenAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (isSaved != null) "isSaved": isSaved,
    if (memoryAt != null) "memoryAt": memoryAt,
    if (seenAt != null) "seenAt": seenAt,
  };

  MemoryUpdateDto copyWith({
    bool? isSaved,
    String? memoryAt,
    String? seenAt,
  }) {
    return MemoryUpdateDto(
      isSaved: isSaved ?? this.isSaved,
      memoryAt: memoryAt ?? this.memoryAt,
      seenAt: seenAt ?? this.seenAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MergePersonDto {
  final List<String>? ids;

  const MergePersonDto({
    this.ids,
  });

  factory MergePersonDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MergePersonDto();
    return MergePersonDto(
      ids: ((json["ids"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ids != null) "ids": ids,
  };

  MergePersonDto copyWith({
    List<String>? ids,
  }) {
    return MergePersonDto(
      ids: ids ?? this.ids,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MetadataSearchDto {
  final List<String>? albumIds;
  final String? checksum;
  final String? city;
  final String? country;
  final String? createdAfter;
  final String? createdBefore;
  final String? cursor;
  final String? description;
  final String? encodedVideoPath;
  final SearchFilter? filter;
  final String? id;
  final bool? isEncoded;
  final bool? isFavorite;
  final bool? isMotion;
  final bool? isNotInAlbum;
  final bool? isOffline;
  final String? lensModel;
  final String? libraryId;
  final String? make;
  final String? model;
  final String? ocr;
  final AssetOrder? order;
  final SearchOrder? orderBy;
  final String? originalFileName;
  final String? originalPath;
  final int? page;
  final List<String>? personIds;
  final String? previewPath;
  final int? rating;
  final int? size;
  final String? state;
  final List<String>? tagIds;
  final String? takenAfter;
  final String? takenBefore;
  final String? thumbnailPath;
  final String? trashedAfter;
  final String? trashedBefore;
  final AssetTypeEnum? type;
  final String? updatedAfter;
  final String? updatedBefore;
  final AssetVisibility? visibility;
  final bool? withDeleted;
  final bool? withExif;
  final bool? withPeople;
  final bool? withStacked;

  const MetadataSearchDto({
    this.albumIds,
    this.checksum,
    this.city,
    this.country,
    this.createdAfter,
    this.createdBefore,
    this.cursor,
    this.description,
    this.encodedVideoPath,
    this.filter,
    this.id,
    this.isEncoded,
    this.isFavorite,
    this.isMotion,
    this.isNotInAlbum,
    this.isOffline,
    this.lensModel,
    this.libraryId,
    this.make,
    this.model,
    this.ocr,
    this.order,
    this.orderBy,
    this.originalFileName,
    this.originalPath,
    this.page,
    this.personIds,
    this.previewPath,
    this.rating,
    this.size,
    this.state,
    this.tagIds,
    this.takenAfter,
    this.takenBefore,
    this.thumbnailPath,
    this.trashedAfter,
    this.trashedBefore,
    this.type,
    this.updatedAfter,
    this.updatedBefore,
    this.visibility,
    this.withDeleted,
    this.withExif,
    this.withPeople,
    this.withStacked,
  });

  factory MetadataSearchDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MetadataSearchDto();
    return MetadataSearchDto(
      albumIds: ((json["albumIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      checksum: json["checksum"]?.toString(),
      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      createdAfter: json["createdAfter"]?.toString(),
      createdBefore: json["createdBefore"]?.toString(),
      cursor: json["cursor"]?.toString(),
      description: json["description"]?.toString(),
      encodedVideoPath: json["encodedVideoPath"]?.toString(),
      filter: SearchFilter.fromJson((json["filter"] as Map<String, dynamic>?)),
      id: json["id"]?.toString(),
      isEncoded: (json["isEncoded"] as bool?),
      isFavorite: (json["isFavorite"] as bool?),
      isMotion: (json["isMotion"] as bool?),
      isNotInAlbum: (json["isNotInAlbum"] as bool?),
      isOffline: (json["isOffline"] as bool?),
      lensModel: json["lensModel"]?.toString(),
      libraryId: json["libraryId"]?.toString(),
      make: json["make"]?.toString(),
      model: json["model"]?.toString(),
      ocr: json["ocr"]?.toString(),
      order: _assetOrderFromJson(json["order"]?.toString()),
      orderBy: SearchOrder.fromJson((json["orderBy"] as Map<String, dynamic>?)),
      originalFileName: json["originalFileName"]?.toString(),
      originalPath: json["originalPath"]?.toString(),
      page: (json["page"] as num?)?.toInt(),
      personIds: ((json["personIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      previewPath: json["previewPath"]?.toString(),
      rating: (json["rating"] as num?)?.toInt(),
      size: (json["size"] as num?)?.toInt(),
      state: json["state"]?.toString(),
      tagIds: ((json["tagIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      takenAfter: json["takenAfter"]?.toString(),
      takenBefore: json["takenBefore"]?.toString(),
      thumbnailPath: json["thumbnailPath"]?.toString(),
      trashedAfter: json["trashedAfter"]?.toString(),
      trashedBefore: json["trashedBefore"]?.toString(),
      type: _assetTypeEnumFromJson(json["type"]?.toString()),
      updatedAfter: json["updatedAfter"]?.toString(),
      updatedBefore: json["updatedBefore"]?.toString(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
      withDeleted: (json["withDeleted"] as bool?),
      withExif: (json["withExif"] as bool?),
      withPeople: (json["withPeople"] as bool?),
      withStacked: (json["withStacked"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumIds != null) "albumIds": albumIds,
    if (checksum != null) "checksum": checksum,
    if (city != null) "city": city,
    if (country != null) "country": country,
    if (createdAfter != null) "createdAfter": createdAfter,
    if (createdBefore != null) "createdBefore": createdBefore,
    if (cursor != null) "cursor": cursor,
    if (description != null) "description": description,
    if (encodedVideoPath != null) "encodedVideoPath": encodedVideoPath,
    if (filter != null) "filter": filter?.toJson(),
    if (id != null) "id": id,
    if (isEncoded != null) "isEncoded": isEncoded,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isMotion != null) "isMotion": isMotion,
    if (isNotInAlbum != null) "isNotInAlbum": isNotInAlbum,
    if (isOffline != null) "isOffline": isOffline,
    if (lensModel != null) "lensModel": lensModel,
    if (libraryId != null) "libraryId": libraryId,
    if (make != null) "make": make,
    if (model != null) "model": model,
    if (ocr != null) "ocr": ocr,
    if (order != null) "order": order?.value,
    if (orderBy != null) "orderBy": orderBy?.toJson(),
    if (originalFileName != null) "originalFileName": originalFileName,
    if (originalPath != null) "originalPath": originalPath,
    if (page != null) "page": page,
    if (personIds != null) "personIds": personIds,
    if (previewPath != null) "previewPath": previewPath,
    if (rating != null) "rating": rating,
    if (size != null) "size": size,
    if (state != null) "state": state,
    if (tagIds != null) "tagIds": tagIds,
    if (takenAfter != null) "takenAfter": takenAfter,
    if (takenBefore != null) "takenBefore": takenBefore,
    if (thumbnailPath != null) "thumbnailPath": thumbnailPath,
    if (trashedAfter != null) "trashedAfter": trashedAfter,
    if (trashedBefore != null) "trashedBefore": trashedBefore,
    if (type != null) "type": type?.value,
    if (updatedAfter != null) "updatedAfter": updatedAfter,
    if (updatedBefore != null) "updatedBefore": updatedBefore,
    if (visibility != null) "visibility": visibility?.value,
    if (withDeleted != null) "withDeleted": withDeleted,
    if (withExif != null) "withExif": withExif,
    if (withPeople != null) "withPeople": withPeople,
    if (withStacked != null) "withStacked": withStacked,
  };

  MetadataSearchDto copyWith({
    List<String>? albumIds,
    String? checksum,
    String? city,
    String? country,
    String? createdAfter,
    String? createdBefore,
    String? cursor,
    String? description,
    String? encodedVideoPath,
    SearchFilter? filter,
    String? id,
    bool? isEncoded,
    bool? isFavorite,
    bool? isMotion,
    bool? isNotInAlbum,
    bool? isOffline,
    String? lensModel,
    String? libraryId,
    String? make,
    String? model,
    String? ocr,
    AssetOrder? order,
    SearchOrder? orderBy,
    String? originalFileName,
    String? originalPath,
    int? page,
    List<String>? personIds,
    String? previewPath,
    int? rating,
    int? size,
    String? state,
    List<String>? tagIds,
    String? takenAfter,
    String? takenBefore,
    String? thumbnailPath,
    String? trashedAfter,
    String? trashedBefore,
    AssetTypeEnum? type,
    String? updatedAfter,
    String? updatedBefore,
    AssetVisibility? visibility,
    bool? withDeleted,
    bool? withExif,
    bool? withPeople,
    bool? withStacked,
  }) {
    return MetadataSearchDto(
      albumIds: albumIds ?? this.albumIds,
      checksum: checksum ?? this.checksum,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      cursor: cursor ?? this.cursor,
      description: description ?? this.description,
      encodedVideoPath: encodedVideoPath ?? this.encodedVideoPath,
      filter: filter ?? this.filter,
      id: id ?? this.id,
      isEncoded: isEncoded ?? this.isEncoded,
      isFavorite: isFavorite ?? this.isFavorite,
      isMotion: isMotion ?? this.isMotion,
      isNotInAlbum: isNotInAlbum ?? this.isNotInAlbum,
      isOffline: isOffline ?? this.isOffline,
      lensModel: lensModel ?? this.lensModel,
      libraryId: libraryId ?? this.libraryId,
      make: make ?? this.make,
      model: model ?? this.model,
      ocr: ocr ?? this.ocr,
      order: order ?? this.order,
      orderBy: orderBy ?? this.orderBy,
      originalFileName: originalFileName ?? this.originalFileName,
      originalPath: originalPath ?? this.originalPath,
      page: page ?? this.page,
      personIds: personIds ?? this.personIds,
      previewPath: previewPath ?? this.previewPath,
      rating: rating ?? this.rating,
      size: size ?? this.size,
      state: state ?? this.state,
      tagIds: tagIds ?? this.tagIds,
      takenAfter: takenAfter ?? this.takenAfter,
      takenBefore: takenBefore ?? this.takenBefore,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      trashedAfter: trashedAfter ?? this.trashedAfter,
      trashedBefore: trashedBefore ?? this.trashedBefore,
      type: type ?? this.type,
      updatedAfter: updatedAfter ?? this.updatedAfter,
      updatedBefore: updatedBefore ?? this.updatedBefore,
      visibility: visibility ?? this.visibility,
      withDeleted: withDeleted ?? this.withDeleted,
      withExif: withExif ?? this.withExif,
      withPeople: withPeople ?? this.withPeople,
      withStacked: withStacked ?? this.withStacked,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class MirrorParameters {
  final MirrorAxis? axis;

  const MirrorParameters({
    this.axis,
  });

  factory MirrorParameters.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MirrorParameters();
    return MirrorParameters(
      axis: _mirrorAxisFromJson(json["axis"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (axis != null) "axis": axis?.value,
  };

  MirrorParameters copyWith({
    MirrorAxis? axis,
  }) {
    return MirrorParameters(
      axis: axis ?? this.axis,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class NotificationDeleteAllDto {
  final List<String>? ids;

  const NotificationDeleteAllDto({
    this.ids,
  });

  factory NotificationDeleteAllDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationDeleteAllDto();
    return NotificationDeleteAllDto(
      ids: ((json["ids"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ids != null) "ids": ids,
  };

  NotificationDeleteAllDto copyWith({
    List<String>? ids,
  }) {
    return NotificationDeleteAllDto(
      ids: ids ?? this.ids,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class NotificationDto {
  final String? createdAt;
  final Map<String, dynamic>? data;
  final String? description;
  final String? id;
  final NotificationLevel? level;
  final String? readAt;
  final String? title;
  final NotificationType? type;

  const NotificationDto({
    this.createdAt,
    this.data,
    this.description,
    this.id,
    this.level,
    this.readAt,
    this.title,
    this.type,
  });

  factory NotificationDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationDto();
    return NotificationDto(
      createdAt: json["createdAt"]?.toString(),
      data: (json["data"] as Map<String, dynamic>?),
      description: json["description"]?.toString(),
      id: json["id"]?.toString(),
      level: _notificationLevelFromJson(json["level"]?.toString()),
      readAt: json["readAt"]?.toString(),
      title: json["title"]?.toString(),
      type: _notificationTypeFromJson(json["type"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (createdAt != null) "createdAt": createdAt,
    if (data != null) "data": data,
    if (description != null) "description": description,
    if (id != null) "id": id,
    if (level != null) "level": level?.value,
    if (readAt != null) "readAt": readAt,
    if (title != null) "title": title,
    if (type != null) "type": type?.value,
  };

  NotificationDto copyWith({
    String? createdAt,
    Map<String, dynamic>? data,
    String? description,
    String? id,
    NotificationLevel? level,
    String? readAt,
    String? title,
    NotificationType? type,
  }) {
    return NotificationDto(
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      description: description ?? this.description,
      id: id ?? this.id,
      level: level ?? this.level,
      readAt: readAt ?? this.readAt,
      title: title ?? this.title,
      type: type ?? this.type,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class NotificationUpdateAllDto {
  final List<String>? ids;
  final String? readAt;

  const NotificationUpdateAllDto({
    this.ids,
    this.readAt,
  });

  factory NotificationUpdateAllDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationUpdateAllDto();
    return NotificationUpdateAllDto(
      ids: ((json["ids"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      readAt: json["readAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ids != null) "ids": ids,
    if (readAt != null) "readAt": readAt,
  };

  NotificationUpdateAllDto copyWith({
    List<String>? ids,
    String? readAt,
  }) {
    return NotificationUpdateAllDto(
      ids: ids ?? this.ids,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class NotificationUpdateDto {
  final String? readAt;

  const NotificationUpdateDto({
    this.readAt,
  });

  factory NotificationUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationUpdateDto();
    return NotificationUpdateDto(
      readAt: json["readAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (readAt != null) "readAt": readAt,
  };

  NotificationUpdateDto copyWith({
    String? readAt,
  }) {
    return NotificationUpdateDto(
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class NumberFilter {
  final double? eq;
  final double? gt;
  final double? gte;
  final List<double>? in_;
  final double? lt;
  final double? lte;
  final double? ne;
  final List<double>? notIn;

  const NumberFilter({
    this.eq,
    this.gt,
    this.gte,
    this.in_,
    this.lt,
    this.lte,
    this.ne,
    this.notIn,
  });

  factory NumberFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NumberFilter();
    return NumberFilter(
      eq: (json["eq"] as num?)?.toDouble(),
      gt: (json["gt"] as num?)?.toDouble(),
      gte: (json["gte"] as num?)?.toDouble(),
      in_: ((json["in"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).whereType<double>().toList()),
      lt: (json["lt"] as num?)?.toDouble(),
      lte: (json["lte"] as num?)?.toDouble(),
      ne: (json["ne"] as num?)?.toDouble(),
      notIn: ((json["notIn"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).whereType<double>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (gt != null) "gt": gt,
    if (gte != null) "gte": gte,
    if (in_ != null) "in": in_,
    if (lt != null) "lt": lt,
    if (lte != null) "lte": lte,
    if (ne != null) "ne": ne,
    if (notIn != null) "notIn": notIn,
  };

  NumberFilter copyWith({
    double? eq,
    double? gt,
    double? gte,
    List<double>? in_,
    double? lt,
    double? lte,
    double? ne,
    List<double>? notIn,
  }) {
    return NumberFilter(
      eq: eq ?? this.eq,
      gt: gt ?? this.gt,
      gte: gte ?? this.gte,
      in_: in_ ?? this.in_,
      lt: lt ?? this.lt,
      lte: lte ?? this.lte,
      ne: ne ?? this.ne,
      notIn: notIn ?? this.notIn,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class NumberFilterNullable {
  final double? eq;
  final double? gt;
  final double? gte;
  final List<double>? in_;
  final double? lt;
  final double? lte;
  final double? ne;
  final List<double>? notIn;

  const NumberFilterNullable({
    this.eq,
    this.gt,
    this.gte,
    this.in_,
    this.lt,
    this.lte,
    this.ne,
    this.notIn,
  });

  factory NumberFilterNullable.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NumberFilterNullable();
    return NumberFilterNullable(
      eq: (json["eq"] as num?)?.toDouble(),
      gt: (json["gt"] as num?)?.toDouble(),
      gte: (json["gte"] as num?)?.toDouble(),
      in_: ((json["in"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).whereType<double>().toList()),
      lt: (json["lt"] as num?)?.toDouble(),
      lte: (json["lte"] as num?)?.toDouble(),
      ne: (json["ne"] as num?)?.toDouble(),
      notIn: ((json["notIn"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).whereType<double>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (gt != null) "gt": gt,
    if (gte != null) "gte": gte,
    if (in_ != null) "in": in_,
    if (lt != null) "lt": lt,
    if (lte != null) "lte": lte,
    if (ne != null) "ne": ne,
    if (notIn != null) "notIn": notIn,
  };

  NumberFilterNullable copyWith({
    double? eq,
    double? gt,
    double? gte,
    List<double>? in_,
    double? lt,
    double? lte,
    double? ne,
    List<double>? notIn,
  }) {
    return NumberFilterNullable(
      eq: eq ?? this.eq,
      gt: gt ?? this.gt,
      gte: gte ?? this.gte,
      in_: in_ ?? this.in_,
      lt: lt ?? this.lt,
      lte: lte ?? this.lte,
      ne: ne ?? this.ne,
      notIn: notIn ?? this.notIn,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class OAuthAuthorizeResponseDto {
  final String? url;

  const OAuthAuthorizeResponseDto({
    this.url,
  });

  factory OAuthAuthorizeResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OAuthAuthorizeResponseDto();
    return OAuthAuthorizeResponseDto(
      url: json["url"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (url != null) "url": url,
  };

  OAuthAuthorizeResponseDto copyWith({
    String? url,
  }) {
    return OAuthAuthorizeResponseDto(
      url: url ?? this.url,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class OAuthCallbackDto {
  final String? codeVerifier;
  final String? state;
  final String? url;

  const OAuthCallbackDto({
    this.codeVerifier,
    this.state,
    this.url,
  });

  factory OAuthCallbackDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OAuthCallbackDto();
    return OAuthCallbackDto(
      codeVerifier: json["codeVerifier"]?.toString(),
      state: json["state"]?.toString(),
      url: json["url"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (codeVerifier != null) "codeVerifier": codeVerifier,
    if (state != null) "state": state,
    if (url != null) "url": url,
  };

  OAuthCallbackDto copyWith({
    String? codeVerifier,
    String? state,
    String? url,
  }) {
    return OAuthCallbackDto(
      codeVerifier: codeVerifier ?? this.codeVerifier,
      state: state ?? this.state,
      url: url ?? this.url,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class OAuthConfigDto {
  final String? codeChallenge;
  final String? redirectUri;
  final String? state;

  const OAuthConfigDto({
    this.codeChallenge,
    this.redirectUri,
    this.state,
  });

  factory OAuthConfigDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OAuthConfigDto();
    return OAuthConfigDto(
      codeChallenge: json["codeChallenge"]?.toString(),
      redirectUri: json["redirectUri"]?.toString(),
      state: json["state"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (codeChallenge != null) "codeChallenge": codeChallenge,
    if (redirectUri != null) "redirectUri": redirectUri,
    if (state != null) "state": state,
  };

  OAuthConfigDto copyWith({
    String? codeChallenge,
    String? redirectUri,
    String? state,
  }) {
    return OAuthConfigDto(
      codeChallenge: codeChallenge ?? this.codeChallenge,
      redirectUri: redirectUri ?? this.redirectUri,
      state: state ?? this.state,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class OnboardingDto {
  final bool? isOnboarded;

  const OnboardingDto({
    this.isOnboarded,
  });

  factory OnboardingDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OnboardingDto();
    return OnboardingDto(
      isOnboarded: (json["isOnboarded"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (isOnboarded != null) "isOnboarded": isOnboarded,
  };

  OnboardingDto copyWith({
    bool? isOnboarded,
  }) {
    return OnboardingDto(
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class OnboardingResponseDto {
  final bool? isOnboarded;

  const OnboardingResponseDto({
    this.isOnboarded,
  });

  factory OnboardingResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OnboardingResponseDto();
    return OnboardingResponseDto(
      isOnboarded: (json["isOnboarded"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (isOnboarded != null) "isOnboarded": isOnboarded,
  };

  OnboardingResponseDto copyWith({
    bool? isOnboarded,
  }) {
    return OnboardingResponseDto(
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PartnerCreateDto {
  final String? sharedWithId;

  const PartnerCreateDto({
    this.sharedWithId,
  });

  factory PartnerCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PartnerCreateDto();
    return PartnerCreateDto(
      sharedWithId: json["sharedWithId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (sharedWithId != null) "sharedWithId": sharedWithId,
  };

  PartnerCreateDto copyWith({
    String? sharedWithId,
  }) {
    return PartnerCreateDto(
      sharedWithId: sharedWithId ?? this.sharedWithId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PartnerResponseDto {
  final UserAvatarColor? avatarColor;
  final String? email;
  final String? id;
  final bool? inTimeline;
  final String? name;
  final String? profileChangedAt;
  final String? profileImagePath;

  const PartnerResponseDto({
    this.avatarColor,
    this.email,
    this.id,
    this.inTimeline,
    this.name,
    this.profileChangedAt,
    this.profileImagePath,
  });

  factory PartnerResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PartnerResponseDto();
    return PartnerResponseDto(
      avatarColor: _userAvatarColorFromJson(json["avatarColor"]?.toString()),
      email: json["email"]?.toString(),
      id: json["id"]?.toString(),
      inTimeline: (json["inTimeline"] as bool?),
      name: json["name"]?.toString(),
      profileChangedAt: json["profileChangedAt"]?.toString(),
      profileImagePath: json["profileImagePath"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (avatarColor != null) "avatarColor": avatarColor?.value,
    if (email != null) "email": email,
    if (id != null) "id": id,
    if (inTimeline != null) "inTimeline": inTimeline,
    if (name != null) "name": name,
    if (profileChangedAt != null) "profileChangedAt": profileChangedAt,
    if (profileImagePath != null) "profileImagePath": profileImagePath,
  };

  PartnerResponseDto copyWith({
    UserAvatarColor? avatarColor,
    String? email,
    String? id,
    bool? inTimeline,
    String? name,
    String? profileChangedAt,
    String? profileImagePath,
  }) {
    return PartnerResponseDto(
      avatarColor: avatarColor ?? this.avatarColor,
      email: email ?? this.email,
      id: id ?? this.id,
      inTimeline: inTimeline ?? this.inTimeline,
      name: name ?? this.name,
      profileChangedAt: profileChangedAt ?? this.profileChangedAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PartnerUpdateDto {
  final bool? inTimeline;

  const PartnerUpdateDto({
    this.inTimeline,
  });

  factory PartnerUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PartnerUpdateDto();
    return PartnerUpdateDto(
      inTimeline: (json["inTimeline"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (inTimeline != null) "inTimeline": inTimeline,
  };

  PartnerUpdateDto copyWith({
    bool? inTimeline,
  }) {
    return PartnerUpdateDto(
      inTimeline: inTimeline ?? this.inTimeline,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PeopleResponse {
  final bool? enabled;
  final int? minimumFaces;
  final bool? sidebarWeb;

  const PeopleResponse({
    this.enabled,
    this.minimumFaces,
    this.sidebarWeb,
  });

  factory PeopleResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PeopleResponse();
    return PeopleResponse(
      enabled: (json["enabled"] as bool?),
      minimumFaces: (json["minimumFaces"] as num?)?.toInt(),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (minimumFaces != null) "minimumFaces": minimumFaces,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  PeopleResponse copyWith({
    bool? enabled,
    int? minimumFaces,
    bool? sidebarWeb,
  }) {
    return PeopleResponse(
      enabled: enabled ?? this.enabled,
      minimumFaces: minimumFaces ?? this.minimumFaces,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PeopleResponseDto {
  final bool? hasNextPage;
  final int? hidden;
  final List<PersonResponseDto>? people;
  final int? total;

  const PeopleResponseDto({
    this.hasNextPage,
    this.hidden,
    this.people,
    this.total,
  });

  factory PeopleResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PeopleResponseDto();
    return PeopleResponseDto(
      hasNextPage: (json["hasNextPage"] as bool?),
      hidden: (json["hidden"] as num?)?.toInt(),
      people: ((json["people"] as List<dynamic>?)?.map((e) => PersonResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<PersonResponseDto>().toList()),
      total: (json["total"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (hasNextPage != null) "hasNextPage": hasNextPage,
    if (hidden != null) "hidden": hidden,
    if (people != null) "people": people?.map((e) => e?.toJson()).toList(),
    if (total != null) "total": total,
  };

  PeopleResponseDto copyWith({
    bool? hasNextPage,
    int? hidden,
    List<PersonResponseDto>? people,
    int? total,
  }) {
    return PeopleResponseDto(
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hidden: hidden ?? this.hidden,
      people: people ?? this.people,
      total: total ?? this.total,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PeopleUpdate {
  final bool? enabled;
  final int? minimumFaces;
  final bool? sidebarWeb;

  const PeopleUpdate({
    this.enabled,
    this.minimumFaces,
    this.sidebarWeb,
  });

  factory PeopleUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PeopleUpdate();
    return PeopleUpdate(
      enabled: (json["enabled"] as bool?),
      minimumFaces: (json["minimumFaces"] as num?)?.toInt(),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (minimumFaces != null) "minimumFaces": minimumFaces,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  PeopleUpdate copyWith({
    bool? enabled,
    int? minimumFaces,
    bool? sidebarWeb,
  }) {
    return PeopleUpdate(
      enabled: enabled ?? this.enabled,
      minimumFaces: minimumFaces ?? this.minimumFaces,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PeopleUpdateDto {
  final List<PeopleUpdateItem>? people;

  const PeopleUpdateDto({
    this.people,
  });

  factory PeopleUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PeopleUpdateDto();
    return PeopleUpdateDto(
      people: ((json["people"] as List<dynamic>?)?.map((e) => PeopleUpdateItem.fromJson((e as Map<String, dynamic>?))).whereType<PeopleUpdateItem>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (people != null) "people": people?.map((e) => e?.toJson()).toList(),
  };

  PeopleUpdateDto copyWith({
    List<PeopleUpdateItem>? people,
  }) {
    return PeopleUpdateDto(
      people: people ?? this.people,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PeopleUpdateItem {
  final String? birthDate;
  final String? color;
  final String? featureFaceAssetId;
  final String? id;
  final bool? isFavorite;
  final bool? isHidden;
  final String? name;

  const PeopleUpdateItem({
    this.birthDate,
    this.color,
    this.featureFaceAssetId,
    this.id,
    this.isFavorite,
    this.isHidden,
    this.name,
  });

  factory PeopleUpdateItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PeopleUpdateItem();
    return PeopleUpdateItem(
      birthDate: json["birthDate"]?.toString(),
      color: json["color"]?.toString(),
      featureFaceAssetId: json["featureFaceAssetId"]?.toString(),
      id: json["id"]?.toString(),
      isFavorite: (json["isFavorite"] as bool?),
      isHidden: (json["isHidden"] as bool?),
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (birthDate != null) "birthDate": birthDate,
    if (color != null) "color": color,
    if (featureFaceAssetId != null) "featureFaceAssetId": featureFaceAssetId,
    if (id != null) "id": id,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isHidden != null) "isHidden": isHidden,
    if (name != null) "name": name,
  };

  PeopleUpdateItem copyWith({
    String? birthDate,
    String? color,
    String? featureFaceAssetId,
    String? id,
    bool? isFavorite,
    bool? isHidden,
    String? name,
  }) {
    return PeopleUpdateItem(
      birthDate: birthDate ?? this.birthDate,
      color: color ?? this.color,
      featureFaceAssetId: featureFaceAssetId ?? this.featureFaceAssetId,
      id: id ?? this.id,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PersonCreateDto {
  final String? birthDate;
  final String? color;
  final bool? isFavorite;
  final bool? isHidden;
  final String? name;

  const PersonCreateDto({
    this.birthDate,
    this.color,
    this.isFavorite,
    this.isHidden,
    this.name,
  });

  factory PersonCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PersonCreateDto();
    return PersonCreateDto(
      birthDate: json["birthDate"]?.toString(),
      color: json["color"]?.toString(),
      isFavorite: (json["isFavorite"] as bool?),
      isHidden: (json["isHidden"] as bool?),
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (birthDate != null) "birthDate": birthDate,
    if (color != null) "color": color,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isHidden != null) "isHidden": isHidden,
    if (name != null) "name": name,
  };

  PersonCreateDto copyWith({
    String? birthDate,
    String? color,
    bool? isFavorite,
    bool? isHidden,
    String? name,
  }) {
    return PersonCreateDto(
      birthDate: birthDate ?? this.birthDate,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PersonResponseDto {
  final String? birthDate;
  final String? color;
  final String? id;
  final bool? isFavorite;
  final bool? isHidden;
  final String? name;
  final String? thumbnailPath;
  final String? updatedAt;

  const PersonResponseDto({
    this.birthDate,
    this.color,
    this.id,
    this.isFavorite,
    this.isHidden,
    this.name,
    this.thumbnailPath,
    this.updatedAt,
  });

  factory PersonResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PersonResponseDto();
    return PersonResponseDto(
      birthDate: json["birthDate"]?.toString(),
      color: json["color"]?.toString(),
      id: json["id"]?.toString(),
      isFavorite: (json["isFavorite"] as bool?),
      isHidden: (json["isHidden"] as bool?),
      name: json["name"]?.toString(),
      thumbnailPath: json["thumbnailPath"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (birthDate != null) "birthDate": birthDate,
    if (color != null) "color": color,
    if (id != null) "id": id,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isHidden != null) "isHidden": isHidden,
    if (name != null) "name": name,
    if (thumbnailPath != null) "thumbnailPath": thumbnailPath,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  PersonResponseDto copyWith({
    String? birthDate,
    String? color,
    String? id,
    bool? isFavorite,
    bool? isHidden,
    String? name,
    String? thumbnailPath,
    String? updatedAt,
  }) {
    return PersonResponseDto(
      birthDate: birthDate ?? this.birthDate,
      color: color ?? this.color,
      id: id ?? this.id,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      name: name ?? this.name,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PersonStatisticsResponseDto {
  final int? assets;

  const PersonStatisticsResponseDto({
    this.assets,
  });

  factory PersonStatisticsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PersonStatisticsResponseDto();
    return PersonStatisticsResponseDto(
      assets: (json["assets"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assets != null) "assets": assets,
  };

  PersonStatisticsResponseDto copyWith({
    int? assets,
  }) {
    return PersonStatisticsResponseDto(
      assets: assets ?? this.assets,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PersonUpdateDto {
  final String? birthDate;
  final String? color;
  final String? featureFaceAssetId;
  final bool? isFavorite;
  final bool? isHidden;
  final String? name;

  const PersonUpdateDto({
    this.birthDate,
    this.color,
    this.featureFaceAssetId,
    this.isFavorite,
    this.isHidden,
    this.name,
  });

  factory PersonUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PersonUpdateDto();
    return PersonUpdateDto(
      birthDate: json["birthDate"]?.toString(),
      color: json["color"]?.toString(),
      featureFaceAssetId: json["featureFaceAssetId"]?.toString(),
      isFavorite: (json["isFavorite"] as bool?),
      isHidden: (json["isHidden"] as bool?),
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (birthDate != null) "birthDate": birthDate,
    if (color != null) "color": color,
    if (featureFaceAssetId != null) "featureFaceAssetId": featureFaceAssetId,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isHidden != null) "isHidden": isHidden,
    if (name != null) "name": name,
  };

  PersonUpdateDto copyWith({
    String? birthDate,
    String? color,
    String? featureFaceAssetId,
    bool? isFavorite,
    bool? isHidden,
    String? name,
  }) {
    return PersonUpdateDto(
      birthDate: birthDate ?? this.birthDate,
      color: color ?? this.color,
      featureFaceAssetId: featureFaceAssetId ?? this.featureFaceAssetId,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PinCodeChangeDto {
  final String? newPinCode;
  final String? password;
  final String? pinCode;

  const PinCodeChangeDto({
    this.newPinCode,
    this.password,
    this.pinCode,
  });

  factory PinCodeChangeDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PinCodeChangeDto();
    return PinCodeChangeDto(
      newPinCode: json["newPinCode"]?.toString(),
      password: json["password"]?.toString(),
      pinCode: json["pinCode"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (newPinCode != null) "newPinCode": newPinCode,
    if (password != null) "password": password,
    if (pinCode != null) "pinCode": pinCode,
  };

  PinCodeChangeDto copyWith({
    String? newPinCode,
    String? password,
    String? pinCode,
  }) {
    return PinCodeChangeDto(
      newPinCode: newPinCode ?? this.newPinCode,
      password: password ?? this.password,
      pinCode: pinCode ?? this.pinCode,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PinCodeResetDto {
  final String? password;
  final String? pinCode;

  const PinCodeResetDto({
    this.password,
    this.pinCode,
  });

  factory PinCodeResetDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PinCodeResetDto();
    return PinCodeResetDto(
      password: json["password"]?.toString(),
      pinCode: json["pinCode"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (password != null) "password": password,
    if (pinCode != null) "pinCode": pinCode,
  };

  PinCodeResetDto copyWith({
    String? password,
    String? pinCode,
  }) {
    return PinCodeResetDto(
      password: password ?? this.password,
      pinCode: pinCode ?? this.pinCode,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PinCodeSetupDto {
  final String? pinCode;

  const PinCodeSetupDto({
    this.pinCode,
  });

  factory PinCodeSetupDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PinCodeSetupDto();
    return PinCodeSetupDto(
      pinCode: json["pinCode"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (pinCode != null) "pinCode": pinCode,
  };

  PinCodeSetupDto copyWith({
    String? pinCode,
  }) {
    return PinCodeSetupDto(
      pinCode: pinCode ?? this.pinCode,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PlacesResponseDto {
  final String? admin1name;
  final String? admin2name;
  final double? latitude;
  final double? longitude;
  final String? name;

  const PlacesResponseDto({
    this.admin1name,
    this.admin2name,
    this.latitude,
    this.longitude,
    this.name,
  });

  factory PlacesResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PlacesResponseDto();
    return PlacesResponseDto(
      admin1name: json["admin1name"]?.toString(),
      admin2name: json["admin2name"]?.toString(),
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (admin1name != null) "admin1name": admin1name,
    if (admin2name != null) "admin2name": admin2name,
    if (latitude != null) "latitude": latitude,
    if (longitude != null) "longitude": longitude,
    if (name != null) "name": name,
  };

  PlacesResponseDto copyWith({
    String? admin1name,
    String? admin2name,
    double? latitude,
    double? longitude,
    String? name,
  }) {
    return PlacesResponseDto(
      admin1name: admin1name ?? this.admin1name,
      admin2name: admin2name ?? this.admin2name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PurchaseResponse {
  final String? hideBuyButtonUntil;
  final bool? showSupportBadge;

  const PurchaseResponse({
    this.hideBuyButtonUntil,
    this.showSupportBadge,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PurchaseResponse();
    return PurchaseResponse(
      hideBuyButtonUntil: json["hideBuyButtonUntil"]?.toString(),
      showSupportBadge: (json["showSupportBadge"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (hideBuyButtonUntil != null) "hideBuyButtonUntil": hideBuyButtonUntil,
    if (showSupportBadge != null) "showSupportBadge": showSupportBadge,
  };

  PurchaseResponse copyWith({
    String? hideBuyButtonUntil,
    bool? showSupportBadge,
  }) {
    return PurchaseResponse(
      hideBuyButtonUntil: hideBuyButtonUntil ?? this.hideBuyButtonUntil,
      showSupportBadge: showSupportBadge ?? this.showSupportBadge,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class PurchaseUpdate {
  final String? hideBuyButtonUntil;
  final bool? showSupportBadge;

  const PurchaseUpdate({
    this.hideBuyButtonUntil,
    this.showSupportBadge,
  });

  factory PurchaseUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PurchaseUpdate();
    return PurchaseUpdate(
      hideBuyButtonUntil: json["hideBuyButtonUntil"]?.toString(),
      showSupportBadge: (json["showSupportBadge"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (hideBuyButtonUntil != null) "hideBuyButtonUntil": hideBuyButtonUntil,
    if (showSupportBadge != null) "showSupportBadge": showSupportBadge,
  };

  PurchaseUpdate copyWith({
    String? hideBuyButtonUntil,
    bool? showSupportBadge,
  }) {
    return PurchaseUpdate(
      hideBuyButtonUntil: hideBuyButtonUntil ?? this.hideBuyButtonUntil,
      showSupportBadge: showSupportBadge ?? this.showSupportBadge,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RandomSearchDto {
  final List<String>? albumIds;
  final String? city;
  final String? country;
  final String? createdAfter;
  final String? createdBefore;
  final SearchFilter? filter;
  final bool? isEncoded;
  final bool? isFavorite;
  final bool? isMotion;
  final bool? isNotInAlbum;
  final bool? isOffline;
  final String? lensModel;
  final String? libraryId;
  final String? make;
  final String? model;
  final String? ocr;
  final List<String>? personIds;
  final int? rating;
  final int? size;
  final String? state;
  final List<String>? tagIds;
  final String? takenAfter;
  final String? takenBefore;
  final String? trashedAfter;
  final String? trashedBefore;
  final AssetTypeEnum? type;
  final String? updatedAfter;
  final String? updatedBefore;
  final AssetVisibility? visibility;
  final bool? withDeleted;
  final bool? withExif;
  final bool? withPeople;
  final bool? withStacked;

  const RandomSearchDto({
    this.albumIds,
    this.city,
    this.country,
    this.createdAfter,
    this.createdBefore,
    this.filter,
    this.isEncoded,
    this.isFavorite,
    this.isMotion,
    this.isNotInAlbum,
    this.isOffline,
    this.lensModel,
    this.libraryId,
    this.make,
    this.model,
    this.ocr,
    this.personIds,
    this.rating,
    this.size,
    this.state,
    this.tagIds,
    this.takenAfter,
    this.takenBefore,
    this.trashedAfter,
    this.trashedBefore,
    this.type,
    this.updatedAfter,
    this.updatedBefore,
    this.visibility,
    this.withDeleted,
    this.withExif,
    this.withPeople,
    this.withStacked,
  });

  factory RandomSearchDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RandomSearchDto();
    return RandomSearchDto(
      albumIds: ((json["albumIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      createdAfter: json["createdAfter"]?.toString(),
      createdBefore: json["createdBefore"]?.toString(),
      filter: SearchFilter.fromJson((json["filter"] as Map<String, dynamic>?)),
      isEncoded: (json["isEncoded"] as bool?),
      isFavorite: (json["isFavorite"] as bool?),
      isMotion: (json["isMotion"] as bool?),
      isNotInAlbum: (json["isNotInAlbum"] as bool?),
      isOffline: (json["isOffline"] as bool?),
      lensModel: json["lensModel"]?.toString(),
      libraryId: json["libraryId"]?.toString(),
      make: json["make"]?.toString(),
      model: json["model"]?.toString(),
      ocr: json["ocr"]?.toString(),
      personIds: ((json["personIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      rating: (json["rating"] as num?)?.toInt(),
      size: (json["size"] as num?)?.toInt(),
      state: json["state"]?.toString(),
      tagIds: ((json["tagIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      takenAfter: json["takenAfter"]?.toString(),
      takenBefore: json["takenBefore"]?.toString(),
      trashedAfter: json["trashedAfter"]?.toString(),
      trashedBefore: json["trashedBefore"]?.toString(),
      type: _assetTypeEnumFromJson(json["type"]?.toString()),
      updatedAfter: json["updatedAfter"]?.toString(),
      updatedBefore: json["updatedBefore"]?.toString(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
      withDeleted: (json["withDeleted"] as bool?),
      withExif: (json["withExif"] as bool?),
      withPeople: (json["withPeople"] as bool?),
      withStacked: (json["withStacked"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumIds != null) "albumIds": albumIds,
    if (city != null) "city": city,
    if (country != null) "country": country,
    if (createdAfter != null) "createdAfter": createdAfter,
    if (createdBefore != null) "createdBefore": createdBefore,
    if (filter != null) "filter": filter?.toJson(),
    if (isEncoded != null) "isEncoded": isEncoded,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isMotion != null) "isMotion": isMotion,
    if (isNotInAlbum != null) "isNotInAlbum": isNotInAlbum,
    if (isOffline != null) "isOffline": isOffline,
    if (lensModel != null) "lensModel": lensModel,
    if (libraryId != null) "libraryId": libraryId,
    if (make != null) "make": make,
    if (model != null) "model": model,
    if (ocr != null) "ocr": ocr,
    if (personIds != null) "personIds": personIds,
    if (rating != null) "rating": rating,
    if (size != null) "size": size,
    if (state != null) "state": state,
    if (tagIds != null) "tagIds": tagIds,
    if (takenAfter != null) "takenAfter": takenAfter,
    if (takenBefore != null) "takenBefore": takenBefore,
    if (trashedAfter != null) "trashedAfter": trashedAfter,
    if (trashedBefore != null) "trashedBefore": trashedBefore,
    if (type != null) "type": type?.value,
    if (updatedAfter != null) "updatedAfter": updatedAfter,
    if (updatedBefore != null) "updatedBefore": updatedBefore,
    if (visibility != null) "visibility": visibility?.value,
    if (withDeleted != null) "withDeleted": withDeleted,
    if (withExif != null) "withExif": withExif,
    if (withPeople != null) "withPeople": withPeople,
    if (withStacked != null) "withStacked": withStacked,
  };

  RandomSearchDto copyWith({
    List<String>? albumIds,
    String? city,
    String? country,
    String? createdAfter,
    String? createdBefore,
    SearchFilter? filter,
    bool? isEncoded,
    bool? isFavorite,
    bool? isMotion,
    bool? isNotInAlbum,
    bool? isOffline,
    String? lensModel,
    String? libraryId,
    String? make,
    String? model,
    String? ocr,
    List<String>? personIds,
    int? rating,
    int? size,
    String? state,
    List<String>? tagIds,
    String? takenAfter,
    String? takenBefore,
    String? trashedAfter,
    String? trashedBefore,
    AssetTypeEnum? type,
    String? updatedAfter,
    String? updatedBefore,
    AssetVisibility? visibility,
    bool? withDeleted,
    bool? withExif,
    bool? withPeople,
    bool? withStacked,
  }) {
    return RandomSearchDto(
      albumIds: albumIds ?? this.albumIds,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      filter: filter ?? this.filter,
      isEncoded: isEncoded ?? this.isEncoded,
      isFavorite: isFavorite ?? this.isFavorite,
      isMotion: isMotion ?? this.isMotion,
      isNotInAlbum: isNotInAlbum ?? this.isNotInAlbum,
      isOffline: isOffline ?? this.isOffline,
      lensModel: lensModel ?? this.lensModel,
      libraryId: libraryId ?? this.libraryId,
      make: make ?? this.make,
      model: model ?? this.model,
      ocr: ocr ?? this.ocr,
      personIds: personIds ?? this.personIds,
      rating: rating ?? this.rating,
      size: size ?? this.size,
      state: state ?? this.state,
      tagIds: tagIds ?? this.tagIds,
      takenAfter: takenAfter ?? this.takenAfter,
      takenBefore: takenBefore ?? this.takenBefore,
      trashedAfter: trashedAfter ?? this.trashedAfter,
      trashedBefore: trashedBefore ?? this.trashedBefore,
      type: type ?? this.type,
      updatedAfter: updatedAfter ?? this.updatedAfter,
      updatedBefore: updatedBefore ?? this.updatedBefore,
      visibility: visibility ?? this.visibility,
      withDeleted: withDeleted ?? this.withDeleted,
      withExif: withExif ?? this.withExif,
      withPeople: withPeople ?? this.withPeople,
      withStacked: withStacked ?? this.withStacked,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RatingsResponse {
  final bool? enabled;

  const RatingsResponse({
    this.enabled,
  });

  factory RatingsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RatingsResponse();
    return RatingsResponse(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  RatingsResponse copyWith({
    bool? enabled,
  }) {
    return RatingsResponse(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RatingsUpdate {
  final bool? enabled;

  const RatingsUpdate({
    this.enabled,
  });

  factory RatingsUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RatingsUpdate();
    return RatingsUpdate(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  RatingsUpdate copyWith({
    bool? enabled,
  }) {
    return RatingsUpdate(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RecentlyAddedResponse {
  final bool? sidebarWeb;

  const RecentlyAddedResponse({
    this.sidebarWeb,
  });

  factory RecentlyAddedResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RecentlyAddedResponse();
    return RecentlyAddedResponse(
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  RecentlyAddedResponse copyWith({
    bool? sidebarWeb,
  }) {
    return RecentlyAddedResponse(
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RecentlyAddedUpdate {
  final bool? sidebarWeb;

  const RecentlyAddedUpdate({
    this.sidebarWeb,
  });

  factory RecentlyAddedUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RecentlyAddedUpdate();
    return RecentlyAddedUpdate(
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  RecentlyAddedUpdate copyWith({
    bool? sidebarWeb,
  }) {
    return RecentlyAddedUpdate(
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RotateParameters {
  final int? angle;

  const RotateParameters({
    this.angle,
  });

  factory RotateParameters.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RotateParameters();
    return RotateParameters(
      angle: (json["angle"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (angle != null) "angle": angle,
  };

  RotateParameters copyWith({
    int? angle,
  }) {
    return RotateParameters(
      angle: angle ?? this.angle,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchAlbumResponseDto {
  final int? count;
  final List<SearchFacetResponseDto>? facets;
  final List<AlbumResponseDto>? items;
  final int? total;

  const SearchAlbumResponseDto({
    this.count,
    this.facets,
    this.items,
    this.total,
  });

  factory SearchAlbumResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchAlbumResponseDto();
    return SearchAlbumResponseDto(
      count: (json["count"] as num?)?.toInt(),
      facets: ((json["facets"] as List<dynamic>?)?.map((e) => SearchFacetResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<SearchFacetResponseDto>().toList()),
      items: ((json["items"] as List<dynamic>?)?.map((e) => AlbumResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AlbumResponseDto>().toList()),
      total: (json["total"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (count != null) "count": count,
    if (facets != null) "facets": facets?.map((e) => e?.toJson()).toList(),
    if (items != null) "items": items?.map((e) => e?.toJson()).toList(),
    if (total != null) "total": total,
  };

  SearchAlbumResponseDto copyWith({
    int? count,
    List<SearchFacetResponseDto>? facets,
    List<AlbumResponseDto>? items,
    int? total,
  }) {
    return SearchAlbumResponseDto(
      count: count ?? this.count,
      facets: facets ?? this.facets,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchAssetResponseDto {
  final int? count;
  final List<SearchFacetResponseDto>? facets;
  final List<AssetResponseDto>? items;
  final String? nextCursor;
  final String? nextPage;
  final int? total;

  const SearchAssetResponseDto({
    this.count,
    this.facets,
    this.items,
    this.nextCursor,
    this.nextPage,
    this.total,
  });

  factory SearchAssetResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchAssetResponseDto();
    return SearchAssetResponseDto(
      count: (json["count"] as num?)?.toInt(),
      facets: ((json["facets"] as List<dynamic>?)?.map((e) => SearchFacetResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<SearchFacetResponseDto>().toList()),
      items: ((json["items"] as List<dynamic>?)?.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetResponseDto>().toList()),
      nextCursor: json["nextCursor"]?.toString(),
      nextPage: json["nextPage"]?.toString(),
      total: (json["total"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (count != null) "count": count,
    if (facets != null) "facets": facets?.map((e) => e?.toJson()).toList(),
    if (items != null) "items": items?.map((e) => e?.toJson()).toList(),
    if (nextCursor != null) "nextCursor": nextCursor,
    if (nextPage != null) "nextPage": nextPage,
    if (total != null) "total": total,
  };

  SearchAssetResponseDto copyWith({
    int? count,
    List<SearchFacetResponseDto>? facets,
    List<AssetResponseDto>? items,
    String? nextCursor,
    String? nextPage,
    int? total,
  }) {
    return SearchAssetResponseDto(
      count: count ?? this.count,
      facets: facets ?? this.facets,
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      nextPage: nextPage ?? this.nextPage,
      total: total ?? this.total,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchExploreItem {
  final AssetResponseDto? data;
  final String? value;

  const SearchExploreItem({
    this.data,
    this.value,
  });

  factory SearchExploreItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchExploreItem();
    return SearchExploreItem(
      data: AssetResponseDto.fromJson((json["data"] as Map<String, dynamic>?)),
      value: json["value"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (data != null) "data": data?.toJson(),
    if (value != null) "value": value,
  };

  SearchExploreItem copyWith({
    AssetResponseDto? data,
    String? value,
  }) {
    return SearchExploreItem(
      data: data ?? this.data,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchExploreResponseDto {
  final String? fieldName;
  final List<SearchExploreItem>? items;

  const SearchExploreResponseDto({
    this.fieldName,
    this.items,
  });

  factory SearchExploreResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchExploreResponseDto();
    return SearchExploreResponseDto(
      fieldName: json["fieldName"]?.toString(),
      items: ((json["items"] as List<dynamic>?)?.map((e) => SearchExploreItem.fromJson((e as Map<String, dynamic>?))).whereType<SearchExploreItem>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (fieldName != null) "fieldName": fieldName,
    if (items != null) "items": items?.map((e) => e?.toJson()).toList(),
  };

  SearchExploreResponseDto copyWith({
    String? fieldName,
    List<SearchExploreItem>? items,
  }) {
    return SearchExploreResponseDto(
      fieldName: fieldName ?? this.fieldName,
      items: items ?? this.items,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchFacetCountResponseDto {
  final int? count;
  final String? value;

  const SearchFacetCountResponseDto({
    this.count,
    this.value,
  });

  factory SearchFacetCountResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchFacetCountResponseDto();
    return SearchFacetCountResponseDto(
      count: (json["count"] as num?)?.toInt(),
      value: json["value"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (count != null) "count": count,
    if (value != null) "value": value,
  };

  SearchFacetCountResponseDto copyWith({
    int? count,
    String? value,
  }) {
    return SearchFacetCountResponseDto(
      count: count ?? this.count,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchFacetResponseDto {
  final List<SearchFacetCountResponseDto>? counts;
  final String? fieldName;

  const SearchFacetResponseDto({
    this.counts,
    this.fieldName,
  });

  factory SearchFacetResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchFacetResponseDto();
    return SearchFacetResponseDto(
      counts: ((json["counts"] as List<dynamic>?)?.map((e) => SearchFacetCountResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<SearchFacetCountResponseDto>().toList()),
      fieldName: json["fieldName"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (counts != null) "counts": counts?.map((e) => e?.toJson()).toList(),
    if (fieldName != null) "fieldName": fieldName,
  };

  SearchFacetResponseDto copyWith({
    List<SearchFacetCountResponseDto>? counts,
    String? fieldName,
  }) {
    return SearchFacetResponseDto(
      counts: counts ?? this.counts,
      fieldName: fieldName ?? this.fieldName,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchFilter {
  final IdsFilter? albumIds;
  final StringFilter? checksum;
  final StringFilterNullable? city;
  final StringFilterNullable? country;
  final DateFilter? createdAt;
  final StringPatternFilter? description;
  final StringFilter? encodedVideoPath;
  final NumberFilter? fileSizeInBytes;
  final BoolFilter? hasAlbums;
  final BoolFilter? hasPeople;
  final BoolFilter? hasTags;
  final IdFilter? id;
  final BoolFilter? isEncoded;
  final BoolFilter? isFavorite;
  final BoolFilter? isMotion;
  final BoolFilter? isOffline;
  final StringFilterNullable? lensModel;
  final IdFilterNullable? libraryId;
  final StringFilterNullable? make;
  final StringFilterNullable? model;
  final StringSimilarityFilter? ocr;
  final List<SearchFilterBranch>? or_;
  final StringPatternFilter? originalFileName;
  final StringPatternFilter? originalPath;
  final IdsFilter? personIds;
  final NumberFilterNullable? rating;
  final StringFilterNullable? state;
  final IdsFilter? tagIds;
  final DateFilter? takenAt;
  final DateFilterNullable? trashedAt;
  final EnumFilterAssetType? type;
  final DateFilter? updatedAt;
  final EnumFilterAssetVisibility? visibility;

  const SearchFilter({
    this.albumIds,
    this.checksum,
    this.city,
    this.country,
    this.createdAt,
    this.description,
    this.encodedVideoPath,
    this.fileSizeInBytes,
    this.hasAlbums,
    this.hasPeople,
    this.hasTags,
    this.id,
    this.isEncoded,
    this.isFavorite,
    this.isMotion,
    this.isOffline,
    this.lensModel,
    this.libraryId,
    this.make,
    this.model,
    this.ocr,
    this.or_,
    this.originalFileName,
    this.originalPath,
    this.personIds,
    this.rating,
    this.state,
    this.tagIds,
    this.takenAt,
    this.trashedAt,
    this.type,
    this.updatedAt,
    this.visibility,
  });

  factory SearchFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchFilter();
    return SearchFilter(
      albumIds: IdsFilter.fromJson((json["albumIds"] as Map<String, dynamic>?)),
      checksum: StringFilter.fromJson((json["checksum"] as Map<String, dynamic>?)),
      city: StringFilterNullable.fromJson((json["city"] as Map<String, dynamic>?)),
      country: StringFilterNullable.fromJson((json["country"] as Map<String, dynamic>?)),
      createdAt: DateFilter.fromJson((json["createdAt"] as Map<String, dynamic>?)),
      description: StringPatternFilter.fromJson((json["description"] as Map<String, dynamic>?)),
      encodedVideoPath: StringFilter.fromJson((json["encodedVideoPath"] as Map<String, dynamic>?)),
      fileSizeInBytes: NumberFilter.fromJson((json["fileSizeInBytes"] as Map<String, dynamic>?)),
      hasAlbums: BoolFilter.fromJson((json["hasAlbums"] as Map<String, dynamic>?)),
      hasPeople: BoolFilter.fromJson((json["hasPeople"] as Map<String, dynamic>?)),
      hasTags: BoolFilter.fromJson((json["hasTags"] as Map<String, dynamic>?)),
      id: IdFilter.fromJson((json["id"] as Map<String, dynamic>?)),
      isEncoded: BoolFilter.fromJson((json["isEncoded"] as Map<String, dynamic>?)),
      isFavorite: BoolFilter.fromJson((json["isFavorite"] as Map<String, dynamic>?)),
      isMotion: BoolFilter.fromJson((json["isMotion"] as Map<String, dynamic>?)),
      isOffline: BoolFilter.fromJson((json["isOffline"] as Map<String, dynamic>?)),
      lensModel: StringFilterNullable.fromJson((json["lensModel"] as Map<String, dynamic>?)),
      libraryId: IdFilterNullable.fromJson((json["libraryId"] as Map<String, dynamic>?)),
      make: StringFilterNullable.fromJson((json["make"] as Map<String, dynamic>?)),
      model: StringFilterNullable.fromJson((json["model"] as Map<String, dynamic>?)),
      ocr: StringSimilarityFilter.fromJson((json["ocr"] as Map<String, dynamic>?)),
      or_: ((json["or"] as List<dynamic>?)?.map((e) => SearchFilterBranch.fromJson((e as Map<String, dynamic>?))).whereType<SearchFilterBranch>().toList()),
      originalFileName: StringPatternFilter.fromJson((json["originalFileName"] as Map<String, dynamic>?)),
      originalPath: StringPatternFilter.fromJson((json["originalPath"] as Map<String, dynamic>?)),
      personIds: IdsFilter.fromJson((json["personIds"] as Map<String, dynamic>?)),
      rating: NumberFilterNullable.fromJson((json["rating"] as Map<String, dynamic>?)),
      state: StringFilterNullable.fromJson((json["state"] as Map<String, dynamic>?)),
      tagIds: IdsFilter.fromJson((json["tagIds"] as Map<String, dynamic>?)),
      takenAt: DateFilter.fromJson((json["takenAt"] as Map<String, dynamic>?)),
      trashedAt: DateFilterNullable.fromJson((json["trashedAt"] as Map<String, dynamic>?)),
      type: EnumFilterAssetType.fromJson((json["type"] as Map<String, dynamic>?)),
      updatedAt: DateFilter.fromJson((json["updatedAt"] as Map<String, dynamic>?)),
      visibility: EnumFilterAssetVisibility.fromJson((json["visibility"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumIds != null) "albumIds": albumIds?.toJson(),
    if (checksum != null) "checksum": checksum?.toJson(),
    if (city != null) "city": city?.toJson(),
    if (country != null) "country": country?.toJson(),
    if (createdAt != null) "createdAt": createdAt?.toJson(),
    if (description != null) "description": description?.toJson(),
    if (encodedVideoPath != null) "encodedVideoPath": encodedVideoPath?.toJson(),
    if (fileSizeInBytes != null) "fileSizeInBytes": fileSizeInBytes?.toJson(),
    if (hasAlbums != null) "hasAlbums": hasAlbums?.toJson(),
    if (hasPeople != null) "hasPeople": hasPeople?.toJson(),
    if (hasTags != null) "hasTags": hasTags?.toJson(),
    if (id != null) "id": id?.toJson(),
    if (isEncoded != null) "isEncoded": isEncoded?.toJson(),
    if (isFavorite != null) "isFavorite": isFavorite?.toJson(),
    if (isMotion != null) "isMotion": isMotion?.toJson(),
    if (isOffline != null) "isOffline": isOffline?.toJson(),
    if (lensModel != null) "lensModel": lensModel?.toJson(),
    if (libraryId != null) "libraryId": libraryId?.toJson(),
    if (make != null) "make": make?.toJson(),
    if (model != null) "model": model?.toJson(),
    if (ocr != null) "ocr": ocr?.toJson(),
    if (or_ != null) "or": or_?.map((e) => e?.toJson()).toList(),
    if (originalFileName != null) "originalFileName": originalFileName?.toJson(),
    if (originalPath != null) "originalPath": originalPath?.toJson(),
    if (personIds != null) "personIds": personIds?.toJson(),
    if (rating != null) "rating": rating?.toJson(),
    if (state != null) "state": state?.toJson(),
    if (tagIds != null) "tagIds": tagIds?.toJson(),
    if (takenAt != null) "takenAt": takenAt?.toJson(),
    if (trashedAt != null) "trashedAt": trashedAt?.toJson(),
    if (type != null) "type": type?.toJson(),
    if (updatedAt != null) "updatedAt": updatedAt?.toJson(),
    if (visibility != null) "visibility": visibility?.toJson(),
  };

  SearchFilter copyWith({
    IdsFilter? albumIds,
    StringFilter? checksum,
    StringFilterNullable? city,
    StringFilterNullable? country,
    DateFilter? createdAt,
    StringPatternFilter? description,
    StringFilter? encodedVideoPath,
    NumberFilter? fileSizeInBytes,
    BoolFilter? hasAlbums,
    BoolFilter? hasPeople,
    BoolFilter? hasTags,
    IdFilter? id,
    BoolFilter? isEncoded,
    BoolFilter? isFavorite,
    BoolFilter? isMotion,
    BoolFilter? isOffline,
    StringFilterNullable? lensModel,
    IdFilterNullable? libraryId,
    StringFilterNullable? make,
    StringFilterNullable? model,
    StringSimilarityFilter? ocr,
    List<SearchFilterBranch>? or_,
    StringPatternFilter? originalFileName,
    StringPatternFilter? originalPath,
    IdsFilter? personIds,
    NumberFilterNullable? rating,
    StringFilterNullable? state,
    IdsFilter? tagIds,
    DateFilter? takenAt,
    DateFilterNullable? trashedAt,
    EnumFilterAssetType? type,
    DateFilter? updatedAt,
    EnumFilterAssetVisibility? visibility,
  }) {
    return SearchFilter(
      albumIds: albumIds ?? this.albumIds,
      checksum: checksum ?? this.checksum,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      encodedVideoPath: encodedVideoPath ?? this.encodedVideoPath,
      fileSizeInBytes: fileSizeInBytes ?? this.fileSizeInBytes,
      hasAlbums: hasAlbums ?? this.hasAlbums,
      hasPeople: hasPeople ?? this.hasPeople,
      hasTags: hasTags ?? this.hasTags,
      id: id ?? this.id,
      isEncoded: isEncoded ?? this.isEncoded,
      isFavorite: isFavorite ?? this.isFavorite,
      isMotion: isMotion ?? this.isMotion,
      isOffline: isOffline ?? this.isOffline,
      lensModel: lensModel ?? this.lensModel,
      libraryId: libraryId ?? this.libraryId,
      make: make ?? this.make,
      model: model ?? this.model,
      ocr: ocr ?? this.ocr,
      or_: or_ ?? this.or_,
      originalFileName: originalFileName ?? this.originalFileName,
      originalPath: originalPath ?? this.originalPath,
      personIds: personIds ?? this.personIds,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      tagIds: tagIds ?? this.tagIds,
      takenAt: takenAt ?? this.takenAt,
      trashedAt: trashedAt ?? this.trashedAt,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchFilterBranch {
  final IdsFilter? albumIds;
  final StringFilter? checksum;
  final StringFilterNullable? city;
  final StringFilterNullable? country;
  final DateFilter? createdAt;
  final StringPatternFilter? description;
  final StringFilter? encodedVideoPath;
  final NumberFilter? fileSizeInBytes;
  final BoolFilter? hasAlbums;
  final BoolFilter? hasPeople;
  final BoolFilter? hasTags;
  final IdFilter? id;
  final BoolFilter? isEncoded;
  final BoolFilter? isFavorite;
  final BoolFilter? isMotion;
  final BoolFilter? isOffline;
  final StringFilterNullable? lensModel;
  final IdFilterNullable? libraryId;
  final StringFilterNullable? make;
  final StringFilterNullable? model;
  final StringSimilarityFilter? ocr;
  final StringPatternFilter? originalFileName;
  final StringPatternFilter? originalPath;
  final IdsFilter? personIds;
  final NumberFilterNullable? rating;
  final StringFilterNullable? state;
  final IdsFilter? tagIds;
  final DateFilter? takenAt;
  final DateFilterNullable? trashedAt;
  final EnumFilterAssetType? type;
  final DateFilter? updatedAt;
  final EnumFilterAssetVisibility? visibility;

  const SearchFilterBranch({
    this.albumIds,
    this.checksum,
    this.city,
    this.country,
    this.createdAt,
    this.description,
    this.encodedVideoPath,
    this.fileSizeInBytes,
    this.hasAlbums,
    this.hasPeople,
    this.hasTags,
    this.id,
    this.isEncoded,
    this.isFavorite,
    this.isMotion,
    this.isOffline,
    this.lensModel,
    this.libraryId,
    this.make,
    this.model,
    this.ocr,
    this.originalFileName,
    this.originalPath,
    this.personIds,
    this.rating,
    this.state,
    this.tagIds,
    this.takenAt,
    this.trashedAt,
    this.type,
    this.updatedAt,
    this.visibility,
  });

  factory SearchFilterBranch.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchFilterBranch();
    return SearchFilterBranch(
      albumIds: IdsFilter.fromJson((json["albumIds"] as Map<String, dynamic>?)),
      checksum: StringFilter.fromJson((json["checksum"] as Map<String, dynamic>?)),
      city: StringFilterNullable.fromJson((json["city"] as Map<String, dynamic>?)),
      country: StringFilterNullable.fromJson((json["country"] as Map<String, dynamic>?)),
      createdAt: DateFilter.fromJson((json["createdAt"] as Map<String, dynamic>?)),
      description: StringPatternFilter.fromJson((json["description"] as Map<String, dynamic>?)),
      encodedVideoPath: StringFilter.fromJson((json["encodedVideoPath"] as Map<String, dynamic>?)),
      fileSizeInBytes: NumberFilter.fromJson((json["fileSizeInBytes"] as Map<String, dynamic>?)),
      hasAlbums: BoolFilter.fromJson((json["hasAlbums"] as Map<String, dynamic>?)),
      hasPeople: BoolFilter.fromJson((json["hasPeople"] as Map<String, dynamic>?)),
      hasTags: BoolFilter.fromJson((json["hasTags"] as Map<String, dynamic>?)),
      id: IdFilter.fromJson((json["id"] as Map<String, dynamic>?)),
      isEncoded: BoolFilter.fromJson((json["isEncoded"] as Map<String, dynamic>?)),
      isFavorite: BoolFilter.fromJson((json["isFavorite"] as Map<String, dynamic>?)),
      isMotion: BoolFilter.fromJson((json["isMotion"] as Map<String, dynamic>?)),
      isOffline: BoolFilter.fromJson((json["isOffline"] as Map<String, dynamic>?)),
      lensModel: StringFilterNullable.fromJson((json["lensModel"] as Map<String, dynamic>?)),
      libraryId: IdFilterNullable.fromJson((json["libraryId"] as Map<String, dynamic>?)),
      make: StringFilterNullable.fromJson((json["make"] as Map<String, dynamic>?)),
      model: StringFilterNullable.fromJson((json["model"] as Map<String, dynamic>?)),
      ocr: StringSimilarityFilter.fromJson((json["ocr"] as Map<String, dynamic>?)),
      originalFileName: StringPatternFilter.fromJson((json["originalFileName"] as Map<String, dynamic>?)),
      originalPath: StringPatternFilter.fromJson((json["originalPath"] as Map<String, dynamic>?)),
      personIds: IdsFilter.fromJson((json["personIds"] as Map<String, dynamic>?)),
      rating: NumberFilterNullable.fromJson((json["rating"] as Map<String, dynamic>?)),
      state: StringFilterNullable.fromJson((json["state"] as Map<String, dynamic>?)),
      tagIds: IdsFilter.fromJson((json["tagIds"] as Map<String, dynamic>?)),
      takenAt: DateFilter.fromJson((json["takenAt"] as Map<String, dynamic>?)),
      trashedAt: DateFilterNullable.fromJson((json["trashedAt"] as Map<String, dynamic>?)),
      type: EnumFilterAssetType.fromJson((json["type"] as Map<String, dynamic>?)),
      updatedAt: DateFilter.fromJson((json["updatedAt"] as Map<String, dynamic>?)),
      visibility: EnumFilterAssetVisibility.fromJson((json["visibility"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumIds != null) "albumIds": albumIds?.toJson(),
    if (checksum != null) "checksum": checksum?.toJson(),
    if (city != null) "city": city?.toJson(),
    if (country != null) "country": country?.toJson(),
    if (createdAt != null) "createdAt": createdAt?.toJson(),
    if (description != null) "description": description?.toJson(),
    if (encodedVideoPath != null) "encodedVideoPath": encodedVideoPath?.toJson(),
    if (fileSizeInBytes != null) "fileSizeInBytes": fileSizeInBytes?.toJson(),
    if (hasAlbums != null) "hasAlbums": hasAlbums?.toJson(),
    if (hasPeople != null) "hasPeople": hasPeople?.toJson(),
    if (hasTags != null) "hasTags": hasTags?.toJson(),
    if (id != null) "id": id?.toJson(),
    if (isEncoded != null) "isEncoded": isEncoded?.toJson(),
    if (isFavorite != null) "isFavorite": isFavorite?.toJson(),
    if (isMotion != null) "isMotion": isMotion?.toJson(),
    if (isOffline != null) "isOffline": isOffline?.toJson(),
    if (lensModel != null) "lensModel": lensModel?.toJson(),
    if (libraryId != null) "libraryId": libraryId?.toJson(),
    if (make != null) "make": make?.toJson(),
    if (model != null) "model": model?.toJson(),
    if (ocr != null) "ocr": ocr?.toJson(),
    if (originalFileName != null) "originalFileName": originalFileName?.toJson(),
    if (originalPath != null) "originalPath": originalPath?.toJson(),
    if (personIds != null) "personIds": personIds?.toJson(),
    if (rating != null) "rating": rating?.toJson(),
    if (state != null) "state": state?.toJson(),
    if (tagIds != null) "tagIds": tagIds?.toJson(),
    if (takenAt != null) "takenAt": takenAt?.toJson(),
    if (trashedAt != null) "trashedAt": trashedAt?.toJson(),
    if (type != null) "type": type?.toJson(),
    if (updatedAt != null) "updatedAt": updatedAt?.toJson(),
    if (visibility != null) "visibility": visibility?.toJson(),
  };

  SearchFilterBranch copyWith({
    IdsFilter? albumIds,
    StringFilter? checksum,
    StringFilterNullable? city,
    StringFilterNullable? country,
    DateFilter? createdAt,
    StringPatternFilter? description,
    StringFilter? encodedVideoPath,
    NumberFilter? fileSizeInBytes,
    BoolFilter? hasAlbums,
    BoolFilter? hasPeople,
    BoolFilter? hasTags,
    IdFilter? id,
    BoolFilter? isEncoded,
    BoolFilter? isFavorite,
    BoolFilter? isMotion,
    BoolFilter? isOffline,
    StringFilterNullable? lensModel,
    IdFilterNullable? libraryId,
    StringFilterNullable? make,
    StringFilterNullable? model,
    StringSimilarityFilter? ocr,
    StringPatternFilter? originalFileName,
    StringPatternFilter? originalPath,
    IdsFilter? personIds,
    NumberFilterNullable? rating,
    StringFilterNullable? state,
    IdsFilter? tagIds,
    DateFilter? takenAt,
    DateFilterNullable? trashedAt,
    EnumFilterAssetType? type,
    DateFilter? updatedAt,
    EnumFilterAssetVisibility? visibility,
  }) {
    return SearchFilterBranch(
      albumIds: albumIds ?? this.albumIds,
      checksum: checksum ?? this.checksum,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      encodedVideoPath: encodedVideoPath ?? this.encodedVideoPath,
      fileSizeInBytes: fileSizeInBytes ?? this.fileSizeInBytes,
      hasAlbums: hasAlbums ?? this.hasAlbums,
      hasPeople: hasPeople ?? this.hasPeople,
      hasTags: hasTags ?? this.hasTags,
      id: id ?? this.id,
      isEncoded: isEncoded ?? this.isEncoded,
      isFavorite: isFavorite ?? this.isFavorite,
      isMotion: isMotion ?? this.isMotion,
      isOffline: isOffline ?? this.isOffline,
      lensModel: lensModel ?? this.lensModel,
      libraryId: libraryId ?? this.libraryId,
      make: make ?? this.make,
      model: model ?? this.model,
      ocr: ocr ?? this.ocr,
      originalFileName: originalFileName ?? this.originalFileName,
      originalPath: originalPath ?? this.originalPath,
      personIds: personIds ?? this.personIds,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      tagIds: tagIds ?? this.tagIds,
      takenAt: takenAt ?? this.takenAt,
      trashedAt: trashedAt ?? this.trashedAt,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchOrder {
  final AssetOrder? direction;
  final SearchOrderField? field;

  const SearchOrder({
    this.direction,
    this.field,
  });

  factory SearchOrder.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchOrder();
    return SearchOrder(
      direction: _assetOrderFromJson(json["direction"]?.toString()),
      field: _searchOrderFieldFromJson(json["field"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (direction != null) "direction": direction?.value,
    if (field != null) "field": field?.value,
  };

  SearchOrder copyWith({
    AssetOrder? direction,
    SearchOrderField? field,
  }) {
    return SearchOrder(
      direction: direction ?? this.direction,
      field: field ?? this.field,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchResponseDto {
  final SearchAlbumResponseDto? albums;
  final SearchAssetResponseDto? assets;

  const SearchResponseDto({
    this.albums,
    this.assets,
  });

  factory SearchResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchResponseDto();
    return SearchResponseDto(
      albums: SearchAlbumResponseDto.fromJson((json["albums"] as Map<String, dynamic>?)),
      assets: SearchAssetResponseDto.fromJson((json["assets"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albums != null) "albums": albums?.toJson(),
    if (assets != null) "assets": assets?.toJson(),
  };

  SearchResponseDto copyWith({
    SearchAlbumResponseDto? albums,
    SearchAssetResponseDto? assets,
  }) {
    return SearchResponseDto(
      albums: albums ?? this.albums,
      assets: assets ?? this.assets,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SearchStatisticsResponseDto {
  final int? total;

  const SearchStatisticsResponseDto({
    this.total,
  });

  factory SearchStatisticsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SearchStatisticsResponseDto();
    return SearchStatisticsResponseDto(
      total: (json["total"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (total != null) "total": total,
  };

  SearchStatisticsResponseDto copyWith({
    int? total,
  }) {
    return SearchStatisticsResponseDto(
      total: total ?? this.total,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ServerAboutResponseDto {
  final String? build;
  final String? buildImage;
  final String? buildImageUrl;
  final String? buildUrl;
  final String? exiftool;
  final String? ffmpeg;
  final String? imagemagick;
  final String? libvips;
  final bool? licensed;
  final String? nodejs;
  final String? repository;
  final String? repositoryUrl;
  final String? sourceCommit;
  final String? sourceRef;
  final String? sourceUrl;
  final String? thirdPartyBugFeatureUrl;
  final String? thirdPartyDocumentationUrl;
  final String? thirdPartySourceUrl;
  final String? thirdPartySupportUrl;
  final String? version;
  final String? versionUrl;

  const ServerAboutResponseDto({
    this.build,
    this.buildImage,
    this.buildImageUrl,
    this.buildUrl,
    this.exiftool,
    this.ffmpeg,
    this.imagemagick,
    this.libvips,
    this.licensed,
    this.nodejs,
    this.repository,
    this.repositoryUrl,
    this.sourceCommit,
    this.sourceRef,
    this.sourceUrl,
    this.thirdPartyBugFeatureUrl,
    this.thirdPartyDocumentationUrl,
    this.thirdPartySourceUrl,
    this.thirdPartySupportUrl,
    this.version,
    this.versionUrl,
  });

  factory ServerAboutResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServerAboutResponseDto();
    return ServerAboutResponseDto(
      build: json["build"]?.toString(),
      buildImage: json["buildImage"]?.toString(),
      buildImageUrl: json["buildImageUrl"]?.toString(),
      buildUrl: json["buildUrl"]?.toString(),
      exiftool: json["exiftool"]?.toString(),
      ffmpeg: json["ffmpeg"]?.toString(),
      imagemagick: json["imagemagick"]?.toString(),
      libvips: json["libvips"]?.toString(),
      licensed: (json["licensed"] as bool?),
      nodejs: json["nodejs"]?.toString(),
      repository: json["repository"]?.toString(),
      repositoryUrl: json["repositoryUrl"]?.toString(),
      sourceCommit: json["sourceCommit"]?.toString(),
      sourceRef: json["sourceRef"]?.toString(),
      sourceUrl: json["sourceUrl"]?.toString(),
      thirdPartyBugFeatureUrl: json["thirdPartyBugFeatureUrl"]?.toString(),
      thirdPartyDocumentationUrl: json["thirdPartyDocumentationUrl"]?.toString(),
      thirdPartySourceUrl: json["thirdPartySourceUrl"]?.toString(),
      thirdPartySupportUrl: json["thirdPartySupportUrl"]?.toString(),
      version: json["version"]?.toString(),
      versionUrl: json["versionUrl"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (build != null) "build": build,
    if (buildImage != null) "buildImage": buildImage,
    if (buildImageUrl != null) "buildImageUrl": buildImageUrl,
    if (buildUrl != null) "buildUrl": buildUrl,
    if (exiftool != null) "exiftool": exiftool,
    if (ffmpeg != null) "ffmpeg": ffmpeg,
    if (imagemagick != null) "imagemagick": imagemagick,
    if (libvips != null) "libvips": libvips,
    if (licensed != null) "licensed": licensed,
    if (nodejs != null) "nodejs": nodejs,
    if (repository != null) "repository": repository,
    if (repositoryUrl != null) "repositoryUrl": repositoryUrl,
    if (sourceCommit != null) "sourceCommit": sourceCommit,
    if (sourceRef != null) "sourceRef": sourceRef,
    if (sourceUrl != null) "sourceUrl": sourceUrl,
    if (thirdPartyBugFeatureUrl != null) "thirdPartyBugFeatureUrl": thirdPartyBugFeatureUrl,
    if (thirdPartyDocumentationUrl != null) "thirdPartyDocumentationUrl": thirdPartyDocumentationUrl,
    if (thirdPartySourceUrl != null) "thirdPartySourceUrl": thirdPartySourceUrl,
    if (thirdPartySupportUrl != null) "thirdPartySupportUrl": thirdPartySupportUrl,
    if (version != null) "version": version,
    if (versionUrl != null) "versionUrl": versionUrl,
  };

  ServerAboutResponseDto copyWith({
    String? build,
    String? buildImage,
    String? buildImageUrl,
    String? buildUrl,
    String? exiftool,
    String? ffmpeg,
    String? imagemagick,
    String? libvips,
    bool? licensed,
    String? nodejs,
    String? repository,
    String? repositoryUrl,
    String? sourceCommit,
    String? sourceRef,
    String? sourceUrl,
    String? thirdPartyBugFeatureUrl,
    String? thirdPartyDocumentationUrl,
    String? thirdPartySourceUrl,
    String? thirdPartySupportUrl,
    String? version,
    String? versionUrl,
  }) {
    return ServerAboutResponseDto(
      build: build ?? this.build,
      buildImage: buildImage ?? this.buildImage,
      buildImageUrl: buildImageUrl ?? this.buildImageUrl,
      buildUrl: buildUrl ?? this.buildUrl,
      exiftool: exiftool ?? this.exiftool,
      ffmpeg: ffmpeg ?? this.ffmpeg,
      imagemagick: imagemagick ?? this.imagemagick,
      libvips: libvips ?? this.libvips,
      licensed: licensed ?? this.licensed,
      nodejs: nodejs ?? this.nodejs,
      repository: repository ?? this.repository,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      sourceCommit: sourceCommit ?? this.sourceCommit,
      sourceRef: sourceRef ?? this.sourceRef,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      thirdPartyBugFeatureUrl: thirdPartyBugFeatureUrl ?? this.thirdPartyBugFeatureUrl,
      thirdPartyDocumentationUrl: thirdPartyDocumentationUrl ?? this.thirdPartyDocumentationUrl,
      thirdPartySourceUrl: thirdPartySourceUrl ?? this.thirdPartySourceUrl,
      thirdPartySupportUrl: thirdPartySupportUrl ?? this.thirdPartySupportUrl,
      version: version ?? this.version,
      versionUrl: versionUrl ?? this.versionUrl,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ServerMediaTypesResponseDto {
  final List<String>? image;
  final List<String>? sidecar;
  final List<String>? video;

  const ServerMediaTypesResponseDto({
    this.image,
    this.sidecar,
    this.video,
  });

  factory ServerMediaTypesResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServerMediaTypesResponseDto();
    return ServerMediaTypesResponseDto(
      image: ((json["image"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      sidecar: ((json["sidecar"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      video: ((json["video"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (image != null) "image": image,
    if (sidecar != null) "sidecar": sidecar,
    if (video != null) "video": video,
  };

  ServerMediaTypesResponseDto copyWith({
    List<String>? image,
    List<String>? sidecar,
    List<String>? video,
  }) {
    return ServerMediaTypesResponseDto(
      image: image ?? this.image,
      sidecar: sidecar ?? this.sidecar,
      video: video ?? this.video,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ServerPingResponse {
  final String? res;

  const ServerPingResponse({
    this.res,
  });

  factory ServerPingResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServerPingResponse();
    return ServerPingResponse(
      res: json["res"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (res != null) "res": res,
  };

  ServerPingResponse copyWith({
    String? res,
  }) {
    return ServerPingResponse(
      res: res ?? this.res,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ServerStatsResponseDto {
  final int? photos;
  final int? usage;
  final List<UsageByUserDto>? usageByUser;
  final int? usagePhotos;
  final int? usageVideos;
  final int? videos;

  const ServerStatsResponseDto({
    this.photos,
    this.usage,
    this.usageByUser,
    this.usagePhotos,
    this.usageVideos,
    this.videos,
  });

  factory ServerStatsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServerStatsResponseDto();
    return ServerStatsResponseDto(
      photos: (json["photos"] as num?)?.toInt(),
      usage: (json["usage"] as num?)?.toInt(),
      usageByUser: ((json["usageByUser"] as List<dynamic>?)?.map((e) => UsageByUserDto.fromJson((e as Map<String, dynamic>?))).whereType<UsageByUserDto>().toList()),
      usagePhotos: (json["usagePhotos"] as num?)?.toInt(),
      usageVideos: (json["usageVideos"] as num?)?.toInt(),
      videos: (json["videos"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (photos != null) "photos": photos,
    if (usage != null) "usage": usage,
    if (usageByUser != null) "usageByUser": usageByUser?.map((e) => e?.toJson()).toList(),
    if (usagePhotos != null) "usagePhotos": usagePhotos,
    if (usageVideos != null) "usageVideos": usageVideos,
    if (videos != null) "videos": videos,
  };

  ServerStatsResponseDto copyWith({
    int? photos,
    int? usage,
    List<UsageByUserDto>? usageByUser,
    int? usagePhotos,
    int? usageVideos,
    int? videos,
  }) {
    return ServerStatsResponseDto(
      photos: photos ?? this.photos,
      usage: usage ?? this.usage,
      usageByUser: usageByUser ?? this.usageByUser,
      usagePhotos: usagePhotos ?? this.usagePhotos,
      usageVideos: usageVideos ?? this.usageVideos,
      videos: videos ?? this.videos,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ServerStorageResponseDto {
  final String? diskAvailable;
  final int? diskAvailableRaw;
  final String? diskSize;
  final int? diskSizeRaw;
  final double? diskUsagePercentage;
  final String? diskUse;
  final int? diskUseRaw;

  const ServerStorageResponseDto({
    this.diskAvailable,
    this.diskAvailableRaw,
    this.diskSize,
    this.diskSizeRaw,
    this.diskUsagePercentage,
    this.diskUse,
    this.diskUseRaw,
  });

  factory ServerStorageResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServerStorageResponseDto();
    return ServerStorageResponseDto(
      diskAvailable: json["diskAvailable"]?.toString(),
      diskAvailableRaw: (json["diskAvailableRaw"] as num?)?.toInt(),
      diskSize: json["diskSize"]?.toString(),
      diskSizeRaw: (json["diskSizeRaw"] as num?)?.toInt(),
      diskUsagePercentage: (json["diskUsagePercentage"] as num?)?.toDouble(),
      diskUse: json["diskUse"]?.toString(),
      diskUseRaw: (json["diskUseRaw"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (diskAvailable != null) "diskAvailable": diskAvailable,
    if (diskAvailableRaw != null) "diskAvailableRaw": diskAvailableRaw,
    if (diskSize != null) "diskSize": diskSize,
    if (diskSizeRaw != null) "diskSizeRaw": diskSizeRaw,
    if (diskUsagePercentage != null) "diskUsagePercentage": diskUsagePercentage,
    if (diskUse != null) "diskUse": diskUse,
    if (diskUseRaw != null) "diskUseRaw": diskUseRaw,
  };

  ServerStorageResponseDto copyWith({
    String? diskAvailable,
    int? diskAvailableRaw,
    String? diskSize,
    int? diskSizeRaw,
    double? diskUsagePercentage,
    String? diskUse,
    int? diskUseRaw,
  }) {
    return ServerStorageResponseDto(
      diskAvailable: diskAvailable ?? this.diskAvailable,
      diskAvailableRaw: diskAvailableRaw ?? this.diskAvailableRaw,
      diskSize: diskSize ?? this.diskSize,
      diskSizeRaw: diskSizeRaw ?? this.diskSizeRaw,
      diskUsagePercentage: diskUsagePercentage ?? this.diskUsagePercentage,
      diskUse: diskUse ?? this.diskUse,
      diskUseRaw: diskUseRaw ?? this.diskUseRaw,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ServerVersionHistoryResponseDto {
  final String? createdAt;
  final String? id;
  final String? version;

  const ServerVersionHistoryResponseDto({
    this.createdAt,
    this.id,
    this.version,
  });

  factory ServerVersionHistoryResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServerVersionHistoryResponseDto();
    return ServerVersionHistoryResponseDto(
      createdAt: json["createdAt"]?.toString(),
      id: json["id"]?.toString(),
      version: json["version"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (createdAt != null) "createdAt": createdAt,
    if (id != null) "id": id,
    if (version != null) "version": version,
  };

  ServerVersionHistoryResponseDto copyWith({
    String? createdAt,
    String? id,
    String? version,
  }) {
    return ServerVersionHistoryResponseDto(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      version: version ?? this.version,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ServerVersionResponseDto {
  final int? major;
  final int? minor;
  final int? patch;
  final int? prerelease;

  const ServerVersionResponseDto({
    this.major,
    this.minor,
    this.patch,
    this.prerelease,
  });

  factory ServerVersionResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServerVersionResponseDto();
    return ServerVersionResponseDto(
      major: (json["major"] as num?)?.toInt(),
      minor: (json["minor"] as num?)?.toInt(),
      patch: (json["patch"] as num?)?.toInt(),
      prerelease: (json["prerelease"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (major != null) "major": major,
    if (minor != null) "minor": minor,
    if (patch != null) "patch": patch,
    if (prerelease != null) "prerelease": prerelease,
  };

  ServerVersionResponseDto copyWith({
    int? major,
    int? minor,
    int? patch,
    int? prerelease,
  }) {
    return ServerVersionResponseDto(
      major: major ?? this.major,
      minor: minor ?? this.minor,
      patch: patch ?? this.patch,
      prerelease: prerelease ?? this.prerelease,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SessionCreateDto {
  final String? deviceOS;
  final String? deviceType;
  final int? duration;

  const SessionCreateDto({
    this.deviceOS,
    this.deviceType,
    this.duration,
  });

  factory SessionCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SessionCreateDto();
    return SessionCreateDto(
      deviceOS: json["deviceOS"]?.toString(),
      deviceType: json["deviceType"]?.toString(),
      duration: (json["duration"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (deviceOS != null) "deviceOS": deviceOS,
    if (deviceType != null) "deviceType": deviceType,
    if (duration != null) "duration": duration,
  };

  SessionCreateDto copyWith({
    String? deviceOS,
    String? deviceType,
    int? duration,
  }) {
    return SessionCreateDto(
      deviceOS: deviceOS ?? this.deviceOS,
      deviceType: deviceType ?? this.deviceType,
      duration: duration ?? this.duration,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SessionCreateResponseDto {
  final String? appVersion;
  final String? createdAt;
  final bool? current;
  final String? deviceOS;
  final String? deviceType;
  final String? expiresAt;
  final String? id;
  final bool? isPendingSyncReset;
  final String? token;
  final String? updatedAt;

  const SessionCreateResponseDto({
    this.appVersion,
    this.createdAt,
    this.current,
    this.deviceOS,
    this.deviceType,
    this.expiresAt,
    this.id,
    this.isPendingSyncReset,
    this.token,
    this.updatedAt,
  });

  factory SessionCreateResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SessionCreateResponseDto();
    return SessionCreateResponseDto(
      appVersion: json["appVersion"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      current: (json["current"] as bool?),
      deviceOS: json["deviceOS"]?.toString(),
      deviceType: json["deviceType"]?.toString(),
      expiresAt: json["expiresAt"]?.toString(),
      id: json["id"]?.toString(),
      isPendingSyncReset: (json["isPendingSyncReset"] as bool?),
      token: json["token"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (appVersion != null) "appVersion": appVersion,
    if (createdAt != null) "createdAt": createdAt,
    if (current != null) "current": current,
    if (deviceOS != null) "deviceOS": deviceOS,
    if (deviceType != null) "deviceType": deviceType,
    if (expiresAt != null) "expiresAt": expiresAt,
    if (id != null) "id": id,
    if (isPendingSyncReset != null) "isPendingSyncReset": isPendingSyncReset,
    if (token != null) "token": token,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  SessionCreateResponseDto copyWith({
    String? appVersion,
    String? createdAt,
    bool? current,
    String? deviceOS,
    String? deviceType,
    String? expiresAt,
    String? id,
    bool? isPendingSyncReset,
    String? token,
    String? updatedAt,
  }) {
    return SessionCreateResponseDto(
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      current: current ?? this.current,
      deviceOS: deviceOS ?? this.deviceOS,
      deviceType: deviceType ?? this.deviceType,
      expiresAt: expiresAt ?? this.expiresAt,
      id: id ?? this.id,
      isPendingSyncReset: isPendingSyncReset ?? this.isPendingSyncReset,
      token: token ?? this.token,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SessionResponseDto {
  final String? appVersion;
  final String? createdAt;
  final bool? current;
  final String? deviceOS;
  final String? deviceType;
  final String? expiresAt;
  final String? id;
  final bool? isPendingSyncReset;
  final String? updatedAt;

  const SessionResponseDto({
    this.appVersion,
    this.createdAt,
    this.current,
    this.deviceOS,
    this.deviceType,
    this.expiresAt,
    this.id,
    this.isPendingSyncReset,
    this.updatedAt,
  });

  factory SessionResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SessionResponseDto();
    return SessionResponseDto(
      appVersion: json["appVersion"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      current: (json["current"] as bool?),
      deviceOS: json["deviceOS"]?.toString(),
      deviceType: json["deviceType"]?.toString(),
      expiresAt: json["expiresAt"]?.toString(),
      id: json["id"]?.toString(),
      isPendingSyncReset: (json["isPendingSyncReset"] as bool?),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (appVersion != null) "appVersion": appVersion,
    if (createdAt != null) "createdAt": createdAt,
    if (current != null) "current": current,
    if (deviceOS != null) "deviceOS": deviceOS,
    if (deviceType != null) "deviceType": deviceType,
    if (expiresAt != null) "expiresAt": expiresAt,
    if (id != null) "id": id,
    if (isPendingSyncReset != null) "isPendingSyncReset": isPendingSyncReset,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  SessionResponseDto copyWith({
    String? appVersion,
    String? createdAt,
    bool? current,
    String? deviceOS,
    String? deviceType,
    String? expiresAt,
    String? id,
    bool? isPendingSyncReset,
    String? updatedAt,
  }) {
    return SessionResponseDto(
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      current: current ?? this.current,
      deviceOS: deviceOS ?? this.deviceOS,
      deviceType: deviceType ?? this.deviceType,
      expiresAt: expiresAt ?? this.expiresAt,
      id: id ?? this.id,
      isPendingSyncReset: isPendingSyncReset ?? this.isPendingSyncReset,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SessionUnlockDto {
  final String? password;
  final String? pinCode;

  const SessionUnlockDto({
    this.password,
    this.pinCode,
  });

  factory SessionUnlockDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SessionUnlockDto();
    return SessionUnlockDto(
      password: json["password"]?.toString(),
      pinCode: json["pinCode"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (password != null) "password": password,
    if (pinCode != null) "pinCode": pinCode,
  };

  SessionUnlockDto copyWith({
    String? password,
    String? pinCode,
  }) {
    return SessionUnlockDto(
      password: password ?? this.password,
      pinCode: pinCode ?? this.pinCode,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SharedLinkCreateDto {
  final String? albumId;
  final bool? allowDownload;
  final bool? allowUpload;
  final List<String>? assetIds;
  final String? description;
  final String? expiresAt;
  final String? password;
  final bool? showMetadata;
  final String? slug;
  final SharedLinkType? type;

  const SharedLinkCreateDto({
    this.albumId,
    this.allowDownload,
    this.allowUpload,
    this.assetIds,
    this.description,
    this.expiresAt,
    this.password,
    this.showMetadata,
    this.slug,
    this.type,
  });

  factory SharedLinkCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SharedLinkCreateDto();
    return SharedLinkCreateDto(
      albumId: json["albumId"]?.toString(),
      allowDownload: (json["allowDownload"] as bool?),
      allowUpload: (json["allowUpload"] as bool?),
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      description: json["description"]?.toString(),
      expiresAt: json["expiresAt"]?.toString(),
      password: json["password"]?.toString(),
      showMetadata: (json["showMetadata"] as bool?),
      slug: json["slug"]?.toString(),
      type: _sharedLinkTypeFromJson(json["type"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumId != null) "albumId": albumId,
    if (allowDownload != null) "allowDownload": allowDownload,
    if (allowUpload != null) "allowUpload": allowUpload,
    if (assetIds != null) "assetIds": assetIds,
    if (description != null) "description": description,
    if (expiresAt != null) "expiresAt": expiresAt,
    if (password != null) "password": password,
    if (showMetadata != null) "showMetadata": showMetadata,
    if (slug != null) "slug": slug,
    if (type != null) "type": type?.value,
  };

  SharedLinkCreateDto copyWith({
    String? albumId,
    bool? allowDownload,
    bool? allowUpload,
    List<String>? assetIds,
    String? description,
    String? expiresAt,
    String? password,
    bool? showMetadata,
    String? slug,
    SharedLinkType? type,
  }) {
    return SharedLinkCreateDto(
      albumId: albumId ?? this.albumId,
      allowDownload: allowDownload ?? this.allowDownload,
      allowUpload: allowUpload ?? this.allowUpload,
      assetIds: assetIds ?? this.assetIds,
      description: description ?? this.description,
      expiresAt: expiresAt ?? this.expiresAt,
      password: password ?? this.password,
      showMetadata: showMetadata ?? this.showMetadata,
      slug: slug ?? this.slug,
      type: type ?? this.type,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SharedLinkEditDto {
  final bool? allowDownload;
  final bool? allowUpload;
  final String? description;
  final String? expiresAt;
  final String? password;
  final bool? showMetadata;
  final String? slug;

  const SharedLinkEditDto({
    this.allowDownload,
    this.allowUpload,
    this.description,
    this.expiresAt,
    this.password,
    this.showMetadata,
    this.slug,
  });

  factory SharedLinkEditDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SharedLinkEditDto();
    return SharedLinkEditDto(
      allowDownload: (json["allowDownload"] as bool?),
      allowUpload: (json["allowUpload"] as bool?),
      description: json["description"]?.toString(),
      expiresAt: json["expiresAt"]?.toString(),
      password: json["password"]?.toString(),
      showMetadata: (json["showMetadata"] as bool?),
      slug: json["slug"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (allowDownload != null) "allowDownload": allowDownload,
    if (allowUpload != null) "allowUpload": allowUpload,
    if (description != null) "description": description,
    if (expiresAt != null) "expiresAt": expiresAt,
    if (password != null) "password": password,
    if (showMetadata != null) "showMetadata": showMetadata,
    if (slug != null) "slug": slug,
  };

  SharedLinkEditDto copyWith({
    bool? allowDownload,
    bool? allowUpload,
    String? description,
    String? expiresAt,
    String? password,
    bool? showMetadata,
    String? slug,
  }) {
    return SharedLinkEditDto(
      allowDownload: allowDownload ?? this.allowDownload,
      allowUpload: allowUpload ?? this.allowUpload,
      description: description ?? this.description,
      expiresAt: expiresAt ?? this.expiresAt,
      password: password ?? this.password,
      showMetadata: showMetadata ?? this.showMetadata,
      slug: slug ?? this.slug,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SharedLinkResponseDto {
  final AlbumResponseDto? album;
  final bool? allowDownload;
  final bool? allowUpload;
  final List<AssetResponseDto>? assets;
  final String? createdAt;
  final String? description;
  final String? expiresAt;
  final String? id;
  final String? key;
  final String? password;
  final bool? showMetadata;
  final String? slug;
  final SharedLinkType? type;
  final String? userId;

  const SharedLinkResponseDto({
    this.album,
    this.allowDownload,
    this.allowUpload,
    this.assets,
    this.createdAt,
    this.description,
    this.expiresAt,
    this.id,
    this.key,
    this.password,
    this.showMetadata,
    this.slug,
    this.type,
    this.userId,
  });

  factory SharedLinkResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SharedLinkResponseDto();
    return SharedLinkResponseDto(
      album: AlbumResponseDto.fromJson((json["album"] as Map<String, dynamic>?)),
      allowDownload: (json["allowDownload"] as bool?),
      allowUpload: (json["allowUpload"] as bool?),
      assets: ((json["assets"] as List<dynamic>?)?.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetResponseDto>().toList()),
      createdAt: json["createdAt"]?.toString(),
      description: json["description"]?.toString(),
      expiresAt: json["expiresAt"]?.toString(),
      id: json["id"]?.toString(),
      key: json["key"]?.toString(),
      password: json["password"]?.toString(),
      showMetadata: (json["showMetadata"] as bool?),
      slug: json["slug"]?.toString(),
      type: _sharedLinkTypeFromJson(json["type"]?.toString()),
      userId: json["userId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (album != null) "album": album?.toJson(),
    if (allowDownload != null) "allowDownload": allowDownload,
    if (allowUpload != null) "allowUpload": allowUpload,
    if (assets != null) "assets": assets?.map((e) => e?.toJson()).toList(),
    if (createdAt != null) "createdAt": createdAt,
    if (description != null) "description": description,
    if (expiresAt != null) "expiresAt": expiresAt,
    if (id != null) "id": id,
    if (key != null) "key": key,
    if (password != null) "password": password,
    if (showMetadata != null) "showMetadata": showMetadata,
    if (slug != null) "slug": slug,
    if (type != null) "type": type?.value,
    if (userId != null) "userId": userId,
  };

  SharedLinkResponseDto copyWith({
    AlbumResponseDto? album,
    bool? allowDownload,
    bool? allowUpload,
    List<AssetResponseDto>? assets,
    String? createdAt,
    String? description,
    String? expiresAt,
    String? id,
    String? key,
    String? password,
    bool? showMetadata,
    String? slug,
    SharedLinkType? type,
    String? userId,
  }) {
    return SharedLinkResponseDto(
      album: album ?? this.album,
      allowDownload: allowDownload ?? this.allowDownload,
      allowUpload: allowUpload ?? this.allowUpload,
      assets: assets ?? this.assets,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      expiresAt: expiresAt ?? this.expiresAt,
      id: id ?? this.id,
      key: key ?? this.key,
      password: password ?? this.password,
      showMetadata: showMetadata ?? this.showMetadata,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SharedLinksResponse {
  final bool? enabled;
  final bool? sidebarWeb;

  const SharedLinksResponse({
    this.enabled,
    this.sidebarWeb,
  });

  factory SharedLinksResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SharedLinksResponse();
    return SharedLinksResponse(
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  SharedLinksResponse copyWith({
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return SharedLinksResponse(
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SharedLinksUpdate {
  final bool? enabled;
  final bool? sidebarWeb;

  const SharedLinksUpdate({
    this.enabled,
    this.sidebarWeb,
  });

  factory SharedLinksUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SharedLinksUpdate();
    return SharedLinksUpdate(
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  SharedLinksUpdate copyWith({
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return SharedLinksUpdate(
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SignUpDto {
  final String? email;
  final String? name;
  final String? password;

  const SignUpDto({
    this.email,
    this.name,
    this.password,
  });

  factory SignUpDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SignUpDto();
    return SignUpDto(
      email: json["email"]?.toString(),
      name: json["name"]?.toString(),
      password: json["password"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (email != null) "email": email,
    if (name != null) "name": name,
    if (password != null) "password": password,
  };

  SignUpDto copyWith({
    String? email,
    String? name,
    String? password,
  }) {
    return SignUpDto(
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SmartSearchDto {
  final List<String>? albumIds;
  final String? city;
  final String? country;
  final String? createdAfter;
  final String? createdBefore;
  final SearchFilter? filter;
  final bool? isEncoded;
  final bool? isFavorite;
  final bool? isMotion;
  final bool? isNotInAlbum;
  final bool? isOffline;
  final String? language;
  final String? lensModel;
  final String? libraryId;
  final String? make;
  final String? model;
  final String? ocr;
  final int? page;
  final List<String>? personIds;
  final String? query;
  final String? queryAssetId;
  final int? rating;
  final int? size;
  final String? state;
  final List<String>? tagIds;
  final String? takenAfter;
  final String? takenBefore;
  final String? trashedAfter;
  final String? trashedBefore;
  final AssetTypeEnum? type;
  final String? updatedAfter;
  final String? updatedBefore;
  final AssetVisibility? visibility;
  final bool? withDeleted;
  final bool? withExif;

  const SmartSearchDto({
    this.albumIds,
    this.city,
    this.country,
    this.createdAfter,
    this.createdBefore,
    this.filter,
    this.isEncoded,
    this.isFavorite,
    this.isMotion,
    this.isNotInAlbum,
    this.isOffline,
    this.language,
    this.lensModel,
    this.libraryId,
    this.make,
    this.model,
    this.ocr,
    this.page,
    this.personIds,
    this.query,
    this.queryAssetId,
    this.rating,
    this.size,
    this.state,
    this.tagIds,
    this.takenAfter,
    this.takenBefore,
    this.trashedAfter,
    this.trashedBefore,
    this.type,
    this.updatedAfter,
    this.updatedBefore,
    this.visibility,
    this.withDeleted,
    this.withExif,
  });

  factory SmartSearchDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SmartSearchDto();
    return SmartSearchDto(
      albumIds: ((json["albumIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      createdAfter: json["createdAfter"]?.toString(),
      createdBefore: json["createdBefore"]?.toString(),
      filter: SearchFilter.fromJson((json["filter"] as Map<String, dynamic>?)),
      isEncoded: (json["isEncoded"] as bool?),
      isFavorite: (json["isFavorite"] as bool?),
      isMotion: (json["isMotion"] as bool?),
      isNotInAlbum: (json["isNotInAlbum"] as bool?),
      isOffline: (json["isOffline"] as bool?),
      language: json["language"]?.toString(),
      lensModel: json["lensModel"]?.toString(),
      libraryId: json["libraryId"]?.toString(),
      make: json["make"]?.toString(),
      model: json["model"]?.toString(),
      ocr: json["ocr"]?.toString(),
      page: (json["page"] as num?)?.toInt(),
      personIds: ((json["personIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      query: json["query"]?.toString(),
      queryAssetId: json["queryAssetId"]?.toString(),
      rating: (json["rating"] as num?)?.toInt(),
      size: (json["size"] as num?)?.toInt(),
      state: json["state"]?.toString(),
      tagIds: ((json["tagIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      takenAfter: json["takenAfter"]?.toString(),
      takenBefore: json["takenBefore"]?.toString(),
      trashedAfter: json["trashedAfter"]?.toString(),
      trashedBefore: json["trashedBefore"]?.toString(),
      type: _assetTypeEnumFromJson(json["type"]?.toString()),
      updatedAfter: json["updatedAfter"]?.toString(),
      updatedBefore: json["updatedBefore"]?.toString(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
      withDeleted: (json["withDeleted"] as bool?),
      withExif: (json["withExif"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumIds != null) "albumIds": albumIds,
    if (city != null) "city": city,
    if (country != null) "country": country,
    if (createdAfter != null) "createdAfter": createdAfter,
    if (createdBefore != null) "createdBefore": createdBefore,
    if (filter != null) "filter": filter?.toJson(),
    if (isEncoded != null) "isEncoded": isEncoded,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isMotion != null) "isMotion": isMotion,
    if (isNotInAlbum != null) "isNotInAlbum": isNotInAlbum,
    if (isOffline != null) "isOffline": isOffline,
    if (language != null) "language": language,
    if (lensModel != null) "lensModel": lensModel,
    if (libraryId != null) "libraryId": libraryId,
    if (make != null) "make": make,
    if (model != null) "model": model,
    if (ocr != null) "ocr": ocr,
    if (page != null) "page": page,
    if (personIds != null) "personIds": personIds,
    if (query != null) "query": query,
    if (queryAssetId != null) "queryAssetId": queryAssetId,
    if (rating != null) "rating": rating,
    if (size != null) "size": size,
    if (state != null) "state": state,
    if (tagIds != null) "tagIds": tagIds,
    if (takenAfter != null) "takenAfter": takenAfter,
    if (takenBefore != null) "takenBefore": takenBefore,
    if (trashedAfter != null) "trashedAfter": trashedAfter,
    if (trashedBefore != null) "trashedBefore": trashedBefore,
    if (type != null) "type": type?.value,
    if (updatedAfter != null) "updatedAfter": updatedAfter,
    if (updatedBefore != null) "updatedBefore": updatedBefore,
    if (visibility != null) "visibility": visibility?.value,
    if (withDeleted != null) "withDeleted": withDeleted,
    if (withExif != null) "withExif": withExif,
  };

  SmartSearchDto copyWith({
    List<String>? albumIds,
    String? city,
    String? country,
    String? createdAfter,
    String? createdBefore,
    SearchFilter? filter,
    bool? isEncoded,
    bool? isFavorite,
    bool? isMotion,
    bool? isNotInAlbum,
    bool? isOffline,
    String? language,
    String? lensModel,
    String? libraryId,
    String? make,
    String? model,
    String? ocr,
    int? page,
    List<String>? personIds,
    String? query,
    String? queryAssetId,
    int? rating,
    int? size,
    String? state,
    List<String>? tagIds,
    String? takenAfter,
    String? takenBefore,
    String? trashedAfter,
    String? trashedBefore,
    AssetTypeEnum? type,
    String? updatedAfter,
    String? updatedBefore,
    AssetVisibility? visibility,
    bool? withDeleted,
    bool? withExif,
  }) {
    return SmartSearchDto(
      albumIds: albumIds ?? this.albumIds,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      filter: filter ?? this.filter,
      isEncoded: isEncoded ?? this.isEncoded,
      isFavorite: isFavorite ?? this.isFavorite,
      isMotion: isMotion ?? this.isMotion,
      isNotInAlbum: isNotInAlbum ?? this.isNotInAlbum,
      isOffline: isOffline ?? this.isOffline,
      language: language ?? this.language,
      lensModel: lensModel ?? this.lensModel,
      libraryId: libraryId ?? this.libraryId,
      make: make ?? this.make,
      model: model ?? this.model,
      ocr: ocr ?? this.ocr,
      page: page ?? this.page,
      personIds: personIds ?? this.personIds,
      query: query ?? this.query,
      queryAssetId: queryAssetId ?? this.queryAssetId,
      rating: rating ?? this.rating,
      size: size ?? this.size,
      state: state ?? this.state,
      tagIds: tagIds ?? this.tagIds,
      takenAfter: takenAfter ?? this.takenAfter,
      takenBefore: takenBefore ?? this.takenBefore,
      trashedAfter: trashedAfter ?? this.trashedAfter,
      trashedBefore: trashedBefore ?? this.trashedBefore,
      type: type ?? this.type,
      updatedAfter: updatedAfter ?? this.updatedAfter,
      updatedBefore: updatedBefore ?? this.updatedBefore,
      visibility: visibility ?? this.visibility,
      withDeleted: withDeleted ?? this.withDeleted,
      withExif: withExif ?? this.withExif,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class StackCreateDto {
  final List<String>? assetIds;

  const StackCreateDto({
    this.assetIds,
  });

  factory StackCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StackCreateDto();
    return StackCreateDto(
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetIds != null) "assetIds": assetIds,
  };

  StackCreateDto copyWith({
    List<String>? assetIds,
  }) {
    return StackCreateDto(
      assetIds: assetIds ?? this.assetIds,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class StackResponseDto {
  final List<AssetResponseDto>? assets;
  final String? id;
  final String? primaryAssetId;

  const StackResponseDto({
    this.assets,
    this.id,
    this.primaryAssetId,
  });

  factory StackResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StackResponseDto();
    return StackResponseDto(
      assets: ((json["assets"] as List<dynamic>?)?.map((e) => AssetResponseDto.fromJson((e as Map<String, dynamic>?))).whereType<AssetResponseDto>().toList()),
      id: json["id"]?.toString(),
      primaryAssetId: json["primaryAssetId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assets != null) "assets": assets?.map((e) => e?.toJson()).toList(),
    if (id != null) "id": id,
    if (primaryAssetId != null) "primaryAssetId": primaryAssetId,
  };

  StackResponseDto copyWith({
    List<AssetResponseDto>? assets,
    String? id,
    String? primaryAssetId,
  }) {
    return StackResponseDto(
      assets: assets ?? this.assets,
      id: id ?? this.id,
      primaryAssetId: primaryAssetId ?? this.primaryAssetId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class StatisticsSearchDto {
  final List<String>? albumIds;
  final String? city;
  final String? country;
  final String? createdAfter;
  final String? createdBefore;
  final String? description;
  final SearchFilter? filter;
  final bool? isEncoded;
  final bool? isFavorite;
  final bool? isMotion;
  final bool? isNotInAlbum;
  final bool? isOffline;
  final String? lensModel;
  final String? libraryId;
  final String? make;
  final String? model;
  final String? ocr;
  final List<String>? personIds;
  final int? rating;
  final String? state;
  final List<String>? tagIds;
  final String? takenAfter;
  final String? takenBefore;
  final String? trashedAfter;
  final String? trashedBefore;
  final AssetTypeEnum? type;
  final String? updatedAfter;
  final String? updatedBefore;
  final AssetVisibility? visibility;

  const StatisticsSearchDto({
    this.albumIds,
    this.city,
    this.country,
    this.createdAfter,
    this.createdBefore,
    this.description,
    this.filter,
    this.isEncoded,
    this.isFavorite,
    this.isMotion,
    this.isNotInAlbum,
    this.isOffline,
    this.lensModel,
    this.libraryId,
    this.make,
    this.model,
    this.ocr,
    this.personIds,
    this.rating,
    this.state,
    this.tagIds,
    this.takenAfter,
    this.takenBefore,
    this.trashedAfter,
    this.trashedBefore,
    this.type,
    this.updatedAfter,
    this.updatedBefore,
    this.visibility,
  });

  factory StatisticsSearchDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StatisticsSearchDto();
    return StatisticsSearchDto(
      albumIds: ((json["albumIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      createdAfter: json["createdAfter"]?.toString(),
      createdBefore: json["createdBefore"]?.toString(),
      description: json["description"]?.toString(),
      filter: SearchFilter.fromJson((json["filter"] as Map<String, dynamic>?)),
      isEncoded: (json["isEncoded"] as bool?),
      isFavorite: (json["isFavorite"] as bool?),
      isMotion: (json["isMotion"] as bool?),
      isNotInAlbum: (json["isNotInAlbum"] as bool?),
      isOffline: (json["isOffline"] as bool?),
      lensModel: json["lensModel"]?.toString(),
      libraryId: json["libraryId"]?.toString(),
      make: json["make"]?.toString(),
      model: json["model"]?.toString(),
      ocr: json["ocr"]?.toString(),
      personIds: ((json["personIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      rating: (json["rating"] as num?)?.toInt(),
      state: json["state"]?.toString(),
      tagIds: ((json["tagIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      takenAfter: json["takenAfter"]?.toString(),
      takenBefore: json["takenBefore"]?.toString(),
      trashedAfter: json["trashedAfter"]?.toString(),
      trashedBefore: json["trashedBefore"]?.toString(),
      type: _assetTypeEnumFromJson(json["type"]?.toString()),
      updatedAfter: json["updatedAfter"]?.toString(),
      updatedBefore: json["updatedBefore"]?.toString(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumIds != null) "albumIds": albumIds,
    if (city != null) "city": city,
    if (country != null) "country": country,
    if (createdAfter != null) "createdAfter": createdAfter,
    if (createdBefore != null) "createdBefore": createdBefore,
    if (description != null) "description": description,
    if (filter != null) "filter": filter?.toJson(),
    if (isEncoded != null) "isEncoded": isEncoded,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isMotion != null) "isMotion": isMotion,
    if (isNotInAlbum != null) "isNotInAlbum": isNotInAlbum,
    if (isOffline != null) "isOffline": isOffline,
    if (lensModel != null) "lensModel": lensModel,
    if (libraryId != null) "libraryId": libraryId,
    if (make != null) "make": make,
    if (model != null) "model": model,
    if (ocr != null) "ocr": ocr,
    if (personIds != null) "personIds": personIds,
    if (rating != null) "rating": rating,
    if (state != null) "state": state,
    if (tagIds != null) "tagIds": tagIds,
    if (takenAfter != null) "takenAfter": takenAfter,
    if (takenBefore != null) "takenBefore": takenBefore,
    if (trashedAfter != null) "trashedAfter": trashedAfter,
    if (trashedBefore != null) "trashedBefore": trashedBefore,
    if (type != null) "type": type?.value,
    if (updatedAfter != null) "updatedAfter": updatedAfter,
    if (updatedBefore != null) "updatedBefore": updatedBefore,
    if (visibility != null) "visibility": visibility?.value,
  };

  StatisticsSearchDto copyWith({
    List<String>? albumIds,
    String? city,
    String? country,
    String? createdAfter,
    String? createdBefore,
    String? description,
    SearchFilter? filter,
    bool? isEncoded,
    bool? isFavorite,
    bool? isMotion,
    bool? isNotInAlbum,
    bool? isOffline,
    String? lensModel,
    String? libraryId,
    String? make,
    String? model,
    String? ocr,
    List<String>? personIds,
    int? rating,
    String? state,
    List<String>? tagIds,
    String? takenAfter,
    String? takenBefore,
    String? trashedAfter,
    String? trashedBefore,
    AssetTypeEnum? type,
    String? updatedAfter,
    String? updatedBefore,
    AssetVisibility? visibility,
  }) {
    return StatisticsSearchDto(
      albumIds: albumIds ?? this.albumIds,
      city: city ?? this.city,
      country: country ?? this.country,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      description: description ?? this.description,
      filter: filter ?? this.filter,
      isEncoded: isEncoded ?? this.isEncoded,
      isFavorite: isFavorite ?? this.isFavorite,
      isMotion: isMotion ?? this.isMotion,
      isNotInAlbum: isNotInAlbum ?? this.isNotInAlbum,
      isOffline: isOffline ?? this.isOffline,
      lensModel: lensModel ?? this.lensModel,
      libraryId: libraryId ?? this.libraryId,
      make: make ?? this.make,
      model: model ?? this.model,
      ocr: ocr ?? this.ocr,
      personIds: personIds ?? this.personIds,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      tagIds: tagIds ?? this.tagIds,
      takenAfter: takenAfter ?? this.takenAfter,
      takenBefore: takenBefore ?? this.takenBefore,
      trashedAfter: trashedAfter ?? this.trashedAfter,
      trashedBefore: trashedBefore ?? this.trashedBefore,
      type: type ?? this.type,
      updatedAfter: updatedAfter ?? this.updatedAfter,
      updatedBefore: updatedBefore ?? this.updatedBefore,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class StringFilter {
  final String? eq;
  final List<String>? in_;
  final String? ne;
  final List<String>? notIn;

  const StringFilter({
    this.eq,
    this.in_,
    this.ne,
    this.notIn,
  });

  factory StringFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StringFilter();
    return StringFilter(
      eq: json["eq"]?.toString(),
      in_: ((json["in"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      ne: json["ne"]?.toString(),
      notIn: ((json["notIn"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (in_ != null) "in": in_,
    if (ne != null) "ne": ne,
    if (notIn != null) "notIn": notIn,
  };

  StringFilter copyWith({
    String? eq,
    List<String>? in_,
    String? ne,
    List<String>? notIn,
  }) {
    return StringFilter(
      eq: eq ?? this.eq,
      in_: in_ ?? this.in_,
      ne: ne ?? this.ne,
      notIn: notIn ?? this.notIn,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class StringFilterNullable {
  final String? eq;
  final List<String>? in_;
  final String? ne;
  final List<String>? notIn;

  const StringFilterNullable({
    this.eq,
    this.in_,
    this.ne,
    this.notIn,
  });

  factory StringFilterNullable.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StringFilterNullable();
    return StringFilterNullable(
      eq: json["eq"]?.toString(),
      in_: ((json["in"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      ne: json["ne"]?.toString(),
      notIn: ((json["notIn"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (eq != null) "eq": eq,
    if (in_ != null) "in": in_,
    if (ne != null) "ne": ne,
    if (notIn != null) "notIn": notIn,
  };

  StringFilterNullable copyWith({
    String? eq,
    List<String>? in_,
    String? ne,
    List<String>? notIn,
  }) {
    return StringFilterNullable(
      eq: eq ?? this.eq,
      in_: in_ ?? this.in_,
      ne: ne ?? this.ne,
      notIn: notIn ?? this.notIn,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class StringPatternFilter {
  final String? endsWith;
  final String? eq;
  final List<String>? in_;
  final String? like;
  final String? ne;
  final List<String>? notIn;
  final String? notLike;
  final String? startsWith;

  const StringPatternFilter({
    this.endsWith,
    this.eq,
    this.in_,
    this.like,
    this.ne,
    this.notIn,
    this.notLike,
    this.startsWith,
  });

  factory StringPatternFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StringPatternFilter();
    return StringPatternFilter(
      endsWith: json["endsWith"]?.toString(),
      eq: json["eq"]?.toString(),
      in_: ((json["in"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      like: json["like"]?.toString(),
      ne: json["ne"]?.toString(),
      notIn: ((json["notIn"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      notLike: json["notLike"]?.toString(),
      startsWith: json["startsWith"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (endsWith != null) "endsWith": endsWith,
    if (eq != null) "eq": eq,
    if (in_ != null) "in": in_,
    if (like != null) "like": like,
    if (ne != null) "ne": ne,
    if (notIn != null) "notIn": notIn,
    if (notLike != null) "notLike": notLike,
    if (startsWith != null) "startsWith": startsWith,
  };

  StringPatternFilter copyWith({
    String? endsWith,
    String? eq,
    List<String>? in_,
    String? like,
    String? ne,
    List<String>? notIn,
    String? notLike,
    String? startsWith,
  }) {
    return StringPatternFilter(
      endsWith: endsWith ?? this.endsWith,
      eq: eq ?? this.eq,
      in_: in_ ?? this.in_,
      like: like ?? this.like,
      ne: ne ?? this.ne,
      notIn: notIn ?? this.notIn,
      notLike: notLike ?? this.notLike,
      startsWith: startsWith ?? this.startsWith,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class StringSimilarityFilter {
  final String? matches;

  const StringSimilarityFilter({
    this.matches,
  });

  factory StringSimilarityFilter.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StringSimilarityFilter();
    return StringSimilarityFilter(
      matches: json["matches"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (matches != null) "matches": matches,
  };

  StringSimilarityFilter copyWith({
    String? matches,
  }) {
    return StringSimilarityFilter(
      matches: matches ?? this.matches,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SyncAckDeleteDto {
  final List<SyncEntityType>? types;

  const SyncAckDeleteDto({
    this.types,
  });

  factory SyncAckDeleteDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SyncAckDeleteDto();
    return SyncAckDeleteDto(
      types: ((json["types"] as List<dynamic>?)?.map((e) => _syncEntityTypeFromJson(e?.toString())).whereType<SyncEntityType>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (types != null) "types": types?.map((e) => e?.value).toList(),
  };

  SyncAckDeleteDto copyWith({
    List<SyncEntityType>? types,
  }) {
    return SyncAckDeleteDto(
      types: types ?? this.types,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SyncAckDto {
  final String? ack;
  final SyncEntityType? type;

  const SyncAckDto({
    this.ack,
    this.type,
  });

  factory SyncAckDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SyncAckDto();
    return SyncAckDto(
      ack: json["ack"]?.toString(),
      type: _syncEntityTypeFromJson(json["type"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ack != null) "ack": ack,
    if (type != null) "type": type?.value,
  };

  SyncAckDto copyWith({
    String? ack,
    SyncEntityType? type,
  }) {
    return SyncAckDto(
      ack: ack ?? this.ack,
      type: type ?? this.type,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SyncAckSetDto {
  final List<String>? acks;

  const SyncAckSetDto({
    this.acks,
  });

  factory SyncAckSetDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SyncAckSetDto();
    return SyncAckSetDto(
      acks: ((json["acks"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (acks != null) "acks": acks,
  };

  SyncAckSetDto copyWith({
    List<String>? acks,
  }) {
    return SyncAckSetDto(
      acks: acks ?? this.acks,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SyncStreamDto {
  final bool? reset;
  final List<SyncRequestType>? types;

  const SyncStreamDto({
    this.reset,
    this.types,
  });

  factory SyncStreamDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SyncStreamDto();
    return SyncStreamDto(
      reset: (json["reset"] as bool?),
      types: ((json["types"] as List<dynamic>?)?.map((e) => _syncRequestTypeFromJson(e?.toString())).whereType<SyncRequestType>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (reset != null) "reset": reset,
    if (types != null) "types": types?.map((e) => e?.value).toList(),
  };

  SyncStreamDto copyWith({
    bool? reset,
    List<SyncRequestType>? types,
  }) {
    return SyncStreamDto(
      reset: reset ?? this.reset,
      types: types ?? this.types,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TagBulkAssetsDto {
  final List<String>? assetIds;
  final List<String>? tagIds;

  const TagBulkAssetsDto({
    this.assetIds,
    this.tagIds,
  });

  factory TagBulkAssetsDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TagBulkAssetsDto();
    return TagBulkAssetsDto(
      assetIds: ((json["assetIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      tagIds: ((json["tagIds"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (assetIds != null) "assetIds": assetIds,
    if (tagIds != null) "tagIds": tagIds,
  };

  TagBulkAssetsDto copyWith({
    List<String>? assetIds,
    List<String>? tagIds,
  }) {
    return TagBulkAssetsDto(
      assetIds: assetIds ?? this.assetIds,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TagBulkAssetsResponseDto {
  final int? count;

  const TagBulkAssetsResponseDto({
    this.count,
  });

  factory TagBulkAssetsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TagBulkAssetsResponseDto();
    return TagBulkAssetsResponseDto(
      count: (json["count"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (count != null) "count": count,
  };

  TagBulkAssetsResponseDto copyWith({
    int? count,
  }) {
    return TagBulkAssetsResponseDto(
      count: count ?? this.count,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TagCreateDto {
  final String? color;
  final String? name;
  final String? parentId;

  const TagCreateDto({
    this.color,
    this.name,
    this.parentId,
  });

  factory TagCreateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TagCreateDto();
    return TagCreateDto(
      color: json["color"]?.toString(),
      name: json["name"]?.toString(),
      parentId: json["parentId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (color != null) "color": color,
    if (name != null) "name": name,
    if (parentId != null) "parentId": parentId,
  };

  TagCreateDto copyWith({
    String? color,
    String? name,
    String? parentId,
  }) {
    return TagCreateDto(
      color: color ?? this.color,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TagResponseDto {
  final String? color;
  final String? createdAt;
  final String? id;
  final String? name;
  final String? parentId;
  final String? updatedAt;
  final String? value;

  const TagResponseDto({
    this.color,
    this.createdAt,
    this.id,
    this.name,
    this.parentId,
    this.updatedAt,
    this.value,
  });

  factory TagResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TagResponseDto();
    return TagResponseDto(
      color: json["color"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      parentId: json["parentId"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
      value: json["value"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (color != null) "color": color,
    if (createdAt != null) "createdAt": createdAt,
    if (id != null) "id": id,
    if (name != null) "name": name,
    if (parentId != null) "parentId": parentId,
    if (updatedAt != null) "updatedAt": updatedAt,
    if (value != null) "value": value,
  };

  TagResponseDto copyWith({
    String? color,
    String? createdAt,
    String? id,
    String? name,
    String? parentId,
    String? updatedAt,
    String? value,
  }) {
    return TagResponseDto(
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      updatedAt: updatedAt ?? this.updatedAt,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TagUpsertDto {
  final List<String>? tags;

  const TagUpsertDto({
    this.tags,
  });

  factory TagUpsertDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TagUpsertDto();
    return TagUpsertDto(
      tags: ((json["tags"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (tags != null) "tags": tags,
  };

  TagUpsertDto copyWith({
    List<String>? tags,
  }) {
    return TagUpsertDto(
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TagsResponse {
  final bool? enabled;
  final bool? sidebarWeb;

  const TagsResponse({
    this.enabled,
    this.sidebarWeb,
  });

  factory TagsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TagsResponse();
    return TagsResponse(
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  TagsResponse copyWith({
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return TagsResponse(
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TagsUpdate {
  final bool? enabled;
  final bool? sidebarWeb;

  const TagsUpdate({
    this.enabled,
    this.sidebarWeb,
  });

  factory TagsUpdate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TagsUpdate();
    return TagsUpdate(
      enabled: (json["enabled"] as bool?),
      sidebarWeb: (json["sidebarWeb"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (sidebarWeb != null) "sidebarWeb": sidebarWeb,
  };

  TagsUpdate copyWith({
    bool? enabled,
    bool? sidebarWeb,
  }) {
    return TagsUpdate(
      enabled: enabled ?? this.enabled,
      sidebarWeb: sidebarWeb ?? this.sidebarWeb,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TimeBucketAssetResponseDto {
  final List<String?>? city;
  final List<String?>? country;
  final List<String>? createdAt;
  final List<int?>? duration;
  final List<String>? fileCreatedAt;
  final List<String>? id;
  final List<bool>? isFavorite;
  final List<bool>? isImage;
  final List<bool>? isTrashed;
  final List<double?>? latitude;
  final List<String?>? livePhotoVideoId;
  final List<double>? localOffsetHours;
  final List<double?>? longitude;
  final List<String>? ownerId;
  final List<String?>? projectionType;
  final List<double>? ratio;
  final List<List<String>?>? stack;
  final List<String?>? thumbhash;
  final List<AssetVisibility>? visibility;

  const TimeBucketAssetResponseDto({
    this.city,
    this.country,
    this.createdAt,
    this.duration,
    this.fileCreatedAt,
    this.id,
    this.isFavorite,
    this.isImage,
    this.isTrashed,
    this.latitude,
    this.livePhotoVideoId,
    this.localOffsetHours,
    this.longitude,
    this.ownerId,
    this.projectionType,
    this.ratio,
    this.stack,
    this.thumbhash,
    this.visibility,
  });

  factory TimeBucketAssetResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TimeBucketAssetResponseDto();
    return TimeBucketAssetResponseDto(
      city: ((json["city"] as List<dynamic>?)?.map((e) => e?.toString()).toList()),
      country: ((json["country"] as List<dynamic>?)?.map((e) => e?.toString()).toList()),
      createdAt: ((json["createdAt"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      duration: ((json["duration"] as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList()),
      fileCreatedAt: ((json["fileCreatedAt"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      id: ((json["id"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      isFavorite: ((json["isFavorite"] as List<dynamic>?)?.map((e) => (e as bool?)).whereType<bool>().toList()),
      isImage: ((json["isImage"] as List<dynamic>?)?.map((e) => (e as bool?)).whereType<bool>().toList()),
      isTrashed: ((json["isTrashed"] as List<dynamic>?)?.map((e) => (e as bool?)).whereType<bool>().toList()),
      latitude: ((json["latitude"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).toList()),
      livePhotoVideoId: ((json["livePhotoVideoId"] as List<dynamic>?)?.map((e) => e?.toString()).toList()),
      localOffsetHours: ((json["localOffsetHours"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).whereType<double>().toList()),
      longitude: ((json["longitude"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).toList()),
      ownerId: ((json["ownerId"] as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList()),
      projectionType: ((json["projectionType"] as List<dynamic>?)?.map((e) => e?.toString()).toList()),
      ratio: ((json["ratio"] as List<dynamic>?)?.map((e) => (e as num?)?.toDouble()).whereType<double>().toList()),
      stack: ((json["stack"] as List<dynamic>?)?.map((e) => ((e as List<dynamic>?)?.map((e) => e?.toString()).whereType<String>().toList())).toList()),
      thumbhash: ((json["thumbhash"] as List<dynamic>?)?.map((e) => e?.toString()).toList()),
      visibility: ((json["visibility"] as List<dynamic>?)?.map((e) => _assetVisibilityFromJson(e?.toString())).whereType<AssetVisibility>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (city != null) "city": city?.map((e) => e).toList(),
    if (country != null) "country": country?.map((e) => e).toList(),
    if (createdAt != null) "createdAt": createdAt,
    if (duration != null) "duration": duration?.map((e) => e).toList(),
    if (fileCreatedAt != null) "fileCreatedAt": fileCreatedAt,
    if (id != null) "id": id,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (isImage != null) "isImage": isImage,
    if (isTrashed != null) "isTrashed": isTrashed,
    if (latitude != null) "latitude": latitude?.map((e) => e).toList(),
    if (livePhotoVideoId != null) "livePhotoVideoId": livePhotoVideoId?.map((e) => e).toList(),
    if (localOffsetHours != null) "localOffsetHours": localOffsetHours,
    if (longitude != null) "longitude": longitude?.map((e) => e).toList(),
    if (ownerId != null) "ownerId": ownerId,
    if (projectionType != null) "projectionType": projectionType?.map((e) => e).toList(),
    if (ratio != null) "ratio": ratio,
    if (stack != null) "stack": stack?.map((e) => e).toList(),
    if (thumbhash != null) "thumbhash": thumbhash?.map((e) => e).toList(),
    if (visibility != null) "visibility": visibility?.map((e) => e?.value).toList(),
  };

  TimeBucketAssetResponseDto copyWith({
    List<String?>? city,
    List<String?>? country,
    List<String>? createdAt,
    List<int?>? duration,
    List<String>? fileCreatedAt,
    List<String>? id,
    List<bool>? isFavorite,
    List<bool>? isImage,
    List<bool>? isTrashed,
    List<double?>? latitude,
    List<String?>? livePhotoVideoId,
    List<double>? localOffsetHours,
    List<double?>? longitude,
    List<String>? ownerId,
    List<String?>? projectionType,
    List<double>? ratio,
    List<List<String>?>? stack,
    List<String?>? thumbhash,
    List<AssetVisibility>? visibility,
  }) {
    return TimeBucketAssetResponseDto(
      city: city ?? this.city,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileCreatedAt: fileCreatedAt ?? this.fileCreatedAt,
      id: id ?? this.id,
      isFavorite: isFavorite ?? this.isFavorite,
      isImage: isImage ?? this.isImage,
      isTrashed: isTrashed ?? this.isTrashed,
      latitude: latitude ?? this.latitude,
      livePhotoVideoId: livePhotoVideoId ?? this.livePhotoVideoId,
      localOffsetHours: localOffsetHours ?? this.localOffsetHours,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId ?? this.ownerId,
      projectionType: projectionType ?? this.projectionType,
      ratio: ratio ?? this.ratio,
      stack: stack ?? this.stack,
      thumbhash: thumbhash ?? this.thumbhash,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TimeBucketsResponseDto {
  final int? count;
  final String? timeBucket;

  const TimeBucketsResponseDto({
    this.count,
    this.timeBucket,
  });

  factory TimeBucketsResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TimeBucketsResponseDto();
    return TimeBucketsResponseDto(
      count: (json["count"] as num?)?.toInt(),
      timeBucket: json["timeBucket"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (count != null) "count": count,
    if (timeBucket != null) "timeBucket": timeBucket,
  };

  TimeBucketsResponseDto copyWith({
    int? count,
    String? timeBucket,
  }) {
    return TimeBucketsResponseDto(
      count: count ?? this.count,
      timeBucket: timeBucket ?? this.timeBucket,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class TrashResponseDto {
  final int? count;

  const TrashResponseDto({
    this.count,
  });

  factory TrashResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TrashResponseDto();
    return TrashResponseDto(
      count: (json["count"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (count != null) "count": count,
  };

  TrashResponseDto copyWith({
    int? count,
  }) {
    return TrashResponseDto(
      count: count ?? this.count,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UpdateAlbumDto {
  final String? albumName;
  final String? albumThumbnailAssetId;
  final String? description;
  final bool? isActivityEnabled;
  final AssetOrder? order;

  const UpdateAlbumDto({
    this.albumName,
    this.albumThumbnailAssetId,
    this.description,
    this.isActivityEnabled,
    this.order,
  });

  factory UpdateAlbumDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpdateAlbumDto();
    return UpdateAlbumDto(
      albumName: json["albumName"]?.toString(),
      albumThumbnailAssetId: json["albumThumbnailAssetId"]?.toString(),
      description: json["description"]?.toString(),
      isActivityEnabled: (json["isActivityEnabled"] as bool?),
      order: _assetOrderFromJson(json["order"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albumName != null) "albumName": albumName,
    if (albumThumbnailAssetId != null) "albumThumbnailAssetId": albumThumbnailAssetId,
    if (description != null) "description": description,
    if (isActivityEnabled != null) "isActivityEnabled": isActivityEnabled,
    if (order != null) "order": order?.value,
  };

  UpdateAlbumDto copyWith({
    String? albumName,
    String? albumThumbnailAssetId,
    String? description,
    bool? isActivityEnabled,
    AssetOrder? order,
  }) {
    return UpdateAlbumDto(
      albumName: albumName ?? this.albumName,
      albumThumbnailAssetId: albumThumbnailAssetId ?? this.albumThumbnailAssetId,
      description: description ?? this.description,
      isActivityEnabled: isActivityEnabled ?? this.isActivityEnabled,
      order: order ?? this.order,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UpdateAlbumUserDto {
  final AlbumUserRole? role;

  const UpdateAlbumUserDto({
    this.role,
  });

  factory UpdateAlbumUserDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpdateAlbumUserDto();
    return UpdateAlbumUserDto(
      role: _albumUserRoleFromJson(json["role"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (role != null) "role": role?.value,
  };

  UpdateAlbumUserDto copyWith({
    AlbumUserRole? role,
  }) {
    return UpdateAlbumUserDto(
      role: role ?? this.role,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UpdateAssetDto {
  final String? dateTimeOriginal;
  final String? description;
  final bool? isFavorite;
  final double? latitude;
  final String? livePhotoVideoId;
  final double? longitude;
  final int? rating;
  final AssetVisibility? visibility;

  const UpdateAssetDto({
    this.dateTimeOriginal,
    this.description,
    this.isFavorite,
    this.latitude,
    this.livePhotoVideoId,
    this.longitude,
    this.rating,
    this.visibility,
  });

  factory UpdateAssetDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpdateAssetDto();
    return UpdateAssetDto(
      dateTimeOriginal: json["dateTimeOriginal"]?.toString(),
      description: json["description"]?.toString(),
      isFavorite: (json["isFavorite"] as bool?),
      latitude: (json["latitude"] as num?)?.toDouble(),
      livePhotoVideoId: json["livePhotoVideoId"]?.toString(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      rating: (json["rating"] as num?)?.toInt(),
      visibility: _assetVisibilityFromJson(json["visibility"]?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (dateTimeOriginal != null) "dateTimeOriginal": dateTimeOriginal,
    if (description != null) "description": description,
    if (isFavorite != null) "isFavorite": isFavorite,
    if (latitude != null) "latitude": latitude,
    if (livePhotoVideoId != null) "livePhotoVideoId": livePhotoVideoId,
    if (longitude != null) "longitude": longitude,
    if (rating != null) "rating": rating,
    if (visibility != null) "visibility": visibility?.value,
  };

  UpdateAssetDto copyWith({
    String? dateTimeOriginal,
    String? description,
    bool? isFavorite,
    double? latitude,
    String? livePhotoVideoId,
    double? longitude,
    int? rating,
    AssetVisibility? visibility,
  }) {
    return UpdateAssetDto(
      dateTimeOriginal: dateTimeOriginal ?? this.dateTimeOriginal,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      latitude: latitude ?? this.latitude,
      livePhotoVideoId: livePhotoVideoId ?? this.livePhotoVideoId,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      visibility: visibility ?? this.visibility,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UsageByUserDto {
  final int? photos;
  final int? quotaSizeInBytes;
  final int? usage;
  final int? usagePhotos;
  final int? usageVideos;
  final String? userId;
  final String? userName;
  final int? videos;

  const UsageByUserDto({
    this.photos,
    this.quotaSizeInBytes,
    this.usage,
    this.usagePhotos,
    this.usageVideos,
    this.userId,
    this.userName,
    this.videos,
  });

  factory UsageByUserDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UsageByUserDto();
    return UsageByUserDto(
      photos: (json["photos"] as num?)?.toInt(),
      quotaSizeInBytes: (json["quotaSizeInBytes"] as num?)?.toInt(),
      usage: (json["usage"] as num?)?.toInt(),
      usagePhotos: (json["usagePhotos"] as num?)?.toInt(),
      usageVideos: (json["usageVideos"] as num?)?.toInt(),
      userId: json["userId"]?.toString(),
      userName: json["userName"]?.toString(),
      videos: (json["videos"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (photos != null) "photos": photos,
    if (quotaSizeInBytes != null) "quotaSizeInBytes": quotaSizeInBytes,
    if (usage != null) "usage": usage,
    if (usagePhotos != null) "usagePhotos": usagePhotos,
    if (usageVideos != null) "usageVideos": usageVideos,
    if (userId != null) "userId": userId,
    if (userName != null) "userName": userName,
    if (videos != null) "videos": videos,
  };

  UsageByUserDto copyWith({
    int? photos,
    int? quotaSizeInBytes,
    int? usage,
    int? usagePhotos,
    int? usageVideos,
    String? userId,
    String? userName,
    int? videos,
  }) {
    return UsageByUserDto(
      photos: photos ?? this.photos,
      quotaSizeInBytes: quotaSizeInBytes ?? this.quotaSizeInBytes,
      usage: usage ?? this.usage,
      usagePhotos: usagePhotos ?? this.usagePhotos,
      usageVideos: usageVideos ?? this.usageVideos,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      videos: videos ?? this.videos,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserAdminResponseDto {
  final UserAvatarColor? avatarColor;
  final String? clusterGroupId;
  final String? createdAt;
  final String? deletedAt;
  final String? email;
  final String? id;
  final bool? isAdmin;
  final UserLicense? license;
  final String? name;
  final String? oauthId;
  final String? profileChangedAt;
  final String? profileImagePath;
  final int? quotaSizeInBytes;
  final int? quotaUsageInBytes;
  final bool? shouldChangePassword;
  final UserStatus? status;
  final String? storageLabel;
  final String? updatedAt;

  const UserAdminResponseDto({
    this.avatarColor,
    this.clusterGroupId,
    this.createdAt,
    this.deletedAt,
    this.email,
    this.id,
    this.isAdmin,
    this.license,
    this.name,
    this.oauthId,
    this.profileChangedAt,
    this.profileImagePath,
    this.quotaSizeInBytes,
    this.quotaUsageInBytes,
    this.shouldChangePassword,
    this.status,
    this.storageLabel,
    this.updatedAt,
  });

  factory UserAdminResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserAdminResponseDto();
    return UserAdminResponseDto(
      avatarColor: _userAvatarColorFromJson(json["avatarColor"]?.toString()),
      clusterGroupId: json["clusterGroupId"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      deletedAt: json["deletedAt"]?.toString(),
      email: json["email"]?.toString(),
      id: json["id"]?.toString(),
      isAdmin: (json["isAdmin"] as bool?),
      license: UserLicense.fromJson((json["license"] as Map<String, dynamic>?)),
      name: json["name"]?.toString(),
      oauthId: json["oauthId"]?.toString(),
      profileChangedAt: json["profileChangedAt"]?.toString(),
      profileImagePath: json["profileImagePath"]?.toString(),
      quotaSizeInBytes: (json["quotaSizeInBytes"] as num?)?.toInt(),
      quotaUsageInBytes: (json["quotaUsageInBytes"] as num?)?.toInt(),
      shouldChangePassword: (json["shouldChangePassword"] as bool?),
      status: _userStatusFromJson(json["status"]?.toString()),
      storageLabel: json["storageLabel"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (avatarColor != null) "avatarColor": avatarColor?.value,
    if (clusterGroupId != null) "clusterGroupId": clusterGroupId,
    if (createdAt != null) "createdAt": createdAt,
    if (deletedAt != null) "deletedAt": deletedAt,
    if (email != null) "email": email,
    if (id != null) "id": id,
    if (isAdmin != null) "isAdmin": isAdmin,
    if (license != null) "license": license?.toJson(),
    if (name != null) "name": name,
    if (oauthId != null) "oauthId": oauthId,
    if (profileChangedAt != null) "profileChangedAt": profileChangedAt,
    if (profileImagePath != null) "profileImagePath": profileImagePath,
    if (quotaSizeInBytes != null) "quotaSizeInBytes": quotaSizeInBytes,
    if (quotaUsageInBytes != null) "quotaUsageInBytes": quotaUsageInBytes,
    if (shouldChangePassword != null) "shouldChangePassword": shouldChangePassword,
    if (status != null) "status": status?.value,
    if (storageLabel != null) "storageLabel": storageLabel,
    if (updatedAt != null) "updatedAt": updatedAt,
  };

  UserAdminResponseDto copyWith({
    UserAvatarColor? avatarColor,
    String? clusterGroupId,
    String? createdAt,
    String? deletedAt,
    String? email,
    String? id,
    bool? isAdmin,
    UserLicense? license,
    String? name,
    String? oauthId,
    String? profileChangedAt,
    String? profileImagePath,
    int? quotaSizeInBytes,
    int? quotaUsageInBytes,
    bool? shouldChangePassword,
    UserStatus? status,
    String? storageLabel,
    String? updatedAt,
  }) {
    return UserAdminResponseDto(
      avatarColor: avatarColor ?? this.avatarColor,
      clusterGroupId: clusterGroupId ?? this.clusterGroupId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      email: email ?? this.email,
      id: id ?? this.id,
      isAdmin: isAdmin ?? this.isAdmin,
      license: license ?? this.license,
      name: name ?? this.name,
      oauthId: oauthId ?? this.oauthId,
      profileChangedAt: profileChangedAt ?? this.profileChangedAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      quotaSizeInBytes: quotaSizeInBytes ?? this.quotaSizeInBytes,
      quotaUsageInBytes: quotaUsageInBytes ?? this.quotaUsageInBytes,
      shouldChangePassword: shouldChangePassword ?? this.shouldChangePassword,
      status: status ?? this.status,
      storageLabel: storageLabel ?? this.storageLabel,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigClipDto {
  final bool? enabled;

  const UserConfigClipDto({
    this.enabled,
  });

  factory UserConfigClipDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigClipDto();
    return UserConfigClipDto(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  UserConfigClipDto copyWith({
    bool? enabled,
  }) {
    return UserConfigClipDto(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigDto {
  final UserConfigFFmpegDto? ffmpeg;
  final UserConfigImageDto? image;
  final UserConfigMachineLearningDto? machineLearning;
  final UserConfigMapDto? map;
  final UserConfigOAuthDto? oauth;
  final UserConfigPasswordLoginDto? passwordLogin;
  final UserConfigReverseGeocodingDto? reverseGeocoding;
  final UserConfigServerDto? server;
  final UserConfigThemeDto? theme;
  final UserConfigTrashDto? trash;
  final UserConfigUserDto? user;

  const UserConfigDto({
    this.ffmpeg,
    this.image,
    this.machineLearning,
    this.map,
    this.oauth,
    this.passwordLogin,
    this.reverseGeocoding,
    this.server,
    this.theme,
    this.trash,
    this.user,
  });

  factory UserConfigDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigDto();
    return UserConfigDto(
      ffmpeg: UserConfigFFmpegDto.fromJson((json["ffmpeg"] as Map<String, dynamic>?)),
      image: UserConfigImageDto.fromJson((json["image"] as Map<String, dynamic>?)),
      machineLearning: UserConfigMachineLearningDto.fromJson((json["machineLearning"] as Map<String, dynamic>?)),
      map: UserConfigMapDto.fromJson((json["map"] as Map<String, dynamic>?)),
      oauth: UserConfigOAuthDto.fromJson((json["oauth"] as Map<String, dynamic>?)),
      passwordLogin: UserConfigPasswordLoginDto.fromJson((json["passwordLogin"] as Map<String, dynamic>?)),
      reverseGeocoding: UserConfigReverseGeocodingDto.fromJson((json["reverseGeocoding"] as Map<String, dynamic>?)),
      server: UserConfigServerDto.fromJson((json["server"] as Map<String, dynamic>?)),
      theme: UserConfigThemeDto.fromJson((json["theme"] as Map<String, dynamic>?)),
      trash: UserConfigTrashDto.fromJson((json["trash"] as Map<String, dynamic>?)),
      user: UserConfigUserDto.fromJson((json["user"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ffmpeg != null) "ffmpeg": ffmpeg?.toJson(),
    if (image != null) "image": image?.toJson(),
    if (machineLearning != null) "machineLearning": machineLearning?.toJson(),
    if (map != null) "map": map?.toJson(),
    if (oauth != null) "oauth": oauth?.toJson(),
    if (passwordLogin != null) "passwordLogin": passwordLogin?.toJson(),
    if (reverseGeocoding != null) "reverseGeocoding": reverseGeocoding?.toJson(),
    if (server != null) "server": server?.toJson(),
    if (theme != null) "theme": theme?.toJson(),
    if (trash != null) "trash": trash?.toJson(),
    if (user != null) "user": user?.toJson(),
  };

  UserConfigDto copyWith({
    UserConfigFFmpegDto? ffmpeg,
    UserConfigImageDto? image,
    UserConfigMachineLearningDto? machineLearning,
    UserConfigMapDto? map,
    UserConfigOAuthDto? oauth,
    UserConfigPasswordLoginDto? passwordLogin,
    UserConfigReverseGeocodingDto? reverseGeocoding,
    UserConfigServerDto? server,
    UserConfigThemeDto? theme,
    UserConfigTrashDto? trash,
    UserConfigUserDto? user,
  }) {
    return UserConfigDto(
      ffmpeg: ffmpeg ?? this.ffmpeg,
      image: image ?? this.image,
      machineLearning: machineLearning ?? this.machineLearning,
      map: map ?? this.map,
      oauth: oauth ?? this.oauth,
      passwordLogin: passwordLogin ?? this.passwordLogin,
      reverseGeocoding: reverseGeocoding ?? this.reverseGeocoding,
      server: server ?? this.server,
      theme: theme ?? this.theme,
      trash: trash ?? this.trash,
      user: user ?? this.user,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigDuplicateDetectionDto {
  final bool? enabled;

  const UserConfigDuplicateDetectionDto({
    this.enabled,
  });

  factory UserConfigDuplicateDetectionDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigDuplicateDetectionDto();
    return UserConfigDuplicateDetectionDto(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  UserConfigDuplicateDetectionDto copyWith({
    bool? enabled,
  }) {
    return UserConfigDuplicateDetectionDto(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigFFmpegDto {
  final UserConfigFFmpegRealtimeDto? realtime;

  const UserConfigFFmpegDto({
    this.realtime,
  });

  factory UserConfigFFmpegDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigFFmpegDto();
    return UserConfigFFmpegDto(
      realtime: UserConfigFFmpegRealtimeDto.fromJson((json["realtime"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (realtime != null) "realtime": realtime?.toJson(),
  };

  UserConfigFFmpegDto copyWith({
    UserConfigFFmpegRealtimeDto? realtime,
  }) {
    return UserConfigFFmpegDto(
      realtime: realtime ?? this.realtime,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigFFmpegRealtimeDto {
  final bool? enabled;
  final List<HlsVideoResolution>? resolutions;
  final List<VideoCodec>? videoCodecs;

  const UserConfigFFmpegRealtimeDto({
    this.enabled,
    this.resolutions,
    this.videoCodecs,
  });

  factory UserConfigFFmpegRealtimeDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigFFmpegRealtimeDto();
    return UserConfigFFmpegRealtimeDto(
      enabled: (json["enabled"] as bool?),
      resolutions: ((json["resolutions"] as List<dynamic>?)?.map((e) => _hlsVideoResolutionFromJson(e?.toString())).whereType<HlsVideoResolution>().toList()),
      videoCodecs: ((json["videoCodecs"] as List<dynamic>?)?.map((e) => _videoCodecFromJson(e?.toString())).whereType<VideoCodec>().toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (resolutions != null) "resolutions": resolutions?.map((e) => e?.value).toList(),
    if (videoCodecs != null) "videoCodecs": videoCodecs?.map((e) => e?.value).toList(),
  };

  UserConfigFFmpegRealtimeDto copyWith({
    bool? enabled,
    List<HlsVideoResolution>? resolutions,
    List<VideoCodec>? videoCodecs,
  }) {
    return UserConfigFFmpegRealtimeDto(
      enabled: enabled ?? this.enabled,
      resolutions: resolutions ?? this.resolutions,
      videoCodecs: videoCodecs ?? this.videoCodecs,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigFacialRecognitionDto {
  final bool? enabled;
  final int? minFaces;

  const UserConfigFacialRecognitionDto({
    this.enabled,
    this.minFaces,
  });

  factory UserConfigFacialRecognitionDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigFacialRecognitionDto();
    return UserConfigFacialRecognitionDto(
      enabled: (json["enabled"] as bool?),
      minFaces: (json["minFaces"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
    if (minFaces != null) "minFaces": minFaces,
  };

  UserConfigFacialRecognitionDto copyWith({
    bool? enabled,
    int? minFaces,
  }) {
    return UserConfigFacialRecognitionDto(
      enabled: enabled ?? this.enabled,
      minFaces: minFaces ?? this.minFaces,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigGeneratedFullsizeImageDto {
  final bool? enabled;

  const UserConfigGeneratedFullsizeImageDto({
    this.enabled,
  });

  factory UserConfigGeneratedFullsizeImageDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigGeneratedFullsizeImageDto();
    return UserConfigGeneratedFullsizeImageDto(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  UserConfigGeneratedFullsizeImageDto copyWith({
    bool? enabled,
  }) {
    return UserConfigGeneratedFullsizeImageDto(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigGeneratedImageDto {
  final int? size;

  const UserConfigGeneratedImageDto({
    this.size,
  });

  factory UserConfigGeneratedImageDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigGeneratedImageDto();
    return UserConfigGeneratedImageDto(
      size: (json["size"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (size != null) "size": size,
  };

  UserConfigGeneratedImageDto copyWith({
    int? size,
  }) {
    return UserConfigGeneratedImageDto(
      size: size ?? this.size,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigImageDto {
  final UserConfigGeneratedFullsizeImageDto? fullsize;
  final UserConfigGeneratedImageDto? preview;
  final UserConfigGeneratedImageDto? thumbnail;

  const UserConfigImageDto({
    this.fullsize,
    this.preview,
    this.thumbnail,
  });

  factory UserConfigImageDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigImageDto();
    return UserConfigImageDto(
      fullsize: UserConfigGeneratedFullsizeImageDto.fromJson((json["fullsize"] as Map<String, dynamic>?)),
      preview: UserConfigGeneratedImageDto.fromJson((json["preview"] as Map<String, dynamic>?)),
      thumbnail: UserConfigGeneratedImageDto.fromJson((json["thumbnail"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (fullsize != null) "fullsize": fullsize?.toJson(),
    if (preview != null) "preview": preview?.toJson(),
    if (thumbnail != null) "thumbnail": thumbnail?.toJson(),
  };

  UserConfigImageDto copyWith({
    UserConfigGeneratedFullsizeImageDto? fullsize,
    UserConfigGeneratedImageDto? preview,
    UserConfigGeneratedImageDto? thumbnail,
  }) {
    return UserConfigImageDto(
      fullsize: fullsize ?? this.fullsize,
      preview: preview ?? this.preview,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigMachineLearningDto {
  final UserConfigClipDto? clip;
  final UserConfigDuplicateDetectionDto? duplicateDetection;
  final bool? enabled;
  final UserConfigFacialRecognitionDto? facialRecognition;
  final UserConfigOcrDto? ocr;

  const UserConfigMachineLearningDto({
    this.clip,
    this.duplicateDetection,
    this.enabled,
    this.facialRecognition,
    this.ocr,
  });

  factory UserConfigMachineLearningDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigMachineLearningDto();
    return UserConfigMachineLearningDto(
      clip: UserConfigClipDto.fromJson((json["clip"] as Map<String, dynamic>?)),
      duplicateDetection: UserConfigDuplicateDetectionDto.fromJson((json["duplicateDetection"] as Map<String, dynamic>?)),
      enabled: (json["enabled"] as bool?),
      facialRecognition: UserConfigFacialRecognitionDto.fromJson((json["facialRecognition"] as Map<String, dynamic>?)),
      ocr: UserConfigOcrDto.fromJson((json["ocr"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (clip != null) "clip": clip?.toJson(),
    if (duplicateDetection != null) "duplicateDetection": duplicateDetection?.toJson(),
    if (enabled != null) "enabled": enabled,
    if (facialRecognition != null) "facialRecognition": facialRecognition?.toJson(),
    if (ocr != null) "ocr": ocr?.toJson(),
  };

  UserConfigMachineLearningDto copyWith({
    UserConfigClipDto? clip,
    UserConfigDuplicateDetectionDto? duplicateDetection,
    bool? enabled,
    UserConfigFacialRecognitionDto? facialRecognition,
    UserConfigOcrDto? ocr,
  }) {
    return UserConfigMachineLearningDto(
      clip: clip ?? this.clip,
      duplicateDetection: duplicateDetection ?? this.duplicateDetection,
      enabled: enabled ?? this.enabled,
      facialRecognition: facialRecognition ?? this.facialRecognition,
      ocr: ocr ?? this.ocr,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigMapDto {
  final String? darkStyle;
  final bool? enabled;
  final String? lightStyle;

  const UserConfigMapDto({
    this.darkStyle,
    this.enabled,
    this.lightStyle,
  });

  factory UserConfigMapDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigMapDto();
    return UserConfigMapDto(
      darkStyle: json["darkStyle"]?.toString(),
      enabled: (json["enabled"] as bool?),
      lightStyle: json["lightStyle"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (darkStyle != null) "darkStyle": darkStyle,
    if (enabled != null) "enabled": enabled,
    if (lightStyle != null) "lightStyle": lightStyle,
  };

  UserConfigMapDto copyWith({
    String? darkStyle,
    bool? enabled,
    String? lightStyle,
  }) {
    return UserConfigMapDto(
      darkStyle: darkStyle ?? this.darkStyle,
      enabled: enabled ?? this.enabled,
      lightStyle: lightStyle ?? this.lightStyle,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigOAuthDto {
  final bool? autoLaunch;
  final String? buttonText;
  final bool? enabled;

  const UserConfigOAuthDto({
    this.autoLaunch,
    this.buttonText,
    this.enabled,
  });

  factory UserConfigOAuthDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigOAuthDto();
    return UserConfigOAuthDto(
      autoLaunch: (json["autoLaunch"] as bool?),
      buttonText: json["buttonText"]?.toString(),
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (autoLaunch != null) "autoLaunch": autoLaunch,
    if (buttonText != null) "buttonText": buttonText,
    if (enabled != null) "enabled": enabled,
  };

  UserConfigOAuthDto copyWith({
    bool? autoLaunch,
    String? buttonText,
    bool? enabled,
  }) {
    return UserConfigOAuthDto(
      autoLaunch: autoLaunch ?? this.autoLaunch,
      buttonText: buttonText ?? this.buttonText,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigOcrDto {
  final bool? enabled;

  const UserConfigOcrDto({
    this.enabled,
  });

  factory UserConfigOcrDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigOcrDto();
    return UserConfigOcrDto(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  UserConfigOcrDto copyWith({
    bool? enabled,
  }) {
    return UserConfigOcrDto(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigPasswordLoginDto {
  final bool? enabled;

  const UserConfigPasswordLoginDto({
    this.enabled,
  });

  factory UserConfigPasswordLoginDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigPasswordLoginDto();
    return UserConfigPasswordLoginDto(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  UserConfigPasswordLoginDto copyWith({
    bool? enabled,
  }) {
    return UserConfigPasswordLoginDto(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigReverseGeocodingDto {
  final bool? enabled;

  const UserConfigReverseGeocodingDto({
    this.enabled,
  });

  factory UserConfigReverseGeocodingDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigReverseGeocodingDto();
    return UserConfigReverseGeocodingDto(
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) "enabled": enabled,
  };

  UserConfigReverseGeocodingDto copyWith({
    bool? enabled,
  }) {
    return UserConfigReverseGeocodingDto(
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigServerDto {
  final String? externalDomain;
  final String? loginPageMessage;
  final bool? publicUsers;

  const UserConfigServerDto({
    this.externalDomain,
    this.loginPageMessage,
    this.publicUsers,
  });

  factory UserConfigServerDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigServerDto();
    return UserConfigServerDto(
      externalDomain: json["externalDomain"]?.toString(),
      loginPageMessage: json["loginPageMessage"]?.toString(),
      publicUsers: (json["publicUsers"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (externalDomain != null) "externalDomain": externalDomain,
    if (loginPageMessage != null) "loginPageMessage": loginPageMessage,
    if (publicUsers != null) "publicUsers": publicUsers,
  };

  UserConfigServerDto copyWith({
    String? externalDomain,
    String? loginPageMessage,
    bool? publicUsers,
  }) {
    return UserConfigServerDto(
      externalDomain: externalDomain ?? this.externalDomain,
      loginPageMessage: loginPageMessage ?? this.loginPageMessage,
      publicUsers: publicUsers ?? this.publicUsers,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigThemeDto {
  final String? customCss;

  const UserConfigThemeDto({
    this.customCss,
  });

  factory UserConfigThemeDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigThemeDto();
    return UserConfigThemeDto(
      customCss: json["customCss"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (customCss != null) "customCss": customCss,
  };

  UserConfigThemeDto copyWith({
    String? customCss,
  }) {
    return UserConfigThemeDto(
      customCss: customCss ?? this.customCss,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigTrashDto {
  final int? days;
  final bool? enabled;

  const UserConfigTrashDto({
    this.days,
    this.enabled,
  });

  factory UserConfigTrashDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigTrashDto();
    return UserConfigTrashDto(
      days: (json["days"] as num?)?.toInt(),
      enabled: (json["enabled"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (days != null) "days": days,
    if (enabled != null) "enabled": enabled,
  };

  UserConfigTrashDto copyWith({
    int? days,
    bool? enabled,
  }) {
    return UserConfigTrashDto(
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserConfigUserDto {
  final int? deleteDelay;

  const UserConfigUserDto({
    this.deleteDelay,
  });

  factory UserConfigUserDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserConfigUserDto();
    return UserConfigUserDto(
      deleteDelay: (json["deleteDelay"] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (deleteDelay != null) "deleteDelay": deleteDelay,
  };

  UserConfigUserDto copyWith({
    int? deleteDelay,
  }) {
    return UserConfigUserDto(
      deleteDelay: deleteDelay ?? this.deleteDelay,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserLicense {
  final String? activatedAt;
  final String? activationKey;
  final String? licenseKey;

  const UserLicense({
    this.activatedAt,
    this.activationKey,
    this.licenseKey,
  });

  factory UserLicense.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserLicense();
    return UserLicense(
      activatedAt: json["activatedAt"]?.toString(),
      activationKey: json["activationKey"]?.toString(),
      licenseKey: json["licenseKey"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (activatedAt != null) "activatedAt": activatedAt,
    if (activationKey != null) "activationKey": activationKey,
    if (licenseKey != null) "licenseKey": licenseKey,
  };

  UserLicense copyWith({
    String? activatedAt,
    String? activationKey,
    String? licenseKey,
  }) {
    return UserLicense(
      activatedAt: activatedAt ?? this.activatedAt,
      activationKey: activationKey ?? this.activationKey,
      licenseKey: licenseKey ?? this.licenseKey,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserPreferencesResponseDto {
  final AlbumsResponse? albums;
  final CastResponse? cast;
  final DownloadResponse? download;
  final EmailNotificationsResponse? emailNotifications;
  final FoldersResponse? folders;
  final MemoriesResponse? memories;
  final PeopleResponse? people;
  final PurchaseResponse? purchase;
  final RatingsResponse? ratings;
  final RecentlyAddedResponse? recentlyAdded;
  final SharedLinksResponse? sharedLinks;
  final TagsResponse? tags;

  const UserPreferencesResponseDto({
    this.albums,
    this.cast,
    this.download,
    this.emailNotifications,
    this.folders,
    this.memories,
    this.people,
    this.purchase,
    this.ratings,
    this.recentlyAdded,
    this.sharedLinks,
    this.tags,
  });

  factory UserPreferencesResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserPreferencesResponseDto();
    return UserPreferencesResponseDto(
      albums: AlbumsResponse.fromJson((json["albums"] as Map<String, dynamic>?)),
      cast: CastResponse.fromJson((json["cast"] as Map<String, dynamic>?)),
      download: DownloadResponse.fromJson((json["download"] as Map<String, dynamic>?)),
      emailNotifications: EmailNotificationsResponse.fromJson((json["emailNotifications"] as Map<String, dynamic>?)),
      folders: FoldersResponse.fromJson((json["folders"] as Map<String, dynamic>?)),
      memories: MemoriesResponse.fromJson((json["memories"] as Map<String, dynamic>?)),
      people: PeopleResponse.fromJson((json["people"] as Map<String, dynamic>?)),
      purchase: PurchaseResponse.fromJson((json["purchase"] as Map<String, dynamic>?)),
      ratings: RatingsResponse.fromJson((json["ratings"] as Map<String, dynamic>?)),
      recentlyAdded: RecentlyAddedResponse.fromJson((json["recentlyAdded"] as Map<String, dynamic>?)),
      sharedLinks: SharedLinksResponse.fromJson((json["sharedLinks"] as Map<String, dynamic>?)),
      tags: TagsResponse.fromJson((json["tags"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albums != null) "albums": albums?.toJson(),
    if (cast != null) "cast": cast?.toJson(),
    if (download != null) "download": download?.toJson(),
    if (emailNotifications != null) "emailNotifications": emailNotifications?.toJson(),
    if (folders != null) "folders": folders?.toJson(),
    if (memories != null) "memories": memories?.toJson(),
    if (people != null) "people": people?.toJson(),
    if (purchase != null) "purchase": purchase?.toJson(),
    if (ratings != null) "ratings": ratings?.toJson(),
    if (recentlyAdded != null) "recentlyAdded": recentlyAdded?.toJson(),
    if (sharedLinks != null) "sharedLinks": sharedLinks?.toJson(),
    if (tags != null) "tags": tags?.toJson(),
  };

  UserPreferencesResponseDto copyWith({
    AlbumsResponse? albums,
    CastResponse? cast,
    DownloadResponse? download,
    EmailNotificationsResponse? emailNotifications,
    FoldersResponse? folders,
    MemoriesResponse? memories,
    PeopleResponse? people,
    PurchaseResponse? purchase,
    RatingsResponse? ratings,
    RecentlyAddedResponse? recentlyAdded,
    SharedLinksResponse? sharedLinks,
    TagsResponse? tags,
  }) {
    return UserPreferencesResponseDto(
      albums: albums ?? this.albums,
      cast: cast ?? this.cast,
      download: download ?? this.download,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      folders: folders ?? this.folders,
      memories: memories ?? this.memories,
      people: people ?? this.people,
      purchase: purchase ?? this.purchase,
      ratings: ratings ?? this.ratings,
      recentlyAdded: recentlyAdded ?? this.recentlyAdded,
      sharedLinks: sharedLinks ?? this.sharedLinks,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserPreferencesUpdateDto {
  final AlbumsUpdate? albums;
  final AvatarUpdate? avatar;
  final CastUpdate? cast;
  final DownloadUpdate? download;
  final EmailNotificationsUpdate? emailNotifications;
  final FoldersUpdate? folders;
  final MemoriesUpdate? memories;
  final PeopleUpdate? people;
  final PurchaseUpdate? purchase;
  final RatingsUpdate? ratings;
  final RecentlyAddedUpdate? recentlyAdded;
  final SharedLinksUpdate? sharedLinks;
  final TagsUpdate? tags;

  const UserPreferencesUpdateDto({
    this.albums,
    this.avatar,
    this.cast,
    this.download,
    this.emailNotifications,
    this.folders,
    this.memories,
    this.people,
    this.purchase,
    this.ratings,
    this.recentlyAdded,
    this.sharedLinks,
    this.tags,
  });

  factory UserPreferencesUpdateDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserPreferencesUpdateDto();
    return UserPreferencesUpdateDto(
      albums: AlbumsUpdate.fromJson((json["albums"] as Map<String, dynamic>?)),
      avatar: AvatarUpdate.fromJson((json["avatar"] as Map<String, dynamic>?)),
      cast: CastUpdate.fromJson((json["cast"] as Map<String, dynamic>?)),
      download: DownloadUpdate.fromJson((json["download"] as Map<String, dynamic>?)),
      emailNotifications: EmailNotificationsUpdate.fromJson((json["emailNotifications"] as Map<String, dynamic>?)),
      folders: FoldersUpdate.fromJson((json["folders"] as Map<String, dynamic>?)),
      memories: MemoriesUpdate.fromJson((json["memories"] as Map<String, dynamic>?)),
      people: PeopleUpdate.fromJson((json["people"] as Map<String, dynamic>?)),
      purchase: PurchaseUpdate.fromJson((json["purchase"] as Map<String, dynamic>?)),
      ratings: RatingsUpdate.fromJson((json["ratings"] as Map<String, dynamic>?)),
      recentlyAdded: RecentlyAddedUpdate.fromJson((json["recentlyAdded"] as Map<String, dynamic>?)),
      sharedLinks: SharedLinksUpdate.fromJson((json["sharedLinks"] as Map<String, dynamic>?)),
      tags: TagsUpdate.fromJson((json["tags"] as Map<String, dynamic>?)),
    );
  }

  Map<String, dynamic> toJson() => {
    if (albums != null) "albums": albums?.toJson(),
    if (avatar != null) "avatar": avatar?.toJson(),
    if (cast != null) "cast": cast?.toJson(),
    if (download != null) "download": download?.toJson(),
    if (emailNotifications != null) "emailNotifications": emailNotifications?.toJson(),
    if (folders != null) "folders": folders?.toJson(),
    if (memories != null) "memories": memories?.toJson(),
    if (people != null) "people": people?.toJson(),
    if (purchase != null) "purchase": purchase?.toJson(),
    if (ratings != null) "ratings": ratings?.toJson(),
    if (recentlyAdded != null) "recentlyAdded": recentlyAdded?.toJson(),
    if (sharedLinks != null) "sharedLinks": sharedLinks?.toJson(),
    if (tags != null) "tags": tags?.toJson(),
  };

  UserPreferencesUpdateDto copyWith({
    AlbumsUpdate? albums,
    AvatarUpdate? avatar,
    CastUpdate? cast,
    DownloadUpdate? download,
    EmailNotificationsUpdate? emailNotifications,
    FoldersUpdate? folders,
    MemoriesUpdate? memories,
    PeopleUpdate? people,
    PurchaseUpdate? purchase,
    RatingsUpdate? ratings,
    RecentlyAddedUpdate? recentlyAdded,
    SharedLinksUpdate? sharedLinks,
    TagsUpdate? tags,
  }) {
    return UserPreferencesUpdateDto(
      albums: albums ?? this.albums,
      avatar: avatar ?? this.avatar,
      cast: cast ?? this.cast,
      download: download ?? this.download,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      folders: folders ?? this.folders,
      memories: memories ?? this.memories,
      people: people ?? this.people,
      purchase: purchase ?? this.purchase,
      ratings: ratings ?? this.ratings,
      recentlyAdded: recentlyAdded ?? this.recentlyAdded,
      sharedLinks: sharedLinks ?? this.sharedLinks,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class UserResponseDto {
  final UserAvatarColor? avatarColor;
  final String? email;
  final String? id;
  final String? name;
  final String? profileChangedAt;
  final String? profileImagePath;

  const UserResponseDto({
    this.avatarColor,
    this.email,
    this.id,
    this.name,
    this.profileChangedAt,
    this.profileImagePath,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserResponseDto();
    return UserResponseDto(
      avatarColor: _userAvatarColorFromJson(json["avatarColor"]?.toString()),
      email: json["email"]?.toString(),
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      profileChangedAt: json["profileChangedAt"]?.toString(),
      profileImagePath: json["profileImagePath"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (avatarColor != null) "avatarColor": avatarColor?.value,
    if (email != null) "email": email,
    if (id != null) "id": id,
    if (name != null) "name": name,
    if (profileChangedAt != null) "profileChangedAt": profileChangedAt,
    if (profileImagePath != null) "profileImagePath": profileImagePath,
  };

  UserResponseDto copyWith({
    UserAvatarColor? avatarColor,
    String? email,
    String? id,
    String? name,
    String? profileChangedAt,
    String? profileImagePath,
  }) {
    return UserResponseDto(
      avatarColor: avatarColor ?? this.avatarColor,
      email: email ?? this.email,
      id: id ?? this.id,
      name: name ?? this.name,
      profileChangedAt: profileChangedAt ?? this.profileChangedAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ValidateAccessTokenResponseDto {
  final bool? authStatus;

  const ValidateAccessTokenResponseDto({
    this.authStatus,
  });

  factory ValidateAccessTokenResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ValidateAccessTokenResponseDto();
    return ValidateAccessTokenResponseDto(
      authStatus: (json["authStatus"] as bool?),
    );
  }

  Map<String, dynamic> toJson() => {
    if (authStatus != null) "authStatus": authStatus,
  };

  ValidateAccessTokenResponseDto copyWith({
    bool? authStatus,
  }) {
    return ValidateAccessTokenResponseDto(
      authStatus: authStatus ?? this.authStatus,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class VersionCheckStateResponseDto {
  final String? checkedAt;
  final String? releaseVersion;

  const VersionCheckStateResponseDto({
    this.checkedAt,
    this.releaseVersion,
  });

  factory VersionCheckStateResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VersionCheckStateResponseDto();
    return VersionCheckStateResponseDto(
      checkedAt: json["checkedAt"]?.toString(),
      releaseVersion: json["releaseVersion"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (checkedAt != null) "checkedAt": checkedAt,
    if (releaseVersion != null) "releaseVersion": releaseVersion,
  };

  VersionCheckStateResponseDto copyWith({
    String? checkedAt,
    String? releaseVersion,
  }) {
    return VersionCheckStateResponseDto(
      checkedAt: checkedAt ?? this.checkedAt,
      releaseVersion: releaseVersion ?? this.releaseVersion,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
