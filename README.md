# Cubex

Simple addictive 2D block puzzle (Block Blast-style) built with Flutter widgets + Provider. Game rules stay in pure Dart.

**Package:** `com.khalil.block_puzzle`  
**Privacy:** https://sites.google.com/view/cubexgame/accueil  
**Contact:** khalilkml23@gmail.com

## Features

- 8x8 engine with shape catalog, placement, line clears, combos, and game-over detection
- 3-piece tray, local high score, dark drag-and-drop UI
- Sounds + haptics on place, clear, combo, invalid drop, revive, and game over
- AdMob: reserved banner, interstitial every 2 game overs, rewarded Revive (once per game)
- Clear bursts, combo banner, placement pop, score-based shape weighting

## Run (debug / test ads — default)

```bash
flutter pub get
flutter run
```

By default `USE_TEST_ADS=true`, so banner / interstitial / rewarded use **Google sample unit IDs**. Safe for everyday debug and profile runs.

Equivalent explicit command:

```bash
flutter run --dart-define=USE_TEST_ADS=true
```

## Run / build with production ads

App IDs in `AndroidManifest.xml` and `ios/Runner/Info.plist` are already set to the Cubex AdMob App ID. Pass `USE_TEST_ADS=false` so unit IDs resolve to production:

```bash
flutter run --release --dart-define=USE_TEST_ADS=false
```

```bash
flutter build appbundle --release --dart-define=USE_TEST_ADS=false
```

Optional overrides (defaults are already the Cubex production units):

```bash
flutter run --release \
  --dart-define=USE_TEST_ADS=false \
  --dart-define=ADMOB_ANDROID_BANNER=ca-app-pub-4915614459591600/8294903854 \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL=ca-app-pub-4915614459591600/6473099454 \
  --dart-define=ADMOB_ANDROID_REWARDED=ca-app-pub-4915614459591600/8197691773
```

## Configured AdMob (production)

| Slot | ID |
| --- | --- |
| App ID (Android / iOS) | `ca-app-pub-4915614459591600~8528864261` |
| Banner | `ca-app-pub-4915614459591600/8294903854` |
| Interstitial | `ca-app-pub-4915614459591600/6473099454` |
| Rewarded | `ca-app-pub-4915614459591600/8197691773` |

Pacing: interstitial every 2 deaths (never before the first); rewarded revive once per game; if an ad fails to load, gameplay continues and Revive stays disabled until ready.

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
