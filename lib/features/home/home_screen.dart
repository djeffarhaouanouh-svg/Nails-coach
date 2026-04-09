import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/bite_event_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/notification_service.dart';
import '../../shared/widgets/mascot_widget.dart' show MascotWidget, MascotMood;
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    final repo = ref.read(biteEventRepositoryProvider);
    final last = repo.getLastEvent();
    setState(() {
      _elapsed = last == null
          ? Duration.zero
          : DateTime.now().difference(last.timestamp);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '${days}j ${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  String _greetingMessage(String? name) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Bonjour';
      emoji = '👋';
    } else if (hour < 17) {
      greeting = 'Bon après-midi';
      emoji = '☀️';
    } else {
      greeting = 'Bonsoir';
      emoji = '🌙';
    }
    final displayName = name != null && name.isNotEmpty ? ', $name' : '';
    return '$greeting$displayName! $emoji';
  }

  String _subMessage() {
    final messages = [
      'Bonne journée ! Vous pouvez le faire.',
      'Chaque heure compte. Restez fort !',
      'Vos ongles vous remercient.',
      'Une décision à la fois.',
    ];
    final index = DateTime.now().day % messages.length;
    return messages[index];
  }

  Future<void> _logBite() async {
    final repo = ref.read(biteEventRepositoryProvider);
    await repo.addBiteEvent();
    _updateElapsed();

    final notif = ref.read(notificationServiceProvider);
    final settings = ref.read(settingsRepositoryProvider).getSettings();
    if (settings?.notificationsEnabled == true) {
      await notif.scheduleBiteFollowUp();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Morsure enregistrée. Série réinitialisée ! 💪'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final userName = settingsAsync.valueOrNull?.userName;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greetingMessage(userName),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subMessage(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  _ProgramDayBadge(),
                ],
              ),
              const SizedBox(height: 12),

              // Mascot
              Center(
                child: MascotWidget(
                  mood: _elapsed == Duration.zero
                      ? MascotMood.neutral
                      : _elapsed.inHours >= 1
                          ? MascotMood.happy
                          : MascotMood.sad,
                  size: 260,
                ),
              ),
              const SizedBox(height: 0),

              // Timer card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Temps depuis la dernière morsure',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _elapsed == Duration.zero
                          ? '0j 0h 00m 00s'
                          : _formatDuration(_elapsed),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Log button
              ElevatedButton.icon(
                onPressed: _logBite,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Enregistrer une morsure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Quick stats row
              _QuickStatsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramDayBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    if (settings == null) return const SizedBox();
    final dayNum = DateTime.now().difference(settings.programStartDate).inDays + 1;
    final day = dayNum.clamp(1, 90);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Jour $day',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppTheme.accent,
            ),
          ),
          const Text(
            'sur 90',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(biteEventRepositoryProvider);
    final now = DateTime.now();
    final last7 = repo
        .getEventsInRange(now.subtract(const Duration(days: 7)), now)
        .length;
    final last = repo.getLastEvent();
    final daysSince = last == null
        ? 0
        : now.difference(last.timestamp).inDays;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Cette semaine',
            value: '$last7',
            unit: 'morsures',
            icon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Sans morsure',
            value: '$daysSince',
            unit: 'jours',
            icon: Icons.local_fire_department_outlined,
            highlight: daysSince >= 1,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.success.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? Border.all(
                color: AppTheme.success.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18,
              color: highlight ? AppTheme.success : AppTheme.textSecondary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: highlight ? AppTheme.success : AppTheme.textPrimary,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
