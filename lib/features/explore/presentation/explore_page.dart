import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/record.dart';
import '../../location/location_service.dart';
import '../providers/map_records_provider.dart';
import '../widgets/map_record_card.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  static const _taiwanCenter = LatLng(23.7, 121.0);

  final _mapController = MapController();
  final _locationService = LocationService();
  String? _bbox;
  Record? _selected;
  Timer? _bboxDebounce;

  @override
  void dispose() {
    _bboxDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  String _bboxFromCamera() {
    final bounds = _mapController.camera.visibleBounds;
    final west = bounds.west;
    final south = bounds.south;
    final east = bounds.east;
    final north = bounds.north;
    return '$west,$south,$east,$north';
  }

  void _scheduleBboxRefresh() {
    _bboxDebounce?.cancel();
    _bboxDebounce = Timer(const Duration(milliseconds: 400), () {
      final next = _bboxFromCamera();
      if (next != _bbox && mounted) {
        setState(() => _bbox = next);
      }
    });
  }

  Future<void> _goToMyLocation() async {
    final coords = await _locationService.getCurrentPosition();
    if (!mounted) return;
    if (coords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法取得定位，請確認權限與 GPS 已開啟')),
      );
      return;
    }
    final point = LatLng(coords.latitude, coords.longitude);
    _mapController.move(point, 14);
    _scheduleBboxRefresh();
  }

  void _onMarkerTap(Record record) {
    setState(() => _selected = record);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapAsync = ref.watch(mapRecordsProvider(_bbox));

    final markers = mapAsync.when(
      data: (response) => response.items
          .where((r) => r.hasLocation)
          .map((record) {
        final point = LatLng(record.latitude!, record.longitude!);
        final isSelected = _selected?.id == record.id;
        return Marker(
          point: point,
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => _onMarkerTap(record),
            child: Icon(
              Icons.location_on,
              size: isSelected ? 44 : 36,
              color: isSelected ? AppColors.secondary : AppColors.primary,
            ),
          ),
        );
      }).toList(),
      loading: () => <Marker>[],
      error: (e, st) => <Marker>[],
    );

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _taiwanCenter,
              initialZoom: 7.2,
              minZoom: 5,
              maxZoom: 16,
              onMapReady: () {
                setState(() => _bbox = _bboxFromCamera());
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) _scheduleBboxRefresh();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cip.langapp.cip_lang_app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('地圖', style: theme.textTheme.titleMedium),
                                mapAsync.when(
                                  data: (r) => Text(
                                    '${r.total} 個採集點',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  loading: () => Text(
                                    '載入中…',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  error: (e, _) => Text(
                                    '載入失敗',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: '重新整理',
                            onPressed: () =>
                                ref.invalidate(mapRecordsProvider(_bbox)),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selected != null ? 200 : 100,
            child: FloatingActionButton.small(
              heroTag: 'map_my_location',
              onPressed: _goToMyLocation,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_selected != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapRecordCard(
                record: _selected!,
                onClose: () => setState(() => _selected = null),
              ),
            ),
        ],
      ),
    );
  }
}
