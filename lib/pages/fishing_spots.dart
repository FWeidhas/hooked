import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooked/database/user_service.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/models/user.dart';
import 'package:hooked/pages/add_fishing_spot_page.dart';
import 'package:hooked/pages/edit_fishing_spot_page.dart';
import 'package:hooked/pages/fishing_spot_weather_screen.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';
import '../database/fishing_spot_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/database/fish_service.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late CloudinaryObject cloudinary;

class FishingSpots extends StatelessWidget {
  FishingSpots({super.key}) {
    cloudinary = CloudinaryObject.fromCloudName(
        cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!);
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishing Spots'),
        backgroundColor: primaryColor,
        actions: const [
          ThemeToggleWidget(),
        ],
      ),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFishingSpotPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAllFishingSpots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              FishingSpot fishingSpot = FishingSpot.fromMap(data, document.id);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  leading: fishingSpot.picture != null
                      ? Container(
                          width: 50,
                          height: 50,
                          child: CldImageWidget(
                            cloudinary: cloudinary,
                            publicId: fishingSpot.picture!,
                            fit: BoxFit.fill,
                          ),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(fishingSpot.title ?? 'No title'),
                  subtitle: Text(fishingSpot.description ?? 'No description'),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            List<Fish> fishes =
                                await getFishesForSpot(fishingSpot);
                            User? user = await getUserForSpot(fishingSpot);
                            if (user == null) {
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditFishingSpotPage(
                                      docId: document.id,
                                      fishingSpot: fishingSpot,
                                      fishes: fishes,
                                      user: user)),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteFishingSpot(document.id);
                          },
                        ),
                      ],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Image
                          if (fishingSpot.picture != null)
                            Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                child: CldImageWidget(
                                  cloudinary: cloudinary,
                                  publicId: fishingSpot.picture!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Basic Information
                          const Text('Spot Details:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                              'Title: ${fishingSpot.title ?? 'Not specified'}'),
                          Text(
                              'Description: ${fishingSpot.description ?? 'Not specified'}'),
                          const SizedBox(height: 16),

                          // Location Information
                          const Text('Location:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                              'Latitude: ${fishingSpot.latitude?.toStringAsFixed(6) ?? 'Not specified'}'),
                          Text(
                              'Longitude: ${fishingSpot.longitude?.toStringAsFixed(6) ?? 'Not specified'}'),
                          const SizedBox(height: 16),

                          // Weather Button
                          if (fishingSpot.latitude != null &&
                              fishingSpot.longitude != null)
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FishingSpotWeatherScreen(
                                      latitude: fishingSpot.latitude!,
                                      longitude: fishingSpot.longitude!,
                                      title: fishingSpot.title!,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                              ),
                              icon: Icon(
                                FontAwesomeIcons.cloudSun,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              label: Text(
                                'Check 7 Day Weather',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Creator Information
                          const Text('Created by:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          FutureBuilder<User?>(
                            future: getUserForSpot(fishingSpot),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              return Text(snapshot.data?.email ?? 'Unknown');
                            },
                          ),
                          const SizedBox(height: 16),

                          // Fish List
                          const Text('Fish at this Spot:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Fish>>(
                            future: getFishesForSpot(fishingSpot),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text(
                                    'No fish recorded at this spot');
                              }
                              return Column(
                                children: snapshot.data!
                                    .map((fish) => Card(
                                          child: ListTile(
                                            leading: fish.picture != null
                                                ? Container(
                                                    width: 40,
                                                    height: 40,
                                                    child: CldImageWidget(
                                                      cloudinary: cloudinary,
                                                      publicId: fish.picture!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : const Icon(
                                                    FontAwesomeIcons.fish),
                                            title: Text(
                                                fish.name ?? 'Unknown Fish'),
                                          ),
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
