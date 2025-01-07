import 'package:flutter/material.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/database/fish_service.dart';
import 'package:hooked/cloudinary/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

final cloudinaryService = CloudinaryService();
final ImagePicker _picker = ImagePicker();

class AddFishPage extends StatefulWidget {
  const AddFishPage({super.key});

  @override
  State<AddFishPage> createState() => _AddFishPageState();
}

class _AddFishPageState extends State<AddFishPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pictureController = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fish'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
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
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Fish newFish = Fish(
                        name: _nameController.text,
                        picture: _uploadedImageUrl,
                      );
                      await addFish(newFish);
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
