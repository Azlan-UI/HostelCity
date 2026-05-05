import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';


class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSearching = false;

  // Default to Pakistan (Islamabad)
  static const LatLng _defaultLocation = LatLng(33.6844, 73.0479);

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (widget.initialLocation != null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
          
        Position? position;
        try {
          position = await Geolocator.getLastKnownPosition();
          position ??= await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 5), // Prevents infinite hang on emulators
          );
        } catch (e) {
          // Ignore timeout or missing location errors
        }

        if (mounted && position != null) {
          final currentPos = position; // Local variable for null-safety inside closure
          setState(() {
            _pickedLocation = LatLng(currentPos.latitude, currentPos.longitude);
            _isLoading = false;
          });
          _mapController.move(_pickedLocation!, 15);
        } else {
           if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      // Use OpenStreetMap Nominatim API instead of geolocator which often fails on emulators/certain devices
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'HostelManagementApp/1.0',
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty && mounted) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          
          setState(() {
            _pickedLocation = LatLng(lat, lon);
            _isSearching = false;
          });
          _mapController.move(_pickedLocation!, 15);
        } else {
          throw Exception('Not found');
        }
      } else {
         throw Exception('API failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found or network error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _pickedLocation);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pickedLocation ?? _defaultLocation,
                    initialZoom: _pickedLocation != null ? 15 : 6,
                    onTap: (tapPosition, point) {
                      setState(() => _pickedLocation = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                      userAgentPackageName: 'com.example.hostelmanagement',
                    ),
                    if (_pickedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pickedLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      _pickedLocation == null
                          ? 'Tap on map to pick location'
                          : 'Location selected!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 70, // Below the "selected" status container if it exists
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city in Pakistan...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        suffixIcon: IconButton(
                          icon: _isSearching 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                              : const Icon(Icons.search),
                          onPressed: () => _searchLocation(_searchController.text),
                        ),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 110,
                  child: FloatingActionButton.small(
                    heroTag: 'my_location_picker',
                    onPressed: _getCurrentLocation,
                    backgroundColor: AppColors.surface,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }
}
