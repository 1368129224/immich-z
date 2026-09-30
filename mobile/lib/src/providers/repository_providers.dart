import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/client.dart';
import '../providers/session_provider.dart';
import '../repositories/asset_repository.dart';
import '../repositories/search_repository.dart';

/// Headers required by media endpoints (API keys use x-api-key, sessions use
/// Authorization: Bearer). Pass these to image/video network providers.
final authHeadersProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(apiClientProvider)?.authHeaders ?? const <String, String>{};
});

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return AssetRepository(client);
});

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return TimelineRepository(client);
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return SearchRepository(client);
});

final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return AlbumRepository(client);
});

final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return PersonRepository(client);
});

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return MemoryRepository(client);
});

final partnerRepositoryProvider = Provider<PartnerRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return PartnerRepository(client);
});

final sharedLinkRepositoryProvider = Provider<SharedLinkRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return SharedLinkRepository(client);
});

final miscRepositoryProvider = Provider<MiscRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return MiscRepository(client);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return UserRepository(client);
});

/// Convenience: the live client, asserted non-null.
final requireClientProvider = Provider<ImmichApiClient>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) {
    throw StateError('Not logged in');
  }
  return client;
});
