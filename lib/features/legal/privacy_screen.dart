import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politique de confidentialité')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegalDate('Dernière mise à jour : 27 février 2026'),
        LegalSection('1. Qui sommes-nous ?',
            "NailBite Coach est une application mobile conçue pour aider les utilisateurs à réduire ou arrêter l'habitude de se ronger les ongles. Elle fournit des conseils beauté et de bien-être à titre informatif uniquement.\n\n"
            "Responsable du traitement : [Hardoroc Lenny]\n"
            "Adresse : [42 Rue de la commune de paris]\n"
            "Contact : [lennyhdr1@gmail.com]"),
        LegalSection('2. Principe fondamental : tout reste sur votre appareil',
            "NailBite Coach ne dispose d'aucun serveur distant. Toutes les données que vous saisissez sont stockées exclusivement sur votre appareil, dans une base de données locale (Hive). Aucune donnée personnelle n'est transmise à nos serveurs ou à des tiers, sauf mention explicite ci-dessous."),
        LegalSection('3. Données collectées et traitées',
            "L'application traite les catégories de données suivantes, uniquement en local sur votre appareil :"),
        _DataTable(),
        LegalSection('4. Autorisations demandées',
            "L'application peut demander les autorisations système suivantes :\n\n"
            "• Caméra / Galerie (image_picker) : pour vous permettre d'ajouter des photos de progression de vos ongles. Ces photos sont stockées uniquement sur votre appareil.\n\n"
            "• Notifications locales : pour vous envoyer des rappels quotidiens de bilan. Ces notifications sont générées localement et n'impliquent aucun serveur de push tiers.\n\n"
            "• Stockage : pour sauvegarder les données de l'application sur votre appareil."),
        LegalSection('5. Services tiers',
            "Nous avons volontairement minimisé les dépendances à des services tiers :\n\n"
            "• Firebase Analytics : nous n'utilisons pas Firebase Analytics à ce jour.\n"
            "• Google AdMob (publicité) : nous n'utilisons pas AdMob à ce jour.\n"
            "• Achats intégrés Google Play (IAP) : nous n'utilisons pas d'achats intégrés à ce jour.\n\n"
            "L'application est distribuée via le Google Play Store. Google peut collecter des données techniques dans le cadre de sa plateforme (rapports de plantage, statistiques d'installation). Ces collectes sont régies par la politique de confidentialité de Google, indépendante de notre application."),
        LegalSection('6. Durée de conservation',
            "Les données sont conservées sur votre appareil tant que l'application est installée. Vous pouvez supprimer toutes vos données en désinstallant l'application ou en utilisant la fonctionnalité de réinitialisation disponible dans les paramètres."),
        LegalSection('7. Vos droits (RGPD)',
            "Conformément au Règlement Général sur la Protection des Données (RGPD) et à la loi Informatique et Libertés, vous disposez des droits suivants :\n\n"
            "• Droit d'accès : vous pouvez consulter toutes vos données directement dans l'application.\n"
            "• Droit de rectification : vous pouvez modifier vos données dans l'application.\n"
            "• Droit à l'effacement : vous pouvez supprimer vos données via les paramètres de l'application ou en la désinstallant.\n"
            "• Droit à la portabilité : les données étant stockées localement, elles sont sous votre contrôle direct.\n"
            "• Droit d'opposition : vous pouvez désactiver les notifications à tout moment dans les paramètres.\n\n"
            "Pour exercer vos droits ou pour toute question, contactez-nous à : [lennyhdr1@gmail.com]\n\n"
            "Vous avez également le droit d'introduire une réclamation auprès de la CNIL (www.cnil.fr)."),
        LegalSection('8. Sécurité',
            "Les données sont stockées localement sur votre appareil et protégées par les mécanismes de sécurité de votre système d'exploitation Android (sandboxing, chiffrement au niveau du système). Nous ne contrôlons pas la sécurité physique de votre appareil."),
        LegalSection('9. Mineurs',
            "Cette application n'est pas destinée aux enfants de moins de 13 ans. Nous ne collectons pas sciemment de données personnelles provenant d'enfants de moins de 13 ans."),
        LegalSection('10. Modifications',
            "Toute modification substantielle de cette politique vous sera notifiée via une mise à jour de l'application. La date de mise à jour en haut de cette page fait foi."),
        LegalSection('11. Contact',
            "Pour toute question relative à cette politique de confidentialité :\n[lennyhdr1@gmail.com]"),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ["Événements (morsures)", "Horodatage de chaque événement enregistré", "Suivi de votre progression", "Locale (Hive)"],
      ["Photos de progression", "Photos de vos ongles prises avec l'appareil photo", "Suivi visuel de vos ongles", "Locale (appareil)"],
      ["Paramètres utilisateur", "Objectif, heure de rappel, date de début du programme", "Personnalisation de l'expérience", "Locale (Hive)"],
      ["Données techniques (OS)", "Collectées par Google Play lors des rapports de plantage", "Stabilité de l'application", "Google (Play Store)"],
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08)),
              children: ['Donnée', 'Description', 'Finalité', 'Stockage']
                  .map((h) => Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(h,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppTheme.textPrimary)),
                      ))
                  .toList(),
            ),
            ...rows.map((r) => TableRow(
                  children: r
                      .map((cell) => Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(cell,
                                style: const TextStyle(fontSize: 11)),
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  final String title;
  final String body;
  const LegalSection(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6)),
        ],
      ),
    );
  }
}

class LegalDate extends StatelessWidget {
  final String text;
  const LegalDate(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              color: AppTheme.accent,
              fontWeight: FontWeight.w600)),
    );
  }
}
