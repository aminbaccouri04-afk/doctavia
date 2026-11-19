import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../../core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/providers/provider-discovery.dart';
import 'package:doctavia/core/models/model-doctor.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/features/search/widgets/widget-search-map-card.dart';
import 'package:doctavia/core/theme/theme.dart';

class ScreenSearchMap extends StatefulWidget {
  const ScreenSearchMap({super.key});

  @override
  State<ScreenSearchMap> createState() => _ScreenSearchMapState();
}

class _ScreenSearchMapState extends State<ScreenSearchMap> {
  DoctorModel? _selected;
  LatLng? _userLocation;
  bool _isLocating = true;
  String _selectedSpecialty = 'All';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initLocationAndData();
  }

  Future<void> _initLocationAndData() async {
    try {
      var status = await ph.Permission.location.status;
      if (status.isDenied) {
        status = await ph.Permission.location.request();
      }

      if (status.isPermanentlyDenied) {
        ph.openAppSettings();
        throw 'Permissions permanently denied';
      }

      if (!status.isGranted) throw 'Permissions not granted';

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLocating = false;
        });
        if (_mapController.camera.zoom != 0) {
          _mapController.move(_userLocation!, 14);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userLocation ??= const LatLng(36.7538, 3.0588); 
          _isLocating = false;
        });
      }
    }

    if (mounted) {
      final p = context.read<DiscoveryProvider>();
      if (p.searchResults.isEmpty) p.searchDoctors();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoveryProvider>();
    final doctors = _selectedSpecialty == 'All'
        ? provider.searchResults
        : provider.searchResults.where((d) => d.specialties.any(
            (s) => s.toLowerCase() == _selectedSpecialty.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('search.map.doctorsNearYou')),
        actions: [
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.list_alt),
            label: Text(AppContent.get('search.screen.listView')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initLocationAndData,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.my_location),
      ),
      body: _isLocating
          ? const Center(child: ChartShimmer())
          : Stack(
              children: [
                _MapBackground(
                  doctors: doctors,
                  userLocation: _userLocation!,
                  mapController: _mapController,
                  onSelected: (d) => setState(() => _selected = d),
                ),

                if (_selected != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: WidgetSearchMapCard(
                      doctor: _selected!,
                      onClose: () => setState(() => _selected = null),
                    ),
                  ),

                Positioned(
                  top: AppSpacing.md,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // ─── Specialty Filter ────────────────────────
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          children: [
                            'All', 'General', 'Cardiology', 'Neurology', 'Pediatrics',
                          ].map((s) {
                            return _FilterChip(
                              label: AppContent.translateSpecialty(s),
                              isActive: _selectedSpecialty == s,
                               onTap: () => setState(() => _selectedSpecialty = s),
                              );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, 
          vertical: 6
        ),
        decoration: BoxDecoration(
          color: isActive 
            ? theme.colorScheme.primary 
            : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// A real map implementation using FlutterMap and OpenStreetMap.
class _MapBackground extends StatelessWidget {
  final List<DoctorModel> doctors;
  final LatLng userLocation;
  final MapController mapController;
  final void Function(DoctorModel) onSelected;

  const _MapBackground({
    required this.doctors,
    required this.userLocation,
    required this.mapController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final processedDoctors = doctors.map((doc) {
      final hasCoords = doc.latitude != null && 
                       doc.longitude != null && 
                       doc.latitude != 0.0 && 
                       doc.longitude != 0.0;
                       
      if (hasCoords) return doc;
      
      final double seed = doc.id.hashCode.toDouble();
      final double latOffset = (seed % 200 - 100) / 4000; 
      final double lngOffset = ((seed * 1.7).toInt() % 200 - 100) / 4000;
      
      return doc.copyWith(
        latitude: 36.7538 + latOffset,
        longitude: 3.0588 + lngOffset,
      );
    }).toList();

    // Generate markers for doctors
    final markers = processedDoctors.map((doc) {
      final point = LatLng(
        doc.latitude!, 
        doc.longitude!
      );

      return Marker(
        point: point,
        width: 80,
        height: 80,
        rotate: true,
        child: GestureDetector(
          onTap: () => onSelected(doc),
          child: _DoctorPin(doctor: doc),
        ),
      );
    }).toList();

    // Add User "You" marker
    markers.add(
      Marker(
        point: userLocation,
        width: 60,
        height: 60,
        child: Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(8)),
              child: Text(AppContent.get('search.screen.mapYou'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: userLocation,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.doctavia.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

class _DoctorPin extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorPin({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
            border: Border.all(color: theme.colorScheme.primary, width: 2),
          ),
          child: WidgetUserAvatar(
            avatarUrl: doctor.avatarUrl,
            radius: 24,
            fallbackIcon: Icons.medical_services,
          ),
        ),
        // Pointing Tip
        CustomPaint(
          size: const Size(12, 8),
          painter: _TrianglePainter(theme.colorScheme.primary),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


