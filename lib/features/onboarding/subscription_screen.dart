import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/mascot_widget.dart';
import '../../data/services/purchase_service.dart';
import '../../data/services/appsflyer_service.dart';
import '../../main.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';

// ignore: avoid_print
void _log(String msg) => print('[RC:Paywall] $msg');

enum _Plan { lifetime, monthly, weekly }

// ─── Robust package finder ────────────────────────────────────────────────────
//
// Cherche dans TOUTES les offerings (pas seulement "current") pour résister
// au cas où "current offering" n'est pas définie dans le dashboard RevenueCat.
//
// Priorité de matching :
//   1. Identifiant standard RevenueCat ($rc_monthly, $rc_weekly, $rc_lifetime)
//   2. Identifiant de package contenant le mot-clé (monthly, weekly, lifetime…)
//   3. Identifiant du storeProduct contenant le mot-clé

Package? _findPackage(Offerings offerings, _Plan plan) {
  // Collecte tous les packages de toutes les offerings (dédupliqués par storeProduct.identifier)
  final seen = <String>{};
  final all = <Package>[];

  // Priorité : current d'abord, puis le reste
  final current = offerings.current;
  if (current != null) {
    for (final p in current.availablePackages) {
      if (seen.add(p.storeProduct.identifier)) all.add(p);
    }
  }
  for (final offering in offerings.all.values) {
    for (final p in offering.availablePackages) {
      if (seen.add(p.storeProduct.identifier)) all.add(p);
    }
  }

  if (all.isEmpty) {
    _log('_findPackage — ⚠️  no packages found across all offerings');
    return null;
  }

  // Identifiants standard RevenueCat
  final rcId = switch (plan) {
    _Plan.monthly => r'$rc_monthly',
    _Plan.weekly => r'$rc_weekly',
    _Plan.lifetime => r'$rc_lifetime',
  };

  // Mots-clés de fallback
  final keywords = switch (plan) {
    _Plan.monthly => ['monthly', 'month'],
    _Plan.weekly => ['weekly', 'week'],
    _Plan.lifetime => ['lifetime', 'life'],
  };

  // 1. Match exact sur l'identifiant RC standard
  for (final p in all) {
    if (p.identifier == rcId) {
      _log('_findPackage — ✅ found "$plan" via RC standard id "${p.identifier}"');
      return p;
    }
  }

  // 2. Keyword match sur package.identifier
  for (final p in all) {
    final pid = p.identifier.toLowerCase();
    for (final kw in keywords) {
      if (pid.contains(kw)) {
        _log('_findPackage — ✅ found "$plan" via package.identifier keyword "$kw" → "${p.identifier}"');
        return p;
      }
    }
  }

  // 3. Keyword match sur storeProduct.identifier
  for (final p in all) {
    final spid = p.storeProduct.identifier.toLowerCase();
    for (final kw in keywords) {
      if (spid.contains(kw)) {
        _log('_findPackage — ✅ found "$plan" via storeProduct.identifier keyword "$kw" → "${p.storeProduct.identifier}"');
        return p;
      }
    }
  }

  _log('_findPackage — ❌ NO package matched for "$plan"');
  _log('_findPackage —    all packages searched:');
  for (final p in all) {
    _log('      • package.id="${p.identifier}"  storeProduct.id="${p.storeProduct.identifier}"');
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  _Plan _selected = _Plan.monthly;
  Offerings? _offerings;
  bool _isPurchasing = false;
  bool _loadingOfferings = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPremiumThenLoad();
    AppsFlyerService.trackPaywallViewed();
    try {
      mixpanel.track('paywall_viewed');
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when user returns from Google Play (app comes back to foreground).
  /// Forces a CustomerInfo refresh so the entitlement is read immediately.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPurchasing) {
      _log('app resumed while purchasing → forcing CustomerInfo refresh');
      _refreshAndCheckPremium();
    }
  }

  Future<void> _refreshAndCheckPremium() async {
    try {
      _log('refreshAndCheckPremium — fetching CustomerInfo…');
      final info = await PurchaseService.getCustomerInfo();
      final isPro = info.entitlements.active.containsKey(kEntitlementPro);
      _log('customer info refreshed — entitlements.active: ${info.entitlements.active.keys.toList()}');
      _log('isPremium = $isPro');
      if (!mounted) return;
      if (isPro) {
        _log('isPremium = true → navigating to app');
        setState(() => _isPurchasing = false);
        _goToApp();
      }
    } catch (e) {
      _log('⚠️  refreshAndCheckPremium error: $e');
    }
  }

  Future<void> _checkPremiumThenLoad() async {
    _log('━━━━ SubscriptionScreen init ━━━━');
    _log('checking isPro…');
    final alreadyPro = await PurchaseService.isPro();
    if (!mounted) return;
    if (alreadyPro) {
      _log('already PRO → skipping paywall');
      _goToApp();
      return;
    }
    _log('not PRO → loading offerings');
    final offerings = await PurchaseService.getOfferings();
    if (!mounted) return;

    if (offerings == null) {
      _log('❌ getOfferings() returned null — network error?');
    } else {
      _log('offerings.all keys: ${offerings.all.keys.toList()}');
      _log('offerings.current: ${offerings.current?.identifier ?? "NULL ⚠️  (set a Current Offering in RC dashboard)"}');

      // Dump complet de tous les packages disponibles
      final seen = <String>{};
      for (final entry in offerings.all.entries) {
        for (final p in entry.value.availablePackages) {
          if (seen.add(p.storeProduct.identifier)) {
            _log('  [${entry.key}] package.id="${p.identifier}"'
                '  storeProduct.id="${p.storeProduct.identifier}"'
                '  title="${p.storeProduct.title}"'
                '  price="${p.storeProduct.priceString}"');
          }
        }
      }

      // Vérifie que chaque plan est trouvable
      for (final plan in _Plan.values) {
        final pkg = _findPackage(offerings, plan);
        if (pkg == null) {
          _log('⚠️  plan $plan → NO matching package found');
        } else {
          _log('✅  plan $plan → "${pkg.storeProduct.identifier}" (${pkg.storeProduct.priceString})');
        }
      }
    }

    setState(() {
      _offerings = offerings;
      _loadingOfferings = false;
    });
  }

  Package? _packageFor(_Plan plan) {
    if (_offerings == null) return null;
    return _findPackage(_offerings!, plan);
  }

  /// Prix affiché : utilise celui de RevenueCat si dispo, sinon fallback hardcodé.
  String _priceFor(_Plan plan) {
    final pkg = _packageFor(plan);
    if (pkg != null) return pkg.storeProduct.priceString;
    return switch (plan) {
      _Plan.lifetime => '29,97 €',
      _Plan.monthly => '7,97 €',
      _Plan.weekly => '4,97 €',
    };
  }

  void _goToApp() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  Future<void> _purchase() async {
    final pkg = _packageFor(_selected);
    _log('━━━━ _purchase() ━━━━');
    _log('selected plan: $_selected');

    if (pkg == null) {
      _log('❌ package is NULL — cannot purchase');
      _showError('Offres non disponibles. Vérifiez votre connexion et réessayez.');
      return;
    }

    _log('package.identifier    : ${pkg.identifier}');
    _log('storeProduct.identifier: ${pkg.storeProduct.identifier}');
    _log('price                 : ${pkg.storeProduct.priceString}');
    _log('→ calling Purchases.purchasePackage() — Google Play Billing should open');

    setState(() => _isPurchasing = true);
    try {
      // purchase() fait déjà un getCustomerInfo() forcé en interne
      final info = await PurchaseService.purchase(pkg);

      final isPro = info.entitlements.active.containsKey(kEntitlementPro);
      _log('entitlements.active = ${info.entitlements.active.keys.toList()}');
      _log('isPremium = $isPro');

      if (isPro) {
        _log('purchase success → navigating to app');
        _trackPurchaseAnalytics(pkg);
        if (mounted) {
          setState(() => _isPurchasing = false);
          _goToApp();
        }
      } else {
        // Entitlement pas encore visible — fallback: restorePurchases
        _log('⚠️  entitlement not active yet — trying restorePurchases() as fallback');
        final restored = await PurchaseService.restorePurchases();
        final isProAfterRestore =
            restored.entitlements.active.containsKey(kEntitlementPro);
        _log('after restore — isPremium = $isProAfterRestore');
        _log('after restore — entitlements.active = ${restored.entitlements.active.keys.toList()}');

        if (!mounted) return;
        if (isProAfterRestore) {
          _log('restore fallback succeeded → navigating to app');
          _trackPurchaseAnalytics(pkg);
          setState(() => _isPurchasing = false);
          _goToApp();
        } else {
          _log('❌ entitlement still not active after restore');
          _log('   → check RC dashboard: is "$kEntitlementPro" linked to "${pkg.storeProduct.identifier}"?');
          setState(() => _isPurchasing = false);
          _showError(
            'Achat enregistré mais accès non encore activé. '
            'Veuillez patienter quelques secondes et utiliser "Restaurer les achats".',
          );
        }
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        _log('user cancelled — normal, no error shown');
      } else {
        _log('❌ PlatformException code=$code message=${e.message}');
        if (mounted) _showError("L'achat a échoué. Veuillez réessayer.");
      }
      if (mounted) setState(() => _isPurchasing = false);
    } catch (e) {
      _log('❌ unexpected error: $e');
      if (mounted) {
        setState(() => _isPurchasing = false);
        _showError("L'achat a échoué. Veuillez réessayer.");
      }
    }
  }

  void _trackPurchaseAnalytics(Package pkg) {
    try {
      if (_selected == _Plan.lifetime) {
        AppsFlyerService.trackSubscribe(planId: pkg.identifier);
        AppsFlyerService.trackPurchase(
          price: pkg.storeProduct.price,
          currency: pkg.storeProduct.currencyCode,
          productId: pkg.storeProduct.identifier,
        );
      } else {
        AppsFlyerService.trackStartTrial(planId: pkg.identifier);
      }
      mixpanel.track('purchase_completed', properties: {
        'source': 'custom_button',
        'plan': _selected.toString(),
        'price': pkg.storeProduct.price,
        'currency': pkg.storeProduct.currencyCode,
      });
    } catch (_) {}
  }

  Future<void> _restorePurchases() async {
    _log('restorePurchases() — start');
    setState(() => _isPurchasing = true);
    try {
      final info = await PurchaseService.restorePurchases();
      if (!mounted) return;
      if (info.entitlements.active.containsKey(kEntitlementPro)) {
        _log('restorePurchases() — ✅ entitlement active → going to app');
        _goToApp();
      } else {
        _log('restorePurchases() — no active entitlement found');
        _showError('Aucun achat à restaurer.');
      }
    } catch (e) {
      _log('restorePurchases() — ❌ error: $e');
      if (mounted) _showError('La restauration a échoué.');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _isPurchasing || _loadingOfferings;

    // Le bouton est désactivé si le package du plan sélectionné est introuvable
    final selectedPackage = _packageFor(_selected);
    final canPurchase = !busy && selectedPackage != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.verified_user_rounded,
                      size: 14, color: AppTheme.accent),
                  SizedBox(width: 6),
                  Text(
                    'Plus de 10 000 utilisateurs utilisent NailBite',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Nails-coach Pro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choisissez votre offre ci-dessous ou affichez le catalogue des offres',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const MascotWidget(mood: MascotMood.happy, size: 200),
                    const SizedBox(height: 20),

                    // Indicateur pendant le chargement des offerings
                    if (_loadingOfferings)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      ),

                    _PlanCard(
                      plan: _Plan.lifetime,
                      selected: _selected == _Plan.lifetime,
                      available: _packageFor(_Plan.lifetime) != null,
                      title: 'À vie',
                      subtitle: 'Nails-coach Pro à vie',
                      price: _priceFor(_Plan.lifetime),
                      onTap: () => setState(() => _selected = _Plan.lifetime),
                    ),
                    const SizedBox(height: 10),
                    _PlanCard(
                      plan: _Plan.monthly,
                      selected: _selected == _Plan.monthly,
                      available: _packageFor(_Plan.monthly) != null,
                      title: 'Mensuel',
                      subtitle: 'Abonnement mensuel',
                      price: _priceFor(_Plan.monthly),
                      badge: '⭐ Populaire',
                      onTap: () => setState(() => _selected = _Plan.monthly),
                    ),
                    const SizedBox(height: 10),
                    _PlanCard(
                      plan: _Plan.weekly,
                      selected: _selected == _Plan.weekly,
                      available: _packageFor(_Plan.weekly) != null,
                      title: 'Semaine',
                      subtitle: 'Abonnement hebdomadaire',
                      price: _priceFor(_Plan.weekly),
                      onTap: () => setState(() => _selected = _Plan.weekly),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: canPurchase ? _purchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.accent.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          canPurchase ? 'Commencer' : 'Chargement…',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterLink(
                    label: 'Restaurer les achats',
                    onTap: busy ? () {} : _restorePurchases,
                  ),
                  const SizedBox(width: 12),
                  _FooterLink(
                    label: 'Conditions',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _FooterLink(
                    label: 'Confidentialité',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool selected;
  final bool available;
  final String title;
  final String subtitle;
  final String price;
  final String? badge;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.available,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: available ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.accent : const Color(0xFFE8E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppTheme.accent : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppTheme.accent
                          : AppTheme.textSecondary.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: available
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppTheme.accent : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -13,
                right: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Footer Link ─────────────────────────────────────────────────────────────

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondary,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
