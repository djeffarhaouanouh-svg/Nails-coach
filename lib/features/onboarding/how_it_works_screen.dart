import 'package:flutter/material.dart';

import '../../app.dart';
import '../../theme/app_theme.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';
import '../legal/legal_screen.dart';
import 'subscription_screen.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  void _goToApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _goToSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // X button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: GestureDetector(
                  onTap: () => _goToApp(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Comment fonctionne\nvotre essai gratuit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Rien ne vous sera facturé aujourd\'hui',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const _TimelineStep(
                      icon: Icons.download_rounded,
                      title: 'Téléchargez & personnalisez',
                      subtitle: 'Configurez votre programme NailBite',
                      isFirst: true,
                      isLast: false,
                      isActive: false,
                      strikethrough: true,
                    ),
                    const _TimelineStep(
                      icon: Icons.play_arrow_rounded,
                      title: 'Aujourd\'hui — Commencez votre parcours',
                      subtitle: '3 jours d\'accès complet, totalement gratuit',
                      isFirst: false,
                      isLast: false,
                      isActive: true,
                    ),
                    const _TimelineStep(
                      icon: Icons.notifications_outlined,
                      title: 'Jour 2 — Rappel d\'essai',
                      subtitle: 'Votre essai se termine bientôt, nous vous enverrons une notification',
                      isFirst: false,
                      isLast: false,
                      isActive: false,
                    ),
                    const _TimelineStep(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Jour 3 — Continuez votre transformation',
                      subtitle: 'Continuez avec l\'accès complet ou annulez à tout moment',
                      isFirst: false,
                      isLast: true,
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ),
            // Progress dots
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 1 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 1
                          ? AppTheme.accent
                          : AppTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: ElevatedButton(
                onPressed: () => _goToSubscription(context),
                child: const Text('Essayer GRATUITEMENT'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterLink(
                    label: 'Mentions légales',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LegalScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _FooterLink(
                    label: 'Conditions',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
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

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;
  final bool isActive;
  final bool strikethrough;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isFirst,
    required this.isLast,
    required this.isActive,
    this.strikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.accent : AppTheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Center(
                      child: Container(width: 2, color: AppTheme.primary.withOpacity(0.3)),
                    ),
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive ? color : color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.white : color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 2, color: AppTheme.primary.withOpacity(0.3)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isActive ? AppTheme.accent : AppTheme.textPrimary,
                      decoration: strikethrough ? TextDecoration.lineThrough : null,
                      decorationColor: AppTheme.textSecondary,
                      decorationThickness: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
