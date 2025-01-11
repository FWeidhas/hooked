import 'package:flutter/material.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/database/fishing_spot_service.dart';
import 'package:hooked/database/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooked/cloudinary/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firestore = FirebaseFirestore.instance;
final cloudinaryService = CloudinaryService();
final ImagePicker _picker = ImagePicker();
late CloudinaryObject cloudinary;
final FirebaseAuth _auth = FirebaseAuth.instance;

class AddFishingSpotPage extends StatefulWidget {
  AddFishingSpotPage({super.key}) {
    cloudinary = CloudinaryObject.fromCloudName(
        cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!);
  }

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
  String? _uploadedImageUrl;

  List<Fish> _availableFishes = [];
  Fish? _selectedFish;
  List<Fish> _selectedFishes = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableFishes();
  }

  Future<void> _loadAvailableFishes() async {
    final snapshot = await FirebaseFirestore.instance.collection('Fish').get();
    final allFishes =
        snapshot.docs.map((doc) => Fish.fromMap(doc.data(), doc.id)).toList();

    setState(() {
      _availableFishes = allFishes;
    });
  }

  void _addSelectedFish() {
    if (_selectedFish != null && !_selectedFishes.contains(_selectedFish)) {
      setState(() {
        _selectedFishes.add(_selectedFish!);
        _availableFishes.remove(_selectedFish);
        _selectedFish = null;
      });
    }
  }

  void _removeFish(Fish fish) {
    setState(() {
      _selectedFishes.remove(fish);
      _availableFishes.add(fish);
    });
  }

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
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fishing Spot'),
        backgroundColor: primaryColor,
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectAndUploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  child: Text(
                    'Select and Upload Image',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 16),
                if (_uploadedImageUrl != null)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CldImageWidget(
                      cloudinary: cloudinary,
                      publicId: _uploadedImageUrl!,
                      errorBuilder: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter latitude';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter longitude';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _creatorController
                    ..text = _auth.currentUser?.email! ?? '',
                  decoration: const InputDecoration(labelText: 'Creator Email'),
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter creator email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Fish>(
                        value: _selectedFish,
                        hint: const Text('Select a fish to add'),
                        items: _availableFishes.map((Fish fish) {
                          return DropdownMenuItem<Fish>(
                            value: fish,
                            child: Text(fish.name ?? 'Unknown Fish'),
                          );
                        }).toList(),
                        onChanged: (Fish? newValue) {
                          setState(() {
                            _selectedFish = newValue;
                          });
                        },
                        validator: (value) {
                          if (_selectedFishes.isEmpty) {
                            return 'Please select at least one fish';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addSelectedFish,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedFishes.isNotEmpty)
                  const Text('Selected Fishes:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  children: _selectedFishes.map((fish) {
                    return Card(
                      child: ListTile(
                        title: Text(fish.name ?? 'Unknown Fish'),
                        leading: fish.picture != null
                            ? SizedBox(
                                width: 50,
                                height: 50,
                                child: CldImageWidget(
                                  cloudinary: cloudinary,
                                  publicId: fish.picture!,
                                  errorBuilder: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _removeFish(fish),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedFishes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select at least one fish.')),
                        );
                        return;
                      }

                      List<DocumentReference> fishRefs = _selectedFishes
                          .map((fish) => FirebaseFirestore.instance
                              .collection('Fish')
                              .doc(fish.id))
                          .toList();

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

                      FishingSpot newSpot = FishingSpot(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        picture: _uploadedImageUrl,
                        latitude: latitude,
                        longitude: longitude,
                        creator: userRef,
                        fishes: fishRefs,
                      );
                      await addFishingSpot(newSpot);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    'Save',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
