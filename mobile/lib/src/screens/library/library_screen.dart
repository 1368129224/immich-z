import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';

/// Library overview: external libraries plus quick links to every collection.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(_librariesProvider);
    final stats = ref.watch(_statisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: stats.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (s) => Row(
                children: [
                  _StatChip(
                    icon: Icons.photo_outlined,
                    label: '${s.images ?? 0} photos',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.videocam_outlined,
                    label: '${s.videos ?? 0} videos',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.folder_outlined,
                    label: formatBytes(s.total ?? 0),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          _LibraryTile(
            icon: Icons.favorite_outline,
            title: 'Favorites',
            onTap: () => context.push(AppRoutes.favorites),
          ),
          _LibraryTile(
            icon: Icons.archive_outlined,
            title: 'Archive',
            onTap: () => context.push(AppRoutes.archive),
          ),
          _LibraryTile(
            icon: Icons.delete_outline,
            title: 'Trash',
            onTap: () => context.push(AppRoutes.trash),
          ),
          _LibraryTile(
            icon: Icons.map_outlined,
            title: 'Places',
            onTap: () => context.push(AppRoutes.map),
          ),
          _LibraryTile(
            icon: Icons.auto_awesome_outlined,
            title: 'Memories',
            onTap: () => context.push(AppRoutes.memories),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'External libraries',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          libraries.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListTile(title: Text('$e')),
            data: (items) => items.isEmpty
                ? const ListTile(title: Text('No external libraries'))
                : Column(
                    children: [
                      for (final l in items)
                        ListTile(
                          leading: const Icon(Icons.folder_copy_outlined),
                          title: Text(l.name ?? ''),
                          subtitle: Text('Owner ${l.ownerId ?? '—'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.sync),
                            tooltip: 'Scan library',
                            onPressed: () async {
                              await ref
                                  .read(miscRepositoryProvider)
                                  .scanLibrary(l.id ?? '');
                              if (context.mounted) {
                                showMessage(context, 'Scan started');
                              }
                            },
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
      );
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
}

final _librariesProvider =
    FutureProvider<List<LibraryResponseDto>>((ref) async {
  return ref.watch(miscRepositoryProvider).libraries();
});

final _statisticsProvider =
    FutureProvider<AssetStatsResponseDto>((ref) async {
  return ref.watch(assetRepositoryProvider).statistics();
});
