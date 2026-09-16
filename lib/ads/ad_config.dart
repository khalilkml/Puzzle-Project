class AdConfig {
  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  static const _androidBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const _iosBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );
  static const _androidInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const _iosInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );
  static const _androidRewarded = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const _iosRewarded = String.fromEnvironment(
    'ADMOB_IOS_REWARDED',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313',
  );

  static const androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713',
  );
  static const iosAppId = String.fromEnvironment(
    'ADMOB_IOS_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511',
  );

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

const int kInterstitialEveryNDeaths = 2;
