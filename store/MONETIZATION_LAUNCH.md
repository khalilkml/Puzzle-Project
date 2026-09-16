# Cubex — Monetization Launch Checklist

App: **Cubex**  
Package: `com.khalil.block_puzzle`  
Privacy: https://sites.google.com/view/cubexgame/accueil  
Contact: khalilkml23@gmail.com

## Status

| Item | Status |
| --- | --- |
| Production AdMob App ID (Android + iOS manifests) | **DONE** — `ca-app-pub-4915614459591600~8528864261` |
| Production Banner unit | **DONE** — `ca-app-pub-4915614459591600/8294903854` |
| Production Interstitial unit | **DONE** — `ca-app-pub-4915614459591600/6473099454` |
| Production Rewarded unit | **DONE** — `ca-app-pub-4915614459591600/8197691773` |
| Debug/profile test ads (`USE_TEST_ADS=true` default) | **DONE** |
| Privacy policy URL | **DONE** |
| Contact email | **DONE** |
| App display name Cubex + package id | **DONE** |
| Sound assets (`assets/sounds/*.wav`) | **DONE** (generated; include in next git commit) |
| Play upload keystore / App Signing | **Waiting on Khalil** — see [PLAY_SHIP.md](PLAY_SHIP.md) |
| Play Console listing + AAB upload | **Waiting on Khalil** — see [PLAY_SHIP.md](PLAY_SHIP.md) |
| Store screenshots / feature graphic | **Waiting on Khalil** — shot list in [listing.md](listing.md) |
| Device QA on production ads | **Waiting on Khalil** — [DEVICE_QA.md](DEVICE_QA.md) |
| Full iOS SKAdNetwork list | **Waiting on Khalil** (partial list present) |

## Ad pacing (retention-safe)

- Banner: always reserved slot; placeholder if load fails.
- Interstitial: every **2** game-overs on **Play Again** only; never before first death (`deathCount <= 0` → skip).
- Rewarded Revive: **once per game**; separate from Play Again — not stacked with interstitial in the same action.
- If rewarded fails/not ready: Revive button disabled / no revive; game still playable via Play Again.

## Run modes

```bash
# Debug / test ads (default)
flutter run

# Release / production ad units
flutter run --release --dart-define=USE_TEST_ADS=false
flutter build appbundle --release --dart-define=USE_TEST_ADS=false
```

## ~$50/month metrics notes (lightweight)

Target early revenue band: about **$50/month** eCPM-driven AdMob (banner + interstitial + rewarded). Track weekly in AdMob console:

1. **DAU** and sessions/day (retention proxy).
2. **Impression / DAU** by format (banner should be high; interstitial ~0.3–0.5 per session with every-2-deaths pacing).
3. **Rewarded completion rate** (Revive offers accepted ÷ shown) — keep offer clear; don’t force.
4. **eCPM** by country/format; if interstitial eCPM is strong but churn rises after day 1, keep N=2 (do not tighten to every death).
5. **Fill rate** — if rewarded fill is under ~70%, Revive UX already degrades gracefully (button disabled).

Rough path to ~$50/mo: ~200–400 DAU at blended ~$1–3 eCPM with current three-format mix is a common early-indie range; optimize creatives/screenshots first, not ad frequency.

## Owner next actions (Khalil)

1. Follow [PLAY_SHIP.md](PLAY_SHIP.md): keystore, `key.properties`, build AAB with `USE_TEST_ADS=false`.
2. Capture screenshots + feature graphic; upload AAB; complete Play listing / Data safety.
3. Run [DEVICE_QA.md](DEVICE_QA.md) on internal testing, then watch AdMob metrics 7–14 days.
