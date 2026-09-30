import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';
import '../../widgets/thumbhash_placeholder.dart';

/// Every memory the server currently offers, newest first.
final memoriesProvider = FutureProvider<List<MemoryResponseDto>>((ref) =>
    ref.watch(memoryRepositoryProvider).search());

/// Memories page: one horizontal strip of thumbnails per memory, with per
/// memory save / hide actions.
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Memories')),
      body: memories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No memories yet'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(memoriesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _MemorySection(memory: items[i]),
            ),
          );
        },
      ),
    );
  }
}

/// One memory: a date header with actions, then a horizontal asset strip.
class _MemorySection extends ConsumerWidget {
  const _MemorySection({required this.memory});

  final MemoryResponseDto memory;

  /// Assets are always present (the generated DTO has a non-nullable list), but
  /// guard anyway so an empty memory renders as an empty strip.
  List<AssetResponseDto> get _assets => memory.assets ?? const <AssetResponseDto>[];

  String get _title {
    final assets = _assets;
    if (assets.isEmpty) return '';
    return formatDate(parseDate(assets.first.fileCreatedAt));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = _assets;
    final theme = Theme.of(context);
    final repo = ref.read(assetRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _title,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: memory.isSaved == true ? 'Unsave' : 'Save',
                icon: Icon(
                  memory.isSaved == true ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () async {
                  await ref
                      .read(memoryRepositoryProvider)
                      .update(memory.id ?? '', isSaved: !(memory.isSaved ?? false));
                  ref.invalidate(memoriesProvider);
                },
              ),
              IconButton(
                tooltip: 'Hide',
                icon: const Icon(Icons.visibility_off_outlined),
                onPressed: () async {
                  await ref
                      .read(memoryRepositoryProvider)
                      .update(memory.id ?? '', seenAt: DateTime.now().toIso8601String());
                  ref.invalidate(memoriesProvider);
                  if (context.mounted) showMessage(context, 'Memory hidden');
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: assets.isEmpty
              ? const Center(child: Text('No assets'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: assets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 4),
                  itemBuilder: (context, i) {
                    final asset = assets[i];
                    return GestureDetector(
                      onTap: () => context.push(
                        '${AppRoutes.viewer}?ids=${Uri.encodeComponent(
                          assets.map((e) => e.id ?? '').join(','),
                        )}&index=$i',
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ThumbhashPlaceholder(thumbhash: asset.thumbhash),
                            CachedNetworkImage(
                              imageUrl: repo.thumbnailUrl(asset.id ?? ''),
                              fit: BoxFit.cover,
                              memCacheWidth: 400,
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                            if (asset.type == AssetTypeEnum.vIDEO)
                              const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.play_circle_outline,
                                      size: 20),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
