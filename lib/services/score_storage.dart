import 'package:shared_preferences/shared_preferences.dart';

class ScoreStorage {
  static const _bestScoreKey = 'block_puzzle_best_score';

  Future<int> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_bestScoreKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_bestScoreKey, score);
    }
  }
}
