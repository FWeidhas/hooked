import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final Uri url =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

  Future<String?> uploadImage(String filePath) async {
// TODO: Implement the uploadImage method
    return null;
  }
}
