import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/level_progress.dart';
import '../services/feedback_service.dart';
import '../state/game_controller.dart';
import 'cubex_theme.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final feedback = context.watch<FeedbackService>();
    final best = controller.bestScore;
    final level = LevelProgress.level(best);

    return Scaffold(
      backgroundColor: CubexTheme.cream,
      body: Stack(
        children: [
          const _PlayBlobs(),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _Pill(
                      icon: Icons.eco_rounded,
                      label: 'CLASSIC WOOD',
                      foreground: CubexTheme.playGreenDeep,
                      background: Color(0xFFE7F9EE),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/cubex_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return const ColoredBox(
                          color: Color(0xFFFFE8D6),
                          child: Center(
                            child: Text(
                              'CUBEX',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                                color: CubexTheme.woodInk,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _CubexWordmark(),
                const SizedBox(height: 10),
                const _Pill(
                  icon: Icons.extension_rounded,
                  label: 'Wood Block Puzzle',
                  foreground: CubexTheme.peachDeep,
                  background: Color(0xFFFFE7D4),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFFE6B422),
                      label: 'BEST SCORE',
                      value: _format(best),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: CubexTheme.peachDeep,
                      label: 'Lv. $level',
                      value: null,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _PlayButton(
                  onPressed: () {
                    controller.newGame();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const GameScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundIcon(
                      icon:
                          feedback.soundsEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                      onTap: feedback.toggleSounds,
                    ),
                    const SizedBox(width: 14),
                    _RoundIcon(
                      icon:
                          feedback.hapticsEnabled
                              ? Icons.vibration_rounded
                              : Icons.phone_iphone_rounded,
                      onTap: feedback.toggleHaptics,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Touch blocks for tactile wooden clack',
                  style: TextStyle(
                    color: CubexTheme.woodMuted.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _format(int value) {
    final raw = '$value';
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buf.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}

class _CubexWordmark extends StatelessWidget {
  const _CubexWordmark();

  @override
  Widget build(BuildContext context) {
    const letters = [
      ('C', Color(0xFF2ECC71)),
      ('U', Color(0xFFFF8A3A)),
      ('B', Color(0xFF4FC3F7)),
      ('E', Color(0xFFAB47BC)),
      ('X', Color(0xFFFFCA28)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final letter in letters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              letter.$1,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: letter.$2,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 280,
        height: 62,
        decoration: BoxDecoration(
          color: CubexTheme.playGreen,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: CubexTheme.playGreenDeep,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            SizedBox(width: 6),
            Text(
              'PLAY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: CubexTheme.woodMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: const TextStyle(
                    color: CubexTheme.woodInk,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: CubexTheme.woodMuted, size: 22),
        ),
      ),
    );
  }
}

class _PlayBlobs extends StatelessWidget {
  const _PlayBlobs();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: -28,
          top: 210,
          child: _Blob(color: Color(0xFFFF9A4A), size: 72),
        ),
        Positioned(
          right: -24,
          top: 168,
          child: _Blob(color: Color(0xFF5EC8F8), size: 78),
        ),
        Positioned(
          left: -18,
          bottom: 210,
          child: _Blob(color: Color(0xFF7BE36A), size: 64),
        ),
        Positioned(
          right: -16,
          bottom: 240,
          child: _Blob(color: Color(0xFFB388FF), size: 70),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.85),
      ),
    );
  }
}
