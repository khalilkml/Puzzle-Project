# Block Puzzle

Simple addictive 2D block puzzle (Block Blast-style) built with Flutter widgets + Provider. Game rules stay in pure Dart.

## Features

- 8x8 engine with shape catalog, placement, line clears, combos, and game-over detection
- 3-piece tray, local high score, dark drag-and-drop UI
- Sounds + haptics on place, clear, combo, invalid drop, revive, and game over
- AdMob: reserved banner, interstitial every 2 game overs, rewarded Revive
- Clear bursts, combo banner, placement pop, score-based shape weighting

## Run

```bash
flutter pub get
flutter run
```

Use Google test ads by default. For release, replace the AdMob App IDs in:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

and pass production unit IDs:

```bash
flutter run --release \
  --dart-define=USE_TEST_ADS=false \
  --dart-define=ADMOB_ANDROID_BANNER=ca-app-pub-xxxx/yyyy \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL=ca-app-pub-xxxx/yyyy \
  --dart-define=ADMOB_ANDROID_REWARDED=ca-app-pub-xxxx/yyyy
```

## Test

```bash
flutter test
```

## Layout

```
lib/
  game/board.dart
  state/game_controller.dart
  services/score_storage.dart
  services/feedback_service.dart
  ads/
  ui/
  main.dart
store/
  listing.md
  privacy.md
```
