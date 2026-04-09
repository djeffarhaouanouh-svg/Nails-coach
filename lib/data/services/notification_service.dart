import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../main.dart';

class NotificationService {
  static const int _dailyReminderID = 1;
  static const int _biteFollowUpID = 2;

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await flutterLocalNotificationsPlugin.cancel(_dailyReminderID);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Rappel quotidien',
      channelDescription: 'Rappel quotidien de bilan des ongles',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _dailyReminderID,
      '🌟 NailBite Coach',
      'C\'est l\'heure de votre bilan quotidien ! Notez vos envies ou prenez une photo.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleBiteFollowUp() async {
    await flutterLocalNotificationsPlugin.cancel(_biteFollowUpID);

    const androidDetails = AndroidNotificationDetails(
      'bite_followup',
      'Suivi après morsure',
      channelDescription: 'Suivi après avoir enregistré une morsure',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 30));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _biteFollowUpID,
      '💪 Vous pouvez y arriver !',
      'Ça fait 30 minutes depuis votre dernière morsure. Essayez la réponse concurrente : serrez le poing pendant 60 secondes.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
