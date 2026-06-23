// lib/state/app_state.dart  (REVISED — Supabase-backed + birth details)
// ============================================================

import 'package:dharma_guide/app_data.dart';
import 'package:dharma_guide/models.dart' hide ManifestationTechnique, Mantra;
import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  // ── Router ──────────────────────────────────────────────────
  String _screen = 'splash';
  String get screen => _screen;

  void nav(String s) {
    _screen = s;
    notifyListeners();
  }

  // ── Onboarding ──────────────────────────────────────────────
  int _onboardingStep = 0;
  int get onboardingStep => _onboardingStep;

  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;

  void nextOnboardingStep(int step) {
    _onboardingStep = step;
    notifyListeners();
  }

  // ── User profile (synced with Supabase) ─────────────────────
  String _userName = 'Seeker';
  String _userStyle = 'balanced';
  bool _isPremium = false;
  int _streak = 0;
  String? _kundliData;

  // ── Birth details (stored for silent re-enrichment) ──────────
  String? _birthName;
  String? _birthDate;   // DD/MM/YYYY
  String? _birthTime;   // HH:MM
  String? _birthPlace;
  String? _birthGender;

  String get userName => _userName;
  String get userStyle => _userStyle;
  bool get isPremium => _isPremium;
  int get streak => _streak;
  String? get kundliData => _kundliData;

  // Birth detail getters
  String? get birthName => _birthName;
  String? get birthDate => _birthDate;
  String? get birthTime => _birthTime;
  String? get birthPlace => _birthPlace;
  String? get birthGender => _birthGender;

  /// True when we have all four fields needed to call VedAstro
  bool get hasBirthDetails =>
      _birthDate != null &&
      _birthTime != null &&
      _birthPlace != null;

  // ── Stats ────────────────────────────────────────────────────
  int _pujasDone = 0;
  int _reflectionsCount = 0;
  int get pujasDone => _pujasDone;
  int get reflectionsCount => _reflectionsCount;

  // ── Active puja session ──────────────────────────────────────
  Mantra? _selectedMantra;
  Mantra? get selectedMantra => _selectedMantra;
  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  // ── Load profile from Supabase on startup ───────────────────
  Future<void> loadProfile() async {
  try {
    final profile = await ProfileService.fetchProfile();
    if (profile != null) {
      _userName       = profile['user_name']      as String? ?? 'Seeker';
      _userStyle      = profile['user_style']      as String? ?? 'balanced';
      _isPremium      = profile['is_premium']      as bool?   ?? false;
      _kundliData     = profile['kundli_data']     as String?;
      _birthName      = profile['birth_name']      as String?;
      _birthDate      = profile['birth_date']      as String?;
      _birthTime      = profile['birth_time']      as String?;
      _birthPlace     = profile['birth_place']     as String?;
      _birthGender    = profile['birth_gender']    as String?;

      // ── Keep this line commented out during dev, restore for release ──
      // _onboardingDone = profile['onboarding_done'] as bool? ?? false;
      _onboardingDone = profile['onboarding_done'] as bool? ?? false;
    }

      final stats = await ProfileService.fetchStats();
      if (stats != null) {
        _streak           = stats['streak_current']   as int? ?? 0;
        _pujasDone        = stats['pujas_done']        as int? ?? 0;
        _reflectionsCount = stats['reflections_count'] as int? ?? 0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('AppState.loadProfile error: $e');
    }
  }

  // ── Profile mutations ────────────────────────────────────────
  Future<void> completeOnboarding() async {
  _onboardingDone = true;
  notifyListeners();
  try {
    await ProfileService.updateProfile({'onboarding_done': true});
  } catch (e) {
    debugPrint('completeOnboarding error (ignored): $e');
  }
}

Future<void> setUserName(String name) async {
  _userName = name;
  // ← removed _onboardingDone = true from here
  notifyListeners();
  try {
    await ProfileService.setUserName(name);
  } catch (e) {
    debugPrint('setUserName Supabase error (ignored): $e');
  }
}

  Future<void> setUserStyle(String style) async {
  _userStyle = style;
  notifyListeners();
  try {
    await ProfileService.setUserStyle(style);
  } catch (e) {
    debugPrint('setUserStyle error (ignored): $e');
  }
}

  Future<void> setKundliData(String data) async {
    _kundliData = data;
    notifyListeners();
    await ProfileService.updateProfile({'kundli_data': data});
  }

  /// Store birth details locally + in Supabase profile.
  /// Call this right after collecting the birth form — before the VedAstro call.
  Future<void> setBirthDetails({
    required String name,
    required String date,
    required String time,
    required String place,
    required String gender,
  }) async {
    _birthName   = name;
    _birthDate   = date;
    _birthTime   = time;
    _birthPlace  = place;
    _birthGender = gender;
    notifyListeners();
    try {
      await ProfileService.updateProfile({
        'birth_name':   name,
        'birth_date':   date,
        'birth_time':   time,
        'birth_place':  place,
        'birth_gender': gender,
      });
    } catch (_) {}
  }

  /// Clear kundli data only (birth details retained for re-generation).
  Future<void> clearKundliData() async {
    _kundliData = null;
    notifyListeners();
    await ProfileService.updateProfile({'kundli_data': null});
  }

  Future<void> setPremium(bool value, {String? plan}) async {
    _isPremium = value;
    notifyListeners();
    await ProfileService.setPremium(value: value, plan: plan);
    if (value && plan != null) {
      await SubscriptionService.logEvent(
        eventType: 'subscribe',
        plan: plan,
        provider: 'in_app',
      );
    }
  }

  // ── Mantra selection ─────────────────────────────────────────
  void setMantra(Mantra m) {
    _selectedMantra = m;
    notifyListeners();
  }

  // ── Start puja session in Supabase ───────────────────────────
  Future<void> startPujaSession() async {
    if (_selectedMantra == null) return;
    try {
      _activeSessionId = await PujaService.startSession(
        mantraId: _selectedMantra!.id,
        totalLines: _selectedMantra!.lines.length,
      );
    } catch (e) {
      debugPrint('startPujaSession error: $e');
    }
  }

  // ── Record a line attempt ────────────────────────────────────
  Future<void> recordLineAttempt({
    required int lineIndex,
    required int attemptNo,
    required String? recognized,
    required double score,
    required bool passed,
  }) async {
    if (_activeSessionId == null) return;
    try {
      await PujaService.recordLineAttempt(
        sessionId: _activeSessionId!,
        lineIndex: lineIndex,
        attemptNo: attemptNo,
        recognized: recognized,
        score: score,
        passed: passed,
      );
    } catch (e) {
      debugPrint('recordLineAttempt error: $e');
    }
  }

  // ── Complete the puja session ────────────────────────────────
  Future<void> completePujaSession({
    required int linesCompleted,
    required double avgScore,
    required int durationSecs,
    String? reflectionText,
    bool skipped = false,
  }) async {
    if (_activeSessionId == null || _selectedMantra == null) return;
    try {
      await PujaService.completeSession(
        sessionId: _activeSessionId!,
        linesCompleted: linesCompleted,
        linesTotal: _selectedMantra!.lines.length,
        avgScore: avgScore,
        durationSecs: durationSecs,
        reflectionText: reflectionText,
        skipped: skipped,
      );
      if (linesCompleted == _selectedMantra!.lines.length) {
        _pujasDone++;
        await loadProfile();
      }
    } catch (e) {
      debugPrint('completePujaSession error: $e');
    }
    _activeSessionId = null;
    notifyListeners();
  }

  // ── Save reflection ──────────────────────────────────────────
  Future<void> saveReflection({
    required String moodId,
    required String moodLabel,
    required String moodEmoji,
    String? guidanceText,
    String? journalText,
  }) async {
    try {
      await ReflectionService.saveReflection(
        moodId: moodId,
        moodLabel: moodLabel,
        moodEmoji: moodEmoji,
        guidanceText: guidanceText,
        journalText: journalText,
      );
      _reflectionsCount++;
      await loadProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('saveReflection error: $e');
    }
  }

ManifestationTechnique? _currentTechnique;
ManifestationTechnique? get currentTechnique => _currentTechnique;

void setTechnique(ManifestationTechnique t) {
  _currentTechnique = t;
  notifyListeners();
}

Aarti? _currentAarti;
  Aarti? get currentAarti => _currentAarti;

  void setAarti(Aarti a) {
    _currentAarti = a;
    notifyListeners();
  }

  VistarPuja? currentVistarPuja;

void setVistarPuja(VistarPuja p) {
  currentVistarPuja = p;
  notifyListeners();
}
}