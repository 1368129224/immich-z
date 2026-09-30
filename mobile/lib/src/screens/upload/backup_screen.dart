import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/repository_providers.dart';
import '../../providers/session_provider.dart';
import '../../services/background_service.dart';
import '../../services/device_media_service.dart';
import '../../services/upload_service.dart';
import '../../utils/format.dart';

/// Backup configuration: which albums to sync, Wi-Fi/charging constraints and
/// the manual "start now" trigger.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(deviceAlbumsProvider);
      ref.read(backupSelectionProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sel = ref.watch(backupSelectionProvider);
    final albums = ref.watch(deviceAlbumsProvider);
    final queue = ref.watch(uploadQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup'),
      ),
      body: ListView(
        children: [
            
            SwitchListTile(
              secondary: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Backup photos'),
              subtitle: const Text('Upload new photos and videos automatically'),
              value: sel.enabled,
              onChanged: (v) async {
                await ref.read(backupSelectionProvider.notifier).setEnabled(v);
                v ? await BackgroundService.enable()
                    : await BackgroundService.disable();
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.wifi),
              title: const Text('Require Wi-Fi'),
              value: sel.requireWifi,
              onChanged: (v) =>
                  ref.read(backupSelectionProvider.notifier).setRequireWifi(v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.battery_charging_full),
              title: const Text('Require charging'),
              value: sel.requireCharging,
              onChanged: (v) => ref
                  .read(backupSelectionProvider.notifier)
                  .setRequireCharging(v),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Albums to back up',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            albums.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ListTile(title: Text('$e')),
              data: (list) => Column(
                children: [
                  for (final a in list)
                    CheckboxListTile(
                      secondary: const Icon(Icons.photo_album_outlined),
                      title: Text(a.name),
                      subtitle: FutureBuilder<int>(
                        future: a.assetCountAsync,
                        builder: (context, snap) =>
                            Text('${snap.data ?? 0} item(s)'),
                      ),
                      value: sel.albumIds.contains(a.id),
                      onChanged: (v) {
                        final ids = [...sel.albumIds];
                        if (v == true) {
                          ids.add(a.id);
                        } else {
                          ids.remove(a.id);
                        }
                        ref.read(backupSelectionProvider.notifier).setAlbums(ids);
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start backup now'),
                    onPressed: queue.isRunning
                        ? null
                        : () async {
                            final controller =
                                ref.read(uploadQueueProvider.notifier);
                            await controller.refresh(sel.albumIds);
                            await controller.start(ref.read(requireClientProvider));
                          },
                  ),
                  const SizedBox(height: 8),
                  if (queue.isRunning) ...[
                    LinearProgressIndicator(
                      value: queue.total == 0
                          ? null
                          : queue.completed / queue.total,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${queue.completed} / ${queue.total} uploaded'
                      '${queue.failed > 0 ? ' • ${queue.failed} failed' : ''}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(uploadQueueProvider.notifier).cancel(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ),
          ],
      ),
    );
  }
}

/// Shows how many items on the device are not yet on the server.
class BackupStatusTile extends ConsumerWidget {
  const BackupStatusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(backupSelectionProvider);
    final media = ref.watch(deviceMediaProvider);
    final s = sel;
    if (!s.enabled) {
          return const ListTile(
            leading: Icon(Icons.cloud_off_outlined),
            title: Text('Backup is off'),
          );
        }
    return FutureBuilder<int>(
      future: _pendingCount(media, s.albumIds),
      builder: (context, snap) => ListTile(
        leading: const Icon(Icons.cloud_queue_outlined),
        title: Text(snap.hasData ? '${snap.data} item(s) pending' : 'Checking…'),
        subtitle: const Text('Backup enabled'),
      ),
    );
  }

  Future<int> _pendingCount(DeviceMediaService media, List<String> ids) async {
    if (ids.isEmpty) return 0;
    final service = UploadService(media);
    final queue = await service.buildQueue(ids);
    return queue.length;
  }
}
