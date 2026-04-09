import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/user_settings.dart';

class SettingsRepository {
  final Box<UserSettings> _box;
  static const _key = 'main';

  SettingsRepository(this._box);

  UserSettings? getSettings() => _box.get(_key);

  Future<UserSettings> getOrCreateSettings() async {
    final existing = _box.get(_key);
    if (existing != null) return existing;
    final settings = UserSettings(
      id: const Uuid().v4(),
      programStartDate: DateTime.now(),
    );
    await _box.put(_key, settings);
    return settings;
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _box.put(_key, settings);
  }

  Future<void> completeOnboarding({
    required String goal,
    required int reminderHour,
    required int reminderMinute,
    required bool notificationsEnabled,
    String? userName,
  }) async {
    final settings = await getOrCreateSettings();
    settings.onboardingDone = true;
    settings.goal = goal;
    settings.reminderHour = reminderHour;
    settings.reminderMinute = reminderMinute;
    settings.notificationsEnabled = notificationsEnabled;
    settings.userName = userName;
    await settings.save();
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(Hive.box<UserSettings>('user_settings'));
});

final settingsProvider = FutureProvider<UserSettings?>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSettings();
});
