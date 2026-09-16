# Play Store / App Store listing — Cubex

Keep screenshots in `store/screenshots/` (create from a real device or emulator before submit).

Ship docs: [PLAY_SHIP.md](PLAY_SHIP.md) · [DEVICE_QA.md](DEVICE_QA.md) · [MONETIZATION_LAUNCH.md](MONETIZATION_LAUNCH.md)

## Khalil upload checklist

- [ ] Create upload keystore + `android/key.properties` (from `android/key.properties.example`) — see [PLAY_SHIP.md](PLAY_SHIP.md)
- [ ] Build AAB: `flutter build appbundle --release --dart-define=USE_TEST_ADS=false`
- [ ] Upload AAB to Play Console (package must be `com.khalil.block_puzzle`)
- [ ] Paste listing copy below (title, short, full description)
- [ ] Set privacy policy URL + contact email in Play Console
- [ ] Capture screenshots (shot list below) + feature graphic
- [ ] Complete Data safety + Ads declaration (AdMob notes below)
- [ ] Run [DEVICE_QA.md](DEVICE_QA.md) on internal testing track
- [ ] Promote to production when QA passes

## App identity

| Field | Value |
| --- | --- |
| App name | Cubex |
| Package / applicationId | `com.khalil.block_puzzle` |
| Privacy policy URL | https://sites.google.com/view/cubexgame/accueil |
| Contact email | khalilkml23@gmail.com |

## AdMob (configured in project)

| Slot | Unit / App ID |
| --- | --- |
| App ID (Android / iOS) | `ca-app-pub-4915614459591600~8528864261` |
| Banner | `ca-app-pub-4915614459591600/8294903854` |
| Interstitial | `ca-app-pub-4915614459591600/6473099454` |
| Rewarded | `ca-app-pub-4915614459591600/8197691773` |

Debug/profile defaults to Google **test** ad units (`USE_TEST_ADS=true`). Release AAB must use `--dart-define=USE_TEST_ADS=false`.

## Title

Cubex

## Short description (80 characters max)

Drag colorful blocks, clear lines, and chase combos in a fast 8x8 puzzle.

## Full description

Cubex is a quick, satisfying block-blast style game.

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

block puzzle, block blast, wood blocks, line clear, casual puzzle, drag and drop, Cubex

## Content rating

Everyone. Ads are shown (banner, interstitial, rewarded). No user-generated content.

## Privacy & contact

- Privacy policy: https://sites.google.com/view/cubexgame/accueil
- Support: khalilkml23@gmail.com

## Screenshot shot list (phone, portrait)

Capture from a release or `flutter run --release --dart-define=USE_TEST_ADS=false` build. Debug banner is already off.

| Shot | Content | Suggested size |
| --- | --- | --- |
| 1 | Empty / early board + 3-piece tray + scoreboard (Cubex first impression) | 1080 x 1920 |
| 2 | Mid-game with a line clear / combo juice visible | 1080 x 1920 |
| 3 | Game Over dialog showing score + **Watch Ad to Revive** | 1080 x 1920 |
| 4 | Optional: high score / dense board near endgame | 1080 x 1920 |

Save under `store/screenshots/` (local; not required in git).

## Feature graphic

| Asset | Size | Notes |
| --- | --- | --- |
| Feature graphic | **1024 x 500** PNG/JPG | Dark Cubex board + one combo burst; no excessive text |
| Hi-res icon | 512 x 512 | Play Console; launcher adaptive icon already in app |
| 7-inch tablet | 1200 x 1920 | Optional |

## Data safety / ads declaration (AdMob)

When filling Play Console **Data safety** and **Ads**:

- App **contains ads** (Google AdMob): banner, interstitial, rewarded.
- Collects / may share advertising ID and approximate diagnostics via Google’s ad SDKs (declare per Play’s AdMob guidance).
- App does **not** require account login; only local high score on device.
- Privacy policy URL required: https://sites.google.com/view/cubexgame/accueil
- Contact: khalilkml23@gmail.com

## Repo release checklist (engineering)

- [x] Production AdMob App IDs in AndroidManifest and Info.plist
- [x] Production ad unit IDs wired in AdConfig (`USE_TEST_ADS=false` for release)
- [x] App name Cubex + package `com.khalil.block_puzzle`
- [x] Privacy policy URL + contact email documented
- [x] Sound assets under `assets/sounds/`
- [x] Release signing wired via `key.properties` (template committed; secrets gitignored)
- [x] Ship docs: PLAY_SHIP.md, DEVICE_QA.md, MONETIZATION_LAUNCH.md
- [ ] Create upload keystore + real `key.properties` (**Waiting on Khalil**)
- [ ] Capture screenshots / feature graphic (**Waiting on Khalil**)
- [ ] Upload AAB + complete Play Console forms (**Waiting on Khalil**)
- [ ] Full iOS SKAdNetwork list (iOS later)
