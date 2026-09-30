import 'package:flutter/material.dart';

import '../../widgets/immich_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../repositories/search_repository.dart';
import '../../routing/app_router.dart';
import '../../screens/people/people_screen.dart';
import '../../utils/format.dart';

/// One person, fetched by id.
final personProvider =
    FutureProvider.family<PersonResponseDto, String>((ref, id) async {
  return ref.watch(personRepositoryProvider).get(id);
});

/// Every asset the person appears in.
final personAssetsProvider =
    FutureProvider.family<List<AssetResponseDto>, String>((ref, id) async {
  final assets = await ref.watch(searchRepositoryProvider).metadataAll(
        filter: SearchFilter(
          personIds: IdsFilter(any: [id]),
        ),
      );
  return sortAssetsNewestFirst(assets);
});

/// Person detail screen: large avatar, birth date, and the asset grid.
class PersonScreen extends ConsumerStatefulWidget {
  const PersonScreen({required this.personId, super.key});

  final String personId;

  @override
  ConsumerState<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends ConsumerState<PersonScreen> {
  Future<void> _rename(String current) async {
    final controller = TextEditingController(text: current);
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
    if (name == null || name.isEmpty || name == current) return;
    await _update(name: name);
  }

  Future<void> _setBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    final iso =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    await _update(birthDate: iso);
  }

  Future<void> _update({
    String? name,
    String? birthDate,
    bool? isFavorite,
  }) async {
    try {
      await ref.read(personRepositoryProvider).update(
            widget.personId,
            name: name,
            birthDate: birthDate,
            isFavorite: isFavorite,
          );
      ref.invalidate(personProvider(widget.personId));
      ref.invalidate(peopleProvider);
    } catch (e) {
      if (mounted) showMessage(context, 'Update failed: $e');
    }
  }

  Future<void> _delete(String name) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete person?'),
            content: Text('Delete "$name"? This cannot be undone.'),
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
      await ref.read(personRepositoryProvider).delete(widget.personId);
      ref.invalidate(peopleProvider);
      if (mounted) context.go(AppRoutes.people);
    } catch (e) {
      if (mounted) showMessage(context, 'Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(personProvider(widget.personId));
    final assets = ref.watch(personAssetsProvider(widget.personId));
    final theme = Theme.of(context);

    return Scaffold(
      body: person.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Failed to load person: $e')),
        ),
        data: (p) {
          final client = ref.read(requireClientProvider);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'rename') {
                        _rename(p.name ?? '');
                      } else if (v == 'birth') {
                        _setBirthDate();
                      } else if (v == 'favorite') {
                        _update(isFavorite: !(p.isFavorite ?? false));
                      } else if (v == 'delete') {
                        _delete(p.name ?? '');
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem<String>(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'birth',
                        child: Text('Set birth date'),
                      ),
                      PopupMenuItem<String>(
                        value: 'favorite',
                        child: Text(
                          (p.isFavorite ?? false)
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete person'),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: kToolbarHeight),
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.12),
                          child: ClipOval(
                            child: ImmichNetworkImage(
                              imageUrl: personThumbnailUrl(client, p.id ?? ''),
                              fit: BoxFit.cover,
                              memCacheWidth: 400,
                              errorWidget: (_, __, ___) => Icon(
                                Icons.person,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (p.name ?? '').isEmpty
                              ? 'Unnamed'
                              : p.name ?? 'Unnamed',
                          style: theme.textTheme.titleLarge,
                        ),
                        if (p.birthDate != null && p.birthDate!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              p.birthDate!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              assets.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Failed to load photos: $e')),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No photos of this person')),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(2),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final a = items[i];
                          return GestureDetector(
                            onTap: () => context.push(
                              '${AppRoutes.viewer}?ids=${Uri.encodeComponent(
                                items.map((e) => e.id ?? '').join(','),
                              )}&index=$i',
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ImmichNetworkImage(
                                  imageUrl: ref
                                      .read(assetRepositoryProvider)
                                      .thumbnailUrl(a.id ?? ''),
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
                                      child: Icon(Icons.play_circle_outline,
                                          size: 18),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
