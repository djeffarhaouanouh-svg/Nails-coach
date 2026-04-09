import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/user_settings.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/purchase_service.dart';
import '../../theme/app_theme.dart';
import '../program/program_screen.dart';
import '../legal/privacy_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/legal_screen.dart';
import '../legal/disclaimer_screen.dart';
import '../onboarding/how_it_works_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read directly from the repository (sync) — avoids the FutureProvider
    // returning null and showing a blank screen.
    final repo = ref.watch(settingsRepositoryProvider);
    final settings = repo.getSettings();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : _ProfileBody(settings: settings),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProfileBody extends ConsumerStatefulWidget {
  final UserSettings settings;
  const _ProfileBody({required this.settings});

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  late bool _notifEnabled;
  late int _reminderHour;
  late int _reminderMinute;

  @override
  void initState() {
    super.initState();
    _notifEnabled = widget.settings.notificationsEnabled;
    _reminderHour = widget.settings.reminderHour;
    _reminderMinute = widget.settings.reminderMinute;
  }

  String get _name => widget.settings.userName?.trim() ?? '';
  String get _initial => _name.isNotEmpty ? _name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final dayNum =
        DateTime.now().difference(widget.settings.programStartDate).inDays + 1;
    final clampedDay = dayNum.clamp(1, 90);
    final progress = clampedDay / 90.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero ─────────────────────────────────────────────────────────
          _HeroHeader(
            name: _name,
            initial: _initial,
            dayNum: clampedDay,
            progress: progress,
            startDate: widget.settings.programStartDate,
            onEditName: () => _showEditNameDialog(context),
          ),

          // ── Stats ─────────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _StatsRow(),
          ),

          // ── Notifications ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _sectionTitle('Notifications'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: _SettingsCard(children: [
              SwitchListTile(
                value: _notifEnabled,
                onChanged: _onToggleNotif,
                title: const Text('Rappel quotidien',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Recevez une notification de bilan quotidien'),
                activeColor: AppTheme.accent,
              ),
              if (_notifEnabled) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.access_time_outlined,
                      color: AppTheme.accent, size: 22),
                  title: const Text('Heure de rappel',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                  onTap: () => _pickTime(context),
                ),
              ],
            ]),
          ),

          // ── Programme ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _sectionTitle('Programme'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: _SettingsCard(children: [
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined,
                    color: AppTheme.accent, size: 22),
                title: const Text('Programme de 90 jours',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Voir les conseils et exercices pour chaque jour'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgramScreen(currentDay: clampedDay),
                  ),
                ),
              ),
            ]),
          ),

          // ── Abonnement ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _sectionTitle('Abonnement'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: _SettingsCard(children: [
              ListTile(
                leading: const Icon(Icons.star_outline_rounded,
                    color: AppTheme.accent, size: 22),
                title: const Text('Gérer mon abonnement',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Voir les détails de votre essai gratuit'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HowItWorksScreen()),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.manage_accounts_rounded,
                    color: AppTheme.accent, size: 22),
                title: const Text('Gérer mon abonnement',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Gérer, restaurer ou annuler — Customer Center'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary),
                onTap: _presentCustomerCenter,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.restore_rounded,
                    color: AppTheme.accent, size: 22),
                title: const Text('Restaurer les achats',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Récupérer un abonnement existant'),
                trailing: const Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary),
                onTap: _restorePurchases,
              ),
            ]),
          ),

          // ── À propos ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _sectionTitle('À propos'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: _SettingsCard(children: [
              ListTile(
                leading: const Icon(Icons.person_outline,
                    color: AppTheme.accent, size: 22),
                title: const Text('Mon prénom',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    _name.isNotEmpty ? _name : 'Non renseigné'),
                trailing: const Icon(Icons.edit_outlined,
                    color: AppTheme.textSecondary, size: 18),
                onTap: () => _showEditNameDialog(context),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.flag_outlined,
                    color: AppTheme.accent, size: 22),
                title: const Text('Mon objectif',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(widget.settings.goal == 'stop'
                    ? 'Arrêter complètement'
                    : 'Réduire la fréquence'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.play_circle_outline,
                    color: AppTheme.accent, size: 22),
                title: const Text('Début du programme',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  DateFormat('d MMM yyyy')
                      .format(widget.settings.programStartDate),
                ),
              ),
            ]),
          ),

          // ── Légal ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _sectionTitle('Informations légales'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: _SettingsCard(children: [
              _LegalTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Politique de confidentialité',
                subtitle: 'RGPD — vos données & vos droits',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyScreen())),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _LegalTile(
                icon: Icons.description_outlined,
                title: 'Conditions d\'utilisation',
                subtitle: 'CGU — règles d\'usage de l\'app',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TermsScreen())),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _LegalTile(
                icon: Icons.business_outlined,
                title: 'Mentions légales',
                subtitle: 'Éditeur & informations légales',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LegalScreen())),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _LegalTile(
                icon: Icons.health_and_safety_outlined,
                title: 'Avertissement',
                subtitle: 'Application non médicale',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DisclaimerScreen())),
              ),
            ]),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'NailBite Coach v1.0.2',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      );

  Future<void> _onToggleNotif(bool v) async {
    setState(() => _notifEnabled = v);
    widget.settings.notificationsEnabled = v;
    await widget.settings.save();
    final notif = ref.read(notificationServiceProvider);
    if (v) {
      await notif.scheduleDailyReminder(
          hour: _reminderHour, minute: _reminderMinute);
    } else {
      await notif.cancelAll();
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );
    if (picked == null) return;
    setState(() {
      _reminderHour = picked.hour;
      _reminderMinute = picked.minute;
    });
    widget.settings.reminderHour = picked.hour;
    widget.settings.reminderMinute = picked.minute;
    await widget.settings.save();
    final notif = ref.read(notificationServiceProvider);
    await notif.scheduleDailyReminder(
        hour: picked.hour, minute: picked.minute);
  }

  Future<void> _presentCustomerCenter() async {
    try {
      await PurchaseService.presentCustomerCenter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Impossible d\'ouvrir la gestion d\'abonnement: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  Future<void> _restorePurchases() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await PurchaseService.restorePurchases();
      messenger.showSnackBar(const SnackBar(
        content: Text('Restauration terminée. Vérifiez votre accès Pro.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Erreur lors de la restauration : $e'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    final controller =
        TextEditingController(text: widget.settings.userName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mon prénom'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Entrez votre prénom',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (result != null) {
      widget.settings.userName = result.isEmpty ? null : result;
      await widget.settings.save();
      if (mounted) setState(() {});
    }
  }
}

// ── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String name;
  final String initial;
  final int dayNum;
  final double progress;
  final DateTime startDate;
  final VoidCallback onEditName;

  const _HeroHeader({
    required this.name,
    required this.initial,
    required this.dayNum,
    required this.progress,
    required this.startDate,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, Color(0xFF3D3D5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: onEditName,
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white60, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar + name
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.35),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Mon profil',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Jour $dayNum / 90',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progression',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF496F9)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Commencé le ${DateFormat('d MMM yyyy').format(startDate)}',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats Row (own ConsumerWidget to isolate analytics) ──────────────────────

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsDataProvider);
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_outlined,
            value: '${data.currentStreak}',
            label: 'jours\nsans morsure',
            color: data.currentStreak > 0
                ? AppTheme.warning
                : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.calendar_today_outlined,
            value: '${data.totalBites7Days}',
            label: 'morsures\ncette semaine',
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.check_circle_outline,
            value: '${data.biteFreeDays30}',
            label: 'jours sans\n(30 derniers)',
            color: AppTheme.success,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LegalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accent, size: 22),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right,
          color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
