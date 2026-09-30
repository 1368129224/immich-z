import 'package:flutter/material.dart';

import '../../widgets/immich_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../repositories/asset_repository.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';
import '../../widgets/thumbhash_placeholder.dart';

/// How many time buckets the archive listing walks before it stops.
const int _archiveBucketLimit = 4;

/// Archived assets, collected from the newest time buckets.
///
/// Mirrors [favoritesProvider], but asks the timeline for the `archive`
/// visibility instead of the favorite flag.
final archiveProvider = FutureProvider<List<AssetResponseDto>>((ref) async {
  final timeline = ref.watch(timelineRepositoryProvider);
  final assets = ref.watch(assetRepositoryProvider);

  final buckets = await timeline.buckets(visibility: AssetVisibility.archive);
  final out = <AssetResponseDto>[];
  for (final b in buckets.take(_archiveBucketLimit)) {
    final when = DateTime.tryParse(b.timeBucket ?? '');
    if (when == null) continue;
    final bucket = await timeline.bucket(
      timeBucket: when,
      visibility: AssetVisibility.archive,
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

/// Archive page: a 3-column grid of archived assets. Long-press opens the
/// per-asset action sheet (restore to timeline, or move to trash).
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = ref.watch(archiveProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: archived.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Nothing archived'));
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
                onLongPress: () => _showActions(context, ref, a),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ThumbhashPlaceholder(thumbhash: a.thumbhash),
                    ImmichNetworkImage(
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

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    AssetResponseDto asset,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.unarchive_outlined),
              title: const Text('Unarchive'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(assetRepositoryProvider)
                    .archive([asset.id ?? ''], false);
                ref.invalidate(archiveProvider);
                if (context.mounted) showMessage(context, 'Moved to timeline');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(assetRepositoryProvider)
                    .delete([asset.id ?? '']);
                ref.invalidate(archiveProvider);
                if (context.mounted) showMessage(context, 'Moved to trash');
              },
            ),
          ],
        ),
      ),
    );
  }
}
