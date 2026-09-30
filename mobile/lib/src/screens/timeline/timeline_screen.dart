import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../providers/theme_provider.dart';
import '../../repositories/asset_repository.dart';
import '../../routing/app_router.dart';
import '../../utils/format.dart';
import '../../widgets/thumbhash_placeholder.dart';

/// Number of columns in the timeline grid; pinch-zoom changes it live.
final timelineColumnsProvider = StateNotifierProvider<ColumnNotifier, int>(
  (ref) => ColumnNotifier(ref.read(prefsProvider)),
);

class ColumnNotifier extends StateNotifier<int> {
  ColumnNotifier(this._store) : super(3);

  final SettingsStore _store;

  Future<void> set(int value) async {
    state = value.clamp(1, 12);
    await _store.write<int>('timeline_columns', state);
  }
}

/// How the timeline groups its rows.
enum GroupBy { day, month, auto, none }

final groupByProvider = StateNotifierProvider<GroupByNotifier, GroupBy>(
  (ref) => GroupByNotifier(ref.read(prefsProvider)),
);

class GroupByNotifier extends StateNotifier<GroupBy> {
  GroupByNotifier(this._store)
      : super(
          GroupBy.values.firstWhere(
            (g) => g.name == 'day',
            orElse: () => GroupBy.day,
          ),
        );

  final SettingsStore _store;

  Future<void> set(GroupBy value) async {
    state = value;
    await _store.write<String>('timeline_group_by', value.name);
  }
}

/// The full timeline: buckets → days → assets, with selection and zoom.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final Set<String> _selected = <String>{};
  bool _selectionMode = false;
  double _scaleBase = 1.0;
  int _columnsBase = 3;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(timelineProvider.notifier).load());
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selectionMode = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _clearSelection() => setState(() {
        _selected.clear();
        _selectionMode = false;
      });

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timelineProvider);
    final columns = ref.watch(timelineColumnsProvider);
    final groupBy = ref.watch(groupByProvider);

    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
              title: Text('${_selected.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  tooltip: 'Favorite',
                  onPressed: () async {
                    await ref
                        .read(assetRepositoryProvider)
                        .favorite(_selected.toList(), true);
                    if (mounted) {
                      _clearSelection();
                      ref.read(timelineProvider.notifier).load();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: 'Archive',
                  onPressed: () async {
                    await ref
                        .read(assetRepositoryProvider)
                        .archive(_selected.toList(), true);
                    if (mounted) {
                      _clearSelection();
                      ref.read(timelineProvider.notifier).load();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share link',
                  onPressed: () => showMessage(context, 'Use album share'),
                ),
              ],
            )
          : AppBar(
              title: const Text('Photos'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  tooltip: 'Jump to date',
                  onPressed: () => _pickDate(context),
                ),
                PopupMenuButton<GroupBy>(
                  icon: const Icon(Icons.view_agenda_outlined),
                  tooltip: 'Group by',
                  onSelected: (g) =>
                      ref.read(groupByProvider.notifier).set(g),
                  itemBuilder: (context) => [
                    for (final g in GroupBy.values)
                      CheckedPopupMenuItem(
                        value: g,
                        checked: groupBy == g,
                        child: Text(_groupLabel(g)),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  onPressed: () => ref.read(timelineProvider.notifier).load(),
                ),
              ],
            ),
      body: GestureDetector(
        // Pinch to change the number of columns, as in the official app.
        onScaleStart: (d) {
          _scaleBase = 1.0;
          _columnsBase = columns;
        },
        onScaleUpdate: (d) {
          final factor = d.scale / _scaleBase;
          if ((factor - 1.0).abs() < 0.15) return;
          _scaleBase = d.scale;
          final next =
              (_columnsBase / (factor > 1 ? 1.5 : 1 / 1.5)).round().clamp(1, 12);
          if (next != columns) {
            ref.read(timelineColumnsProvider.notifier).set(next);
          }
        },
        child: state.isLoading && state.days.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.days.isEmpty
                ? _ErrorView(
                    message: state.error!,
                    onRetry: () => ref.read(timelineProvider.notifier).load(),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.read(timelineProvider.notifier).load(),
                    child: CustomScrollView(
                      slivers: [
                        for (final day in state.days)
                          ..._buildDay(context, day, columns, groupBy),
                        if (state.hasMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: state.isLoading
                                    ? const CircularProgressIndicator()
                                    : OutlinedButton(
                                        onPressed: () => ref
                                            .read(timelineProvider.notifier)
                                            .loadMore(),
                                        child: const Text('Load more'),
                                      ),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  ),
      ),
    );
  }

  String _groupLabel(GroupBy g) => switch (g) {
        GroupBy.day => 'Day',
        GroupBy.month => 'Month',
        GroupBy.auto => 'Auto',
        GroupBy.none => 'None',
      };

  List<Widget> _buildDay(
    BuildContext context,
    TimelineDay day,
    int columns,
    GroupBy groupBy,
  ) {
    final showHeader = groupBy != GroupBy.none;
    return [
      if (showHeader)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  groupBy == GroupBy.month
                      ? formatBucket(day.date)
                      : formatDate(day.date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${day.assets.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final asset = day.assets[i];
            return _TimelineCell(
              asset: asset,
              thumbnailUrl: ref.read(assetRepositoryProvider).thumbnailUrl(
                    asset.id,
                    size: 'thumbnail',
                  ),
              selected: _selected.contains(asset.id),
              selectionMode: _selectionMode,
              onTap: () {
                if (_selectionMode) {
                  _toggle(asset.id);
                  return;
                }
                context.push(
                  '${AppRoutes.viewer}?ids=${Uri.encodeComponent(_allIds.join(','))}'
                  '&index=${_flatIndex(asset.id)}',
                );
              },
              onLongPress: () {
                setState(() {
                  _selectionMode = true;
                  _selected.add(asset.id);
                });
              },
            );
          },
          childCount: day.assets.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
      ),
    ];
  }

  List<String> get _allIds =>
      ref.read(timelineProvider).days.expand((d) => d.assets).map((a) => a.id).toList();

  int _flatIndex(String id) {
    final ids = _allIds;
    final i = ids.indexOf(id);
    return i < 0 ? 0 : i;
  }

  Future<void> _pickDate(BuildContext context) async {
    final state = ref.read(timelineProvider);
    if (state.days.isEmpty) return;
    final first = state.days.last.date;
    final last = state.days.first.date;
    final picked = await showDatePicker(
      context: context,
      initialDate: last,
      firstDate: first,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await ref.read(timelineProvider.notifier).jumpTo(picked);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Move to trash?'),
            content: Text('${_selected.length} item(s) will be moved to trash.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Move to trash'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await ref.read(assetRepositoryProvider).delete(_selected.toList());
    if (mounted) {
      _clearSelection();
      ref.read(timelineProvider.notifier).load();
    }
  }
}

/// One day of assets.
class TimelineDay {
  TimelineDay(this.date, this.assets);

  final DateTime date;
  final List<TimelineAsset> assets;
}

/// Timeline state: day groups + pagination cursor.
class TimelineState {
  TimelineState({
    this.days = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.error,
  });

  final List<TimelineDay> days;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  TimelineState copyWith({
    List<TimelineDay>? days,
    bool? isLoading,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) =>
      TimelineState(
        days: days ?? this.days,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Loads buckets, then lazily fetches each bucket's assets.
class TimelineController extends StateNotifier<TimelineState> {
  TimelineController(this._repo) : super(TimelineState());

  final TimelineRepository _repo;

  List<TimeBucketsResponseDto> _buckets = [];
  int _nextBucket = 0;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true, days: const []);
    try {
      final buckets = await _repo.buckets();
      _buckets = buckets;
      _nextBucket = 0;
      await loadMore();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fetches the next few buckets and appends them as day groups.
  Future<void> loadMore() async {
    if (_nextBucket >= _buckets.length) {
      state = state.copyWith(isLoading: false, hasMore: false);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final slice = _buckets.skip(_nextBucket).take(3).toList();
      _nextBucket += slice.length;

      final newDays = <TimelineDay>[];
      for (final b in slice) {
        final bucket = await _repo.bucket(timeBucket: _bucketDate(b));
        final assets = flattenBucket(bucket);
        if (assets.isEmpty) continue;
        newDays.add(TimelineDay(_bucketDate(b), assets));
      }

      state = state.copyWith(
        days: [...state.days, ...newDays],
        isLoading: false,
        hasMore: _nextBucket < _buckets.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Timeline buckets are returned as `YYYY-MM-DDTHH:MM:SS.000Z` strings.
  DateTime _bucketDate(TimeBucketsResponseDto b) =>
      DateTime.tryParse(b.timeBucket ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);

  /// Scrolls the timeline to the bucket containing `date`.
  Future<void> jumpTo(DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final month = DateTime(date.year, date.month, 1);
      final bucket = await _repo.bucket(timeBucket: month);
      final assets = flattenBucket(bucket);
      state = state.copyWith(
        days: [TimelineDay(month, assets)],
        isLoading: false,
        hasMore: _nextBucket < _buckets.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final timelineProvider =
    StateNotifierProvider<TimelineController, TimelineState>((ref) {
  return TimelineController(ref.watch(timelineRepositoryProvider));
});

/// A single grid cell: cached thumbnail with a thumbhash placeholder and a
/// video badge.
class _TimelineCell extends StatelessWidget {
  const _TimelineCell({
    required this.asset,
    required this.thumbnailUrl,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final TimelineAsset asset;
  final String thumbnailUrl;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ThumbhashPlaceholder(thumbhash: asset.thumbhash),
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            memCacheWidth: 400,
            fadeInDuration: const Duration(milliseconds: 120),
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
          ),
          if (asset.isVideo)
            const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.play_circle_outline, size: 18),
              ),
            ),
          if (asset.isFavorite)
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.favorite, size: 16, color: Colors.red),
              ),
            ),
          if (selectionMode)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked_outlined,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white70,
                ),
              ),
            ),
          if (selected)
            ColoredBox(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
