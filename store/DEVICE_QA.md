# Cubex — device QA (production ads)

Run on a **physical Android device** (or emulator with Google Play services) using a release/internal build with production ad units:

```bash
flutter run --release --dart-define=USE_TEST_ADS=false
```

Or install the AAB/APK from Play internal testing after upload.

Package under test: `com.khalil.block_puzzle` · Display name: **Cubex**

## Script

| # | Step | Expected |
| --- | --- | --- |
| 1 | Cold start the app | Game UI loads. Bottom banner slot shows a real banner **or** fails gracefully (placeholder / empty slot). App does not crash. |
| 2 | Play until **death #1** → tap **Play Again** | New game starts. **No interstitial** yet (cadence is every 2 deaths). |
| 3 | Play until **death #2** → tap **Play Again** | **One** interstitial shows (then dismisses). New game continues. |
| 4 | Later game over → tap **Watch Ad to Revive** | Rewarded ad plays; after earn reward, board clears space and play continues. |
| 5 | Force game over again in the **same** run | Revive is **unavailable** (button missing/disabled or already used). Only **Play Again**. |
| 6 | Enable **Airplane mode**, open app / play | Core game (place, clear, score, new game) still works. Ads may fail; Revive disabled if not ready. No crash. |

## Pass / fail notes

- Interstitial must not fire on first Play Again after death #1.
- Interstitial and rewarded must not stack in the same button action.
- Banner / rewarded fill failures must not block Play Again or placement.

Record device model, Android version, and build number when filing issues.
