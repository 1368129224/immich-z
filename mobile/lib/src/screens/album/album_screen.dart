import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../repositories/asset_repository.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';

final albumProvider =
    FutureProvider.family<AlbumResponseDto, String>((ref, id) async {
  return ref.watch(albumRepositoryProvider).get(id);
});

/// One album: its assets plus activity (comments and likes).
class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key, required this.albumId});

  final String albumId;

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen> {
  final Set<String> _selected = <String>{};
  bool _selectionMode = false;

  @override
  Widget build(BuildContext context) {
    final album = ref.watch(albumProvider(widget.albumId));

    return Scaffold(
      body: album.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (a) => _buildBody(context, ref, a),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AlbumResponseDto album,
  ) {
    final repo = ref.watch(albumRepositoryProvider);
    final assets = ref.watch(_albumAssetsProvider(widget.albumId));

    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(album.albumName ?? ''),
            background: album.albumThumbnailAssetId == null
                ? null
                : CachedNetworkImage(
                    imageUrl: ref
                        .read(assetRepositoryProvider)
                        .thumbnailUrl(album.albumThumbnailAssetId!, size: 'preview'),
                    fit: BoxFit.cover,
                  ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.link),
              tooltip: 'Shared link',
              onPressed: () => _shareLink(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Share with users',
              onPressed: () => showMessage(context, 'Add users from web UI'),
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'rename') await _rename(context, ref, album);
                if (v == 'delete') await _delete(context, ref);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'delete', child: Text('Delete album')),
              ],
            ),
          ],
        ),
      ],
      body: assets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('This album is empty'));
          }
          final ids = items.map((e) => e.id ?? '').toList();
          return Column(
            children: [
              if (_selectionMode)
                Material(
                  elevation: 2,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _selected.clear();
                          _selectionMode = false;
                        }),
                      ),
                      Text('${_selected.length} selected'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: 'Remove from album',
                        onPressed: () async {
                          await repo.removeAssets(
                            widget.albumId,
                            _selected.toList(),
                          );
                          setState(() {
                            _selected.clear();
                            _selectionMode = false;
                          });
                          ref.invalidate(_albumAssetsProvider(widget.albumId));
                          ref.invalidate(albumProvider(widget.albumId));
                        },
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final asset = items[i];
                    final selected = _selected.contains(asset.id ?? '');
                    return GestureDetector(
                      onLongPress: () => setState(() {
                        _selectionMode = true;
                        _selected.add(asset.id ?? '');
                      }),
                      onTap: () {
                        if (_selectionMode) {
                          setState(() {
                            selected
                                ? _selected.remove(asset.id ?? '')
                                : _selected.add(asset.id ?? '');
                          });
                          return;
                        }
                        context.push(
                          '${AppRoutes.viewer}?ids=${Uri.encodeComponent(ids.join(','))}'
                          '&index=$i',
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: ref
                                .read(assetRepositoryProvider)
                                .thumbnailUrl(asset.id ?? ''),
                            fit: BoxFit.cover,
                            memCacheWidth: 400,
                          ),
                          if (asset.type == AssetTypeEnum.vIDEO)
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.play_circle_outline, size: 18),
                              ),
                            ),
                          if (_selectionMode)
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked_outlined,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Album assets are fetched through the timeline bucket endpoint scoped to
  /// the album, which is how the official app loads them.
  Future<void> _shareLink(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(sharedLinkRepositoryProvider);
    final link = await repo.create(albumId: widget.albumId);
    if (!context.mounted) return;
    showMessage(context, 'Shared link created: ${link.slug ?? link.id}');
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    AlbumResponseDto album,
  ) async {
    final controller = TextEditingController(text: album.albumName);
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Rename album'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Album name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(albumRepositoryProvider)
        .update(widget.albumId, albumName: name.trim());
    ref.invalidate(albumProvider(widget.albumId));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Delete album?'),
            content: const Text('The photos inside will not be deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await ref.read(albumRepositoryProvider).delete(widget.albumId);
    if (context.mounted) context.go(AppRoutes.albums);
  }
}

final _albumAssetsProvider =
    FutureProvider.family<List<AssetResponseDto>, String>((ref, albumId) async {
  final buckets = await ref.watch(timelineRepositoryProvider).buckets(
        albumId: albumId,
      );
  final repo = ref.watch(timelineRepositoryProvider);
  final out = <AssetResponseDto>[];
  for (final b in buckets.take(6)) {
    final bucket = await repo.bucket(
      timeBucket: DateTime.tryParse(b.timeBucket ?? '') ?? DateTime.now(),
      albumId: albumId,
    );
    final flat = flattenBucket(bucket);
    final assetRepo = ref.watch(assetRepositoryProvider);
    for (final f in flat) {
      try {
        out.add(await assetRepo.get(f.id));
      } catch (_) {
        // Skip assets that vanished mid-flight.
      }
    }
  }
  return out;
});
