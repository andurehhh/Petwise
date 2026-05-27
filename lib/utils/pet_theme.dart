import 'package:flutter/material.dart';

class PetTheme {
  static Color cardColor(String species) {
    final s = species.toLowerCase();
    if (s.contains('dog')) return const Color(0xFF97ACDA);
    if (s.contains('cat')) return const Color(0xFFAE9CEE);
    if (s.contains('rabbit')) return const Color(0xFFFF99CC);
    if (s.contains('bird')) return const Color(0xFFF7A433);
    return const Color(0xFFABC4ED);
  }

  static Color detailColor(String species) {
    final s = species.toLowerCase();
    if (s.contains('dog')) return const Color(0xFF5F76A7);
    if (s.contains('cat')) return const Color(0xFF8D64AD);
    if (s.contains('rabbit')) return const Color(0xFF880E4F);
    if (s.contains('bird')) return const Color(0xFFE1962D);
    return const Color(0xFF435B85);
  }

  static Color tileBackground(String species) {
    final s = species.toLowerCase();
    if (s.contains('dog')) return const Color(0xFFD9E9FE);
    if (s.contains('cat')) return const Color(0xFFE4D9FE);
    if (s.contains('rabbit')) return const Color(0xFFFCE4EC);
    if (s.contains('bird')) return const Color(0xFFF7E6CE);
    return const Color(0xFFE3F2FD);
  }
}
