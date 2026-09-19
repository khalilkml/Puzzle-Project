import 'dart:math';

import 'package:flutter/material.dart';

/// Shared drag → board mapping so floating feedback and hover/drop stay in sync.
class DragPlacement {
  /// How far above the finger the bottom of the piece sits, in cell strides.
  static const double liftCells = 1.4;

  /// Top-left of the floating piece relative to the pointer (pointerDragAnchor).
  static Offset feedbackLift({
    required int shapeWidth,
    required int shapeHeight,
    required double cellSize,
    required double gap,
  }) {
    final stride = cellSize + gap;
    final width = shapeWidth * cellSize + max(0, shapeWidth - 1) * gap;
    final height = shapeHeight * cellSize + max(0, shapeHeight - 1) * gap;
    // Center horizontally on the finger; sit fully above it.
    return Offset(-width / 2, -height - stride * liftCells);
  }

  /// Board cell origin (x = col, y = row) for the shape's top-left under [globalPointer].
  ///
  /// Uses the same [feedbackLift] offset as the floating preview so shadow cells
  /// match the piece the player sees.
  static Point<int>? originForPointer({
    required Offset globalPointer,
    required Offset boardGlobalTopLeft,
    required int shapeWidth,
    required int shapeHeight,
    required double cellSize,
    required double gap,
    required double boardPadding,
    required int boardSize,
  }) {
    final lift = feedbackLift(
      shapeWidth: shapeWidth,
      shapeHeight: shapeHeight,
      cellSize: cellSize,
      gap: gap,
    );
    // Top-left of the floating piece in global space — same as painted feedback.
    final pieceTopLeftGlobal = globalPointer + lift;
    final local = pieceTopLeftGlobal - boardGlobalTopLeft;
    final stride = cellSize + gap;
    final col = ((local.dx - boardPadding) / stride).floor();
    final row = ((local.dy - boardPadding) / stride).floor();
    if (col < -shapeWidth ||
        row < -shapeHeight ||
        col >= boardSize ||
        row >= boardSize) {
      return null;
    }
    return Point(col, row);
  }
}
