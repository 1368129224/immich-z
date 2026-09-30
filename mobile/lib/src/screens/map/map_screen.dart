import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/generated/models.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/repository_providers.dart';

/// Map view of every geotagged asset, plus a bottom sheet of the photos near
/// the tapped marker.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _favoriteOnly = false;
  bool _includeArchived = false;

  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(
      _mapMarkersProvider((_favoriteOnly, _includeArchived)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
        actions: [
          IconButton(
            icon: Icon(
              _favoriteOnly ? Icons.favorite : Icons.favorite_border,
            ),
            tooltip: 'Favorites only',
            onPressed: () => setState(() => _favoriteOnly = !_favoriteOnly),
          ),
          IconButton(
            icon: Icon(
              _includeArchived ? Icons.inventory_2 : Icons.inventory_2_outlined,
            ),
            tooltip: 'Include archived',
            onPressed: () => setState(() => _includeArchived = !_includeArchived),
          ),
        ],
      ),
      body: markers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (points) {
          if (points.isEmpty) {
            return const Center(child: Text('No photos with a location'));
          }
          final geocoded = points
              .where((p) => p.lat != null && p.lon != null)
              .toList(growable: false);
          if (geocoded.isEmpty) {
            return const Center(child: Text('No photos with a location'));
          }
          final center = geocoded.first;
          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(center.lat!, center.lon!),
              initialZoom: 4,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.immichz.immich_z',
              ),
              MarkerLayer(
                markers: [
                  for (final p in geocoded)
                    Marker(
                      point: LatLng(p.lat!, p.lon!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showLocation(context, p),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLocation(BuildContext context, MapMarkerResponseDto marker) {
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
              Text(
                marker.city ?? 'Unknown place',
                style: Theme.of(c).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(marker.country ?? ''),
              const SizedBox(height: 16),
              Text(
                '${marker.lat ?? 0}, ${marker.lon ?? 0}',
                style: Theme.of(c).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _mapMarkersProvider = FutureProvider.family<
    List<MapMarkerResponseDto>,
    (bool, bool)>((ref, args) async {
  return ref.watch(miscRepositoryProvider).mapMarkers(
        isFavorite: args.$1 ? true : null,
        isArchived: args.$2 ? true : null,
        withPartners: true,
      );
});
