# Play Store / App Store listing

Keep screenshots in `store/screenshots/` (create from a real device or emulator before submit).

## Title

Block Puzzle

## Short description (80 characters max)

Drag colorful blocks, clear lines, and chase combos in a fast 8x8 puzzle.

## Full description

Block Puzzle is a quick, satisfying block-blast style game.

Drag one of three pieces onto the 8x8 board. Fill a full row or column to clear it. Chain clears for combo multipliers, and empty the board for an All Clear bonus.

Features:
- Smooth drag-and-drop with ghost placement
- Combos, All Clear bonus, and a climbing high score
- Revive with a rewarded ad when you get stuck
- Portrait dark theme built for one-handed play

How to play:
1. Drag a shape from the tray onto the board.
2. Complete rows and columns to clear them.
3. Use all three pieces to deal a new set.
4. Game over when none of the remaining pieces fit. Watch an ad to revive once per game.

## Keywords

block puzzle, block blast, wood blocks, line clear, casual puzzle, drag and drop

## Content rating

Everyone. Ads are shown (banner, interstitial, rewarded). No user-generated content.

## Graphics

| Asset | Size | Notes |
| --- | --- | --- |
| App icon | 512 x 512 | Adaptive icon already uses the Flutter launcher |
| Feature graphic | 1024 x 500 | Dark board + one combo burst |
| Phone screenshots | 1080 x 1920 | Empty board, mid-game combo, game-over revive |
| 7-inch tablet | 1200 x 1920 | Optional |

Capture from `flutter run` on a device. Hide the debug banner (already off).

## Release checklist

- [ ] Replace test AdMob App IDs in AndroidManifest and Info.plist
- [ ] Pass production ad unit IDs with `--dart-define=USE_TEST_ADS=false`
- [ ] Add the full SKAdNetwork list from Google before iOS release
- [ ] Create a Play App Signing key (debug signing is only for local `--release`)
- [ ] Enable `isMinifyEnabled = true` in `android/app/build.gradle.kts` if you ship R8
- [ ] Privacy policy URL (see `store/privacy.md`)
