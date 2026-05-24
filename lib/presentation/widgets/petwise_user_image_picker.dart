import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetwiseUserImagePickerSheet extends StatefulWidget {
  final String currentImageUrl;
  final ValueChanged<String> onImageSelected;

  const PetwiseUserImagePickerSheet({
    super.key,
    required this.currentImageUrl,
    required this.onImageSelected,
  });

  @override
  State<PetwiseUserImagePickerSheet> createState() =>
      _PetwiseUserImagePickerSheetState();
}

class _PetwiseUserImagePickerSheetState
    extends State<PetwiseUserImagePickerSheet> {
  final TextEditingController _urlController = TextEditingController();

  // Preset illustrations/avatars for user profiles
  final List<Map<String, String>> _presets = [
    {
      'name': 'Avatar 1',
      'url':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    },
    {
      'name': 'Avatar 2',
      'url':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
    },
    {
      'name': 'Avatar 3',
      'url':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.currentImageUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
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
          const SizedBox(height: 20),
          Text(
            "Change Profile Photo",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2D40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Select a quick preset avatar:",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),

          // Row of clickable profile styles
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF4E6)
                          : const Color(0xFFF8F7F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF7A433)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            preset['url']!,
                            height: 55,
                            width: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preset['name']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
            "Or paste a custom image URL link:",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://example.com/your-avatar.jpg',
              filled: true,
              fillColor: const Color(0xFFF8F7F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7A433),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_urlController.text.trim().isNotEmpty) {
                  widget.onImageSelected(_urlController.text.trim());
                }
                Navigator.pop(context);
              },
              child: Text(
                "Apply Custom Photo",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
