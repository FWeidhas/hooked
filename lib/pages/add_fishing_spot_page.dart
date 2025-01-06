import 'package:flutter/material.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/database/fishing_spot_service.dart';
import 'package:hooked/database/fish_service.dart';
import 'package:hooked/database/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/cloudinary/cloudinary_service.dart';

final firestore = FirebaseFirestore.instance;
final cloudinaryServvice = CloudinaryService();

class AddFishingSpotPage extends StatefulWidget {
  const AddFishingSpotPage({super.key});

  @override
  State<AddFishingSpotPage> createState() => _AddFishingSpotPageState();
}

class _AddFishingSpotPageState extends State<AddFishingSpotPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pictureController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _creatorController = TextEditingController();
  final _fishesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fishing Spot'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _pictureController,
                  decoration: const InputDecoration(labelText: 'Picture URL'),
                ),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _creatorController,
                  decoration:
                      const InputDecoration(labelText: 'Email from creator'),
                ),
                TextFormField(
                  controller: _fishesController,
                  decoration: const InputDecoration(
                      labelText: 'Fishes (comma separated)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      List<String> fishNames = _fishesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList();
                      List<DocumentReference> fishRefs = [];

                      bool validFishs = true;
                      for (String fishName in fishNames) {
                        DocumentReference? fishRef =
                            await getFishByName(fishName);
                        if (fishRef == null) {
                          validFishs = false;
                          break;
                        } else {
                          fishRefs.add(fishRef);
                        }
                      }

                      if (fishRefs.isEmpty || !validFishs) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter valid fishs.')),
                        );
                        return;
                      }

                      DocumentReference? userRef =
                          await getUserByEmail(_creatorController.text);

                      if (userRef == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Creator not found. Please enter a valid email.')),
                        );
                        return;
                      }

                      FishingSpot newSpot = FishingSpot(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        picture: _pictureController.text,
                        latitude: double.tryParse(_latitudeController.text),
                        longitude: double.tryParse(_longitudeController.text),
                        creator: userRef,
                        fishes: fishRefs,
                      );
                      addFishingSpot(newSpot);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
