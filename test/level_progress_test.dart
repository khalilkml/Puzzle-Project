import 'package:flutter_test/flutter_test.dart';

import 'package:block_puzzle/game/level_progress.dart';

void main() {
  test('level and XP fraction follow 400-point steps', () {
    expect(LevelProgress.level(0), 1);
    expect(LevelProgress.fraction(0), 0);

    expect(LevelProgress.level(399), 1);
    expect(LevelProgress.xpIntoLevel(399), 399);

    expect(LevelProgress.level(400), 2);
    expect(LevelProgress.fraction(400), 0);

    expect(LevelProgress.level(1420), 4);
    expect(LevelProgress.fraction(1420), closeTo(0.55, 0.01));
  });
}
