import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bite_event.dart';
import '../repositories/bite_event_repository.dart';
import '../repositories/settings_repository.dart';

class AnalyticsData {
  final int totalBites7Days;
  final int totalBites30Days;
  final int totalBitesAllTime;
  final int currentStreak; // bite-free days
  final int biteFreeDays30;
  final Map<int, int> bitesPerDayLast30; // x=0 oldest, x=29 today
  final List<String> insights;

  const AnalyticsData({
    required this.totalBites7Days,
    required this.totalBites30Days,
    required this.totalBitesAllTime,
    required this.currentStreak,
    required this.biteFreeDays30,
    required this.bitesPerDayLast30,
    required this.insights,
  });
}

class AnalyticsService {
  final BiteEventRepository _repo;
  final SettingsRepository _settingsRepo;

  AnalyticsService(this._repo, this._settingsRepo);

  AnalyticsData compute() {
    final now = DateTime.now();
    final all = _repo.getAllEvents();

    // Cap streak at days since program start (avoid showing 365 on fresh install)
    final settings = _settingsRepo.getSettings();
    final programStart = settings?.programStartDate ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final programStartDay = DateTime(
        programStart.year, programStart.month, programStart.day);
    final daysSinceStart = today.difference(programStartDay).inDays;

    final last7Start = now.subtract(const Duration(days: 7));
    final last30Start = now.subtract(const Duration(days: 30));

    final bites7 = all.where((e) => e.timestamp.isAfter(last7Start)).length;
    final bites30 = all.where((e) => e.timestamp.isAfter(last30Start)).length;

    // Bites per day last 30 days
    // x=0 = 29 days ago (oldest, left of chart), x=29 = today (right of chart)
    final Map<int, int> bitesPerDay = {for (int i = 0; i < 30; i++) i: 0};
    for (final event in all.where((e) => e.timestamp.isAfter(last30Start))) {
      final diff = now.difference(event.timestamp).inDays;
      if (diff < 30) {
        final x = 29 - diff;
        bitesPerDay[x] = (bitesPerDay[x] ?? 0) + 1;
      }
    }

    // Current streak (consecutive bite-free days counting back from today)
    // Capped at days since program start to avoid showing 365 with no data
    int streak = 0;
    final maxDays = daysSinceStart + 1;
    for (int i = 0; i < maxDays; i++) {
      final dayStart = today.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final hasEvent = all.any(
          (e) => e.timestamp.isAfter(dayStart) && e.timestamp.isBefore(dayEnd));
      if (!hasEvent) {
        streak++;
      } else {
        break;
      }
    }

    // Bite-free days in last 30
    int biteFreeDays = 0;
    for (int i = 0; i < 30; i++) {
      final dayStart = today.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final hasEvent = all.any(
          (e) => e.timestamp.isAfter(dayStart) && e.timestamp.isBefore(dayEnd));
      if (!hasEvent) biteFreeDays++;
    }

    final insights = _generateInsights(all, bites7, bites30, streak);

    return AnalyticsData(
      totalBites7Days: bites7,
      totalBites30Days: bites30,
      totalBitesAllTime: all.length,
      currentStreak: streak,
      biteFreeDays30: biteFreeDays,
      bitesPerDayLast30: bitesPerDay,
      insights: insights,
    );
  }

  List<String> _generateInsights(List<BiteEvent> all, int bites7, int bites30,
      int streak) {
    final insights = <String>[];

    if (all.isEmpty) {
      insights.add(
          'Commencez à enregistrer vos morsures pour obtenir des informations personnalisées !');
      return insights;
    }

    // Time of day analysis
    final eveningBites = all.where((e) => e.timestamp.hour >= 18).length;
    final morningBites = all.where((e) => e.timestamp.hour < 12).length;
    final afternoonBites =
        all.where((e) => e.timestamp.hour >= 12 && e.timestamp.hour < 18).length;

    final times = {
      'matin': morningBites,
      'après-midi': afternoonBites,
      'soir': eveningBites,
    };
    final peak = times.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (peak.value > 0) {
      insights.add(
          'Vous vous mordez le plus le ${peak.key} — restez particulièrement vigilant pendant cette période.');
    }

    // Trend
    if (bites7 > 0 && bites30 > 0) {
      final weeklyAvg = bites30 / 30 * 7;
      if (bites7 < weeklyAvg * 0.7) {
        insights.add(
            'Excellent progrès ! La fréquence de vos morsures cette semaine est significativement inférieure à votre moyenne mensuelle.');
      } else if (bites7 > weeklyAvg * 1.3) {
        insights.add(
            'Cette semaine a été plus difficile que d\'habitude. Identifiez ce qui est différent et ajustez votre stratégie.');
      }
    }

    if (streak >= 3) {
      insights.add(
          'Vous êtes sur une série de $streak jours ! Continuez à la protéger — une envie à la fois.');
    }

    if (bites30 == 0) {
      insights.add(
          'Un mois entier sans morsure ? Extraordinaire ! Vous avez vraiment créé une nouvelle habitude.');
    }

    if (insights.isEmpty) {
      insights.add(
          'Continuez à enregistrer régulièrement pour débloquer plus d\'informations personnalisées.');
    }

    return insights;
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final repo = ref.watch(biteEventRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return AnalyticsService(repo, settingsRepo);
});

final analyticsDataProvider = Provider<AnalyticsData>((ref) {
  // Watch biteEventsProvider so stats rebuild automatically when bites change
  ref.watch(biteEventsProvider);
  final service = ref.watch(analyticsServiceProvider);
  return service.compute();
});
