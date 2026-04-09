# LEGAL_SETUP.md — NailBite Coach

Guide pour tester les pages légales en local et les préparer pour Google Play Console.

---

## 1. Structure des fichiers créés

```
lib/features/legal/
├── privacy_screen.dart     → Politique de confidentialité
├── terms_screen.dart       → Conditions générales d'utilisation (CGU)
├── legal_screen.dart       → Mentions légales
└── disclaimer_screen.dart  → Avertissement (application non médicale)
```

Les 4 pages sont accessibles depuis l'onglet **Profil → section "Informations légales"**.

---

## 2. Lancer l'app en local (Android)

### Prérequis
- Flutter SDK installé : https://flutter.dev/docs/get-started/install
- Android Studio ou un émulateur Android connecté

### Commandes

```bash
# Installer les dépendances
flutter pub get

# Lancer sur émulateur ou appareil connecté
flutter run

# Lancer sur un appareil spécifique (liste d'abord)
flutter devices
flutter run -d <device_id>

# Build APK de debug pour tester
flutter build apk --debug
```

### Vérifier les pages légales dans l'app
1. Lancer l'app
2. Aller dans l'onglet **Profil** (icône personne en bas à droite)
3. Faire défiler jusqu'à la section **"Informations légales"**
4. Tapper sur chaque entrée :
   - Politique de confidentialité
   - Conditions d'utilisation
   - Mentions légales
   - Avertissement

---

## 3. Checklist avant publication Google Play

### Contenu des pages légales
- [ ] Remplacer **[VOTRE NOM / SOCIÉTÉ]** par votre nom ou raison sociale
- [ ] Remplacer **[VOTRE ADRESSE]** par votre adresse complète
- [ ] Remplacer **[VOTRE EMAIL DE CONTACT]** par votre email réel
- [ ] Remplir **[VOTRE NUMÉRO SIRET]** (si auto-entrepreneur ou société)
- [ ] Remplir **[NOM DE L'HÉBERGEUR]** dans les mentions légales (si vous hébergez ces pages sur un site web externe)

### Fichiers à modifier
- `lib/features/legal/privacy_screen.dart` — lignes contenant `[VOTRE …]`
- `lib/features/legal/terms_screen.dart`   — lignes contenant `[VOTRE …]`
- `lib/features/legal/legal_screen.dart`   — lignes contenant `[VOTRE …]`
- `lib/features/legal/disclaimer_screen.dart` — lignes contenant `[VOTRE …]`

### Vérifications techniques
- [ ] L'app compile sans erreur : `flutter build apk --release`
- [ ] Les 4 pages s'ouvrent sans crash sur un vrai appareil Android
- [ ] Le texte est lisible sur petits et grands écrans (tester sur plusieurs tailles)
- [ ] Le bouton retour (flèche AppBar) fonctionne sur chaque page légale

---

## 4. Rendre les pages accessibles via une URL publique (pour Google Play)

Google Play Console exige une **URL publique** (accessible sans connexion) pour :
- La politique de confidentialité (obligatoire)
- Les conditions d'utilisation (recommandé)

### Option A — Héberger sur un site statique (recommandé)

Créer des pages HTML simples reprenant le contenu de vos écrans Flutter, à déployer sur :

| Hébergeur | Coût | Commande de déploiement |
|-----------|------|------------------------|
| **GitHub Pages** | Gratuit | `git push` (avec Actions) |
| **Netlify** | Gratuit | Drag & drop ou `netlify deploy` |
| **Vercel** | Gratuit | `vercel --prod` |

### Option B — Flutter Web

```bash
flutter build web
# Déployer le dossier build/web/ sur Netlify/Vercel/GitHub Pages
```
> Note : les routes `/privacy`, `/terms` etc. nécessitent go_router ou une configuration de redirections.

### Option C — Page simple sur votre propre domaine
Mettre les 4 fichiers HTML sur votre domaine existant (ex : `mondomaine.com/privacy`).

---

## 5. Après déploiement — URLs à copier dans Google Play Console

Une fois déployé, copier-coller ces URLs dans **Google Play Console → Configuration du store** :

```
Politique de confidentialité : https://VOTRE-DOMAINE/privacy
Conditions d'utilisation     : https://VOTRE-DOMAINE/terms
Mentions légales             : https://VOTRE-DOMAINE/legal
Avertissement                : https://VOTRE-DOMAINE/disclaimer
```

**Dans Google Play Console :**
- Politique de confidentialité → *Store listing > Privacy Policy*
- Conditions d'utilisation → *Store listing > Terms of Service* (optionnel mais recommandé)

---

## 6. Détection des services tiers (résultat d'analyse)

| Service | Présent dans le code | Action |
|---------|---------------------|--------|
| Firebase Analytics | NON | Mentionné comme absent dans la politique |
| Google AdMob | NON | Mentionné comme absent dans la politique |
| Achats intégrés (IAP) | NON | Mentionné comme absent dans la politique |
| Hive (stockage local) | OUI | Données stockées uniquement sur l'appareil |
| flutter_local_notifications | OUI | Notifications locales, aucun serveur |
| image_picker (caméra) | OUI | Photos stockées localement sur l'appareil |

> Si vous ajoutez Firebase, AdMob ou IAP dans le futur, pensez à mettre à jour
> la politique de confidentialité dans `lib/features/legal/privacy_screen.dart`.
