import 'dart:math';

class Shape {
  final String id;
  final int colorId;
  final List<Point<int>> cells;

  const Shape({
    required this.id,
    required this.colorId,
    required this.cells,
  });

  int get blockCount => cells.length;

  int get width {
    if (cells.isEmpty) return 0;
    return cells.map((c) => c.x).reduce(max) - cells.map((c) => c.x).reduce(min) + 1;
  }

  int get height {
    if (cells.isEmpty) return 0;
    return cells.map((c) => c.y).reduce(max) - cells.map((c) => c.y).reduce(min) + 1;
  }

  Shape copyWith({String? id, int? colorId, List<Point<int>>? cells}) {
    return Shape(
      id: id ?? this.id,
      colorId: colorId ?? this.colorId,
      cells: cells ?? this.cells,
    );
  }
}

class ShapeCatalog {
  static const List<Shape> all = [
    Shape(id: 'mono', colorId: 1, cells: [Point(0, 0)]),
    Shape(id: 'domino_h', colorId: 2, cells: [Point(0, 0), Point(1, 0)]),
    Shape(id: 'domino_v', colorId: 2, cells: [Point(0, 0), Point(0, 1)]),
    Shape(id: 'tri_h', colorId: 3, cells: [Point(0, 0), Point(1, 0), Point(2, 0)]),
    Shape(id: 'tri_v', colorId: 3, cells: [Point(0, 0), Point(0, 1), Point(0, 2)]),
    Shape(
      id: 'line4_h',
      colorId: 4,
      cells: [Point(0, 0), Point(1, 0), Point(2, 0), Point(3, 0)],
    ),
    Shape(
      id: 'line4_v',
      colorId: 4,
      cells: [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3)],
    ),
    Shape(
      id: 'line5_h',
      colorId: 5,
      cells: [Point(0, 0), Point(1, 0), Point(2, 0), Point(3, 0), Point(4, 0)],
    ),
    Shape(
      id: 'line5_v',
      colorId: 5,
      cells: [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4)],
    ),
    Shape(
      id: 'square2',
      colorId: 6,
      cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
    ),
    Shape(
      id: 'square3',
      colorId: 7,
      cells: [
        Point(0, 0),
        Point(1, 0),
        Point(2, 0),
        Point(0, 1),
        Point(1, 1),
        Point(2, 1),
        Point(0, 2),
        Point(1, 2),
        Point(2, 2),
      ],
    ),
    Shape(
      id: 'l_small',
      colorId: 8,
      cells: [Point(0, 0), Point(0, 1), Point(1, 1)],
    ),
    Shape(
      id: 'l_small_mirror',
      colorId: 8,
      cells: [Point(1, 0), Point(0, 1), Point(1, 1)],
    ),
    Shape(
      id: 'l_big',
      colorId: 9,
      cells: [Point(0, 0), Point(0, 1), Point(0, 2), Point(1, 2), Point(2, 2)],
    ),
    Shape(
      id: 'l_big_mirror',
      colorId: 9,
      cells: [Point(2, 0), Point(2, 1), Point(0, 2), Point(1, 2), Point(2, 2)],
    ),
    Shape(
      id: 't_small',
      colorId: 10,
      cells: [Point(0, 0), Point(1, 0), Point(2, 0), Point(1, 1)],
    ),
    Shape(
      id: 't_up',
      colorId: 10,
      cells: [Point(1, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    ),
    Shape(
      id: 's_horizontal',
      colorId: 11,
      cells: [Point(1, 0), Point(2, 0), Point(0, 1), Point(1, 1)],
    ),
    Shape(
      id: 'z_horizontal',
      colorId: 12,
      cells: [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)],
    ),
    Shape(
      id: 'corner',
      colorId: 13,
      cells: [Point(0, 0), Point(0, 1), Point(0, 2), Point(1, 2), Point(2, 2)],
    ),
  ];

  static Shape random(Random rng) {
    final base = all[rng.nextInt(all.length)];
    return base.copyWith(colorId: 1 + rng.nextInt(13));
  }

  static List<Shape> deal(Random rng, [int count = 3]) {
    return List.generate(count, (_) => random(rng));
  }
}

class ClearResult {
  final int rowsCleared;
  final int colsCleared;
  final int cellsCleared;

  const ClearResult({
    required this.rowsCleared,
    required this.colsCleared,
    required this.cellsCleared,
  });

  int get linesCleared => rowsCleared + colsCleared;

  bool get hasClears => linesCleared > 0;
}

class Board {
  static const int size = 8;

  final List<List<int?>> cells;

  Board({List<List<int?>>? cells})
      : cells = cells ??
            List.generate(size, (_) => List<int?>.filled(size, null));

  Board copy() {
    return Board(
      cells: List.generate(
        size,
        (r) => List<int?>.from(cells[r]),
      ),
    );
  }

  bool isInside(int row, int col) {
    return row >= 0 && row < size && col >= 0 && col < size;
  }

  bool canPlaceShape(Shape shape, int row, int col) {
    for (final cell in shape.cells) {
      final r = row + cell.y;
      final c = col + cell.x;
      if (!isInside(r, c)) return false;
      if (cells[r][c] != null) return false;
    }
    return true;
  }

  bool placeShape(Shape shape, int row, int col) {
    if (!canPlaceShape(shape, row, col)) return false;
    for (final cell in shape.cells) {
      cells[row + cell.y][col + cell.x] = shape.colorId;
    }
    return true;
  }

  ClearResult checkAndClearLines() {
    final fullRows = <int>[];
    final fullCols = <int>[];

    for (var r = 0; r < size; r++) {
      if (cells[r].every((cell) => cell != null)) {
        fullRows.add(r);
      }
    }

    for (var c = 0; c < size; c++) {
      var full = true;
      for (var r = 0; r < size; r++) {
        if (cells[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) fullCols.add(c);
    }

    if (fullRows.isEmpty && fullCols.isEmpty) {
      return const ClearResult(rowsCleared: 0, colsCleared: 0, cellsCleared: 0);
    }

    final cleared = <Point<int>>{};
    for (final r in fullRows) {
      for (var c = 0; c < size; c++) {
        cleared.add(Point(c, r));
      }
    }
    for (final c in fullCols) {
      for (var r = 0; r < size; r++) {
        cleared.add(Point(c, r));
      }
    }

    for (final point in cleared) {
      cells[point.y][point.x] = null;
    }

    return ClearResult(
      rowsCleared: fullRows.length,
      colsCleared: fullCols.length,
      cellsCleared: cleared.length,
    );
  }

  bool canPlaceAnywhere(Shape shape) {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (canPlaceShape(shape, r, c)) return true;
      }
    }
    return false;
  }

  bool isGameOver(List<Shape?> tray) {
    final remaining = tray.whereType<Shape>().toList();
    if (remaining.isEmpty) return false;
    return remaining.every((shape) => !canPlaceAnywhere(shape));
  }

  int get filledCount {
    var count = 0;
    for (final row in cells) {
      for (final cell in row) {
        if (cell != null) count++;
      }
    }
    return count;
  }
}
