import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';

final tagsProvider = FutureProvider<List<TagResponseDto>>((ref) async {
  return ref.watch(miscRepositoryProvider).tags();
});

/// Tag management: create, rename and delete tags.
class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createTag(context, ref),
          ),
        ],
      ),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No tags'));
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(tagsProvider),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final t = items[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(t.color),
                    child: const Icon(Icons.label, color: Colors.white),
                  ),
                  title: Text(t.value ?? ''),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'delete') {
                        await ref.read(miscRepositoryProvider).deleteTag(t.id ?? '');
                        ref.invalidate(tagsProvider);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () => context.push(
                    '${AppRoutes.viewer}?ids=&index=0',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    final v = hex.replaceAll('#', '');
    final n = int.tryParse(v.length == 6 ? 'FF$v' : v, radix: 16);
    return n == null ? Colors.grey : Color(n);
  }

  Future<void> _createTag(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tag name'),
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
    await ref.read(miscRepositoryProvider).createTag(name: name.trim());
    ref.invalidate(tagsProvider);
  }
}
