import 'package:flutter/material.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/database/fishing_spot_service.dart';
import 'package:hooked/database/fish_service.dart';
import 'package:hooked/database/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/models/user.dart';

class EditFishingSpotPage extends StatefulWidget {
  final String docId;
  final FishingSpot fishingSpot;
  final List<Fish>? fishes;

  const EditFishingSpotPage(
      {required this.docId, required this.fishingSpot, super.key, this.fishes});

  @override
  State<EditFishingSpotPage> createState() => _EditFishingSpotPageState();
}

class _EditFishingSpotPageState extends State<EditFishingSpotPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _pictureController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _creatorController;
  late TextEditingController _fishesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.fishingSpot.title);
    _descriptionController =
        TextEditingController(text: widget.fishingSpot.description);
    _pictureController =
        TextEditingController(text: widget.fishingSpot.picture);
    _latitudeController =
        TextEditingController(text: widget.fishingSpot.latitude?.toString());
    _longitudeController =
        TextEditingController(text: widget.fishingSpot.longitude?.toString());
    print(widget.fishingSpot.creator?.path);
    _creatorController =
        TextEditingController(text: widget.fishingSpot.creator?.path);

    _fishesController = TextEditingController(
      text: widget.fishes?.map((fish) => fish.name).join(', ') ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Fishing Spot'),
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
                  decoration: const InputDecoration(labelText: 'Creator'),
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

                      for (String fishName in fishNames) {
                        DocumentReference? fishRef =
                            await getFishByName(fishName);
                        if (fishRef != null) {
                          fishRefs.add(fishRef);
                        }
                      }

                      DocumentReference? userRef =
                          await getUserByEmail(_creatorController.text);

                      FishingSpot updatedSpot = FishingSpot(
                        id: widget.fishingSpot.id,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        picture: _pictureController.text,
                        latitude: double.tryParse(_latitudeController.text),
                        longitude: double.tryParse(_longitudeController.text),
                        creator: userRef,
                        fishes: fishRefs,
                      );
                      await updateFishingSpot(widget.docId, updatedSpot);
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

extension on Future<User?> {
  get email => null;
}
