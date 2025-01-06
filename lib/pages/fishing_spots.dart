import 'package:flutter/material.dart';
import 'package:hooked/database/user_service.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/models/user.dart';
import 'package:hooked/pages/add_fishing_spot_page.dart';
import 'package:hooked/pages/edit_fishing_spot_page.dart';
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
              builder: (context) => const AddFishingSpotPage(),
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
            return const CircularProgressIndicator();
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
                child: ListTile(
                  leading: fishingSpot.picture != null
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: CldImageWidget(
                            cloudinary: cloudinary,
                            publicId: fishingSpot.picture!,
                          ),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(data['title'] ?? 'No title'),
                  subtitle: Text(data['description'] ?? 'No description'),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
