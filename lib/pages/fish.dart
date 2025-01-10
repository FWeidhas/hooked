import 'package:flutter/material.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/pages/add_fish_page.dart';
import 'package:hooked/pages/edit_fish_page.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';
import 'package:hooked/database/fish_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late CloudinaryObject cloudinary;

class FishPage extends StatelessWidget {
  FishPage({super.key}) {
    cloudinary = CloudinaryObject.fromCloudName(
        cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!);
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish'),
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
              builder: (context) => const AddFishPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAllFishes(),
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
              Fish fish = Fish.fromMap(data, document.id);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: fish.picture != null
                      ? Container(
                          width: 50,
                          height: 50,
                          child: CldImageWidget(
                            cloudinary: cloudinary,
                            publicId: fish.picture!,
                            fit: BoxFit.fill,
                          ),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(data['name'] ?? 'No name'),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditFishPage(
                                      docId: document.id, fish: fish)),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            try {
                              await deleteFish(document.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Fish deleted successfully.')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
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
