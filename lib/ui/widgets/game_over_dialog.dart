import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.score,
    required this.bestScore,
    required this.canRevive,
    required this.rewardedReady,
    required this.onPlayAgain,
    required this.onRevive,
  });

  final int score;
  final int bestScore;
  final bool canRevive;
  final bool rewardedReady;
  final VoidCallback onPlayAgain;
  final VoidCallback onRevive;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2128),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No more moves',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text('Score  $score', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            'Best  $bestScore',
            style: TextStyle(color: Colors.amber.shade300),
          ),
          if (canRevive) ...[
            const SizedBox(height: 12),
            Text(
              rewardedReady
                  ? 'Watch a short ad to clear space and keep playing.'
                  : 'Revive ad is loading…',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (canRevive)
          TextButton(
            onPressed: rewardedReady ? onRevive : null,
            child: Text(rewardedReady ? 'Watch Ad to Revive' : 'Revive'),
          ),
        FilledButton(onPressed: onPlayAgain, child: const Text('Play Again')),
      ],
    );
  }
}
