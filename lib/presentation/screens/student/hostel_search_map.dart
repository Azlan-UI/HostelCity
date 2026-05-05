import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/loading_indicator.dart';

class HostelSearchMap extends ConsumerStatefulWidget {
  const HostelSearchMap({super.key});

  @override
  ConsumerState<HostelSearchMap> createState() => _HostelSearchMapState();
}

class _HostelSearchMapState extends ConsumerState<HostelSearchMap> {
  final MapController _mapController = MapController();

  Future<void> _goToMyLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostelsAsync = ref.watch(filteredHostelsProvider);
    final hostels = hostelsAsync.valueOrNull ?? [];

    ref.listen(filteredHostelsProvider, (_, next) {
      final list = next.valueOrNull ?? [];
      if (list.isNotEmpty) {
        _mapController.move(list.first.coordinates, AppConstants.markerZoom);
      }
    });

    if (hostels.isEmpty) {
      return Center(
        child: Text('No hostels to show',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Stack(
      children: [
        // ── Dark map ─────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: hostels.first.coordinates,
            initialZoom: hostels.isNotEmpty ? AppConstants.defaultZoom : 5.0,
            minZoom: 2,
            maxZoom: 18,
          ),
          children: [
            // CartoDB Dark Matter — free, no key required
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.hostelmanagement',
            ),

            // Price-tag markers
            MarkerLayer(
              markers: hostels.map((hostel) {
                final price = _formatPrice(hostel.minRent);
                return Marker(
                  point: hostel.coordinates,
                  width: 90,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => _showHostelSheet(hostel.hostelId),
                    child: _PriceMarker(price: price),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // ── Map controls ─────────────────────────────────────────────────
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _MapFab(
                heroTag: 'my_loc',
                icon: Icons.my_location_rounded,
                onTap: _goToMyLocation,
              ),
              const SizedBox(height: 8),
              _MapFab(
                heroTag: 'zoom_in',
                icon: Icons.add_rounded,
                onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1),
              ),
              const SizedBox(height: 8),
              _MapFab(
                heroTag: 'zoom_out',
                icon: Icons.remove_rounded,
                onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return 'Rs. ${(price / 1000).toStringAsFixed(0)}k';
    }
    return 'Rs. ${price.toInt()}';
  }

  void _showHostelSheet(String hostelId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HostelMapSheet(hostelId: hostelId),
    );
  }
}

// ─── Price-tag marker ─────────────────────────────────────────────────────────
class _PriceMarker extends StatelessWidget {
  final String price;
  const _PriceMarker({required this.price});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label pill
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ),
        // Pointer triangle
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePainter(
            color: Colors.black.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ─── Map FAB ──────────────────────────────────────────────────────────────────
class _MapFab extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final VoidCallback onTap;
  const _MapFab({required this.heroTag, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─── Hostel bottom sheet ──────────────────────────────────────────────────────
class _HostelMapSheet extends ConsumerWidget {
  final String hostelId;
  const _HostelMapSheet({required this.hostelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
          ),
          Consumer(builder: (ctx, ref, _) {
            final hostelAsync = ref.watch(hostelByIdProvider(hostelId));
            return hostelAsync.when(
              loading: () => const LoadingIndicator(),
              error: (_, __) =>
                  Text('Error', style: TextStyle(color: AppColors.textSecondary)),
              data: (hostel) {
                if (hostel == null) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hostel.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('${hostel.area}, ${hostel.city}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Rs. ${hostel.minRent.toInt()} – ${hostel.maxRent.toInt()}/mo',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(ctx, AppRouter.hostelDetail,
                              arguments: hostelId);
                        },
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
