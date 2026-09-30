import 'package:flutter/material.dart';

import '../../widgets/immich_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../repositories/search_repository.dart';
import '../../routing/app_router.dart';
import '../../widgets/thumbhash_placeholder.dart';

/// Which search backend is currently driving the results.
enum SearchMode { smart, metadata }

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchModeProvider = StateProvider<SearchMode>((ref) => SearchMode.smart);

final searchResultsProvider =
    FutureProvider<List<AssetResponseDto>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final mode = ref.watch(searchModeProvider);
  final repo = ref.watch(searchRepositoryProvider);
  if (query.isEmpty) {
    return repo.metadataAll(filter: const SearchFilter());
  }
  if (mode == SearchMode.smart) {
    final hits = await repo.smart(query: query);
    return sortAssetsNewestFirst(
      hits.map((h) => h.remote).whereType<AssetResponseDto>(),
    );
  }
  final hits = await repo.metadata(
    filter: metadataQueryFilter(query),
  );
  return sortAssetsNewestFirst(
    hits.map((h) => h.remote).whereType<AssetResponseDto>(),
  );
});

/// Search page: natural-language (CLIP) search and full-library browsing.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  bool _dirty = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String v) {
    ref.read(searchQueryProvider.notifier).state = v;
    setState(() => _dirty = v.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(searchModeProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: TextField(
          controller: _controller,
          autofocus: false,
          textInputAction: TextInputAction.search,
          onSubmitted: _submit,
          onChanged: (v) {
            if (v.isEmpty) _submit('');
          },
          decoration: InputDecoration(
            hintText: mode == SearchMode.smart
                ? 'Search photos (e.g. "sunset on a beach")'
                : 'Search by filename or metadata',
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _submit('');
                    },
                  ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              mode == SearchMode.smart
                  ? Icons.auto_awesome
                  : Icons.filter_alt_outlined,
            ),
            tooltip: mode == SearchMode.smart ? 'Smart search' : 'Filters',
            onPressed: () {
              ref.read(searchModeProvider.notifier).state =
                  mode == SearchMode.smart
                      ? SearchMode.metadata
                      : SearchMode.smart;
              final q = _controller.text;
              if (q.isNotEmpty) _submit(q);
            },
          ),
        ],
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(_dirty ? 'No results' : 'Nothing to show'),
            );
          }
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
                  '${AppRoutes.viewer}?ids=${Uri.encodeComponent(
                    items.map((e) => e.id ?? '').join(','),
                  )}&index=$i',
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ThumbhashPlaceholder(thumbhash: a.thumbhash),
                    ImmichNetworkImage(
                      imageUrl: _thumbnailUrl(a.id ?? ''),
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

  String _thumbnailUrl(String id) =>
      ref.read(assetRepositoryProvider).thumbnailUrl(id);
}
