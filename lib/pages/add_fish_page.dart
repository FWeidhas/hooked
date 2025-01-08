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
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fish'),
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
