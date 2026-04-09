import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

/// Central AppsFlyer tracking service.
/// All conversion events flow through here → AppsFlyer → TikTok Ads.
///
/// Standard AF event names (strings) are used so AppsFlyer maps them
/// automatically to TikTok Ads standard events in the dashboard.
class AppsFlyerService {
  static const _devKey = 'fd2Nx2z2cuLFk3EoPb2Eb';

  /// iOS App Store numeric ID (digits only, no "id" prefix).
  /// TODO: replace with your real App Store ID when published.
  static const _iosAppId = 'YOUR_IOS_APP_STORE_ID';

  static late AppsflyerSdk _sdk;
  static bool _initialized = false;

  /// Call once from main() before runApp().
  static Future<void> init() async {
    final options = AppsFlyerOptions(
      afDevKey: _devKey,
      appId: _iosAppId,
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 15.0,
    );

    _sdk = AppsflyerSdk(options);

    await _sdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _initialized = true;
    debugPrint('[AppsFlyer] ✅ SDK initialized (debug=$kDebugMode)');
  }

  // ─── Private helper ───────────────────────────────────────────────────────

  static void _log(String eventName, [Map<String, Object>? params]) {
    if (!_initialized) {
      debugPrint('[AppsFlyer] ⚠️  Not initialized — skipping $eventName');
      return;
    }
    _sdk.logEvent(eventName, params ?? {});
    debugPrint('[AppsFlyer] 📤 $eventName ${params ?? ""}');
  }

  // ─── Event name constants ─────────────────────────────────────────────────
  // AF standard string names → auto-mapped to TikTok Ads standard events.
  // Source: https://support.appsflyer.com/hc/en-us/articles/115005544169

  static const _evCompleteRegistration = 'af_complete_registration';
  static const _evStartTrial = 'af_start_trial';
  static const _evSubscribe = 'af_subscribe';
  static const _evPurchase = 'af_purchase';

  // ─── Events ───────────────────────────────────────────────────────────────
  // NB: first_open / install est envoyé AUTOMATIQUEMENT par le SDK au premier
  // initSdk(). Ne jamais l'appeler manuellement pour éviter les doublons.

  /// User completed registration / sign-up.
  /// → TikTok: CompleteRegistration
  static void trackSignUp() => _log(_evCompleteRegistration);

  /// User finished onboarding flow.
  /// → TikTok: custom event
  static void trackOnboardingCompleted() => _log('onboarding_completed');

  /// Paywall / subscription screen viewed.
  /// → TikTok: custom event
  static void trackPaywallViewed() => _log('paywall_viewed');

  /// User started a free trial (subscription with trial period).
  /// → TikTok: StartTrial
  static void trackStartTrial({String? planId}) => _log(
        _evStartTrial,
        planId != null ? {'af_order_id': planId} : null,
      );

  /// User subscribed (non-trial / lifetime).
  /// → TikTok: Subscribe
  static void trackSubscribe({String? planId}) => _log(
        _evSubscribe,
        planId != null ? {'af_order_id': planId} : null,
      );

  /// Completed purchase (lifetime).
  /// → TikTok: Purchase
  static void trackPurchase({
    required double price,
    String currency = 'EUR',
    String? productId,
  }) =>
      _log(_evPurchase, {
        'af_revenue': price,
        'af_currency': currency,
        if (productId != null) 'af_content_id': productId,
      });
}
