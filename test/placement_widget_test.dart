import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_puzzle/game/board.dart';
import 'package:block_puzzle/state/game_controller.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('placing a tray piece updates score and clears the slot', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = GameController(random: Random(42));

    await tester.pumpWidget(wrapGame(controller));
    await controller.init();
    await tester.pumpAndSettle();

    final shape = controller.tray[0]!;
    expect(controller.tryPlaceAt(0, 0, 0), isTrue);
    await tester.pumpAndSettle();

    expect(controller.tray[0], isNull);
    expect(controller.score, shape.blockCount);
    expect(find.text('${shape.blockCount}'), findsWidgets);
    expect(find.text('Ad Banner Slot'), findsOneWidget);
  });

  testWidgets('game over shows revive and play again', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = GameController(random: Random(7));
    await tester.pumpWidget(wrapGame(controller));
    await controller.init();
    await tester.pumpAndSettle();

    final full = List.generate(
      Board.size,
      (_) => List<int?>.filled(Board.size, 1),
    );
    const square = Shape(
      id: 'square2',
      colorId: 6,
      cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
    );
    controller.debugLoadBoard(full, [square, square, square]);
    await tester.pumpAndSettle();

    expect(find.textContaining('Game Over'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);
    expect(find.text('Watch Ad to Revive'), findsOneWidget);

    controller.newGame();
    await tester.pumpAndSettle();

    expect(find.textContaining('Game Over'), findsNothing);
    expect(controller.isGameOver, isFalse);
    expect(controller.score, 0);
  });
}
