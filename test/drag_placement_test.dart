import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:block_puzzle/ui/drag_placement.dart';

void main() {
  const cellSize = 40.0;
  const gap = 4.0;
  const padding = 10.0;
  const boardSize = 8;
  // Board top-left in global space for the test.
  const boardOrigin = Offset(100, 200);

  test('feedbackLift centers on finger with small upward bias', () {
    final lift = DragPlacement.feedbackLift(
      shapeWidth: 2,
      shapeHeight: 3,
      cellSize: cellSize,
      gap: gap,
    );
    final width = 2 * cellSize + gap;
    final height = 3 * cellSize + 2 * gap;
    final stride = cellSize + gap;

    expect(lift.dx, closeTo(-width / 2, 0.001));
    expect(
      lift.dy,
      closeTo(-height / 2 - stride * DragPlacement.liftCells, 0.001),
    );
  });

  test('originForPointer uses the same lift as feedback (tall piece)', () {
    final lift = DragPlacement.feedbackLift(
      shapeWidth: 1,
      shapeHeight: 4,
      cellSize: cellSize,
      gap: gap,
    );
    // Place floating top-left exactly on board cell (2, 3).
    final pieceTopLeft = Offset(
      boardOrigin.dx + padding + 2 * (cellSize + gap),
      boardOrigin.dy + padding + 3 * (cellSize + gap),
    );
    final finger = pieceTopLeft - lift;

    final origin = DragPlacement.originForPointer(
      globalPointer: finger,
      boardGlobalTopLeft: boardOrigin,
      shapeWidth: 1,
      shapeHeight: 4,
      cellSize: cellSize,
      gap: gap,
      boardPadding: padding,
      boardSize: boardSize,
    );

    expect(origin, const Point(2, 3));
  });

  test('originForPointer matches feedback for wide piece', () {
    final lift = DragPlacement.feedbackLift(
      shapeWidth: 5,
      shapeHeight: 1,
      cellSize: cellSize,
      gap: gap,
    );
    final pieceTopLeft = Offset(
      boardOrigin.dx + padding + 1 * (cellSize + gap),
      boardOrigin.dy + padding + 6 * (cellSize + gap),
    );
    final finger = pieceTopLeft - lift;

    final origin = DragPlacement.originForPointer(
      globalPointer: finger,
      boardGlobalTopLeft: boardOrigin,
      shapeWidth: 5,
      shapeHeight: 1,
      cellSize: cellSize,
      gap: gap,
      boardPadding: padding,
      boardSize: boardSize,
    );

    expect(origin, const Point(1, 6));
  });

  test('hover and drop share identical mapping for the same pointer', () {
    final finger = const Offset(260, 480);
    Point<int>? map() => DragPlacement.originForPointer(
      globalPointer: finger,
      boardGlobalTopLeft: boardOrigin,
      shapeWidth: 2,
      shapeHeight: 2,
      cellSize: cellSize,
      gap: gap,
      boardPadding: padding,
      boardSize: boardSize,
    );

    expect(map(), map());
  });
}
