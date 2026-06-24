import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petwise/presentation/screens/pet_profile_screen.dart';
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
  double groundLevel; // Original Y to return to after falling
  bool isFacingRight;
  bool isWalking;
  bool isSleeping;
  bool isDragging;
  bool isFalling;
  double verticalSpeed;
  String? lastState;

  _PetInstance({
    required this.id,
    this.x = 50.0,
    this.yOffset = 25.0,
    this.groundLevel = 25.0,
    this.isFacingRight = true,
    this.isWalking = true,
    this.isSleeping = false,
    this.isDragging = false,
    this.isFalling = false,
    this.verticalSpeed = 0.0,
  });
}

class _InteractivePetPenState extends State<InteractivePetPen> {
  int _currentFrame = 1;
  int _physicsTick = 0;
  final Map<int, _PetInstance> _petInstances = {};
  Timer? _animationTimer;
  Timer? _behaviorTimer;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _showingProfileForId;
  int? _pausedForId;
  final Set<int> _heartsShown = {};
  int? _showingHeartForId;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  // Helper method to play sound on pet press/interaction
  Future<void> _playPressSound() async {
    try {
      int randSound = Random().nextInt(3);
      String soundPath = 'oi.mp3';
      if (randSound == 0) {
        soundPath = 'huh.mp3';
      } else if (randSound == 1) {
        soundPath = 'yaha.mp3';
      } else{
        soundPath = 'oi.mp3';
      }
      await _audioPlayer.play(AssetSource('sounds/$soundPath'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  // NEW: Triggers the one-time heart bubble
  void _triggerHeart(_PetInstance instance) {
    if (!_heartsShown.contains(instance.id)) {
      setState(() {
        _heartsShown.add(instance.id);
        _showingHeartForId = instance.id;
      });
      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showingHeartForId = null);
      });
    }
  }

  void _startAnimation() {
    // Faster timer (50ms) for smooth dragging and falling physics
    _animationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _physicsTick++;
        // Update animation frame every 250ms (5 ticks of 50ms)
        if (_physicsTick >= 5) {
          _currentFrame = _currentFrame == 1 ? 2 : 1;
          _physicsTick = 0;
        }

        for (var instance in _petInstances.values) {
          if (instance.isDragging) continue;

          if (instance.isFalling) {
            instance.verticalSpeed -= 2.0; // Gravity force
            instance.yOffset += instance.verticalSpeed;

            // Hit ground detection
            if (instance.yOffset <= instance.groundLevel) {
              instance.yOffset = instance.groundLevel;
              instance.isFalling = false;
              instance.verticalSpeed = 0;
              instance.lastState = 'land';

              // Stay in "land" pose for 400ms then go back to normal
              Timer(const Duration(milliseconds: 400), () {
                if (mounted) setState(() => instance.lastState = null);
              });
            }
          } else if (instance.isWalking && !instance.isSleeping) {
            instance.x += instance.isFacingRight ? 1.2 : -1.2;
          }
        }
      });
    });

    _behaviorTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        for (var instance in _petInstances.values) {
          if (instance.isDragging || instance.isFalling) continue;
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
        double startY = 15.0 + _random.nextDouble() * 20.0;
        _petInstances[pet.id] = _PetInstance(
          id: pet.id,
          x: 20.0 + _random.nextDouble() * 150,
          yOffset: startY,
          groundLevel: startY,
          isFacingRight: _random.nextBool(),
        );
      }
    }
  }

  String _getSpritePrefix(String species) {
    final lowerCaseSpecies = species.toLowerCase();
    if (lowerCaseSpecies.contains('dog') || lowerCaseSpecies.contains('puppy')) {
      return 'dog';
    } else if (lowerCaseSpecies.contains('cat') || lowerCaseSpecies.contains('kitten')) {
      return 'cat';
    } else if (lowerCaseSpecies.contains('bunny') || lowerCaseSpecies.contains('rabbit')) {
      return 'bunny';
    }
    return 'generic';
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
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -28,
                left: -20,
                child: _PenBlob(
                  size: 90,
                  color: const Color(0xFFF7A433).withOpacity(0.13),
                  animOffset: 0,
                  ctrl: _animationTimer,
                ),
              ),
              Positioned(
                top: -10,
                right: -16,
                child: _PenBlob(
                  size: 64,
                  color: const Color(0xFFF7A433).withOpacity(0.1),
                  animOffset: 0.3,
                  ctrl: _animationTimer,
                ),
              ),
              Positioned(
                bottom: -18,
                left: 60,
                child: _PenBlob(
                  size: 52,
                  color: const Color(0xFFF7A433).withOpacity(0.09),
                  animOffset: 0.6,
                  ctrl: _animationTimer,
                ),
              ),
              Positioned(
                bottom: -10,
                right: 40,
                child: _PenBlob(
                  size: 40,
                  color: const Color(0xFFF7A433).withOpacity(0.07),
                  animOffset: 0.9,
                  ctrl: _animationTimer,
                ),
              ),
              ..._petInstances.keys.map((id) {
                final pet = pets.firstWhere((p) => p.id == id);
                final instance = _petInstances[id]!;
                return _buildPetSprite(pet, instance, maxRight);
              }),
              ..._petInstances.keys.where((id) => _showingProfileForId == id).map((id) {
                final pet = pets.firstWhere((p) => p.id == id);
                final instance = _petInstances[id]!;
                return Positioned(
                  left: instance.x.clamp(10.0, maxRight),
                  bottom: instance.yOffset + 60,
                  child: Builder(
                    builder: (popupContext) => GestureDetector(
                      onTap: () {
                        debugPrint("Profile tapped for ${pet.name}");
                        setState(() => _showingProfileForId = null);
                        popupContext.read<PetProvider>().selectPet(pet);
                        Navigator.of(popupContext, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const PetProfileScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFF7A433).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF422521),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFFF7A433)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
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

    // Determine current visual state
    String state = 'idle';
    if (instance.isDragging) state = 'drag';
    else if (instance.isFalling) state = 'fall';
    else if (instance.lastState == 'land') state = 'land';
    else if (instance.isSleeping) state = 'sleep';
    else if (instance.isWalking) state = 'walk';

    final spritePrefix = _getSpritePrefix(pet.species);
    String frameSuffix = (state == 'drag' || state == 'fall' || state == 'land') ? '1' : '$_currentFrame';
    String assetPath = 'assets/images/$spritePrefix/$state$frameSuffix.png';
    String genericIdlePath = 'assets/images/generic/idle$_currentFrame.png';

    // --- DYNAMIC POSITIONING ---
    final faceOffsets = _getFaceOffsets(spritePrefix, state, instance.isFacingRight, _currentFrame);
    double faceTop = faceOffsets['top']!;
    double faceLeft = faceOffsets['left']!;

    return AnimatedPositioned(
      key: ValueKey(pet.id),
      duration: instance.isDragging ? Duration.zero : const Duration(milliseconds: 50),
      left: instance.x.clamp(10.0, maxRight),
      bottom: instance.yOffset - (state == 'land' ? 10.0: 0.0),
      child: GestureDetector(
        onPanStart: (_) {
        },
        onPanUpdate: (details) {
          // Only start the "drag" state once movement is detected
          if (!instance.isDragging) {
            _playPressSound();
            _triggerHeart(instance); // Trigger one-time heart bubble on first interaction
            setState(() {
              instance.isDragging = true;
              instance.isWalking = false;
              instance.isSleeping = false;
              instance.isFalling = false;
              instance.lastState = null;
            });
          }
          setState(() {
            instance.x = (instance.x + details.delta.dx).clamp(0.0, maxRight);
            instance.yOffset = (instance.yOffset - details.delta.dy).clamp(instance.groundLevel, 140.0);
          });
        },
        onPanEnd: (_) {
          if (instance.isDragging) {
            setState(() {
              instance.isDragging = false;
              instance.isFalling = true;
              instance.verticalSpeed = 0;
            });
          }
        },
        onPanCancel: () {
          if (instance.isDragging) {
            setState(() {
              instance.isDragging = false;
              instance.isFalling = true;
              instance.verticalSpeed = 0;
            });
          }
        },
        onTap: () {
          _playPressSound();
          _triggerHeart(instance);
          setState(() {
            if (instance.isSleeping) {
              instance.isSleeping = false;
            }
            // Pause all movement briefly
            instance.isWalking = false;
            instance.isSleeping = false;
            _pausedForId = instance.id;
          });
          // Resume after 1200ms
          Timer(const Duration(milliseconds: 1200), () {
            if (mounted) setState(() {
              _pausedForId = null;
              instance.isWalking = true;
            });
          });
        },
        onLongPress: () {
          _playPressSound();
          setState(() {
            _showingProfileForId = instance.id;
            instance.isWalking = false;
            instance.isSleeping = false;
          });
          Timer(const Duration(seconds: 4), () {
            if (mounted) setState(() => _showingProfileForId = null);
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ONE-TIME HEART SPEECH BUBBLE
            if (_showingHeartForId == instance.id)
              Positioned(
                top: -35,
                left: instance.isFacingRight ? 40 : 15,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text("❤️", style: TextStyle(fontSize: 20)),
                ),
              ),
            if (instance.isSleeping)
              const Positioned(
                top: -15,
                right: 0,
                child: Text("Zzz...", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF7A433))),
              ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(instance.isFacingRight ? 0 : 3.14159),
              child: Image.asset(
                assetPath,
                width: 90, height: 90,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Image.asset(
                  genericIdlePath,
                  width: 90, height: 90,
                  fit: BoxFit.contain, gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 50, color: Color(0xFFF7A433)),
                ),
              ),
            ),
            Positioned(
              top: faceTop,
              left: faceLeft,
              child: Transform.rotate(
                angle: instance.isSleeping ? (instance.isFacingRight ? -0.4 : 0.4) : 0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF422521), width: 0.5),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: ClipOval(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(instance.isFacingRight ? 0 : 3.14159),
                      child: Transform.scale(scale: 1.1, child: _buildFaceImage(pet.image_url)),
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
    if (url == null || url.isEmpty) return Container(color: const Color(0xFFF7A433), child: const Icon(Icons.pets, size: 20, color: Colors.white));
    if (url.startsWith('http')) return Image.network(url, fit: BoxFit.cover);
    return Image.file(File(url), fit: BoxFit.cover);
  }
  Map<String, double> _getFaceOffsets(String spritePrefix, String state, bool isFacingRight, int currentFrame) {
    double top = 18.0;
    double left = isFacingRight ? 35.0 : 18.0;

    switch (spritePrefix) {
      case 'dog':
        top = 18.0;
        left = isFacingRight ? 32.0 : 20.0;
        break;
      case 'cat':
        top = 18.0;
        left = isFacingRight ? 34.0 : 19.0;
        break;
      case 'bunny':
        top = 26.0;
        left = isFacingRight ? 33.0 : 20.0;
        break;
      case 'generic':
        top = 18.0;
        left = isFacingRight ? 35.0 : 18.0;
        break;
    }

    if (state == 'drag') {
      top +=4.0;
    } else if (state == 'fall') {
      top -= 2.0;
    } else if (state == 'land') {
      top += 20.0;
    } else if (state == 'sleep') {
      top += 12.0;
      left += isFacingRight ? -16.0 : 14.0;
    } else if (currentFrame == 2) {
      top += 1.5;
    }

    return {'top': top, 'left': left};
  }
}

class _PenBlob extends StatefulWidget {
  final double size;
  final Color color;
  final double animOffset;
  final dynamic ctrl;

  const _PenBlob({
    required this.size,
    required this.color,
    required this.animOffset,
    required this.ctrl,
  });

  @override
  State<_PenBlob> createState() => _PenBlobState();
}

class _PenBlobState extends State<_PenBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2800 + (widget.animOffset * 600).toInt()),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.88, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: _anim.value,
        child: Container(
          width: widget.size,
          height: widget.size * 0.85,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.size * 0.5),
              topRight: Radius.circular(widget.size * 0.35),
              bottomLeft: Radius.circular(widget.size * 0.35),
              bottomRight: Radius.circular(widget.size * 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
