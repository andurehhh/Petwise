import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../utils/app_config.dart';
import 'storage/media_validator.dart';
import 'storage/storage_destination.dart';

class CloudinaryService {
  static const String uploadPreset = AppConfig.cloudinaryUploadPreset;

  /// Uploads an image to Cloudinary within a structured directory folder and validates file constraints.
  ///
  /// [destination]: Specifies the target folder path (e.g. petwise/prod/pets/{id}/profile).
  /// [maxSizeBytes]: Overrides default size caps if specified.
  Future<String?> uploadImage(
    File imageFile, {
    StorageDestination? destination,
    int? maxSizeBytes,
  }) async {
    // 1. Pre-upload security and size validation
    final int effectiveLimit = maxSizeBytes ??
        (destination?.category == MediaCategory.userAvatar
            ? MediaValidator.maxAvatarBytes
            : MediaValidator.maxImageBytes);

    final validation = MediaValidator.validateImage(
      imageFile,
      maxBytes: effectiveLimit,
    );

    if (!validation.isValid) {
      debugPrint('DEBUG: MediaValidator rejected upload: ${validation.errorMessage}');
      throw Exception(validation.errorMessage);
    }

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload',
      );

      // 2. Prepare multipart request
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // 3. Attach directory folder structure if provided
      if (destination != null) {
        request.fields['folder'] = destination.folderPath;
        debugPrint('DEBUG: Target Cloudinary directory: ${destination.folderPath}');
      }

      debugPrint('DEBUG: Uploading file: ${imageFile.path}');

      // 4. Send with timeout
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
      rethrow;
    }
  }
}
