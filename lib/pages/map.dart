import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:hooked/controller/themecontroller.dart';
import 'package:hooked/pages/fishing_spot_weather_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';
import 'package:hooked/models/fishingSpot.dart';
import '../database/fishing_spot_service.dart';
import '../models/fish.dart';
import '../database/fish_service.dart';

class FishingMap extends StatefulWidget {
  const FishingMap({super.key});

  @override
  State<FishingMap> createState() => _FishingMapState();
}

class _FishingMapState extends State<FishingMap> {
  LatLng? userLocation;
  List<Marker> fishingSpotsMarkers = [];
  List<FishingSpot> fishingSpots = [];
  List<LatLng> routeCoordinates = [];

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

  Future<void> _calculateRoute(FishingSpot spot) async {
    if (userLocation == null) {
      _showToast("User location not available.");
      return;
    }

    final start = '${userLocation!.longitude},${userLocation!.latitude}';
    final end = '${spot.longitude},${spot.latitude}';
    final osrmUrl =
        'https://router.project-osrm.org/route/v1/driving/$start;$end?overview=full';

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry'];
        // Decode polyline using flutter_polyline_points
        final PolylinePoints polylinePoints = PolylinePoints();
        final List<PointLatLng> decodedPoints =
            polylinePoints.decodePolyline(geometry);
        setState(() {
          routeCoordinates = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        });
      } else {
        _showToast("Failed to fetch route. Try again.");
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
      _showToast("Error calculating route.");
    }
  }

  void _showFishingSpotDetails(FishingSpot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          snap: true,
          snapSizes: const [0.3, 0.5, 0.8],
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Drag handle
                  Center(
                    child: Obx(() {
                      final isDarkTheme =
                          Get.find<ThemeController>().themeMode ==
                              ThemeMode.dark;
                      return Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkTheme ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  // Image section
                  Container(
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 16),
                    alignment: Alignment.center,
                    child: spot.picture != null
                        ? Image.network(
                            spot.picture!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                  // Title
                  Text(
                    spot.title ?? 'No Title',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    spot.description ?? 'No Description',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // Fish List Section
                  Text(
                    'Fish you can catch here:',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Fish List using service
                  FutureBuilder<List<Fish>>(
                    future: getFishesForSpot(spot),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error loading fish data',
                              style: TextStyle(color: Colors.red[400]),
                            ),
                          ),
                        );
                      }

                      final fishes = snapshot.data ?? [];
                      if (fishes.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No fish available at this spot'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fishes.length,
                        itemBuilder: (context, index) {
                          final fish = fishes[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: fish.picture != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          fish.picture!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.phishing,
                                              size: 30,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.phishing,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                              ),
                              title: Text(
                                fish.name ?? 'Unnamed Fish',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _calculateRouteAndShowInstructions(spot);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(
                      "Calculate Route",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FishingSpotWeatherScreen(
                            latitude: spot.latitude!,
                            longitude: spot.longitude!,
                            title: spot.title!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                    child: Text(
                      'Check 7 Day Weather',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _calculateRouteAndShowInstructions(FishingSpot spot) async {
    if (userLocation == null) {
      _showToast("User location not available.");
      return;
    }

    final start = '${userLocation!.longitude},${userLocation!.latitude}';
    final end = '${spot.longitude},${spot.latitude}';
    final osrmUrl =
        'https://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&steps=true';

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final geometry = route['geometry'];
        final steps = route['legs'][0]['steps'] as List;

        final PolylinePoints polylinePoints = PolylinePoints();
        final List<PointLatLng> decodedPoints =
            polylinePoints.decodePolyline(geometry);
        setState(() {
          routeCoordinates = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        });

        // Extract instructions from the steps
        final instructions = steps.map((step) {
          final distance = step['distance'];
          final roadName = step['name'] ?? "";
          final instruction = step['maneuver']['modifier'] ?? "";

          return {
            'instruction': instruction,
            'distance': distance,
            'road_name': roadName,
          };
        }).toList();

        // Create a controller to handle the bottom sheet state
        final DraggableScrollableController _sheetController =
            DraggableScrollableController();

        // Show the new bottom sheet with instructions
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              snap: true,
              snapSizes: const [0.3, 0.5, 0.8],
              builder:
                  (BuildContext context, ScrollController scrollController) {
                // Listen for changes to the bottom sheet position
                _sheetController.addListener(() {
                  final extent = _sheetController.size;
                  if (extent == 0.3) {
                    setState(() {
                      routeCoordinates = [];
                    });
                  }
                });

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Drag handle
                      Center(
                        child: Obx(() {
                          final isDarkTheme =
                              Get.find<ThemeController>().themeMode ==
                                  ThemeMode.dark;
                          return Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isDarkTheme ? Colors.white : Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      // Title
                      Text(
                        "Route Instructions",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Display the route instructions with icons
                      ...instructions.map((step) {
                        // Determine the icon based on the instruction
                        IconData icon;
                        switch (step['instruction']) {
                          case 'right':
                            icon = Icons.turn_right_outlined;
                            break;
                          case 'left':
                            icon = Icons.turn_left_outlined;
                            break;
                          case 'straight':
                          default:
                            icon = Icons.straight_outlined;
                            break;
                        }
                        // Format distance for meters/kilometers
                        String formattedDistance;
                        if (step['distance'] > 1000) {
                          formattedDistance =
                              "${(step['distance'] / 1000).toStringAsFixed(1)} km";
                        } else {
                          formattedDistance =
                              "${step['distance'].toStringAsFixed(0)} m";
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(icon),
                            title: Text("Distance: $formattedDistance"),
                            subtitle: Text(step['road_name']),
                          ),
                        );
                      }),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              routeCoordinates = [];
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                          ),
                          child: Text(
                            "Cancel route",
                            style: Theme.of(context).textTheme.labelMedium,
                          )),
                    ],
                  ),
                );
              },
            );
          },
        );
      } else {
        _showToast("Failed to fetch route instructions.");
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
      _showToast("Error calculating route.");
    }
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
                  fishingSpots = snapshot.data!.docs.map((doc) {
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
                      child: GestureDetector(
                        onTap: () {
                          _showFishingSpotDetails(spot);
                        },
                        child: const Icon(
                          Icons.location_pin,
                          color: Color.fromARGB(255, 192, 41, 41),
                          size: 40,
                        ),
                      ),
                    );
                  }).toList();
                }

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: userLocation!,
                    initialZoom: 10.0,
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
                    if (routeCoordinates.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routeCoordinates,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
    );
  }
}
