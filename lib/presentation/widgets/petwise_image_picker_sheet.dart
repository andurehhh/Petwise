import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // Added
import 'package:petwise/services/cloudinary_service.dart';

class PetwiseImagePickerSheet extends StatefulWidget {
  final String currentImageUrl;
  final ValueChanged<String> onImageSelected;

  const PetwiseImagePickerSheet({
    super.key,
    required this.currentImageUrl,
    required this.onImageSelected,
  });

  @override
  State<PetwiseImagePickerSheet> createState() =>
      _PetwiseImagePickerSheetState();
}

class _PetwiseImagePickerSheetState extends State<PetwiseImagePickerSheet> {
  final List<Map<String, String>> _presets = [
    {
      'name': 'Happy Dog',
      'url':
          'https://cdn.pixabay.com/photo/2023/08/18/15/02/dog-8198719_1280.jpg',
    },
    {
      'name': 'Fluffy Cat',
      'url':
          'https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492_1280.jpg',
    },
    {
      'name': 'Cute Bunny',
      'url':
          'https://cdn.pixabay.com/photo/2016/12/04/21/58/rabbit-1882699_1280.jpg',
    },
  ];

  Future<void> _handleGalleryUpload() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    // --- ZOOM AND CROP LOGIC ---
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Zoom & Crop',
          toolbarColor: const Color(0xFFF7A433),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Zoom & Crop'),
      ],
    );

    if (croppedFile == null) return; // User cancelled

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Upload the cropped file path
      final String? uploadedUrl = await CloudinaryService().uploadImage(
        File(croppedFile.path),
      );

      if (mounted) Navigator.pop(context);

      if (uploadedUrl != null) {
        widget.onImageSelected(uploadedUrl);
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload failed. Check your connection."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Select a preset:",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presets.map((preset) {
                final isSelected = widget.currentImageUrl == preset['url'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onImageSelected(preset['url']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFF4E6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF7A433)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          ClipOval(
                            child: Image.network(
                              preset['url']!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preset['name']!,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              "Or add a personal photo:",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _handleGalleryUpload,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text(
                  "Upload & Crop",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7A433),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
