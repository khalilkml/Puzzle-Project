class AdConfig {
  /// Defaults to test ads. Pass `--dart-define=USE_TEST_ADS=false` for production.
  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  // Production unit IDs (Cubex / Khalil). Used when USE_TEST_ADS=false.
  static const _androidBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER',
    defaultValue: 'ca-app-pub-4915614459591600/8294903854',
  );
  static const _iosBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER',
    defaultValue: 'ca-app-pub-4915614459591600/8294903854',
  );
  static const _androidInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL',
    defaultValue: 'ca-app-pub-4915614459591600/6473099454',
  );
  static const _iosInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL',
    defaultValue: 'ca-app-pub-4915614459591600/6473099454',
  );
  static const _androidRewarded = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED',
    defaultValue: 'ca-app-pub-4915614459591600/8197691773',
  );
  static const _iosRewarded = String.fromEnvironment(
    'ADMOB_IOS_REWARDED',
    defaultValue: 'ca-app-pub-4915614459591600/8197691773',
  );

  static const androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-4915614459591600~8528864261',
  );
  static const iosAppId = String.fromEnvironment(
    'ADMOB_IOS_APP_ID',
    defaultValue: 'ca-app-pub-4915614459591600~8528864261',
  );

  // Google sample unit IDs — used while USE_TEST_ADS=true (debug/profile default).
  static const _testAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const _testAndroidRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _testIosRewarded = 'ca-app-pub-3940256099942544/1712485313';

  static String bannerAdUnitId({required bool ios}) {
    if (useTestAds) return ios ? _testIosBanner : _testAndroidBanner;
    return ios ? _iosBanner : _androidBanner;
  }

  static String interstitialAdUnitId({required bool ios}) {
    if (useTestAds) {
      return ios ? _testIosInterstitial : _testAndroidInterstitial;
    }
    return ios ? _iosInterstitial : _androidInterstitial;
  }

  static String rewardedAdUnitId({required bool ios}) {
    if (useTestAds) return ios ? _testIosRewarded : _testAndroidRewarded;
    return ios ? _iosRewarded : _androidRewarded;
  }
}

/// Show interstitial every N game-overs (Play Again). Never before first death.
const int kInterstitialEveryNDeaths = 2;
