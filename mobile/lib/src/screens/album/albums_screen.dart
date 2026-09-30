import 'package:flutter/material.dart';

import '../../widgets/immich_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../routing/app_router.dart';

final albumsProvider = FutureProvider<List<AlbumResponseDto>>((ref) async {
  return ref.watch(albumRepositoryProvider).all();
});

/// Album list, split into "owned" and "shared with me" like the official app.
class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(albumsProvider),
          ),
        ],
      ),
      body: albums.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No albums yet'));
          }
          final owned = items.where((a) => a.shared != true).toList();
          final shared = items.where((a) => a.shared == true).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(albumsProvider),
            child: ListView(
              children: [
                if (owned.isNotEmpty) ...[
                  _SectionHeader(title: 'My albums', count: owned.length),
                  ...owned.map((a) => _AlbumTile(album: a)),
                ],
                if (shared.isNotEmpty) ...[
                  _SectionHeader(title: 'Shared with me', count: shared.length),
                  ...shared.map((a) => _AlbumTile(album: a)),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createAlbum(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createAlbum(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New album'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Album name'),
          onSubmitted: (v) => Navigator.pop(c, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(albumRepositoryProvider).create(albumName: name.trim());
    ref.invalidate(albumsProvider);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('$count', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AlbumTile extends ConsumerWidget {
  const _AlbumTile({required this.album});

  final AlbumResponseDto album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = album.albumThumbnailAssetId == null
        ? null
        : ref
            .read(assetRepositoryProvider)
            .thumbnailUrl(album.albumThumbnailAssetId!);
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url == null
              ? const ColoredBox(
                  color: Colors.black26,
                  child: Icon(Icons.photo_album_outlined),
                )
              : ImmichNetworkImage(imageUrl: url, fit: BoxFit.cover),
        ),
      ),
      title: Text(album.albumName ?? ''),
      subtitle: Text(
        '${album.assetCount ?? 0} item(s)'
        '${album.shared == true ? ' • shared' : ''}',
      ),
      trailing: album.hasSharedLink == true
          ? const Icon(Icons.link, size: 18)
          : const Icon(Icons.chevron_right),
      onTap: () => context.push('${AppRoutes.albums}/${album.id ?? ''}'),
    );
  }
}
