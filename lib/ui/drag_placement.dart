import 'dart:math';

import 'package:flutter/material.dart';

/// Shared drag → board mapping so floating feedback and hover/drop stay in sync.
///
/// Offset contract (pointerDragAnchor = feedback top-left starts at the finger):
/// - [feedbackLift] is the ONLY vertical/horizontal bias applied to the floating
///   piece. Hover shadow and final drop MUST add this same offset to the pointer
///   before converting to board cells (`originForPointer`).
/// - We center the piece on the finger (`-width/2`, `-height/2`) then nudge it
///   up by [liftCells] strides (~0.75 cell) so the fingertip does not fully
///   cover the art — Block Blast style, NOT "entire piece above the finger".
class DragPlacement {
  /// Small upward bias in cell strides after centering on the finger.
  static const double liftCells = 0.75;

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
    return Offset(-width / 2, -height / 2 - stride * liftCells);
  }

  /// Board cell origin (x = col, y = row) for the shape's top-left under [globalPointer].
  ///
  /// Uses the same [feedbackLift] as the floating preview so shadow cells match
  /// the piece the player sees; release places on those same cells.
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
