import 'package:hive/hive.dart';

part 'daily_photo.g.dart';

@HiveType(typeId: 1)
class DailyPhoto extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String localPath;

  @HiveField(3)
  String? note;

  DailyPhoto({
    required this.id,
    required this.date,
    required this.localPath,
    this.note,
  });

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
