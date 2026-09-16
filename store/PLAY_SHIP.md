# Cubex — Play Store ship pack

App: **Cubex**  
Package / applicationId: `com.khalil.block_puzzle`  
Launcher label: **Cubex**  
Privacy: https://sites.google.com/view/cubexgame/accueil  
Contact: khalilkml23@gmail.com

Related docs: [listing.md](listing.md) · [MONETIZATION_LAUNCH.md](MONETIZATION_LAUNCH.md) · [DEVICE_QA.md](DEVICE_QA.md)

## 1. Create an upload keystore (once — Khalil)

Run from the `android/` folder (or adjust paths). **Do not commit** the `.jks` or real `key.properties`.

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Suggested location: `android/upload-keystore.jks` (gitignored).

## 2. Local signing config (never commit secrets)

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties` with your real passwords and paths:

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=../upload-keystore.jks
```

`storeFile` is resolved relative to `android/app/` (so `../upload-keystore.jks` means `android/upload-keystore.jks`).

If `key.properties` is missing, the Gradle release build falls back to the **debug** keystore (local-only; not for Play upload).

## 3. Build the production AAB

From the repo root:

```bash
flutter pub get
flutter build appbundle --release --dart-define=USE_TEST_ADS=false
```

Output:

```
build/app/outputs/bundle/release/app-release.aab
```

Confirm before upload:

- applicationId `com.khalil.block_puzzle`
- App shows as **Cubex**
- Built with `USE_TEST_ADS=false` (production AdMob unit IDs)

Optional version bump in `pubspec.yaml` (`version: x.y.z+build`).

## 4. Play Console (Khalil)

1. Create app **Cubex** with package `com.khalil.block_puzzle` (must match AAB).
2. Enable Play App Signing; upload the AAB (or enroll with your upload key).
3. Fill listing from [listing.md](listing.md) (title, short/full description, privacy URL, contact).
4. Add screenshots + feature graphic (see shot list in listing).
5. Complete Data safety / Ads declarations (AdMob — see listing).
6. Run [DEVICE_QA.md](DEVICE_QA.md) on a real device with a release or internal-testing build.
7. Submit internal testing → production when ready.

## 5. What stays out of git

| File | Git |
| --- | --- |
| `android/key.properties.example` | committed (template) |
| `android/key.properties` | **ignored** |
| `*.jks` / `*.keystore` | **ignored** |
| `store/screenshots/*` | optional local captures |

Never paste keystore passwords into chat, issues, or the repo.
