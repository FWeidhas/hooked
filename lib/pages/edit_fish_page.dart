import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:flutter/material.dart';
import 'package:hooked/models/fish.dart';
import 'package:hooked/database/fish_service.dart';
import 'package:hooked/cloudinary/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final cloudinaryService = CloudinaryService();
final ImagePicker _picker = ImagePicker();
late CloudinaryObject cloudinary;

class EditFishPage extends StatefulWidget {
  EditFishPage({
    required this.docId,
    required this.fish,
    super.key,
  }) {
    cloudinary = CloudinaryObject.fromCloudName(
        cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!);
  }

  final String docId;
  final Fish fish;

  @override
  State<EditFishPage> createState() => _EditFishPageState();
}

class _EditFishPageState extends State<EditFishPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _pictureController;
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
    _nameController = TextEditingController(text: widget.fish.name);
    _pictureController = TextEditingController(text: widget.fish.picture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Fish'),
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
                if (widget.fish.picture != null)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CldImageWidget(
                      cloudinary: cloudinary,
                      publicId: widget.fish.picture!,
                      errorBuilder: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Fish updatedFish = Fish(
                        id: widget.fish.id,
                        name: _nameController.text,
                        picture: _uploadedImageUrl ?? widget.fish.picture,
                      );
                      await updateFish(widget.docId, updatedFish);
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
