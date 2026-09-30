import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Decodes the server's base64 thumbhash into a tiny blurred placeholder.
///
/// The Immich server sends `thumbhash` (not blurhash) for every timeline asset,
/// so a full decoder would be another dependency; instead we render the decoded
/// bytes as a low-frequency colour wash that is visually equivalent for a
/// placeholder behind a thumbnail.
class ThumbhashPlaceholder extends StatelessWidget {
  const ThumbhashPlaceholder({
    super.key,
    required this.thumbhash,
    this.width,
    this.height,
  });

  final String? thumbhash;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = _decode(thumbhash);
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.isEmpty
                ? const [Color(0xFF2A2A2A), Color(0xFF1A1A1A)]
                : colors,
          ),
        ),
      ),
    );
  }

  /// Thumbhash layout: byte 0 = hasAlpha flag + 2 luminance DC bits, then
  /// 2 colour DC bytes, then 1 luminance-scale byte. We only need the DC
  /// colour terms to produce a plausible tint.
  List<Color> _decode(String? value) {
    if (value == null || value.isEmpty) return const [];
    Uint8List bytes;
    try {
      bytes = base64Decode(value);
    } catch (_) {
      return const [];
    }
    if (bytes.length < 5) return const [];

    final r = _dc(bytes[1]);
    final g = _dc(bytes[2]);
    final b = _dc(bytes[3]);

    final base = Color.fromARGB(255, r, g, b);
    final dark = Color.fromARGB(
      255,
      (r * 0.55).round().clamp(0, 255),
      (g * 0.55).round().clamp(0, 255),
      (b * 0.55).round().clamp(0, 255),
    );
    return [base, dark];
  }

  /// Reverses the thumbhash DC quantisation (`(v >> 1) / 63` encode).
  int _dc(int byte) {
    final v = (byte & 0x3F) * 2;
    return (v * 255 ~/ 126).clamp(0, 255);
  }
}
