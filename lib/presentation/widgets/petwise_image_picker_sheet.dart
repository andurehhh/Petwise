import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController _urlController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    // Only prefill if it looks like a valid internet link
    if (widget.currentImageUrl.startsWith('http')) {
      _urlController.text = widget.currentImageUrl;
    }
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
            "Change Pet Photo",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2D40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Select a quick preset style:",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),

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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            preset['url']!,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 50,
                                width: 50,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 20),
                              );
                            },
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
            "Or paste any custom link image URL:",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'https://example.com/pet.jpg',
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
                final inputUrl = _urlController.text.trim();
                if (inputUrl.isNotEmpty) {
                  widget.onImageSelected(inputUrl);
                }
                Navigator.pop(context);
              },
              child: Text(
                "Apply Custom Link",
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
