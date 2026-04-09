import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'privacy_screen.dart' show LegalSection, LegalDate;

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegalDate('Dernière mise à jour : 27 février 2026'),
        LegalSection('1. Acceptation des conditions',
            "En téléchargeant, installant ou utilisant l'application NailBite Coach, vous acceptez les présentes Conditions Générales d'Utilisation (CGU). Si vous n'acceptez pas ces conditions, veuillez ne pas utiliser l'application."),
        LegalSection('2. Description du service',
            "NailBite Coach est une application mobile de coaching comportemental qui vous accompagne dans votre programme de 90 jours pour réduire ou arrêter l'habitude de vous ronger les ongles. L'application propose :\n\n"
            "• Un programme de 90 jours avec conseils quotidiens\n"
            "• Un suivi des événements (enregistrement des moments de morsure)\n"
            "• Un suivi photo de vos ongles\n"
            "• Des analyses de progression locales\n"
            "• Des rappels quotidiens (notifications locales)"),
        _DisclaimerBanner(),
        LegalSection('3. Avertissement — Application non médicale',
            "NailBite Coach est une application de bien-être et de coaching comportemental à titre informatif uniquement. Elle ne constitue en aucun cas :\n\n"
            "• Un dispositif médical au sens de la réglementation européenne (MDR 2017/745)\n"
            "• Un avis, un diagnostic ou un traitement médical ou psychologique\n"
            "• Un substitut à une consultation auprès d'un professionnel de santé\n\n"
            "Si vous souffrez d'une dermatillomania, d'une onychophagie sévère ou de tout autre trouble comportemental compulsif, nous vous encourageons vivement à consulter un professionnel de santé qualifié."),
        LegalSection('4. Utilisation acceptable',
            "Vous vous engagez à utiliser l'application de manière licite et à :\n\n"
            "• Ne pas tenter de décompiler, désassembler ou altérer l'application\n"
            "• Ne pas utiliser l'application à des fins commerciales sans autorisation\n"
            "• Ne pas usurper l'identité d'un autre utilisateur"),
        LegalSection('5. Données utilisateur',
            "Toutes vos données sont stockées localement sur votre appareil. Vous êtes responsable de la sauvegarde de vos données. Nous déclinons toute responsabilité en cas de perte de données suite à une réinitialisation ou un remplacement de votre appareil.\n\n"
            "Pour plus de détails, consultez notre Politique de confidentialité."),
        LegalSection('6. Propriété intellectuelle',
            "L'application Nais-Coach, son code source, ses textes, ses visuels et ses contenus sont la propriété exclusive de [Hardoroc Lenny] et sont protégés par les lois françaises et internationales sur la propriété intellectuelle.\n\n"
            "Toute reproduction, distribution ou utilisation non autorisée est strictement interdite."),
        LegalSection('7. Limitation de responsabilité',
            "Dans les limites autorisées par la loi applicable :\n\n"
            "• L'application est fournie « en l'état », sans garantie d'aucune sorte.\n"
            "• Nous ne garantissons pas de résultats spécifiques (arrêt ou réduction de l'onychophagie).\n"
            "• Nous ne sommes pas responsables des dommages indirects résultant de l'utilisation de l'application.\n"
            "• La responsabilité totale de [Hardoroc Lenny] ne pourra excéder le montant payé pour l'application."),
        LegalSection('8. Modifications des CGU',
            "Nous nous réservons le droit de modifier les présentes CGU à tout moment. Les modifications prennent effet dès leur publication dans l'application. En continuant à utiliser l'application après une modification, vous acceptez les nouvelles conditions."),
        LegalSection('9. Résiliation',
            "Vous pouvez cesser d'utiliser l'application à tout moment en la désinstallant. Nous nous réservons le droit de suspendre l'accès à l'application en cas de violation des présentes CGU."),
        LegalSection('10. Droit applicable et juridiction',
            "Les présentes CGU sont régies par le droit français. En cas de litige, les parties s'engagent à rechercher une solution amiable. À défaut, les tribunaux compétents seront ceux du ressort du siège social de [Hardoroc Lenny]."),
        LegalSection('11. Contact',
            "Pour toute question relative aux présentes CGU :\n[lennyhdr1@gmail.com]"),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Nails-Coach est une application de coaching beauté et bien-être. "
              "Elle ne constitue pas un dispositif médical et ne remplace pas l'avis d'un professionnel de santé.",
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
