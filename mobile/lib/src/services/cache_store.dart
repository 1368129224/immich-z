import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// A tiny append/replace JSON document store used for the offline cache.
///
/// It deliberately avoids a full database and its code-generation step: the
/// cache is keyed by `kind + serverId`, which is exactly what the timeline,
/// album, person and tag screens need, and a single JSON file per kind keeps
/// writes cheap even on low-end devices.
class JsonStore {
  JsonStore._(this._dir);

  final Directory _dir;

  static JsonStore? _instance;

  static Future<JsonStore> instance() async {
    final existing = _instance;
    if (existing != null) return existing;
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/store');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _instance = JsonStore._(dir);
    return _instance!;
  }

  File _file(String kind) => File('${_dir.path}/$kind.json');

  /// Reads every cached document of one kind.
  Future<List<Map<String, dynamic>>> readAll(String kind) async {
    final f = _file(kind);
    if (!await f.exists()) return <Map<String, dynamic>>[];
    try {
      final raw = await f.readAsString();
      if (raw.isEmpty) return <Map<String, dynamic>>[];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .toList(growable: true);
      }
    } catch (_) {
      // A corrupt cache file must never crash the app.
    }
    return <Map<String, dynamic>>[];
  }

  /// Replaces one document (matched on `id`), or appends it.
  Future<void> upsert(String kind, Map<String, dynamic> doc) async {
    final items = await readAll(kind);
    final id = doc['id']?.toString();
    final idx = id == null
        ? -1
        : items.indexWhere((e) => e['id']?.toString() == id);
    if (idx >= 0) {
      items[idx] = doc;
    } else {
      items.add(doc);
    }
    await _write(kind, items);
  }

  Future<void> upsertAll(String kind, List<Map<String, dynamic>> docs) async {
    final items = await readAll(kind);
    final byId = <String, int>{};
    for (var i = 0; i < items.length; i++) {
      final id = items[i]['id']?.toString();
      if (id != null) byId[id] = i;
    }
    for (final doc in docs) {
      final id = doc['id']?.toString();
      if (id != null && byId.containsKey(id)) {
        items[byId[id]!] = doc;
      } else {
        items.add(doc);
      }
    }
    await _write(kind, items);
  }

  Future<void> remove(String kind, String id) async {
    final items = await readAll(kind);
    items.removeWhere((e) => e['id']?.toString() == id);
    await _write(kind, items);
  }

  Future<void> clear(String kind) async => _write(kind, <Map<String, dynamic>>[]);

  Future<void> _write(String kind, List<Map<String, dynamic>> items) async {
    await _file(kind).writeAsString(jsonEncode(items));
  }
}
