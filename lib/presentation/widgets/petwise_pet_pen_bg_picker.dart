import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:petwise/services/pet_pen_background_service.dart';

class PetPenBgPicker extends StatefulWidget {
  const PetPenBgPicker({super.key});

  @override
  State<PetPenBgPicker> createState() => _PetPenBgPickerState();
}

class _PetPenBgPickerState extends State<PetPenBgPicker> {
  String? _selectedAsset = _sentinel; // sentinel = "not changed yet"
  static const _sentinel = '##unchanged##';

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<PetPenBackgroundService>();
    final current = _selectedAsset == _sentinel ? svc.currentAsset : _selectedAsset;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Choose background',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF422521))),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
              ),
              itemCount: PetPenBackgroundService.presets.length,
              itemBuilder: (_, i) {
                final p = PetPenBackgroundService.presets[i];
                final isSelected = current == p.asset;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAsset = p.asset),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: p.fallback,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF7A433) : Colors.transparent,
                        width: 3,
                      ),
                      image: p.asset != null
                          ? DecorationImage(image: AssetImage(p.asset!), fit: BoxFit.cover,
                          onError: (_, __) {})
                          : null,
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                      child: Text(p.label,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text('Upload image'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(source: ImageSource.gallery);
                    if (file != null && mounted) {
                      await svc.setUploadedFile(file.path);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF422521),
                    side: const BorderSide(color: Color(0xFFF7A433)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedAsset != _sentinel) {
                    await svc.setPreset(_selectedAsset);
                  }
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7A433),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Apply'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}