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

/// How many time buckets the trash listing walks before it stops.
const int _trashBucketLimit = 4;

/// Assets currently sitting in the trash.
///
/// Mirrors the archive listing, but asks the timeline for `isTrashed: true`.
final trashProvider = FutureProvider<List<AssetResponseDto>>((ref) async {
  final timeline = ref.watch(timelineRepositoryProvider);
  final assets = ref.watch(assetRepositoryProvider);

  final buckets = await timeline.buckets(isTrashed: true);
  final out = <AssetResponseDto>[];
  for (final b in buckets.take(_trashBucketLimit)) {
    final when = DateTime.tryParse(b.timeBucket ?? '');
    if (when == null) continue;
    final bucket = await timeline.bucket(
      timeBucket: when,
      isTrashed: true,
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

/// Trash page: the soft-deleted assets, with restore / delete-forever actions
/// per tile and an "Empty trash" action in the app bar.
class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  Future<void> _emptyTrash() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Empty trash?'),
        content: const Text(
          'Every asset in the trash will be permanently deleted. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Empty'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final result = await ref.read(assetRepositoryProvider).emptyTrash();
      ref.invalidate(trashProvider);
      if (!mounted) return;
      showMessage(context, 'Trash emptied (${result.count})');
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Could not empty trash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trash = ref.watch(trashProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'empty') _emptyTrash();
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'empty',
                child: Text('Empty trash'),
              ),
            ],
          ),
        ],
      ),
      body: trash.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Trash is empty'));
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
                onLongPress: () => _showActions(context, a),
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

  Future<void> _showActions(BuildContext context, AssetResponseDto asset) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: const Text('Restore'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                try {
                  await ref
                      .read(assetRepositoryProvider)
                      .restore([asset.id ?? '']);
                  ref.invalidate(trashProvider);
                  if (!mounted) return;
                  showMessage(context, 'Restored');
                } catch (e) {
                  if (!mounted) return;
                  showMessage(context, 'Could not restore: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Delete permanently'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                try {
                  await ref
                      .read(assetRepositoryProvider)
                      .delete([asset.id ?? ''], force: true);
                  ref.invalidate(trashProvider);
                  if (!mounted) return;
                  showMessage(context, 'Deleted permanently');
                } catch (e) {
                  if (!mounted) return;
                  showMessage(context, 'Could not delete: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
