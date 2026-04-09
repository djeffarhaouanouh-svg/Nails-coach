import 'package:flutter/material.dart';

import '../../app.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/mascot_widget.dart';
import 'how_it_works_screen.dart';

class TrialScreen extends StatelessWidget {
  const TrialScreen({super.key});

  void _goToApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _goToHowItWorks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: GestureDetector(
                  onTap: () => _goToHowItWorks(context),
                  child: const Text(
                    'Passer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
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
                    const MascotWidget(mood: MascotMood.happy, size: 200),
                    const SizedBox(height: 32),
                    const Text(
                      '3 jours offert 🎉',
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
                      'Ce que vous allez obtenir',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _BenefitItem(text: 'Profitez de vos 3 premiers jours, c\'est gratuit', highlight: '3 premiers jours'),
                    const _BenefitItem(text: 'Un programme personnalisé de 90 jours'),
                    const _BenefitItem(text: 'Prenez confiance en vous'),
                    const _BenefitItem(text: 'Annulez facilement depuis l\'app ou iCloud'),
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
                    width: i == 0 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? AppTheme.accent
                          : AppTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: () => _goToHowItWorks(context),
                child: const Text('Commencer mon essai gratuit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;
  final String? highlight;

  const _BenefitItem({required this.text, this.highlight});

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: 15,
      color: AppTheme.textPrimary,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );

    Widget textWidget;
    if (highlight != null && text.contains(highlight!)) {
      final parts = text.split(highlight!);
      textWidget = RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: parts.first),
            TextSpan(
              text: highlight,
              style: const TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: parts.last),
          ],
        ),
      );
    } else {
      textWidget = Text(text, style: baseStyle);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppTheme.accent, size: 15),
          ),
          const SizedBox(width: 14),
          Expanded(child: textWidget),
        ],
      ),
    );
  }
}
