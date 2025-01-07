import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/database/fishing_spot_service.dart';
import 'package:hooked/database/fish_service.dart';
import 'package:hooked/database/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/cloudinary/cloudinary_service.dart';
import 'package:hooked/models/user.dart' as models;
import 'package:hooked/pages/fishing_spot_weather_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

final cloudinaryService = CloudinaryService();
final ImagePicker _picker = ImagePicker();
late CloudinaryObject cloudinary;
final FirebaseAuth _auth = FirebaseAuth.instance;

class EditFishingSpotPage extends StatefulWidget {
  EditFishingSpotPage({
    required this.docId,
    required this.fishingSpot,
    super.key,
    this.fishes,
    required this.user,
  }) {
    cloudinary = CloudinaryObject.fromCloudName(
        cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!);
  }

  final String docId;
  final FishingSpot fishingSpot;
  final List<Fish>? fishes;
  final models.User user;

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
  String? _uploadedImageUrl;

  Future<void> _selectAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageUrl = await cloudinaryService.uploadImage(image.path);
      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
          _pictureController.text = imageUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image.')),
        );
      }
    }
  }

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

    _creatorController = TextEditingController(text: widget.user.email);

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
                  readOnly: true,
                ),
                ElevatedButton(
                  onPressed: _selectAndUploadImage,
                  child: const Text('Select and Upload Image'),
                ),
                if (widget.fishingSpot.picture != null)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CldImageWidget(
                      cloudinary: cloudinary,
                      publicId: widget.fishingSpot.picture!,
                      errorBuilder: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                // Check Weather button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FishingSpotWeatherScreen(
                          latitude: widget.fishingSpot.latitude!,
                          longitude: widget.fishingSpot.longitude!,
                          title: widget.fishingSpot.title!,
                        ),
                      ),
                    );
                  },
                  child: const Text('Check 7 Day Weather'),
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
                if (widget.fishes != null && widget.fishes!.isNotEmpty)
                  Column(
                    children: widget.fishes!.map((fish) {
                      return Column(
                        children: [
                          Text(fish.name ?? 'Unknown Fish'),
                          if (fish.picture != null)
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CldImageWidget(
                                cloudinary: cloudinary,
                                publicId: fish.picture!,
                                errorBuilder: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Check if the logged-in user's email matches the creator's email
                      if (_auth.currentUser?.email != widget.user.email) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'You do not have permission to edit this fishing spot.')),
                        );
                        return;
                      }

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

                      double? latitude =
                          double.tryParse(_latitudeController.text);
                      double? longitude =
                          double.tryParse(_longitudeController.text);

                      if (latitude == null || longitude == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please enter valid latitude and longitude.')),
                        );
                        return;
                      }

                      FishingSpot updatedSpot = FishingSpot(
                        id: widget.fishingSpot.id,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        picture:
                            _uploadedImageUrl ?? widget.fishingSpot.picture,
                        latitude: latitude,
                        longitude: longitude,
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
