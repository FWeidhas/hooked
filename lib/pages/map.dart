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

  // void _showFishingSpotDetails(FishingSpot spot) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (BuildContext context) {
  //       return DraggableScrollableSheet(
  //         initialChildSize: 0.5, // 50% of screen height
  //         minChildSize: 0.3, // 30% of screen height
  //         maxChildSize: 0.8, // 80% of screen height
  //         snap: true, // Enable snapping
  //         snapSizes: const [0.3, 0.5, 0.8], // Define snap points
  //         builder: (BuildContext context, ScrollController scrollController) {
  //           return Container(
  //             decoration: const BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //             ),
  //             child: ListView(
  //               controller: scrollController,
  //               padding: const EdgeInsets.all(16),
  //               children: [
  //                 // Drag handle
  //                 Center(
  //                   child: Container(
  //                     width: 40,
  //                     height: 4,
  //                     margin: const EdgeInsets.symmetric(vertical: 8),
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[300],
  //                       borderRadius: BorderRadius.circular(2),
  //                     ),
  //                   ),
  //                 ),
  //                 // Image section
  //                 Container(
  //                   height: 150,
  //                   margin: const EdgeInsets.only(bottom: 16),
  //                   alignment: Alignment.center,
  //                   child: spot.picture != null
  //                       ? Image.network(
  //                           spot.picture!,
  //                           fit: BoxFit.cover,
  //                         )
  //                       : const Icon(
  //                           Icons.image_not_supported,
  //                           size: 50,
  //                           color: Colors.grey,
  //                         ),
  //                 ),
  //                 // Title
  //                 Text(
  //                   spot.title ?? 'No Title',
  //                   style: Theme.of(context)
  //                       .textTheme
  //                       .headlineMedium
  //                       ?.copyWith(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 // Description
  //                 Text(
  //                   spot.description ?? 'No Description',
  //                   style: Theme.of(context).textTheme.bodyLarge,
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
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
                    'Fish You Can Catch Here',
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
                ],
              ),
            );
          },
        );
      },
    );
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
