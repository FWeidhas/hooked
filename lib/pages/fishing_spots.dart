import 'package:flutter/material.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/pages/add_fishing_spot_page.dart';
import 'package:hooked/pages/edit_fishing_spot_page.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';
import '../database/fishing_spot_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/database/fish_service.dart';

class FishingSpots extends StatelessWidget {
  const FishingSpots({super.key});

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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditFishingSpotPage(
                                      docId: document.id,
                                      fishingSpot: fishingSpot,
                                      fishes: fishes)),
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
