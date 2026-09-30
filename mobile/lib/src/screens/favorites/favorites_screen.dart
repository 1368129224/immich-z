import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../repositories/asset_repository.dart';
import '../../routing/app_router.dart';
import '../../widgets/thumbhash_placeholder.dart';

/// How many time buckets a "favorites" listing walks before it stops.
const int _favoriteBucketLimit = 4;

/// Favorited assets, collected from the newest time buckets.
///
/// The timeline bucket endpoints only expose the light parallel-array records,
/// so each id is resolved through `AssetRepository.get` for the full payload.
/// Buckets that fail to resolve are skipped rather than failing the provider.
final favoritesProvider = FutureProvider<List<AssetResponseDto>>((ref) async {
  final timeline = ref.watch(timelineRepositoryProvider);
  final assets = ref.watch(assetRepositoryProvider);

  final buckets = await timeline.buckets(isFavorite: true);
  final out = <AssetResponseDto>[];
  for (final b in buckets.take(_favoriteBucketLimit)) {
    final when = DateTime.tryParse(b.timeBucket ?? '');
    if (when == null) continue;
    final bucket = await timeline.bucket(
      timeBucket: when,
      isFavorite: true,
    );
    for (final item in flattenBucket(bucket)) {
      try {
        out.add(await assets.get(item.id));
      } catch (_) {
        // A single unreadable asset should not sink the whole listing.
      }
    }
  }
  return out;
});

/// Favorites page: a plain 3-column grid of everything marked as favorite.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          final ids = items.map((e) => e.id ?? '').join(',');
          final repo = ref.read(assetRepositoryProvider);
          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final a = items[i];
              return GestureDetector(
                onTap: () => context.push(
                  '${AppRoutes.viewer}?ids=${Uri.encodeComponent(ids)}'
                  '&index=$i',
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ThumbhashPlaceholder(thumbhash: a.thumbhash),
                    CachedNetworkImage(
                      imageUrl: repo.thumbnailUrl(a.id ?? ''),
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                    if (a.type == AssetTypeEnum.vIDEO)
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.play_circle_outline, size: 18),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
