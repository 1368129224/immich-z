import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode persisted to disk.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    state = switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

/// Accent colour, mirroring the official app's colour-preset setting.
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier();
});

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(const Color(0xFF4254F8)) {
    _load();
  }

  static const _key = 'accent_color';
  static const presets = <String, int>{
    'blue': 0xFF4254F8,
    'green': 0xFF2BAE66,
    'red': 0xFFE53935,
    'orange': 0xFFFB8C00,
    'purple': 0xFF8E24AA,
    'teal': 0xFF00897B,
    'pink': 0xFFD81B60,
    'grey': 0xFF607D8B,
  };

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_key);
    if (v != null) state = Color(v);
  }

  Future<void> set(Color c) async {
    state = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, c.toARGB32());
  }
}

/// Dynamic colour ("Material You") toggle.
final dynamicColorProvider =
    StateNotifierProvider<DynamicColorNotifier, bool>((ref) {
  return DynamicColorNotifier();
});

class DynamicColorNotifier extends StateNotifier<bool> {
  DynamicColorNotifier() : super(true) {
    _load();
  }

  static const _key = 'dynamic_color';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> set(bool v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
  }
}

/// Text scale, exposing the standard accessibility slider.
final textScaleProvider =
    StateNotifierProvider<TextScaleNotifier, double>((ref) {
  return TextScaleNotifier();
});

class TextScaleNotifier extends StateNotifier<double> {
  TextScaleNotifier() : super(1.0) {
    _load();
  }

  static const _key = 'text_scale';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> set(double v) async {
    state = v.clamp(0.8, 2.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, state);
  }
}

/// Generic typed preference helper used by all settings screens.
final prefsProvider = Provider<SettingsStore>((ref) => SettingsStore());

class SettingsStore {
  static const _kTimelineColumns = 'timeline_columns';
  static const _kGroupBy = 'timeline_group_by';
  static const _kShowStorage = 'timeline_storage_indicator';
  static const _kLoadOriginal = 'image_load_original';
  static const _kPreferRemote = 'image_prefer_remote';
  static const _kLoopVideo = 'viewer_loop_video';
  static const _kAutoPlayVideo = 'viewer_auto_play_video';
  static const _kTapToNavigate = 'viewer_tap_to_navigate';
  static const _kLoadOriginalVideo = 'viewer_load_original_video';
  static const _kBackupEnabled = 'backup_enabled';
  static const _kBackupAlbums = 'backup_album_ids';
  static const _kBackupRequireCharging = 'backup_require_charging';
  static const _kBackupRequireWifi = 'backup_require_wifi';
  static const _kBackupTriggerDelay = 'backup_trigger_delay';
  static const _kHaptics = 'haptic_feedback';
  static const _kAutoSaveAlbum = 'auto_save_album';
  static const _kSlideshowDuration = 'slideshow_duration';
  static const _kSlideshowRepeat = 'slideshow_repeat';
  static const _kMapShowFavoriteOnly = 'map_favorite_only';
  static const _kMapIncludeArchived = 'map_include_archived';
  static const _kMapWithPartners = 'map_with_partners';
  static const _kSelectedBackupAlbums = 'selected_backup_albums';

  Future<T> read<T>(String key, T fallback) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.get(key);
    if (v == null) return fallback;
    if (v is T) return v as T;
    return fallback;
  }

  Future<void> write<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (value) {
      case bool v:
        await prefs.setBool(key, v);
      case int v:
        await prefs.setInt(key, v);
      case double v:
        await prefs.setDouble(key, v);
      case String v:
        await prefs.setString(key, v);
      case List<String> v:
        await prefs.setStringList(key, v);
      default:
        await prefs.setString(key, jsonEncode(value));
    }
  }

  Future<List<String>> readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? <String>[];
  }
}

// -- keys re-exported so screens cannot typo them --------------------------------
// ignore: avoid_classes_with_only_static_members
class SettingsKeys {
  static const String timelineColumns = SettingsStore._kTimelineColumns;
  static const String groupBy = SettingsStore._kGroupBy;
  static const String showStorage = SettingsStore._kShowStorage;
  static const String loadOriginal = SettingsStore._kLoadOriginal;
  static const String preferRemote = SettingsStore._kPreferRemote;
  static const String loopVideo = SettingsStore._kLoopVideo;
  static const String autoPlayVideo = SettingsStore._kAutoPlayVideo;
  static const String tapToNavigate = SettingsStore._kTapToNavigate;
  static const String loadOriginalVideo = SettingsStore._kLoadOriginalVideo;
  static const String backupEnabled = SettingsStore._kBackupEnabled;
  static const String backupAlbums = SettingsStore._kBackupAlbums;
  static const String backupRequireCharging =
      SettingsStore._kBackupRequireCharging;
  static const String backupRequireWifi = SettingsStore._kBackupRequireWifi;
  static const String backupTriggerDelay = SettingsStore._kBackupTriggerDelay;
  static const String haptics = SettingsStore._kHaptics;
  static const String autoSaveAlbum = SettingsStore._kAutoSaveAlbum;
  static const String slideshowDuration = SettingsStore._kSlideshowDuration;
  static const String slideshowRepeat = SettingsStore._kSlideshowRepeat;
  static const String mapShowFavoriteOnly =
      SettingsStore._kMapShowFavoriteOnly;
  static const String mapIncludeArchived = SettingsStore._kMapIncludeArchived;
  static const String mapWithPartners = SettingsStore._kMapWithPartners;
  static const String selectedBackupAlbums =
      SettingsStore._kSelectedBackupAlbums;
}
