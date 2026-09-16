import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_puzzle/game/board.dart';
import 'package:block_puzzle/state/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('placing pieces updates score and clears tray slots', () async {
    final controller = GameController(random: Random(1));
    await controller.init();

    expect(controller.tray.whereType<Shape>().length, 3);

    final shape = controller.tray[0]!;
    final placed = controller.tryPlaceAt(0, 0, 0);
    expect(placed, isTrue);
    expect(controller.tray[0], isNull);
    expect(controller.score, greaterThanOrEqualTo(shape.blockCount));
    expect(controller.isGameOver, isFalse);
    expect(controller.lastEvent, GameEvent.placed);
  });

  test('combo scoring multiplies line clears', () async {
    final controller = GameController(random: Random(2));
    await controller.init();

    final cells = List.generate(
      Board.size,
      (_) => List<int?>.filled(Board.size, null),
    );
    for (var c = 0; c < Board.size; c++) {
      cells[0][c] = 1;
      cells[1][c] = 1;
    }
    cells[0][7] = null;
    cells[1][7] = null;

    const vertical = Shape(
      id: 'domino_v',
      colorId: 2,
      cells: [Point(0, 0), Point(0, 1)],
    );
    controller.debugLoadBoard(cells, [vertical, null, null]);
    expect(controller.tryPlaceAt(0, 0, 7), isTrue);
    expect(controller.lastLinesCleared, 2);
    expect(controller.lastCombo, 2);
    expect(controller.lastPerfectClear, isTrue);
    expect(controller.score, 2 + 2 * 10 * 2 + 50);
    expect(controller.lastEvent, GameEvent.combo);
  });

  test('revive clears space once per game', () async {
    final controller = GameController(random: Random(3));
    await controller.init();

    final full = List.generate(
      Board.size,
      (_) => List<int?>.filled(Board.size, 4),
    );
    const square = Shape(
      id: 'square2',
      colorId: 6,
      cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
    );
    controller.debugLoadBoard(full, [square, square, square]);
    expect(controller.isGameOver, isTrue);
    expect(controller.canRevive, isTrue);

    expect(controller.revive(), isTrue);
    expect(controller.reviveUsed, isTrue);
    expect(controller.canRevive, isFalse);
    expect(controller.board.filledCount, lessThan(Board.size * Board.size));
    expect(controller.revive(), isFalse);
  });

  test('newGame clears game over and deals three pieces', () async {
    final controller = GameController(random: Random(4));
    await controller.init();

    final full = List.generate(
      Board.size,
      (_) => List<int?>.filled(Board.size, 4),
    );
    const square = Shape(
      id: 'square2',
      colorId: 6,
      cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
    );
    controller.debugLoadBoard(full, [square, square, square]);
    expect(controller.isGameOver, isTrue);

    controller.newGame();
    expect(controller.isGameOver, isFalse);
    expect(controller.score, 0);
    expect(controller.tray.whereType<Shape>().length, 3);
  });

  test('game continues if any remaining tray piece still fits', () async {
    final controller = GameController(random: Random(5));
    await controller.init();

    final cells = List.generate(
      Board.size,
      (r) => List<int?>.generate(Board.size, (c) => 1),
    );
    cells[0][0] = null;

    const mono = Shape(id: 'mono', colorId: 1, cells: [Point(0, 0)]);
    const square = Shape(
      id: 'square2',
      colorId: 6,
      cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
    );
    controller.debugLoadBoard(cells, [square, mono, null]);
    expect(controller.isGameOver, isFalse);
    expect(controller.canPlaceTrayIndex(0), isFalse);
    expect(controller.canPlaceTrayIndex(1), isTrue);
  });

  test('hover still highlights cells when the drop is invalid', () async {
    final controller = GameController(random: Random(6));
    await controller.init();
    const square = Shape(
      id: 'square2',
      colorId: 6,
      cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
    );
    controller.debugLoadBoard(
      List.generate(Board.size, (_) => List<int?>.filled(Board.size, null)),
      [square, null, null],
    );
    controller.beginDrag(0);
    controller.updateHover(const Point(7, 7));
    expect(controller.isHoverValid, isFalse);
    expect(controller.canHighlightAt(7, 7), isTrue);
  });

  test('refills the tray after all three pieces are placed', () async {
    final controller = GameController(random: Random(8));
    await controller.init();
    expect(controller.tray.whereType<Shape>().length, 3);

    for (var i = 0; i < 3; i++) {
      final index = controller.tray.indexWhere((shape) => shape != null);
      final shape = controller.tray[index]!;
      final origin = _firstFit(controller.board, shape);
      expect(origin, isNotNull);
      expect(controller.tryPlaceAt(index, origin!.y, origin.x), isTrue);
    }

    expect(controller.tray.whereType<Shape>().length, 3);
    expect(controller.tray.every((shape) => shape != null), isTrue);
  });

  test('new game on an empty board is never immediately over', () async {
    for (var seed = 0; seed < 25; seed++) {
      final controller = GameController(random: Random(seed));
      await controller.init();
      expect(controller.isGameOver, isFalse, reason: 'seed $seed');
    }
  });
}

Point<int>? _firstFit(Board board, Shape shape) {
  for (var row = 0; row < Board.size; row++) {
    for (var col = 0; col < Board.size; col++) {
      if (board.canPlaceShape(shape, row, col)) {
        return Point(col, row);
      }
    }
  }
  return null;
}
