import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetPenBackgroundService extends ChangeNotifier {
  static const _key = 'pet_pen_background';

  // Built-in asset backgrounds
  static const List<({String label, String? asset, Color fallback})> presets = [
    (label: 'Default',  asset: 'assets/images/default-bg.png', fallback: Color(0xFFFFF9E6)),
    (label: 'Fields',   asset: 'assets/images/fields-bg.png',  fallback: Color(0xFFE8F5E9)),
    (label: 'Sky',      asset: 'assets/images/sky-bg.png',     fallback: Color(0xFFE3F2FD)),
    (label: 'Beach',    asset: 'assets/images/beach-bg.png',   fallback: Color(0xFFDADEF5)),
    (label: 'Chiikawa', asset: 'assets/images/chiikawa-bg.png',fallback: Color(0xFFFFF9E6)),
  ];

  String? _currentAsset = 'assets/images/default-bg.png';        // null = default color
  String? _uploadedFilePath;    // user-uploaded local file path

  String? get currentAsset => _currentAsset;
  String? get uploadedFilePath => _uploadedFilePath;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentAsset = prefs.getString(_key);
    notifyListeners();
  }

  Future<void> setPreset(String? assetPath) async {
    _currentAsset = assetPath;
    _uploadedFilePath = null;
    final prefs = await SharedPreferences.getInstance();
    if (assetPath == null) {
      prefs.remove(_key);
    } else {
      prefs.setString(_key, assetPath);
    }
    notifyListeners();
  }

  Future<void> setUploadedFile(String filePath) async {
    _uploadedFilePath = filePath;
    _currentAsset = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, 'file:$filePath');
    notifyListeners();
  }
}