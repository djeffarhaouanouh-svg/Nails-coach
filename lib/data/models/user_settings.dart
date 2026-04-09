import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late bool onboardingDone;

  @HiveField(2)
  late String goal; // 'reduce' | 'stop'

  @HiveField(3)
  late int reminderHour;

  @HiveField(4)
  late int reminderMinute;

  @HiveField(5)
  late bool notificationsEnabled;

  @HiveField(6)
  late DateTime programStartDate;

  @HiveField(7)
  String? userName;

  UserSettings({
    required this.id,
    this.onboardingDone = false,
    this.goal = 'stop',
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.notificationsEnabled = true,
    required this.programStartDate,
    this.userName,
  });
}
