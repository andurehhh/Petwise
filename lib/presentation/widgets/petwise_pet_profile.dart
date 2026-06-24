import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class PetCircle extends StatelessWidget {
  final String imagePath;
  final String petName;
  final String petType;
  final bool isFavorite;

  const PetCircle({
    super.key,
    required this.imagePath,
    required this.petName,
    required this.petType,
    this.isFavorite = false,
  });

  Widget _buildAvatar() {
    final isNetworkUrl =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    final isFilePath = imagePath.startsWith('/');

    if (isNetworkUrl) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: const Color(0xffFFF9F2),
        backgroundImage: NetworkImage(imagePath),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    if (isFilePath) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xffFFF9F2),
          backgroundImage: FileImage(file),
        );
      }
      return _pawFallback();
    }

    return _assetAvatarWithFallback();
  }

  Widget _assetAvatarWithFallback() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: const Color(0xffFFF9F2),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _pawFallback(),
        ),
      ),
    );
  }

  Widget _pawFallback() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: const Color(0xffFFF9F2),
      child: const Icon(Icons.pets, size: 36, color: Color(0xffF4AD44)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFavorite
                      ? Colors.redAccent.withValues(alpha: 0.6)
                      : const Color(0xffD0DAF0),
                  width: 3,
                ),
              ),
              child: _buildAvatar(),
            ),
            if (isFavorite)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          petName,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        Text(
          petType,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.grey.shade600,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
