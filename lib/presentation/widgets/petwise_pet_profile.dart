import 'package:flutter/material.dart';

class PetCircle extends StatelessWidget {
  final String imagePath;
  final String petName;
  final String petType;

  const PetCircle({
    super.key,
    required this.imagePath,
    required this.petName,
    required this.petType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 8),
        Text(petName, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          petType,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
