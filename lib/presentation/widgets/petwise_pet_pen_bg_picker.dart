import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/services/pet_pen_background_service.dart';

class PetPenBgPicker extends StatefulWidget {
  const PetPenBgPicker({super.key});

  @override
  State<PetPenBgPicker> createState() => _PetPenBgPickerState();
}

class _PetPenBgPickerState extends State<PetPenBgPicker> {
  String? _previewAsset;
  String? _previewFilePath;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final svc = context.read<PetPenBackgroundService>();
      _previewAsset = svc.currentAsset;
      _previewFilePath = svc.uploadedFilePath;
      _isInitialized = true;
    }
  }

  String _getPreviewLabel() {
    if (_previewFilePath != null) return 'Custom Upload';
    if (_previewAsset == null) return 'Default';
    for (final p in PetPenBackgroundService.presets) {
      if (p.asset == _previewAsset) return p.label;
    }
    return 'Custom';
  }

  Color _getPreviewFallbackColor() {
    if (_previewAsset != null) {
      for (final p in PetPenBackgroundService.presets) {
        if (p.asset == _previewAsset) return p.fallback;
      }
    }
    return const Color(0xFFFFF9E6);
  }

  String _getPetSpritePrefix(String? species) {
    final lower = (species ?? '').toLowerCase();
    if (lower.contains('dog') || lower.contains('puppy')) return 'dog';
    if (lower.contains('cat') || lower.contains('kitten')) return 'cat';
    if (lower.contains('bunny') || lower.contains('rabbit')) return 'bunny';
    return 'generic';
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<PetPenBackgroundService>();
    final pets = context.watch<PetProvider>().pets;
    final firstPet = pets.isNotEmpty ? pets.first : null;
    final spritePrefix = _getPetSpritePrefix(firstPet?.species);

    final isUploadSelected = _previewFilePath != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.wallpaper_rounded,
                    color: Color(0xFFF7A433),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Change Background',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A2D40),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: Colors.grey.shade600,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF7A433),
                    width: 3.5,
                  ),
                  color: _getPreviewFallbackColor(),
                  image: _previewFilePath != null
                      ? DecorationImage(
                          image: FileImage(File(_previewFilePath!)),
                          fit: BoxFit.cover,
                        )
                      : _previewAsset != null
                      ? DecorationImage(
                          image: AssetImage(_previewAsset!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Top Left "Preview" Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Preview',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right Current Selection Label
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7A433),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          _getPreviewLabel(),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 12,
                      left: 30,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/$spritePrefix/idle1.png',
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Image.asset(
                                  'assets/images/generic/idle1.png',
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.pets,
                                    size: 36,
                                    color: Color(0xFFF7A433),
                                  ),
                                ),
                              ),
                              if (firstPet?.imageUrl != null &&
                                  firstPet!.imageUrl!.isNotEmpty)
                                Positioned(
                                  top: 10,
                                  left: 20,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF422521),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child:
                                          firstPet.imageUrl!.startsWith('http')
                                          ? Image.network(
                                              firstPet.imageUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(firstPet.imageUrl!),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (firstPet != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                firstPet.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A2D40),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'PRESETS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF92A1B7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                ),
                itemCount: PetPenBackgroundService.presets.length,
                itemBuilder: (_, i) {
                  final p = PetPenBackgroundService.presets[i];
                  final isSelected =
                      !isUploadSelected && _previewAsset == p.asset;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _previewAsset = p.asset;
                        _previewFilePath = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: p.fallback,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF7A433)
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF7A433,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                        image: p.asset != null
                            ? DecorationImage(
                                image: AssetImage(p.asset!),
                                fit: BoxFit.cover,
                                onError: (_, _) {},
                              )
                            : null,
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.label,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(0xFFF7A433),
                              child: Icon(
                                Icons.check,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        isUploadSelected
                            ? Icons.check_circle
                            : Icons.upload_rounded,
                        size: 18,
                        color: isUploadSelected
                            ? const Color(0xFFF7A433)
                            : const Color(0xFF422521),
                      ),
                      label: Text(
                        isUploadSelected ? 'Change Photo' : 'Upload Image',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null && mounted) {
                          setState(() {
                            _previewFilePath = file.path;
                            _previewAsset = null;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF422521),
                        side: BorderSide(
                          color: isUploadSelected
                              ? const Color(0xFFF7A433)
                              : Colors.grey.shade300,
                          width: isUploadSelected ? 2 : 1,
                        ),
                        backgroundColor: isUploadSelected
                            ? const Color(0xFFFFF4E6)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      if (_previewFilePath != null) {
                        await svc.setUploadedFile(_previewFilePath!);
                      } else {
                        await svc.setPreset(_previewAsset);
                      }
                      if (mounted) navigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7A433),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
