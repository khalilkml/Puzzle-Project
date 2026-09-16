# Block Puzzle

Simple addictive 2D block puzzle (Block Blast–style) built with Flutter.

## Features (Milestones 1–3)

- Pure Dart 8×8 board engine with shape catalog, placement, line clears, and game-over detection
- Provider-based `GameController` with score, best score, combo multipliers, and a 3-piece tray
- Local high-score persistence via `shared_preferences`
- Dark mobile UI with scoreboard, draggable shapes, hover preview, and reserved AdMob banner slot

## Run

```bash
cd block_puzzle
flutter pub get
flutter run
```

## Test

```bash
cd block_puzzle
flutter test
```

## Layout

```
lib/
  game/board.dart
  state/game_controller.dart
  services/score_storage.dart
  ui/game_screen.dart
  main.dart
```
