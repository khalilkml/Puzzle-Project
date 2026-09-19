import 'package:flutter/material.dart';

import '../cubex_theme.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.score,
    required this.bestScore,
    required this.canRevive,
    required this.rewardedReady,
    required this.onPlayAgain,
    required this.onRevive,
    this.lastScoreGain = 0,
  });

  final int score;
  final int bestScore;
  final bool canRevive;
  final bool rewardedReady;
  final VoidCallback onPlayAgain;
  final VoidCallback onRevive;
  final int lastScoreGain;

  @override
  Widget build(BuildContext context) {
    final isBest = score > 0 && score >= bestScore;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.72, end: 1),
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: CubexTheme.cream,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE8C9A8), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/cubex_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.extension_rounded,
                        color: CubexTheme.peachDeep,
                        size: 36,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Game Over!',
                style: TextStyle(
                  color: CubexTheme.woodInk,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'No more moves! Great puzzle solving!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CubexTheme.woodMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ScoreChip(
                      label: 'SCORE',
                      value: '$score',
                      badge:
                          lastScoreGain > 0 ? '+$lastScoreGain pts' : null,
                      badgeColor: CubexTheme.playGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ScoreChip(
                      label: 'BEST',
                      value: '$bestScore',
                      badge: isBest ? 'Super Star!' : null,
                      badgeColor: CubexTheme.peachDeep,
                      icon: Icons.emoji_events_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (canRevive) ...[
                _ActionButton(
                  label: 'Watch Ad to Revive',
                  subtitle:
                      rewardedReady
                          ? 'Clear space and keep playing'
                          : 'Revive ad is loading…',
                  color: CubexTheme.peach,
                  shadow: CubexTheme.peachDeep,
                  icon: Icons.play_arrow_rounded,
                  enabled: rewardedReady,
                  onPressed: onRevive,
                ),
                const SizedBox(height: 10),
              ],
              _ActionButton(
                label: 'Play Again',
                color: CubexTheme.playGreen,
                shadow: CubexTheme.playGreenDeep,
                icon: Icons.refresh_rounded,
                enabled: true,
                onPressed: onPlayAgain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.value,
    this.badge,
    this.badgeColor,
    this.icon,
  });

  final String label;
  final String value;
  final String? badge;
  final Color? badgeColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: CubexTheme.peachDeep),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: CubexTheme.woodMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: CubexTheme.woodInk,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1.05,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? CubexTheme.playGreen).withValues(
                  alpha: 0.18,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: badgeColor ?? CubexTheme.playGreenDeep,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.shadow,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final Color color;
  final Color shadow;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(color: shadow, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
