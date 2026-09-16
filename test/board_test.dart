import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:block_puzzle/game/board.dart';

void main() {
  group('Board', () {
    test('places shapes and rejects overlaps', () {
      final board = Board();
      const square = Shape(
        id: 'square2',
        colorId: 6,
        cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
      );

      expect(board.canPlaceShape(square, 0, 0), isTrue);
      expect(board.placeShape(square, 0, 0), isTrue);
      expect(board.canPlaceShape(square, 0, 0), isFalse);
      expect(board.canPlaceShape(square, 1, 1), isFalse);
      expect(board.canPlaceShape(square, 0, 2), isTrue);
    });

    test('clears full rows and columns together', () {
      final board = Board();
      for (var c = 0; c < Board.size; c++) {
        board.cells[0][c] = 1;
      }
      for (var r = 0; r < Board.size; r++) {
        board.cells[r][0] = 1;
      }

      final result = board.checkAndClearLines();
      expect(result.rowsCleared, 1);
      expect(result.colsCleared, 1);
      expect(result.linesCleared, 2);
      expect(board.cells[0][0], isNull);
      expect(board.cells[0][3], isNull);
      expect(board.cells[3][0], isNull);
      expect(board.cells[1][1], isNull);
    });

    test('detects game over when no tray piece fits', () {
      final board = Board();
      for (var r = 0; r < Board.size; r++) {
        for (var c = 0; c < Board.size; c++) {
          board.cells[r][c] = 1;
        }
      }
      board.cells[0][0] = null;

      const mono = Shape(id: 'mono', colorId: 1, cells: [Point(0, 0)]);
      const square = Shape(
        id: 'square2',
        colorId: 6,
        cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
      );

      expect(board.isGameOver([mono, null, null]), isFalse);
      expect(board.isGameOver([square, null, null]), isTrue);
    });

    test('clears the fullest lines for revive', () {
      final board = Board();
      for (var c = 0; c < Board.size; c++) {
        board.cells[0][c] = 1;
        board.cells[3][c] = 2;
      }
      board.cells[1][0] = 3;
      board.cells[2][0] = 3;

      final result = board.clearFullestLines(count: 2);
      expect(result.rowsCleared, 2);
      expect(board.cells[0].every((cell) => cell == null), isTrue);
      expect(board.cells[3].every((cell) => cell == null), isTrue);
      expect(board.cells[1][0], 3);
    });

    test('weighted deal always returns three shapes', () {
      final easy = ShapeCatalog.deal(Random(11), score: 0);
      final hard = ShapeCatalog.deal(Random(11), score: 900);
      expect(easy, hasLength(3));
      expect(hard, hasLength(3));
      expect(easy.every((shape) => shape.blockCount >= 1), isTrue);
    });
  });
}
