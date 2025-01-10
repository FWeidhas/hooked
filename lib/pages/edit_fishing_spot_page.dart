import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/models/fishingSpot.dart';
import 'package:hooked/database/fishing_spot_service.dart';
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
  String? _uploadedImageUrl;
  bool _isCreator = false;

  List<Fish> _availableFishes = [];
  Fish? _selectedFish;
  List<Fish> _selectedFishes = [];

  Future<void> _loadAvailableFishes() async {
    // Get all fishes
    final snapshot = await FirebaseFirestore.instance.collection('Fish').get();
    final allFishes =
        snapshot.docs.map((doc) => Fish.fromMap(doc.data(), doc.id)).toList();

    // Filter out fishes that are already in the fishing spot
    final existingFishIds = widget.fishes?.map((f) => f.id).toSet() ?? {};
    setState(() {
      _availableFishes = allFishes
          .where((fish) => !existingFishIds.contains(fish.id))
          .toList();
      _selectedFishes = widget.fishes?.toList() ?? [];
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
    _isCreator = _auth.currentUser?.email == widget.user.email;
    _loadAvailableFishes();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Fishing Spot'),
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
                  readOnly: !_isCreator,
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
                  readOnly: !_isCreator,
                ),
                TextFormField(
                  controller: _pictureController,
                  decoration: const InputDecoration(labelText: 'Picture URL'),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                if (_isCreator)
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
                if (widget.fishingSpot.picture != null)
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CldImageWidget(
                      cloudinary: cloudinary,
                      publicId: widget.fishingSpot.picture!,
                      errorBuilder: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                const SizedBox(height: 16),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  child: Text(
                    'Check 7 Day Weather',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                  readOnly: !_isCreator,
                ),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                  readOnly: !_isCreator,
                ),
                TextFormField(
                  controller: _creatorController,
                  decoration: const InputDecoration(labelText: 'Creator'),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                if (_isCreator)
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
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addSelectedFish,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
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
                        trailing: _isCreator
                            ? IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _removeFish(fish),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (_isCreator)
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
