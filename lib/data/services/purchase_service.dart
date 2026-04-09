import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'api_service.dart';

// ─── Package identifiers (must match RevenueCat Dashboard exactly) ──────────
/// Monthly subscription package
const String kProductMonthly = '1:monthly';

/// Weekly subscription package
const String kProductWeekly = '1:premium-weekly';

/// One-time lifetime purchase package
const String kProductLifetime = 'premium_lifetime';

// ─── Entitlement identifier (must match RevenueCat Dashboard exactly) ────────
const String kEntitlementPro = 'Nails-coach Pro';

// ignore: avoid_print
void _log(String msg) => print('[RC] $msg');

/// RevenueCat purchase and subscription service.
class PurchaseService {
  static bool _initialized = false;
  static CustomerInfo? _lastCustomerInfo;
  static final _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  static Stream<CustomerInfo> get customerInfoStream =>
      _customerInfoController.stream;

  static CustomerInfo? get lastCustomerInfo => _lastCustomerInfo;

  /// Initialise RevenueCat. Call once in [main] before [runApp].
  static Future<void> init({
    String? androidApiKey,
    String? iosApiKey,
    String? appUserId,
  }) async {
    if (_initialized) return;

    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('INIT — start');
    _log('  androidApiKey : ${androidApiKey ?? "(none)"}');
    _log('  appUserId     : ${appUserId ?? "(none — anonymous)"}');

    await Purchases.setLogLevel(
      kDebugMode ? LogLevel.verbose : LogLevel.info,
    );

    final apiKey = androidApiKey ?? iosApiKey ?? '';
    final configuration = PurchasesConfiguration(apiKey)
      ..appUserID = appUserId;

    await Purchases.configure(configuration);
    _initialized = true;
    _log('INIT — Purchases.configure() OK');

    // Listen to SDK-level updates (app foreground, webhook push, etc.)
    Purchases.addCustomerInfoUpdateListener(_updateCustomerInfo);
    _log('INIT — customerInfoUpdateListener registered');

    try {
      _log('INIT — fetching initial CustomerInfo…');
      final info = await Purchases.getCustomerInfo();
      _updateCustomerInfo(info);
      _log('INIT — CustomerInfo fetched OK');
    } catch (e) {
      _log('INIT — ⚠️  initial CustomerInfo fetch FAILED: $e');
    }

    _log('INIT — done');
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void _updateCustomerInfo(CustomerInfo info) {
    _lastCustomerInfo = info;
    final active = info.entitlements.active;
    final isPro = active.containsKey(kEntitlementPro);
    _log('customerInfo UPDATE — entitlements.active: ${active.keys.toList()}');
    _log('customerInfo UPDATE — isPremium ("$kEntitlementPro"): $isPro');
    if (!isPro) {
      _log('customerInfo UPDATE — ⚠️  entitlement NOT active (not purchased or expired)');
    }
    if (!_customerInfoController.isClosed) {
      _customerInfoController.add(info);
    }
  }

  /// Returns whether the user has an active "Nails-coach Pro" entitlement.
  static Future<bool> isPro() async {
    _log('isPro() — checking…');
    try {
      final info = await getCustomerInfo();
      final result = info.entitlements.active.containsKey(kEntitlementPro);
      _log('isPro() — result: $result');
      return result;
    } catch (e) {
      _log('isPro() — ⚠️  error: $e → returning false');
      return false;
    }
  }

  /// Fetches the latest [CustomerInfo] from RevenueCat (network).
  static Future<CustomerInfo> getCustomerInfo() async {
    final info = await Purchases.getCustomerInfo();
    _updateCustomerInfo(info);
    return info;
  }

  /// Gets current offerings.
  static Future<Offerings?> getOfferings() async {
    _log('getOfferings() — fetching…');
    try {
      final offerings = await Purchases.getOfferings();
      _log('getOfferings() — offerings.all keys: ${offerings.all.keys.toList()}');

      if (offerings.current == null) {
        _log('getOfferings() — ⚠️  offerings.current is NULL');
        _log('getOfferings() —    → Go to RevenueCat dashboard > Offerings and set a "Current" offering');
        _log('getOfferings() —    → The paywall will still work via keyword-matching on all offerings');
      } else {
        _log('getOfferings() — current offering: "${offerings.current!.identifier}"');
      }

      // Dump de TOUS les packages de TOUTES les offerings
      final seen = <String>{};
      for (final entry in offerings.all.entries) {
        _log('  offering "${entry.key}" (${entry.value.availablePackages.length} packages):');
        for (final p in entry.value.availablePackages) {
          if (seen.add(p.storeProduct.identifier)) {
            _log('    • package.id="${p.identifier}"'
                '  storeProduct.id="${p.storeProduct.identifier}"'
                '  title="${p.storeProduct.title}"'
                '  price="${p.storeProduct.priceString}"');
          }
        }
      }

      if (seen.isEmpty) {
        _log('getOfferings() — ❌ NO packages found anywhere — check RC dashboard configuration');
      }

      return offerings;
    } catch (e) {
      _log('getOfferings() — ❌ ERROR: $e');
      return null;
    }
  }

  /// Purchases a package. Returns updated [CustomerInfo] on success.
  ///
  /// After [purchasePackage] returns, we **always force a fresh network fetch**
  /// of CustomerInfo because Google Play sometimes validates asynchronously and
  /// the info returned by purchasePackage() may not yet show the entitlement.
  static Future<CustomerInfo> purchase(Package package) async {
    _log('━━━━ purchase started ━━━━');
    _log('  package.identifier     : ${package.identifier}');
    _log('  storeProduct.identifier: ${package.storeProduct.identifier}');
    _log('  price                  : ${package.storeProduct.priceString}');
    _log('  appUserId              : ${_lastCustomerInfo?.originalAppUserId ?? "(not yet fetched)"}');
    _log('  → opening Google Play Billing…');

    final rawInfo = await Purchases.purchasePackage(package);
    _log('purchase success — raw entitlements.active: ${rawInfo.entitlements.active.keys.toList()}');

    // Force a fresh network fetch — Play can be slightly behind
    _log('customer info refreshed (forced network fetch)…');
    CustomerInfo info;
    try {
      info = await Purchases.getCustomerInfo();
      _log('customer info refreshed — entitlements.active: ${info.entitlements.active.keys.toList()}');
    } catch (e) {
      _log('⚠️  forced refresh failed ($e) — using raw purchasePackage result');
      info = rawInfo;
    }

    final isPremium = info.entitlements.active.containsKey(kEntitlementPro);
    _log('isPremium = $isPremium');
    if (!isPremium) {
      _log('⚠️  entitlement "$kEntitlementPro" still NOT active after refresh');
      _log('   → check RC dashboard: is "$kEntitlementPro" linked to "${package.storeProduct.identifier}"?');
    }

    _updateCustomerInfo(info);
    _syncSubscriptionToNeon(info, productId: package.storeProduct.identifier);
    return info;
  }

  /// Restores previous purchases. Returns updated [CustomerInfo].
  static Future<CustomerInfo> restorePurchases() async {
    _log('restorePurchases() — calling Purchases.restorePurchases()…');
    final info = await Purchases.restorePurchases();
    final isPro = info.entitlements.active.containsKey(kEntitlementPro);
    _log('restorePurchases() — done. entitlement active: $isPro');
    _updateCustomerInfo(info);
    _syncSubscriptionToNeon(info, status: 'restored');
    return info;
  }

  /// Sync l'état d'abonnement vers Neon
  static void _syncSubscriptionToNeon(
    CustomerInfo info, {
    String? productId,
    String? status,
  }) {
    final isPro = info.entitlements.active.containsKey(kEntitlementPro);
    final userId = info.originalAppUserId;

    String resolvedProductId = productId ?? 'unknown';
    DateTime? expiresAt;

    if (info.entitlements.active.containsKey(kEntitlementPro)) {
      final entitlement = info.entitlements.active[kEntitlementPro]!;
      resolvedProductId = productId ?? entitlement.productIdentifier;
      final expStr = entitlement.expirationDate;
      if (expStr != null) expiresAt = DateTime.tryParse(expStr);
    }

    ApiService.logSubscription(
      userId: userId,
      revenueCatUserId: userId,
      productId: resolvedProductId,
      status: status ?? (isPro ? 'active' : 'expired'),
      isPro: isPro,
      purchasedAt: DateTime.now(),
      expiresAt: expiresAt,
    );
  }

  // ─── RevenueCat Paywall (purchases_ui_flutter) ────────────────────────────

  static Future<PaywallResult> presentPaywallIfNeeded() async {
    return RevenueCatUI.presentPaywallIfNeeded(
      kEntitlementPro,
      displayCloseButton: true,
    );
  }

  static Future<PaywallResult> presentPaywall({
    Offering? offering,
    bool displayCloseButton = true,
  }) async {
    return RevenueCatUI.presentPaywall(
      offering: offering,
      displayCloseButton: displayCloseButton,
    );
  }

  // ─── Customer Center ─────────────────────────────────────────────────────

  static Future<void> presentCustomerCenter() async {
    await RevenueCatUI.presentCustomerCenter();
    try {
      await getCustomerInfo();
    } catch (_) {}
  }

  @visibleForTesting
  static void disposeStream() {
    _customerInfoController.close();
  }
}
