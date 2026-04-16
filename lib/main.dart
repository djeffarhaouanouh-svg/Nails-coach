import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'data/services/purchase_service.dart';
import 'data/services/api_service.dart';
import 'data/services/appsflyer_service.dart';
import 'data/repositories/settings_repository.dart';
import 'data/models/bite_event.dart';
import 'data/models/daily_photo.dart';
import 'data/models/user_settings.dart';
import 'app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late Mixpanel mixpanel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Mixpanel
  print('START MIXPANEL INIT');
  mixpanel = await Mixpanel.init(
    'bebaae194f1fde4a98fc02fac9ef5767',
    trackAutomaticEvents: true,
  );
  mixpanel.setServerURL('https://api-eu.mixpanel.com');
  mixpanel.track('app_open');
  await mixpanel.flush();
  print('EVENT app_open SENT + FLUSH');

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BiteEventAdapter());
  Hive.registerAdapter(DailyPhotoAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  await Hive.openBox<BiteEvent>('bite_events');
  await Hive.openBox<DailyPhoto>('daily_photos');
  await Hive.openBox<UserSettings>('user_settings');

  // Enregistre l'user dans Neon (idempotent, silencieux si backend down)
  final settingsRepo = SettingsRepository(Hive.box<UserSettings>('user_settings'));
  final userSettings = await settingsRepo.getOrCreateSettings();
  ApiService.createUser(userSettings.id, name: userSettings.userName);

  // Init AppsFlyer — Android uniquement (désactivé sur iOS)
  if (!Platform.isIOS) {
    await AppsFlyerService.init();
  }

  // Init RevenueCat — Android uniquement (désactivé sur iOS)
  if (!Platform.isIOS) {
    await PurchaseService.init(
      androidApiKey: 'goog_tTsMTnTFbSevwbmBATmfmcxEOty',
      appUserId: userSettings.id,
    );
  }

  // Init timezone
  tz.initializeTimeZones();

  // Init notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const ProviderScope(child: NailBiteApp()));
}
