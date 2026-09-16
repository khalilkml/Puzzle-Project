import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_puzzle/game/board.dart';
import 'package:block_puzzle/state/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('placing pieces updates score and clears tray slots', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = GameController(random: Random(1));
    await controller.init();

    expect(controller.tray.whereType<Shape>().length, 3);

    final shape = controller.tray[0]!;
    final placed = controller.tryPlaceAt(0, 0, 0);
    expect(placed, isTrue);
    expect(controller.tray[0], isNull);
    expect(controller.score, greaterThanOrEqualTo(shape.blockCount));
    expect(controller.isGameOver, isFalse);
  });
}
