import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'privacy_screen.dart' show LegalSection, LegalDate;

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avertissement')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _DisclaimerContent(),
      ),
    );
  }
}

class _DisclaimerContent extends StatelessWidget {
  const _DisclaimerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegalDate('Dernière mise à jour : 27 février 2026'),
        _MainWarningCard(),
        LegalSection('1. Nature de l\'application',
            "NailBite Coach est une application de coaching comportemental et de bien-être beauté. Elle propose un programme de 90 jours basé sur des techniques de suivi et de prise de conscience pour aider les utilisateurs à réduire ou arrêter l'habitude de se ronger les ongles (onychophagie).\n\n"
            "Cette application est conçue à titre informatif et de soutien comportemental uniquement."),
        LegalSection('2. Ce que cette application N\'est PAS',
            "• Elle n'est pas un dispositif médical au sens du Règlement européen MDR 2017/745.\n"
            "• Elle ne fournit pas de diagnostic médical ou psychologique.\n"
            "• Elle ne constitue pas un traitement médical, psychiatrique ou psychothérapeutique.\n"
            "• Elle ne remplace pas une consultation auprès d'un médecin, d'un dermatologue, d'un psychologue ou de tout autre professionnel de santé.\n"
            "• Les conseils fournis ne sont pas des prescriptions médicales."),
        LegalSection('3. Cas nécessitant une consultation médicale',
            "Nous vous encourageons vivement à consulter un professionnel de santé si :\n\n"
            "• Votre onychophagie est compulsive ou associée à un état anxieux important\n"
            "• Vous présentez des blessures, infections ou complications cutanées\n"
            "• Vous souffrez de dermatillomania ou d'autres troubles obsessionnels compulsifs (TOC)\n"
            "• L'application ne suffit pas à améliorer votre situation\n\n"
            "En France, votre médecin traitant ou un psychologue clinicien peut vous orienter vers les soins adaptés."),
        LegalSection('4. Absence de garantie de résultats',
            "NailBite Coach ne garantit pas :\n\n"
            "• L'arrêt ou la réduction de l'onychophagie\n"
            "• Des résultats spécifiques en un temps donné\n"
            "• L'absence de rechute\n\n"
            "Les résultats varient selon les individus. L'efficacité du programme dépend de la régularité de l'utilisation et de la motivation personnelle de l'utilisateur."),
        LegalSection('5. Informations fournies',
            "Les conseils, exercices et informations fournis dans l'application sont basés sur des approches comportementales générales (prise de conscience, substitution d'habitudes, renforcement positif). Ils n'ont pas été validés par des essais cliniques et ne constituent pas une recommandation médicale officielle."),
        LegalSection('6. Responsabilité',
            "Dans les limites autorisées par la loi française, [Hardoroc] décline toute responsabilité pour :\n\n"
            "• Les décisions prises par l'utilisateur sur la base des contenus de l'application\n"
            "• Tout dommage corporel, psychologique ou matériel résultant de l'utilisation de l'application\n"
            "• Le non-suivi d'un traitement médical au profit de l'utilisation exclusive de l'application"),
        LegalSection('7. Contact',
            "Pour toute question :\n[lennyhdr1@gmail.com]"),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _MainWarningCard extends StatelessWidget {
  const _MainWarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warning.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined,
                  color: AppTheme.warning, size: 22),
              const SizedBox(width: 8),
              const Text('Application non médicale',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "NailBite Coach est une application de bien-être et de coaching beauté. "
            "Elle ne constitue pas un dispositif médical et ne remplace en aucun cas "
            "l'avis, le diagnostic ou le traitement d'un professionnel de santé qualifié.",
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}
