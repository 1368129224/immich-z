import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';

/// Cached Immich media image with the active session's auth header.
///
/// Immich media endpoints require the same authentication as JSON endpoints;
/// plain image URLs silently receive 401s unless the Bearer or x-api-key header
/// is supplied.
class ImmichNetworkImage extends ConsumerWidget {
  const ImmichNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.memCacheWidth,
    this.errorWidget,
    this.placeholder,
  });

  final String imageUrl;
  final BoxFit? fit;
  final int? memCacheWidth;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final Widget Function(BuildContext, String)? placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: ref.watch(authHeadersProvider),
      fit: fit,
      memCacheWidth: memCacheWidth,
      errorWidget: errorWidget,
      placeholder: placeholder,
    );
  }
}
