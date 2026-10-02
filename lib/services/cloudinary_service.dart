import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../utils/app_config.dart';

class CloudinaryService {
  static const String uploadPreset = AppConfig.cloudinaryUploadPreset;

  Future<String?> uploadImage(File imageFile) async {
    // 1. Verify file exists before even trying to send
    if (!await imageFile.exists()) {
      debugPrint('DEBUG: File does not exist at ${imageFile.path}');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload',
      );

      // 2. Use a client with a dedicated timeout
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      debugPrint('DEBUG: Uploading file: ${imageFile.path}');

      final response = await request.send().timeout(
        const Duration(seconds: 45),
      );

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        final error = await response.stream.bytesToString();
        debugPrint('DEBUG: Cloudinary Error (${response.statusCode}): $error');
        return null;
      }
    } on TimeoutException {
      debugPrint('DEBUG: Upload timed out. Check your firewall.');
      return null;
    } catch (e) {
      debugPrint('DEBUG: Unexpected error: $e');
      return null;
    }
  }
}
