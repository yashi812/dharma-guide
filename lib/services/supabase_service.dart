// lib/services/supabase_service.dart
// ============================================================
// DHARMA GUIDE — Supabase Service Layer
// Project URL: https://bklyszfnaebbpkxlmilw.supabase.co
// ============================================================
// pubspec.yaml dependencies to add:
//   supabase_flutter: ^2.5.0
//   shared_preferences: ^2.2.3
// ============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Init (call in main.dart before runApp) ──────────────────
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://bklyszfnaebbpkxlmilw.supabase.co',
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      // Replace with your actual anon key below for dev only.
      // In production, use --dart-define=SUPABASE_ANON_KEY=<key>
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrbHlzemZuYWViYnBreGxtaWx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTI5MDQsImV4cCI6MjA5MTAyODkwNH0.z14EBElS6PeTZQOHkoVLYdPebjIUigRLeHdd4X6bI2I',
    ),
  );
}

SupabaseClient get _db => Supabase.instance.client;
User? get currentUser => _db.auth.currentUser;
String? get _uid => currentUser?.id;

// ============================================================
// AUTH
// ============================================================
class AuthService {
  /// Sign up with email + password. Profile auto-created by trigger.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String userName = 'Seeker',
  }) async {
    return _db.auth.signUp(
      email: email,
      password: password,
      data: {'user_name': userName},
    );
  }

  /// Sign in with email + password.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _db.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign in anonymously (guest mode, upgrade later).
  static Future<AuthResponse> signInAnonymously() async {
    return _db.auth.signInAnonymously();
  }

  /// Sign out.
  static Future<void> signOut() => _db.auth.signOut();

  /// Auth state stream.
  static Stream<AuthState> get authStateChanges => _db.auth.onAuthStateChange;
}

// ============================================================
// PROFILE
// ============================================================
class ProfileService {
  static const _table = 'profiles';

  /// Fetch the current user's profile.
  static Future<Map<String, dynamic>?> fetchProfile() async {
    if (_uid == null) return null;
    // FIX: .eq() before .select() — filter first, then transform
    return await _db
        .from(_table)
        .select()
        .eq('id', _uid!)
        .maybeSingle();
  }

  /// Update profile fields.
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_uid == null) return;  
    // FIX: .eq() on PostgrestFilterBuilder (from .update()), not after .select()
    await _db.from(_table).update(data).eq('id', _uid!);
  }

  /// Set user name (called at onboarding step 2).
  static Future<void> setUserName(String name) =>
      updateProfile({'user_name': name, 'onboarding_done': true});

  /// Set guidance style.
  static Future<void> setUserStyle(String style) =>
      updateProfile({'user_style': style});

  /// Unlock premium after purchase.
  static Future<void> setPremium({
    required bool value,
    String? plan,
  }) =>
      updateProfile({
        'is_premium': value,
        'premium_plan': plan,
        'premium_since': value ? DateTime.now().toIso8601String() : null,
      });

  /// Fetch user stats (streak, counts).
  static Future<Map<String, dynamic>?> fetchStats() async {
    // FIX: .eq() before .maybeSingle()
    return await _db
        .from('user_stats')
        .select()
        .eq('user_id', _uid!)
        .maybeSingle();
  }

  /// Stream profile changes in real-time.
  static Stream<List<Map<String, dynamic>>> streamProfile() {
    return _db
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', _uid!);
  }
}

// ============================================================
// MANTRAS
// ============================================================
class MantraService {
  static const _table = 'mantras';

  /// Fetch all mantras the user is allowed to see.
  static Future<List<Map<String, dynamic>>> fetchMantras({
    bool premiumUser = false,
  }) async {
    // FIX: apply .eq() filter before .order() transform
    final query = _db.from(_table).select();
    if (!premiumUser) {
      return await query
          .eq('is_premium', false)
          .order('sort_order', ascending: true);
    }
    return await query.order('sort_order', ascending: true);
  }

  /// Fetch a single mantra by slug.
  static Future<Map<String, dynamic>?> fetchBySlug(String slug) async {
    // FIX: .eq() before .maybeSingle()
    return await _db
        .from(_table)
        .select()
        .eq('slug', slug)
        .maybeSingle();
  }
}

// ============================================================
// PUJA SESSIONS
// ============================================================
class PujaService {
  static const _sessions = 'puja_sessions';
  static const _attempts = 'line_attempts';

  /// Create a new puja session when practice begins.
  /// Returns the new session id.
  static Future<String> startSession({
    required String mantraId,
    required int totalLines,
  }) async {
    final res = await _db.from(_sessions).insert({
      'user_id': _uid,
      'mantra_id': mantraId,
      'lines_total': totalLines,
      'lines_completed': 0,
    }).select('id').single();
    return res['id'] as String;
  }

  /// Record a single line attempt.
  static Future<void> recordLineAttempt({
    required String sessionId,
    required int lineIndex,
    required int attemptNo,
    required String? recognized,
    required double score,
    required bool passed,
  }) async {
    await _db.from(_attempts).insert({
      'session_id': sessionId,
      'line_index': lineIndex,
      'attempt_no': attemptNo,
      'recognized': recognized,
      'score': score,
      'passed': passed,
    });
  }

  /// Mark session complete (or partial if skipped).
  static Future<void> completeSession({
    required String sessionId,
    required int linesCompleted,
    required int linesTotal,
    required double avgScore,
    required int durationSecs,
    String? reflectionText,
    bool skipped = false,
  }) async {
    // FIX: .eq() on the FilterBuilder returned by .update(), not after .select()
    await _db.from(_sessions).update({
      'lines_completed': linesCompleted,
      'avg_score': avgScore,
      'duration_secs': durationSecs,
      'reflection_text': reflectionText,
      'skipped': skipped,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', sessionId);
  }

  /// Fetch all sessions for the current user (most recent first).
  static Future<List<Map<String, dynamic>>> fetchHistory({
    int limit = 20,
  }) async {
    // FIX: .eq() before .order() and .limit()
    return await _db
        .from(_sessions)
        .select('*, mantras(name, deity, slug)')
        .eq('user_id', _uid!)
        .order('completed_at', ascending: false)
        .limit(limit);
  }

  /// Count completed pujas (lines_completed = lines_total).
  static Future<int> countCompleted() async {
    // FIX: use .count() via head request — avoids fetching all rows
    final res = await _db
        .from(_sessions)
        .select('id')
        .eq('user_id', _uid!)
        .filter('lines_completed', 'eq', 'lines_total')
        .count(CountOption.exact);
    return res.count;
  }
}

// ============================================================
// REFLECTIONS
// ============================================================
class ReflectionService {
  static const _table = 'reflections';

  /// Save (upsert) today's reflection.
  static Future<void> saveReflection({
    required String moodId,
    required String moodLabel,
    required String moodEmoji,
    String? guidanceText,
    String? journalText,
  }) async {
    await _db.from(_table).upsert(
      {
        'user_id': _uid,
        'reflected_on': DateTime.now().toIso8601String().substring(0, 10),
        'mood_id': moodId,
        'mood_label': moodLabel,
        'mood_emoji': moodEmoji,
        'guidance_text': guidanceText,
        'journal_text': journalText,
      },
      onConflict: 'user_id,reflected_on',
    );
  }

  /// Check if user already reflected today.
  static Future<Map<String, dynamic>?> fetchToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    // FIX: both .eq() calls before .maybeSingle()
    return await _db
        .from(_table)
        .select()
        .eq('user_id', _uid!)
        .eq('reflected_on', today)
        .maybeSingle();
  }

  /// Fetch last N reflections.
  static Future<List<Map<String, dynamic>>> fetchHistory({
    int limit = 30,
  }) async {
    // FIX: .eq() before .order() and .limit()
    return await _db
        .from(_table)
        .select()
        .eq('user_id', _uid!)
        .order('reflected_on', ascending: false)
        .limit(limit);
  }

  /// Count total reflections.
  static Future<int> countReflections() async {
    // FIX: use .count() — avoids fetching all rows just to get length
    final res = await _db
        .from(_table)
        .select('id')
        .eq('user_id', _uid!)
        .count(CountOption.exact);
    return res.count;
  }
}

// ============================================================
// GUIDANCE SESSIONS
// ============================================================
class GuidanceService {
  static const _sessions = 'guidance_sessions';
  static const _messages = 'guidance_messages';

  /// Start a new guidance session on a topic.
  static Future<String> startSession({
    required String topicId,
    required String topicLabel,
    required String guidanceStyle,
  }) async {
    final res = await _db.from(_sessions).insert({
      'user_id': _uid,
      'topic_id': topicId,
      'topic_label': topicLabel,
      'guidance_style': guidanceStyle,
    }).select('id').single();
    return res['id'] as String;
  }

  /// Append a message to a guidance session.
  static Future<void> appendMessage({
    required String sessionId,
    required String role, // 'user' | 'assistant'
    required String content,
  }) async {
    await _db.from(_messages).insert({
      'session_id': sessionId,
      'role': role,
      'content': content,
    });
  }

  /// Fetch messages for a session.
  static Future<List<Map<String, dynamic>>> fetchMessages(
    String sessionId,
  ) async {
    // FIX: .eq() before .order()
    return await _db
        .from(_messages)
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);
  }

  /// Fetch recent guidance sessions.
  static Future<List<Map<String, dynamic>>> fetchHistory({
    int limit = 10,
  }) async {
    // FIX: .eq() before .order() and .limit()
    return await _db
        .from(_sessions)
        .select()
        .eq('user_id', _uid!)
        .order('created_at', ascending: false)
        .limit(limit);
  }
/// Save an arbitrary user input field for analytics/persistence.
  static Future<void> saveUserInput({
    required String screen,
    required String fieldName,
    required String value,
  }) async {
    if (_uid == null) return; 
    try {
      await _db.from('user_inputs').upsert({
        'user_id':    _uid,
        'screen':     screen,
        'field_name': fieldName,
        'value':      value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('GuidanceService.saveUserInput error: $e');
    }
  }

  /// Upsert core user profile fields.
  static Future<void> upsertUserProfile({
    required String name,
    required String guidanceStyle,
    required String birthDate,
    required String birthTime,
    required String birthPlace,
    required String birthGender,
  }) async {
    if (_uid == null) return;
    try {
      await ProfileService.updateProfile({
        'user_name':    name,
        'user_style':   guidanceStyle,
        'birth_date':   birthDate,
        'birth_time':   birthTime,
        'birth_place':  birthPlace,
        'birth_gender': birthGender,
      });
    } catch (e) {
      debugPrint('GuidanceService.upsertUserProfile error: $e');
    }
  }

}

// ============================================================
// GITA VERSES
// ============================================================
class GitaService {
  /// Fetch today's rotating verse via server-side RPC.
  static Future<Map<String, dynamic>?> fetchTodaysVerse() async {
    final res = await _db.rpc('todays_verse');
    if (res is List && res.isNotEmpty) return res.first as Map<String, dynamic>;
    return null;
  }

  /// Fetch all verses ordered by chapter then verse number.
  static Future<List<Map<String, dynamic>>> fetchAll() async {
    // FIX: chain .order() calls correctly — no .eq() needed here (no filter)
    return await _db
        .from('gita_verses')
        .select()
        .order('chapter', ascending: true)
        .order('verse', ascending: true);
  }
}

// ============================================================
// SUBSCRIPTIONS
// ============================================================
class SubscriptionService {
  static const _table = 'subscription_events';

  /// Log a subscription event (subscribe, cancel, restore, expire).
  static Future<void> logEvent({
    required String eventType,
    String? plan,
    String? provider,
    Map<String, dynamic>? receiptData,
  }) async {
    await _db.from(_table).insert({
      'user_id': _uid,
      'event_type': eventType,
      'plan': plan,
      'provider': provider,
      'receipt_data': receiptData,
    });
  }

  /// Full subscribe flow: log event + update profile atomically.
  static Future<void> subscribe({
    required String plan,
    required String provider,
    Map<String, dynamic>? receiptData,
  }) async {
    await Future.wait([
      logEvent(
        eventType: 'subscribe',
        plan: plan,
        provider: provider,
        receiptData: receiptData,
      ),
      ProfileService.setPremium(value: true, plan: plan),
    ]);
  }
}

// ============================================================
// MANIFESTATION JOURNALS
// ============================================================
class ManifestationService {
  static const _table = 'manifestation_journals';

  static Future<void> saveEntry({
    required String techniqueName,
    required String journalText,
  }) async {
    await _db.from(_table).insert({
      'user_id': _uid,
      'technique_name': techniqueName,
      'journal_text': journalText,
      'journaled_on': DateTime.now().toIso8601String().substring(0, 10),
    });
  }

  static Future<List<Map<String, dynamic>>> fetchHistory({
    int limit = 30,
  }) async {
    return await _db
        .from(_table)
        .select()
        .eq('user_id', _uid !)
        .order('journaled_on', ascending: false)
        .limit(limit);
  }

  static Future<List<Map<String, dynamic>>> fetchForTechnique(
    String techniqueName, {
    int limit = 30,
  }) async {
    return await _db
        .from(_table)
        .select()
        .eq('user_id', _uid!)
        .eq('technique_name', techniqueName)
        .order('journaled_on', ascending: false)
        .limit(limit);
  }
}