import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../utils/format.dart';

final sharedLinksProvider =
    FutureProvider<List<SharedLinkResponseDto>>((ref) async {
  return ref.watch(sharedLinkRepositoryProvider).all();
});

/// Lists every public share link and allows revoking them.
class SharedLinksScreen extends ConsumerWidget {
  const SharedLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(sharedLinksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared links'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(sharedLinksProvider),
          ),
        ],
      ),
      body: links.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No shared links'));
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sharedLinksProvider),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final l = items[i];
                return ListTile(
                  leading: const Icon(Icons.link),
                  title: Text(l.description ?? l.slug ?? l.id ?? ''),
                  subtitle: Text(
                    '${l.type?.value ?? 'link'}'
                    '${l.expiresAt != null ? ' • expires ${formatDate(parseDate(l.expiresAt))}' : ''}'
                    '${l.allowDownload == true ? ' • download' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref.read(sharedLinkRepositoryProvider).remove(l.id ?? '');
                      ref.invalidate(sharedLinksProvider);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
