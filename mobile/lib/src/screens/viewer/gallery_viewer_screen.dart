import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '../../api/generated/models.dart';
import '../../providers/repository_providers.dart';
import '../../utils/format.dart';

/// Full-screen swipeable asset viewer with pinch-zoom, video playback and an
/// info panel. Mirrors the official app's `GalleryViewer` behaviour.
class GalleryViewerScreen extends ConsumerStatefulWidget {
  const GalleryViewerScreen({
    super.key,
    required this.assetIds,
    this.initialIndex = 0,
  });

  final List<String> assetIds;
  final int initialIndex;

  @override
  ConsumerState<GalleryViewerScreen> createState() =>
      _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends ConsumerState<GalleryViewerScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _maxIndex);
    _controller = PageController(initialPage: _index);
  }

  int get _maxIndex =>
      widget.assetIds.isEmpty ? 0 : widget.assetIds.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetIds.isEmpty) {
      return const Scaffold(body: Center(child: Text('No assets')));
    }
    final asset = ref.watch(_assetProvider(widget.assetIds[_index]));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.assetIds.length}'),
        actions: [
          IconButton(
            icon: Icon(
              asset.value?.isFavorite == true
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () async {
              final a = asset.value;
              if (a == null) return;
              await ref
                  .read(assetRepositoryProvider)
                  .favorite([a.id ?? ''], !(a.isFavorite ?? false));
              ref.invalidate(_assetProvider(a.id ?? ''));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context, asset.value),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.assetIds.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => _AssetPage(
          assetId: widget.assetIds[i],
          asset: i == _index ? asset : null,
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, AssetResponseDto? a) {
    if (a == null) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Details', style: Theme.of(c).textTheme.titleMedium),
              const SizedBox(height: 12),
              _InfoRow('ID', a.id ?? ''),
              _InfoRow('Type', a.type?.value ?? ''),
              _InfoRow(
                'Date',
                formatDateTime(parseDate(a.fileCreatedAt ?? a.localDateTime)),
              ),
              _InfoRow(
                'Dimensions',
                (a.exifInfo?.exifImageWidth != null &&
                        a.exifInfo?.exifImageHeight != null)
                    ? '${a.exifInfo?.exifImageWidth} × ${a.exifInfo?.exifImageHeight}'
                    : '—',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

/// One page of the viewer: an image with pinch-zoom, or a video player.
class _AssetPage extends ConsumerStatefulWidget {
  const _AssetPage({required this.assetId, this.asset});

  final String assetId;
  final AsyncValue<AssetResponseDto?>? asset;

  @override
  ConsumerState<_AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends ConsumerState<_AssetPage> {
  VideoPlayerController? _video;

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  Future<void> _ensureVideo(String url) async {
    final existing = _video;
    if (existing != null && existing.dataSource == url) return;
    await existing?.dispose();
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _video = c;
    try {
      await c.initialize();
      if (mounted) setState(() {});
    } catch (_) {
      // A broken stream must not take the whole viewer down.
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(assetRepositoryProvider);
    final value = widget.asset;

    // While the asset is unknown, render the image endpoint; the server
    // returns a thumbnail-prefixed original that works for both.
    if (value == null || value.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final a = value.value;
    if (a == null) {
      return Center(child: Text('${value.error}'));
    }

    if (a.type == AssetTypeEnum.vIDEO) {
      final url = repo.videoPlaybackUrl(a.id ?? '');
      _ensureVideo(url);
      final c = _video;
      return Center(
        child: c != null && c.value.isInitialized
            ? AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(c),
                    VideoProgressIndicator(c, allowScrubbing: true),
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: Icon(
                          c.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 56,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          c.value.isPlaying ? c.pause() : c.play();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      );
    }

    return PhotoView(
      imageProvider: NetworkImage(repo.originalUrl(a.id ?? '')),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 6,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image, color: Colors.white)),
    );
  }
}

final _assetProvider =
    FutureProvider.family<AssetResponseDto?, String>((ref, id) async {
  try {
    return await ref.watch(assetRepositoryProvider).get(id);
  } catch (_) {
    return null;
  }
});
