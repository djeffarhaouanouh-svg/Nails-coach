import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/purchase_service.dart';

class _PremiumNotifier extends StateNotifier<AsyncValue<bool>> {
  _PremiumNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  StreamSubscription<CustomerInfo>? _sub;

  void _init() {
    // Seed with last known value so the UI doesn't flicker on re-navigation
    final cached = PurchaseService.lastCustomerInfo;
    if (cached != null) {
      state = AsyncValue.data(
        cached.entitlements.active.containsKey(kEntitlementPro),
      );
    }

    // Stay in sync with every SDK update (purchase, restore, foreground refresh)
    _sub = PurchaseService.customerInfoStream.listen(
      (info) => state = AsyncValue.data(
        info.entitlements.active.containsKey(kEntitlementPro),
      ),
      onError: (Object e, StackTrace st) =>
          state = AsyncValue.error(e, st),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Reactive premium status.
///
/// ```dart
/// final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
/// ```
final isPremiumProvider =
    StateNotifierProvider<_PremiumNotifier, AsyncValue<bool>>(
  (_) => _PremiumNotifier(),
);
