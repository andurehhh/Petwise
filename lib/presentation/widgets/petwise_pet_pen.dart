import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/data/models/pet_model.dart';
import 'package:audioplayers/audioplayers.dart';
class InteractivePetPen extends StatefulWidget {
  const InteractivePetPen({super.key});

  @override
  State<InteractivePetPen> createState() => _InteractivePetPenState();
}

class _PetInstance {
  final int id;
  double x;
  double yOffset;
  bool isFacingRight;
  bool isWalking;
  bool isSleeping;

  _PetInstance({
    required this.id,
    this.x = 50.0,
    this.yOffset = 25.0,
    this.isFacingRight = true,
    this.isWalking = true,
    this.isSleeping = false,
  });
}

class _InteractivePetPenState extends State<InteractivePetPen> {
  int _currentFrame = 1;
  final Map<int, _PetInstance> _petInstances = {};
  Timer? _animationTimer;
  Timer? _behaviorTimer;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _playPressSound(String sound) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$sound.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _startAnimation() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) return;
      setState(() {
        _currentFrame = _currentFrame == 1 ? 2 : 1;
        for (var instance in _petInstances.values) {
          if (instance.isWalking && !instance.isSleeping) {
            instance.x += instance.isFacingRight ? 6 : -6;
          }
        }
      });
    });

    _behaviorTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        for (var instance in _petInstances.values) {
          int behavior = _random.nextInt(3);
          instance.isWalking = behavior == 0;
          instance.isSleeping = behavior == 2;
        }
      });
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _behaviorTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _syncInstances(List<Pet> pets) {
    final petIds = pets.map((p) => p.id).toSet();
    _petInstances.removeWhere((id, _) => !petIds.contains(id));
    for (var pet in pets) {
      if (!_petInstances.containsKey(pet.id)) {
        _petInstances[pet.id] = _PetInstance(
          id: pet.id,
          x: 20.0 + _random.nextDouble() * 150,
          yOffset: 15.0 + _random.nextDouble() * 20.0,
          isFacingRight: _random.nextBool(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetProvider>().pets.take(3).toList();
    _syncInstances(pets);

    return LayoutBuilder(builder: (context, constraints) {
      double maxRight = constraints.maxWidth - 100;

      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF7A433).withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: _petInstances.keys.map((id) {
            final pet = pets.firstWhere((p) => p.id == id);
            final instance = _petInstances[id]!;
            return _buildPetSprite(pet, instance, maxRight);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildPetSprite(Pet pet, _PetInstance instance, double maxRight) {
    if (instance.x >= maxRight) {
      instance.isFacingRight = false;
    } else if (instance.x <= 10) {
      instance.isFacingRight = true;
    }

    String state = 'idle';
    if (instance.isSleeping) state = 'sleep';
    else if (instance.isWalking) state = 'walk';

    String assetPath = 'assets/images/$state$_currentFrame (1).png';

    // --- DYNAMIC POSITIONING ---
    // Base Top lowered from 15 to 22
    double faceTop = 18.0;
    double faceLeft = instance.isFacingRight ? 35.0 : 18.0; //Face Right : Face Left

    // Bobbing effect (Moves down during the second frame of animation)
    if (_currentFrame == 2 && !instance.isSleeping) {
      faceTop += 1.5;
    }

    // Sleep adjustment (Drops face lower to match laying down sprite)
    if (instance.isSleeping) {
      faceTop += 12.0;
      faceLeft += instance.isFacingRight ? -16.0 : 14.0; // Face Left : Face Right
    }

    return AnimatedPositioned(
      key: ValueKey(pet.id),
      duration: const Duration(milliseconds: 250),
      left: instance.x.clamp(10.0, maxRight),
      bottom: instance.yOffset,
      child: GestureDetector(
        onTap: () => setState(() {
          if (instance.isSleeping) {
            instance.isSleeping = false;
            instance.isWalking = true;
          } else {
            instance.isWalking = !instance.isWalking;
            var sound = _random.nextInt(3);
            switch (sound){
              case 0:
                _playPressSound(!instance.isWalking ? 'oi' : 'idle');
                break;
              case 1:
                _playPressSound(instance.isWalking ? 'yaha' : 'idle');
                break;
              case 2:
                _playPressSound(instance.isWalking ? 'huh' : 'idle');
                break;
            }

          }
        }),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (instance.isSleeping)
              const Positioned(
                top: -15,
                right: -5,
                child: Text("Zzz...", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF7A433))),
              ),
            // BASE ANIMATED SPRITE
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(instance.isFacingRight ? 0 : 3.14159),
              child: Image.asset(
                assetPath,
                width: 90, height: 90,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Image.asset('assets/images/idle$_currentFrame.png', width: 90, height: 90,
                  fit: BoxFit.contain, gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 50, color: Color(0xFFF7A433)),
                ),
              ),
            ),
            // "ZOOMED" & MIRRORED FACE OVERLAY
            Positioned(
              top: faceTop,
              left: faceLeft,
              child: Transform.rotate(
                // Tilt the face overlay when sleeping (approx 23 degrees)
                angle: instance.isSleeping ? (instance.isFacingRight ? -0.4 : 0.4) : 0,
                child: Container(
                  width: 38, // Increased size for "Zoomed" look
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF422521), width: 0.5),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: ClipOval(
                    child: Transform(
                      alignment: Alignment.center,
                      // Mirrors the profile picture to match the sprite's direction
                      transform: Matrix4.rotationY(instance.isFacingRight ? 0 : 3.14159),
                      child: _buildFaceImage(pet.image_url),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceImage(String? url) {
    Widget image;
    if (url == null || url.isEmpty) {
      image = Container(color: const Color(0xFFF7A433), child: const Icon(Icons.pets, size: 20, color: Colors.white));
    } else if (url.startsWith('http')) {
      image = Image.network(url, fit: BoxFit.cover);
    } else {
      image = Image.file(File(url), fit: BoxFit.cover);
    }

    // Applies the 10% Zoom (1.1 scale) as requested
    return Transform.scale(scale: 1.1, child: image);
  }
}
