import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/daily_photo.dart';
import '../services/api_service.dart';
import '../../main.dart';
import 'settings_repository.dart';

class PhotoRepository {
  final Box<DailyPhoto> _box;
  final SettingsRepository _settingsRepo;
  final ImagePicker _picker = ImagePicker();

  PhotoRepository(this._box, this._settingsRepo);

  String? get _userId => _settingsRepo.getSettings()?.id;

  List<DailyPhoto> getAllPhotos() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DailyPhoto? getPhotoForDate(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return _box.values.firstWhere((p) => p.dateKey == key);
    } catch (_) {
      return null;
    }
  }

  bool hasPhotoToday() {
    return getPhotoForDate(DateTime.now()) != null;
  }

  Future<DailyPhoto?> capturePhoto() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image == null) return null;
      return await _savePhoto(image);
    } catch (_) {
      return null;
    }
  }

  Future<DailyPhoto?> pickFromGallery() async {
    // Android 13+ uses READ_MEDIA_IMAGES, older uses READ_EXTERNAL_STORAGE
    final status = await Permission.photos.request();
    if (!status.isGranted && !status.isLimited) return null;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return null;
      return await _savePhoto(image);
    } catch (_) {
      return null;
    }
  }

  Future<DailyPhoto> _savePhoto(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/nail_photos');
    if (!await photosDir.exists()) await photosDir.create(recursive: true);

    final id = const Uuid().v4();
    final fileName = '$id.jpg';
    final savedPath = '${photosDir.path}/$fileName';

    await File(image.path).copy(savedPath);

    final now = DateTime.now();
    final photo = DailyPhoto(
      id: id,
      date: now,
      localPath: savedPath,
    );

    await _box.put(id, photo);

    // Track photo in Mixpanel
    try {
      mixpanel.track('daily_photo_saved', properties: {
        'id': id,
        'file_name': fileName,
        'local_path': savedPath,
        'timestamp': now.toIso8601String(),
      });
    } catch (_) {}

    // Sync photo vers Neon
    if (_userId != null) {
      ApiService.logPhoto(
        id: id,
        userId: _userId!,
        photoDate: now,
      );
    }

    return photo;
  }

  /// Seed test photos from assets (only if box is empty).
  Future<void> seedTestPhotos() async {
    if (_box.isNotEmpty) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/nail_photos');
    if (!await photosDir.exists()) await photosDir.create(recursive: true);

    final now = DateTime.now();

    // Ongles-2.png → 15 jours (photo "avant")
    final bytes2 =
        await rootBundle.load('assets/images/Ongles-2.png');
    final id2 = const Uuid().v4();
    final path2 = '${photosDir.path}/$id2.jpg';
    await File(path2)
        .writeAsBytes(bytes2.buffer.asUint8List());
    final date2 = now.subtract(const Duration(days: 15));
    await _box.put(
        id2, DailyPhoto(id: id2, date: date2, localPath: path2));

    // Ongles-1.png → 8 jours (photo "après")
    final bytes1 =
        await rootBundle.load('assets/images/Ongles-1.png');
    final id1 = const Uuid().v4();
    final path1 = '${photosDir.path}/$id1.jpg';
    await File(path1)
        .writeAsBytes(bytes1.buffer.asUint8List());
    final date1 = now.subtract(const Duration(days: 8));
    await _box.put(
        id1, DailyPhoto(id: id1, date: date1, localPath: path1));
  }

  Future<void> deletePhoto(String id) async {
    final photo = _box.get(id);
    if (photo != null) {
      final file = File(photo.localPath);
      if (await file.exists()) await file.delete();
      await _box.delete(id);
    }
  }
}

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final settingsRepo = ref.read(settingsRepositoryProvider);
  return PhotoRepository(Hive.box<DailyPhoto>('daily_photos'), settingsRepo);
});

final photosListProvider = StreamProvider<List<DailyPhoto>>((ref) {
  final box = Hive.box<DailyPhoto>('daily_photos');
  return box.watch().map((_) {
    final repo = ref.read(photoRepositoryProvider);
    return repo.getAllPhotos();
  });
});
