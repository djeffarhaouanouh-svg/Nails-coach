import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Connexion directe Flutter → Neon via HTTP API SQL
class ApiService {
  static const String _host =
      'ep-dawn-night-abd29yl2-pooler.eu-west-2.aws.neon.tech';
  static const String _connectionString =
      'postgresql://neondb_owner:npg_5S2RhykPZYmz@ep-dawn-night-abd29yl2-pooler.eu-west-2.aws.neon.tech/neondb?sslmode=require';

  static Future<void> _query(String sql, List<dynamic> params) async {
    try {
      await http.post(
        Uri.https(_host, '/sql'),
        headers: {
          'Content-Type': 'application/json',
          'Neon-Connection-String': _connectionString,
        },
        body: jsonEncode({'query': sql, 'params': params}),
      );
    } catch (_) {
      // Silencieux — l'app fonctionne sans réseau
    }
  }

  // ─── USERS ────────────────────────────────────────────────────────────────

  /// Crée ou met à jour un user
  static Future<void> createUser(
    String id, {
    String? name,
    String? goal,
    DateTime? programStartDate,
  }) async {
    final platform = Platform.isAndroid ? 'android' : 'ios';
    await _query(
      '''
      INSERT INTO users (id, name, goal, program_start_date, platform)
      VALUES (\$1, \$2, \$3, \$4, \$5)
      ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        goal = EXCLUDED.goal,
        program_start_date = EXCLUDED.program_start_date
      ''',
      [id, name, goal, programStartDate?.toIso8601String(), platform],
    );
  }

  // ─── MORSURES ─────────────────────────────────────────────────────────────

  /// Enregistre une morsure dans la table bite_events
  static Future<void> logBite({
    required String id,
    required String userId,
    required DateTime bittenAt,
    String? finger,
    String? note,
  }) async {
    await _query(
      '''
      INSERT INTO bite_events (id, user_id, finger, note, bitten_at)
      VALUES (\$1, \$2, \$3, \$4, \$5)
      ON CONFLICT (id) DO NOTHING
      ''',
      [id, userId, finger, note, bittenAt.toIso8601String()],
    );
  }

  // ─── PHOTOS ───────────────────────────────────────────────────────────────

  /// Enregistre une photo d'ongle dans nail_photos
  static Future<void> logPhoto({
    required String id,
    required String userId,
    required DateTime photoDate,
    String? note,
  }) async {
    await _query(
      '''
      INSERT INTO nail_photos (id, user_id, photo_date, note)
      VALUES (\$1, \$2, \$3, \$4)
      ON CONFLICT (id) DO NOTHING
      ''',
      [
        id,
        userId,
        '${photoDate.year}-${photoDate.month.toString().padLeft(2, '0')}-${photoDate.day.toString().padLeft(2, '0')}',
        note,
      ],
    );
  }

  // ─── ABONNEMENTS ──────────────────────────────────────────────────────────

  /// Enregistre ou met à jour un abonnement RevenueCat
  static Future<void> logSubscription({
    required String userId,
    required String productId,
    required String status, // 'active' | 'expired' | 'restored' | 'cancelled'
    required bool isPro,
    String? revenueCatUserId,
    DateTime? purchasedAt,
    DateTime? expiresAt,
  }) async {
    await _query(
      '''
      INSERT INTO subscriptions (user_id, revenue_cat_user_id, product_id, status, is_pro, purchased_at, expires_at)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)
      ''',
      [
        userId,
        revenueCatUserId,
        productId,
        status,
        isPro,
        purchasedAt?.toIso8601String(),
        expiresAt?.toIso8601String(),
      ],
    );

    // Met à jour aussi le flag is_pro sur l'user
    await _query(
      'UPDATE users SET is_pro = \$1 WHERE id = \$2',
      [isPro, userId],
    );
  }

  // ─── EVENTS GÉNÉRIQUES ────────────────────────────────────────────────────

  /// Log un événement analytics générique
  static Future<void> logEvent(
    String eventType, {
    String? userId,
    Map<String, dynamic>? payload,
  }) async {
    await _query(
      'INSERT INTO events (user_id, event_type, payload) VALUES (\$1, \$2, \$3)',
      [userId, eventType, payload != null ? jsonEncode(payload) : null],
    );
  }
}
