import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late final AudioPlayer audioPlayer;
  bool isPlaying = false;
  double volume = 0.5;
  late AnimationController _noteAnimationController;
  final List<double> _noteRotationSpeeds = List.generate(12, (index) => 0.5 + (index % 3) * 0.3);

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _initAudio();

    // Initialize animation controller for smooth continuous rotation
    _noteAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  Future<void> _initAudio() async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.setVolume(volume);

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await audioPlayer.play(AssetSource('audio/background.mp3'));
    } catch (e) {
      debugPrint('Error playing music: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play background music')),
        );
      }
    }
  }

  Future<void> _toggleMusic() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
  }

  Future<void> _setVolume(double newVolume) async {
    setState(() => volume = newVolume);
    await audioPlayer.setVolume(newVolume);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _noteAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A001A),
                  const Color(0xFF220055),
                  const Color(0xFF4500A0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.1, 0.5, 0.9],
              ),
            ),
          ),

          // Floating animated music notes with continuous rotation
          AnimatedBuilder(
            animation: _noteAnimationController,
            builder: (context, child) {
              return Stack(
                children: List.generate(12, (index) {
                  final color = index % 3 == 0
                      ? const Color(0xFFFF00FF).withOpacity(0.4)
                      : index % 3 == 1
                      ? const Color(0xFF00F0FF).withOpacity(0.4)
                      : const Color(0xFF00FFAA).withOpacity(0.4);

                  final rotationAngle = _noteAnimationController.value * 2 * 3.1416 * _noteRotationSpeeds[index];

                  return Positioned(
                    top: (size.height * 0.1) + (index * 80),
                    left: index.isEven ? -30 : null,
                    right: index.isOdd ? -30 : null,
                    child: Transform.rotate(
                      angle: rotationAngle,
                      child: Icon(
                        Icons.music_note,
                        color: color,
                        size: 40 + (index % 5) * 10,
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Game title with glow effect
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFFFF00FF),
                              Color(0xFF00F0FF),
                              Color(0xFFFFFF00),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'BEAT BREAKER',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Feel the rhythm of the game',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Modern menu buttons
                      _buildModernMenuButton(
                        context,
                        icon: Icons.play_arrow_rounded,
                        text: 'PLAY NOW',
                        iconColor: Colors.greenAccent,
                        onPressed: () {
                          // Navigate to game screen
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildModernMenuButton(
                        context,
                        icon: Icons.leaderboard_rounded,
                        text: 'LEADERBOARDS',
                        iconColor: Colors.blueAccent,
                        onPressed: () {
                          // Navigate to leaderboards
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildModernMenuButton(
                        context,
                        icon: Icons.settings_rounded,
                        text: 'GAME SETTINGS',
                        iconColor: Colors.orangeAccent,
                        onPressed: () {
                          // Navigate to settings
                        },
                      ),
                      const SizedBox(height: 40),

                      // Bottom action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIconButton(
                            icon: Icons.account_circle_rounded,
                            color: const Color(0xFF00F0FF),
                            onPressed: () {
                              // Navigate to profile
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildIconButton(
                            icon: Icons.help_rounded,
                            color: const Color(0xFFFFFF00),
                            onPressed: () {
                              // Show help dialog
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildIconButton(
                            icon: Icons.logout_rounded,
                            color: const Color(0xFFFF0066),
                            onPressed: () async {
                              await audioPlayer.stop();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Music control panel
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleMusic,
                  ),
                  SizedBox(
                    width: 100,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                      ),
                      child: Slider(
                        value: volume,
                        onChanged: _setVolume,
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required Color iconColor,
        required VoidCallback onPressed,
      }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: iconColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 28),
        color: Colors.white,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: color.withOpacity(0.8),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}