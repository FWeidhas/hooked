import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';
import 'package:hooked/models/fishingSpot.dart';
import '../database/fishing_spot_service.dart';

class FishingMap extends StatefulWidget {
  const FishingMap({super.key});

  @override
  State<FishingMap> createState() => _FishingMapState();
}

class _FishingMapState extends State<FishingMap> {
  LatLng? userLocation;
  List<Marker> fishingSpotsMarkers = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showToast('Location services are disabled. Please enable them.');
        _setFallbackLocation();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showToast('Location permissions are denied.');
          _setFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showToast('Location permissions are permanently denied.');
        _setFallbackLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Error fetching location: $e');
      _showToast(
          'Failed to fetch location. Using fallback location in Regensburg.');
      _setFallbackLocation();
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _setFallbackLocation() {
    setState(() {
      userLocation = const LatLng(49.013432, 12.101624); // Fallback location
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
        backgroundColor: primaryColor,
        actions: const [
          ThemeToggleWidget(),
        ],
      ),
      drawer: const CustomDrawer(),
      body: userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: getAllFishingSpots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.hasData) {
                  // Process the fishing spots data
                  final fishingSpots = snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    return FishingSpot.fromMap(data, doc.id);
                  }).toList();

                  // Create markers for each fishing spot
                  fishingSpotsMarkers = fishingSpots.map((spot) {
                    return Marker(
                      point:
                          LatLng(spot.latitude ?? 0.0, spot.longitude ?? 0.0),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Color.fromARGB(255, 192, 41, 41),
                        size: 40,
                      ),
                    );
                  }).toList();
                }

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: userLocation!,
                    initialZoom: 3.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'de.othr.hooked',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        // User Location Marker
                        Marker(
                          point: userLocation!,
                          width: 40,
                          height: 40,
                          rotate: true,
                          child: const Icon(
                            Icons.navigation,
                            color: Color.fromARGB(255, 26, 152, 255),
                            size: 40,
                          ),
                        ),
                        // All Fishing Spot Markers
                        ...fishingSpotsMarkers,
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
