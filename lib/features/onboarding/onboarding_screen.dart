import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/repositories/settings_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/appsflyer_service.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../app.dart';
import '../../shared/widgets/mascot_widget.dart';
// trial_screen.dart kept in project (unused in build flow)

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  String _goal = 'stop';
  int _reminderHour = 9;
  int _reminderMinute = 0;
  String _name = '';
  bool _notifEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(name: _name, onNameChange: (v) => _name = v),
                  _GoalPage(
                    goal: _goal,
                    onGoalChange: (v) => setState(() => _goal = v),
                  ),
                  _ReminderPage(
                    hour: _reminderHour,
                    minute: _reminderMinute,
                    enabled: _notifEnabled,
                    onTimeChange: (h, m) => setState(() {
                      _reminderHour = h;
                      _reminderMinute = m;
                    }),
                    onEnabledChange: (v) => setState(() => _notifEnabled = v),
                  ),
                  _ReadyPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? AppTheme.accent
                              : AppTheme.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                children: [
                  if (_page > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: AppTheme.primary),
                          foregroundColor: AppTheme.primary,
                        ),
                        child: const Text('Retour'),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _page == 3 ? _finish : _next,
                      child: Text(_page == 3 ? 'Commencer mon parcours ! 🚀' : 'Continuer'),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _finish() async {
    if (_notifEnabled) {
      await Permission.notification.request();
    }

    final settingsRepo = ref.read(settingsRepositoryProvider);
    await settingsRepo.completeOnboarding(
      goal: _goal,
      reminderHour: _reminderHour,
      reminderMinute: _reminderMinute,
      notificationsEnabled: _notifEnabled,
      userName: _name.isNotEmpty ? _name : null,
    );

    // Enregistre l'user dans Neon avec toutes ses infos
    final settings = await settingsRepo.getOrCreateSettings();
    ApiService.createUser(
      settings.id,
      name: _name.isNotEmpty ? _name : null,
      goal: _goal,
      programStartDate: settings.programStartDate,
    );

    // Track onboarding dans Neon
    ApiService.logEvent(
      'onboarding_completed',
      userId: settings.id,
      payload: {
        'goal': _goal,
        'notifications_enabled': _notifEnabled,
        'reminder': '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}',
      },
    );

    if (_notifEnabled) {
      try {
        final notif = ref.read(notificationServiceProvider);
        await notif.scheduleDailyReminder(
            hour: _reminderHour, minute: _reminderMinute);
      } catch (_) {
        // Notification scheduling failed (e.g. permission denied) — continue anyway
      }
    }

    AppsFlyerService.trackSignUp();
    AppsFlyerService.trackOnboardingCompleted();

    // Track onboarding completion in Mixpanel
    try {
      mixpanel.track('onboarding_completed', properties: {
        'goal': _goal,
        'notifications_enabled': _notifEnabled,
      });
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    }
  }
}

class _WelcomePage extends StatelessWidget {
  final String name;
  final ValueChanged<String> onNameChange;

  const _WelcomePage({required this.name, required this.onNameChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌟', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          const Text(
            'Bienvenue sur\nNailBite Coach',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            decoration: InputDecoration(
              hintText: 'Votre prénom (facultatif)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: onNameChange,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          const Text(
            'Votre programme de 90 jours basé sur la science pour arrêter de vous ronger les ongles pour toujours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  final String goal;
  final ValueChanged<String> onGoalChange;

  const _GoalPage({required this.goal, required this.onGoalChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          const Text(
            'Quel est votre objectif ?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez ce que vous visez',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _GoalOption(
            value: 'stop',
            selected: goal,
            title: 'Arrêter complètement',
            description: 'Je veux arrêter complètement de me ronger les ongles',
            emoji: '🛑',
            onTap: onGoalChange,
          ),
          const SizedBox(height: 12),
          _GoalOption(
            value: 'reduce',
            selected: goal,
            title: 'Réduire considérablement',
            description: 'Je veux me ronger les ongles beaucoup moins souvent',
            emoji: '📉',
            onTap: onGoalChange,
          ),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String value;
  final String selected;
  final String title;
  final String description;
  final String emoji;
  final ValueChanged<String> onTap;

  const _GoalOption({
    required this.value,
    required this.selected,
    required this.title,
    required this.description,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(description,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.accent),
          ],
        ),
      ),
    );
  }
}

class _ReminderPage extends ConsumerWidget {
  final int hour;
  final int minute;
  final bool enabled;
  final void Function(int, int) onTimeChange;
  final ValueChanged<bool> onEnabledChange;

  const _ReminderPage({
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.onTimeChange,
    required this.onEnabledChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          const Text(
            'Configurer votre rappel',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recevez un bilan quotidien pour rester sur la bonne voie',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: enabled,
                  onChanged: onEnabledChange,
                  title: const Text('Activer les rappels',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  activeColor: AppTheme.accent,
                ),
                if (enabled) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Heure du rappel',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            await showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) => _TimePickerSheet(
                                hour: hour,
                                minute: minute,
                                onChanged: onTimeChange,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_outlined, size: 20, color: AppTheme.textSecondary),
                                const SizedBox(width: 12),
                                Text(
                                  '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚀', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          const Text(
            'Tout est prêt !',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _FeatureItem(
              emoji: '📊',
              text: 'Suivez chaque donnée d\'un simple toucher'),
          _FeatureItem(
              emoji: '📸',
              text: 'Photos quotidiennes pour voir la croissance de vos ongles'),
          _FeatureItem(
              emoji: '📈',
              text: 'Analyses et informations sur votre habitude'),
          _FeatureItem(
              emoji: '📅',
              text: '90 jours de conseils et d\'exercices'),
          const SizedBox(height: 24),
          const Text(
            'Le premier pas est le plus difficile. Vous l\'avez déjà franchi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePickerSheet extends StatefulWidget {
  final int hour;
  final int minute;
  final void Function(int, int) onChanged;

  const _TimePickerSheet({required this.hour, required this.minute, required this.onChanged});

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.hour;
    _minute = widget.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Heure du rappel', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Spinner(
                label: 'Heures',
                value: _hour,
                min: 0,
                max: 23,
                onChanged: (v) { setState(() => _hour = v); widget.onChanged(_hour, _minute); },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              ),
              _Spinner(
                label: 'Minutes',
                value: _minute,
                min: 0,
                max: 59,
                onChanged: (v) { setState(() => _minute = v); widget.onChanged(_hour, _minute); },
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Confirmer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Spinner({required this.label, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        _SpinButton(icon: Icons.keyboard_arrow_up_rounded, onTap: () => onChanged(value == max ? min : value + 1)),
        const SizedBox(height: 8),
        SizedBox(
          width: 64,
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        _SpinButton(icon: Icons.keyboard_arrow_down_rounded, onTap: () => onChanged(value == min ? max : value - 1)),
      ],
    );
  }
}

class _SpinButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SpinButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 28),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String text;

  const _FeatureItem({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
