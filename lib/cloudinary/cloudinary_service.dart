import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static final String apiKey = dotenv.env['CLOUDINARY_API_KEY']!;
  static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET']!;
  static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  static final Uri url =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
  static final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  Future<String?> uploadImage(String filePath) async {
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      final url = jsonMap['url'];
      return url;
    }
    return null;
  }
}
