import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/client.dart';
import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';

/// Builds the full URL for a person's thumbnail from the raw server path.
String personThumbnailUrl(ImmichApiClient client, String id) =>
    '${client.baseUrl}/people/$id/thumbnail';

/// Whether hidden people are included in the grid.
final _showHiddenProvider = StateProvider<bool>((ref) => false);

/// All people known to the server; hidden ones follow [_showHiddenProvider].
final peopleProvider = FutureProvider<List<PersonResponseDto>>((ref) async {
  final withHidden = ref.watch(_showHiddenProvider);
  final res =
      await ref.watch(personRepositoryProvider).all(withHidden: withHidden);
  return res.people ?? const <PersonResponseDto>[];
});

/// People screen: a grid of every recognised person.
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  Future<void> _rename(PersonResponseDto person) async {
    final controller = TextEditingController(text: person.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename person'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == person.name) return;
    try {
      await ref.read(personRepositoryProvider).update(person.id ?? '', name: name);
      ref.invalidate(peopleProvider);
      if (mounted) showMessage(context, 'Renamed to $name');
    } catch (e) {
      if (mounted) showMessage(context, 'Rename failed: $e');
    }
  }

  Future<void> _toggleFavorite(PersonResponseDto person) async {
    try {
      await ref.read(personRepositoryProvider).update(
            person.id ?? '',
            isFavorite: !(person.isFavorite ?? false),
          );
      ref.invalidate(peopleProvider);
    } catch (e) {
      if (mounted) showMessage(context, 'Failed: $e');
    }
  }

  Future<void> _setHidden(PersonResponseDto person, bool hidden) async {
    try {
      await ref
          .read(personRepositoryProvider)
          .update(person.id ?? '', isHidden: hidden);
      ref.invalidate(peopleProvider);
    } catch (e) {
      if (mounted) showMessage(context, 'Failed: $e');
    }
  }

  Future<void> _delete(PersonResponseDto person) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete person?'),
            content: Text('Delete "${person.name ?? ''}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await ref.read(personRepositoryProvider).delete(person.id ?? '');
      ref.invalidate(peopleProvider);
      if (mounted) showMessage(context, 'Deleted ${person.name}');
    } catch (e) {
      if (mounted) showMessage(context, 'Delete failed: $e');
    }
  }

  Future<void> _hideUnnamed(List<PersonResponseDto> people) async {
    final unnamed = people
        .where((p) => (p.name ?? '').trim().isEmpty || (p.name ?? '').trim() == 'Unknown')
        .toList(growable: false);
    if (unnamed.isEmpty) {
      showMessage(context, 'No unnamed people');
      return;
    }
    try {
      final repo = ref.read(personRepositoryProvider);
      for (final p in unnamed) {
        await repo.update(p.id ?? '', isHidden: true);
      }
      ref.invalidate(peopleProvider);
      if (mounted) showMessage(context, 'Hid ${unnamed.length} unnamed people');
    } catch (e) {
      if (mounted) showMessage(context, 'Failed: $e');
    }
  }

  void _showSheet(PersonResponseDto person) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(ctx).pop();
                _rename(person);
              },
            ),
            ListTile(
              leading: Icon(
                (person.isFavorite ?? false)
                    ? Icons.star
                    : Icons.star_border_outlined,
              ),
              title: Text(
                (person.isFavorite ?? false)
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _toggleFavorite(person);
              },
            ),
            ListTile(
              leading: Icon(
                person.isHidden == true ? Icons.visibility : Icons.visibility_off,
              ),
              title: Text(person.isHidden == true ? 'Unhide' : 'Hide'),
              onTap: () {
                Navigator.of(ctx).pop();
                _setHidden(person, !(person.isHidden ?? false));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.of(ctx).pop();
                _delete(person);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(peopleProvider);
    final showHidden = ref.watch(_showHiddenProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            tooltip: showHidden ? 'Hide hidden people' : 'Show hidden people',
            icon: Icon(
              showHidden ? Icons.visibility_off : Icons.visibility_outlined,
            ),
            onPressed: () =>
                ref.read(_showHiddenProvider.notifier).state = !showHidden,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'hide-unnamed') {
                _hideUnnamed(people.valueOrNull ?? const <PersonResponseDto>[]);
              } else if (value == 'refresh') {
                ref.invalidate(peopleProvider);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'hide-unnamed',
                child: Text('Hide unnamed people'),
              ),
              PopupMenuItem<String>(value: 'refresh', child: Text('Refresh')),
            ],
          ),
        ],
      ),
      body: people.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load people: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No people yet'));
          }
          final client = ref.read(requireClientProvider);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(peopleProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final p = items[i];
                return GestureDetector(
                  onTap: () => context.push('${AppRoutes.people}/${p.id ?? ''}'),
                  onLongPress: () => _showSheet(p),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: personThumbnailUrl(client, p.id ?? ''),
                                fit: BoxFit.cover,
                                memCacheWidth: 400,
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: 40,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                                placeholder: (_, __) => ColoredBox(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                            ),
                          ),
                          if (p.isFavorite ?? false)
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child: Icon(Icons.star,
                                  size: 20, color: Colors.amber),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (p.name ?? '').isEmpty ? 'Unnamed' : p.name ?? 'Unnamed',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
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
