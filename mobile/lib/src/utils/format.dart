import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Parses the many date shapes the server sends back (ISO-8601 with or without
/// an offset, or a bare `YYYY-MM-DD`).
DateTime? parseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final direct = DateTime.tryParse(value);
  if (direct != null) return direct.toLocal();
  final loose = DateTime.tryParse('${value}Z');
  return loose?.toLocal();
}

/// `Mar 4, 2025` style label.
String formatDate(DateTime? d) {
  if (d == null) return '';
  return DateFormat.yMMMd().format(d);
}

/// `Mar 2025` bucket header.
String formatBucket(DateTime d) => DateFormat.yMMMM().format(d);

/// `March 4, 2025 at 14:32`.
String formatDateTime(DateTime? d) {
  if (d == null) return '';
  return DateFormat.yMMMd().add_jm().format(d);
}

/// Compact human duration, e.g. `01:23` or `1:02:03`.
String formatDuration(int? seconds) {
  if (seconds == null || seconds <= 0) return '';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// Human byte size.
String formatBytes(int? bytes) {
  if (bytes == null) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// `Mar 4` used by the memories carousel.
String formatShortDate(DateTime? d) =>
    d == null ? '' : DateFormat.MMMd().format(d);

/// Builds a `yyyy-MM-dd` key used to group timeline assets into days.
String dayKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// Decodes a JWT payload without verifying the signature, used only to read the
/// token expiry so we can warn before the session lapses.
DateTime? tokenExpiry(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return null;
  try {
    var payload = parts[1];
    payload += base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(payload));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    final exp = map['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }
  } catch (_) {
    return null;
  }
  return null;
}

/// Relative label for "last backup" rows.
String relativeTime(DateTime? d) {
  if (d == null) return 'never';
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(d);
}

/// The month/day header shown above a timeline group.
String groupHeader(DateTime d, bool byMonth) =>
    byMonth ? DateFormat.yMMMM().format(d) : DateFormat.yMMMd().format(d);

/// Snack bar helper so screens share one style.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
