# RevenueCat setup for Nails-coach

## 1. Dashboard configuration

### Products (App Store Connect / Google Play)

Create these product identifiers in your stores and in RevenueCat:

| Product ID (code) | Type   | Description  |
|-------------------|--------|---------------|
| `monthly`         | Subscription | Monthly  |
| `yearly`          | Subscription | Yearly   |
| `lifetime`         | Non-consumable | Lifetime |

In RevenueCat: **Project → Products** → add each product and link to your store product IDs.

### Entitlement: Nails-coach Pro

1. **Project → Entitlements** → create entitlement with identifier: **`pro`** (display name can be "Nails-coach Pro").
2. Attach the products above to this entitlement so that any of them unlocks "pro".

### Offerings & packages

1. **Project → Offerings** → create an offering (e.g. "default").
2. Add **Packages** and map store products:
   - Package identifier `monthly` → product `monthly`
   - Package identifier `yearly` → product `yearly`
   - Package identifier `lifetime` → product `lifetime`
3. Set one offering as **Current**.

### Paywall (optional but recommended)

1. **Tools → Paywalls** → create a paywall for your current offering.
2. Design the paywall in the editor; the app will show it when you call `PurchaseService.presentPaywall()` or when using "Voir les offres (RevenueCat)" on the subscription screen.

### Customer Center (optional, Pro/Enterprise plan)

1. **Tools → Customer Center** → configure options (restore, manage subscription, contact support, etc.).
2. The app calls `PurchaseService.presentCustomerCenter()` from Profile → "Gérer mon abonnement".

## 2. API keys

- **Test**: The app uses the test key `test_VzMlyNEcVgouqKYszrYxKAqNrRM` by default (see `lib/data/services/purchase_service.dart`).
- **Production**: In `main.dart`, call with platform-specific keys:
  ```dart
  await PurchaseService.init(
    androidApiKey: 'goog_xxxx',  // from RevenueCat dashboard
    iosApiKey: 'appl_xxxx',
  );
  ```
  Or set only one if you are building for a single platform.

## 3. App usage

- **Entitlement check**: `PurchaseService.isPro()` or `PurchaseService.getCustomerInfo()` then `customerInfo.entitlements.active.containsKey('pro')`.
- **Customer updates**: `PurchaseService.customerInfoStream` for reactive UI.
- **Show paywall**: `PurchaseService.presentPaywall()` or `PurchaseService.presentPaywallIfNeeded('pro')`.
- **Manage subscription**: `PurchaseService.presentCustomerCenter()`.

## 4. References

- [RevenueCat Flutter installation](https://www.revenuecat.com/docs/getting-started/installation/flutter)
- [Paywalls](https://www.revenuecat.com/docs/tools/paywalls)
- [Customer Center](https://www.revenuecat.com/docs/tools/customer-center)
