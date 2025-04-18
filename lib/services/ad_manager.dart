import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  static final String _interstitialAdUnitId = 'ca-app-pub-7189875059131521/6146624676';
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isInitialized = false;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;
    loadInterstitialAd();
  }

  /// Load the interstitial ad
  Future<void> loadInterstitialAd() async {
    if (_interstitialAd != null) return;

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
            _setupAdCallbacks(ad);
            debugPrint('Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isInterstitialAdReady = false;
            _interstitialAd = null;
            debugPrint('Interstitial ad failed to load: ${error.message}');
            // Retry loading after failure
            Future.delayed(const Duration(minutes: 1), loadInterstitialAd);
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _isInterstitialAdReady = false;
      _interstitialAd = null;
    }
  }

  /// Show the interstitial ad if it's ready
  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      debugPrint('Trying to show interstitial ad before it\'s ready.');
      await loadInterstitialAd();
      return;
    }

    try {
      await _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
      // Load the next ad
      loadInterstitialAd();
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      _isInterstitialAdReady = false;
      _interstitialAd = null;
      loadInterstitialAd();
    }
  }

  /// Set up callbacks for the interstitial ad
  void _setupAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('Interstitial ad showed fullscreen content.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('Interstitial ad dismissed fullscreen content.');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('Interstitial ad failed to show fullscreen content: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        loadInterstitialAd();
      },
    );
  }

  /// Dispose of the current interstitial ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }

  /// Check if the interstitial ad is ready to be shown
  bool get isInterstitialAdReady => _isInterstitialAdReady;
} 