import 'package:flutter/material.dart';
import 'privacy_screen.dart' show LegalSection, LegalDate;

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentions légales')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _LegalContent(),
      ),
    );
  }
}

class _LegalContent extends StatelessWidget {
  const _LegalContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegalDate('Dernière mise à jour : 27 février 2026'),
        LegalSection('1. Éditeur de l\'application',
            "Application : Nails-Coach\n"
            "Version : 1.0.0\n\n"
            "Éditeur : [Lenny Hardoroc]\n"
            "Forme juridique : [Auto-entrepreneur]\n"
            "Email : [lennyhdr1@gmail.com]"),
        LegalSection('2. Directeur de la publication',
            "[Hardoroc]\n"
            "Contact : [lennyhdr1@gmail.com]"),
        LegalSection('3. Hébergement des pages légales',
            "Les présentes mentions légales sont accessibles via l'application NailBite Coach. "
            "L'application elle-même ne dispose pas de serveur distant : toutes les données utilisateur sont stockées localement sur l'appareil.\n\n"
            "Si ces pages légales sont également publiées sur un site web, l'hébergeur sera mentionné ici."),
        LegalSection('4. Distribution',
            "NailBite Coach est distribuée via le Google Play Store, exploité par Google LLC, 1600 Amphitheatre Parkway, Mountain View, CA 94043, États-Unis."),
        LegalSection('5. Propriété intellectuelle',
            "L'ensemble des éléments constituant l'application NailBite Coach (code source, visuels, textes, icônes, logo, structure) est la propriété exclusive de [Hardoroc], sauf mention contraire.\n\n"
            "Toute reproduction, représentation, modification ou exploitation de tout ou partie de l'application sans autorisation expresse est interdite et constituerait une contrefaçon sanctionnée par le Code de la propriété intellectuelle."),
        LegalSection('6. Données personnelles',
            "Le traitement des données personnelles dans le cadre de l'utilisation de NailBite Coach est décrit dans notre Politique de confidentialité, accessible depuis l'application.\n\n"
            "Conformément à la loi n° 78-17 du 6 janvier 1978 relative à l'informatique, aux fichiers et aux libertés (modifiée par le RGPD), vous disposez d'un droit d'accès, de rectification et de suppression des données vous concernant."),
        LegalSection('7. Loi applicable',
            "Les présentes mentions légales sont régies par le droit français. Tout litige relatif à l'application NailBite Coach relève de la compétence des tribunaux français."),
        LegalSection('8. Contact',
            "Pour toute question ou réclamation :\n[lennyhdr1@gmail.com]"),
        const SizedBox(height: 40),
      ],
    );
  }
}
