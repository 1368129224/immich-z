import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/repository_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routing/app_router.dart';
import '../../services/background_service.dart';
import '../../utils/format.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

/// Settings: appearance, backup, account, and server information.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final dynamicColor = ref.watch(dynamicColorProvider);
    final textScale = ref.watch(textScaleProvider);
    final info = ref.watch(_packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _Section(title: 'Appearance', children: [
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Theme'),
              trailing: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.palette_outlined),
              title: const Text('Dynamic color'),
              subtitle: const Text('Use the system wallpaper color'),
              value: dynamicColor,
              onChanged: (v) =>
                  ref.read(dynamicColorProvider.notifier).set(v),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Text scale'),
              subtitle: Slider(
                value: textScale.clamp(0.8, 2.0),
                min: 0.8,
                max: 2.0,
                divisions: 12,
                label: textScale.toStringAsFixed(2),
                onChanged: (v) => ref.read(textScaleProvider.notifier).set(v),
              ),
            ),
          ]),
          _Section(title: 'Backup', children: [
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Backup settings'),
              subtitle: const Text('Albums, Wi-Fi and charging rules'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.backup),
            ),
          ]),
          _Section(title: 'Library', children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Library'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.library),
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('Tags'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.tags),
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('Shared links'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.shared),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Memories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.memories),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Places'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.map),
            ),
          ]),
          _Section(title: 'Storage', children: [
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.archive),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Trash'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.trash),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Favorites'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.favorites),
            ),
          ]),
          _Section(title: 'Account', children: [
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Server storage'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStorage(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Server version'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showServerInfo(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => _signOut(context, ref),
            ),
          ]),
          _Section(title: 'About', children: [
            ListTile(
              leading: const Icon(Icons.app_settings_alt_outlined),
              title: const Text('Version'),
              subtitle: Text(
                info.when(
                  data: (i) => '${i.version} (${i.buildNumber})',
                  loading: () => '—',
                  error: (_, __) => '—',
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showStorage(BuildContext context, WidgetRef ref) async {
    final info = await ref.read(userRepositoryProvider).storage();
    if (!context.mounted) return;
    showMessage(
      context,
      'Used ${info.diskUse ?? '—'} of ${info.diskSize ?? '—'}'
      ' (${info.diskAvailable ?? '—'} free)',
    );
  }

  Future<void> _showServerInfo(BuildContext context, WidgetRef ref) async {
    final v = await ref.read(userRepositoryProvider).version();
    if (!context.mounted) return;
    showMessage(
      context,
      'Server v${v.major ?? 0}.${v.minor ?? 0}.${v.patch ?? 0}'
      '${v.prerelease != null ? '-${v.prerelease}' : ''}',
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await BackgroundService.clearSession();
    await ref.read(sessionProvider.notifier).logout();
    if (context.mounted) context.go(AppRoutes.login);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
          const Divider(height: 1),
        ],
      ),
    );
  }
}
