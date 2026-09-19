/// Score-derived level and XP bar. 400 points per level matches Stitch HUD
/// (e.g. 1,420 → Lvl 4 at ~55–60%).
class LevelProgress {
  static const int pointsPerLevel = 400;

  static int level(int score) {
    final safe = score < 0 ? 0 : score;
    return 1 + safe ~/ pointsPerLevel;
  }

  static int xpIntoLevel(int score) {
    final safe = score < 0 ? 0 : score;
    return safe % pointsPerLevel;
  }

  static double fraction(int score) {
    return xpIntoLevel(score) / pointsPerLevel;
  }
}
