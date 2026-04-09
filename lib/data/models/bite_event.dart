import 'package:hive/hive.dart';

part 'bite_event.g.dart';

@HiveType(typeId: 0)
class BiteEvent extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime timestamp;

  @HiveField(2)
  String? note;

  @HiveField(3)
  String? finger; // optional: which finger

  BiteEvent({
    required this.id,
    required this.timestamp,
    this.note,
    this.finger,
  });
}
