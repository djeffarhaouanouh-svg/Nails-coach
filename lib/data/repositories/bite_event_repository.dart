import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/bite_event.dart';
import '../services/api_service.dart';
import '../../main.dart';
import 'settings_repository.dart';

abstract class BiteEventRepositoryBase {
  Future<void> addBiteEvent({String? note, String? finger});
  List<BiteEvent> getAllEvents();
  List<BiteEvent> getEventsInRange(DateTime start, DateTime end);
  BiteEvent? getLastEvent();
  Future<void> deleteEvent(String id);
}

class BiteEventRepository implements BiteEventRepositoryBase {
  final Box<BiteEvent> _box;
  final SettingsRepository _settingsRepo;

  BiteEventRepository(this._box, this._settingsRepo);

  String? get _userId => _settingsRepo.getSettings()?.id;

  @override
  Future<void> addBiteEvent({String? note, String? finger}) async {
    final event = BiteEvent(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      note: note,
      finger: finger,
    );
    await _box.put(event.id, event);

    // Track event in Mixpanel
    try {
      mixpanel.track('bite_event_added', properties: {
        'id': event.id,
        'timestamp': event.timestamp.toIso8601String(),
        'note': event.note,
        'finger': event.finger,
      });
    } catch (_) {}

    // Sync morsure vers Neon (table bite_events)
    if (_userId != null) {
      ApiService.logBite(
        id: event.id,
        userId: _userId!,
        bittenAt: event.timestamp,
        finger: event.finger,
        note: event.note,
      );
    }
  }

  @override
  List<BiteEvent> getAllEvents() {
    return _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  List<BiteEvent> getEventsInRange(DateTime start, DateTime end) {
    return _box.values
        .where(
            (e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  BiteEvent? getLastEvent() {
    final events = getAllEvents();
    return events.isEmpty ? null : events.first;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _box.delete(id);
  }

  /// Seed demo bite events showing a decreasing trend (only if box is empty).
  Future<void> seedDemoData() async {
    if (_box.isNotEmpty) return;

    // x=0 = 29 days ago, x=29 = today — decreasing trend
    const demoBites = [
      8, 7, 8, 6, 7, 5, 7, 6, 5, 6, // x 0–9
      4, 5, 4, 3, 5, 3, 2, 4, 2, 2, // x 10–19
      1, 3, 1, 2, 1, 1, 2, 0, 1, 0, // x 20–29 (today = 0)
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int x = 0; x < 30; x++) {
      final count = demoBites[x];
      final day = today.subtract(Duration(days: 29 - x));
      for (int b = 0; b < count; b++) {
        final hour = 8 + (b * 2) % 12;
        final event = BiteEvent(
          id: const Uuid().v4(),
          timestamp: day.add(Duration(hours: hour, minutes: b * 7 % 60)),
        );
        await _box.put(event.id, event);
      }
    }
  }

}

final biteEventRepositoryProvider = Provider<BiteEventRepository>((ref) {
  final settingsRepo = ref.read(settingsRepositoryProvider);
  return BiteEventRepository(Hive.box<BiteEvent>('bite_events'), settingsRepo);
});

// Watchable events provider
final biteEventsProvider = StreamProvider<List<BiteEvent>>((ref) {
  final box = Hive.box<BiteEvent>('bite_events');
  return box.watch().map((_) {
    final repo = ref.read(biteEventRepositoryProvider);
    return repo.getAllEvents();
  });
});

// Last event provider
final lastBiteEventProvider = Provider<BiteEvent?>((ref) {
  final repo = ref.watch(biteEventRepositoryProvider);
  return repo.getLastEvent();
});
