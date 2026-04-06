// lib/state/app_state.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  // ── Router ──────────────────────────────────────────────────
  String _screen = 'splash';
  String get screen => _screen;

  void nav(String s) { _screen = s; notifyListeners(); }

  // ── Onboarding ──────────────────────────────────────────────
  int _onboardingStep = 0;
  int get onboardingStep => _onboardingStep;

  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;

  void nextOnboardingStep(int step) { _onboardingStep = step; notifyListeners(); }

  // ── Profile ──────────────────────────────────────────────────
  String _userName = 'Seeker';
  String _userStyle = 'balanced';
  bool _isPremium = false;
  int _streak = 0;
  int _pujasDone = 0;
  int _reflectionsCount = 0;

  String get userName => _userName;
  String get userStyle => _userStyle;
  bool get isPremium => _isPremium;
  int get streak => _streak;
  int get pujasDone => _pujasDone;
  int get reflectionsCount => _reflectionsCount;

  // ── Active session ───────────────────────────────────────────
  Mantra? _selectedMantra;
  Mantra? get selectedMantra => _selectedMantra;
  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  // ── Load from Supabase ───────────────────────────────────────
  Future<void> loadProfile() async {
    try {
      final profile = await ProfileService.fetchProfile();
      if (profile != null) {
        _userName       = profile['user_name']      as String? ?? 'Seeker';
        _userStyle      = profile['user_style']      as String? ?? 'balanced';
        _isPremium      = profile['is_premium']      as bool?   ?? false;
        _onboardingDone = profile['onboarding_done'] as bool?   ?? false;
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

  // ── Mutations ────────────────────────────────────────────────
  Future<void> setUserName(String name) async {
    _userName = name; _onboardingDone = true; notifyListeners();
    await ProfileService.setUserName(name);
  }

  Future<void> setUserStyle(String style) async {
    _userStyle = style; notifyListeners();
    await ProfileService.setUserStyle(style);
  }

  Future<void> setPremium(bool value, {String? plan}) async {
    _isPremium = value; notifyListeners();
    await ProfileService.setPremium(value: value, plan: plan);
    if (value && plan != null) {
      await SubscriptionService.logEvent(eventType: 'subscribe', plan: plan, provider: 'in_app');
    }
  }

  void setMantra(Mantra m) { _selectedMantra = m; notifyListeners(); }

  // ── Puja ─────────────────────────────────────────────────────
  Future<void> startPujaSession() async {
    if (_selectedMantra == null) return;
    try {
      _activeSessionId = await PujaService.startSession(
        mantraId: _selectedMantra!.id,
        totalLines: _selectedMantra!.lines.length,
      );
    } catch (e) { debugPrint('startPujaSession error: $e'); }
  }

  Future<void> recordLineAttempt({
    required int lineIndex, required int attemptNo,
    required String? recognized, required double score, required bool passed,
  }) async {
    if (_activeSessionId == null) return;
    try {
      await PujaService.recordLineAttempt(
        sessionId: _activeSessionId!, lineIndex: lineIndex,
        attemptNo: attemptNo, recognized: recognized, score: score, passed: passed,
      );
    } catch (e) { debugPrint('recordLineAttempt error: $e'); }
  }

  Future<void> completePujaSession({
    required int linesCompleted, required double avgScore,
    required int durationSecs, String? reflectionText, bool skipped = false,
  }) async {
    if (_activeSessionId == null || _selectedMantra == null) return;
    try {
      await PujaService.completeSession(
        sessionId: _activeSessionId!, linesCompleted: linesCompleted,
        linesTotal: _selectedMantra!.lines.length, avgScore: avgScore,
        durationSecs: durationSecs, reflectionText: reflectionText, skipped: skipped,
      );
      if (linesCompleted == _selectedMantra!.lines.length) {
        _pujasDone++;
        await loadProfile();
      }
    } catch (e) { debugPrint('completePujaSession error: $e'); }
    _activeSessionId = null;
    notifyListeners();
  }

  // ── Reflection ───────────────────────────────────────────────
  Future<void> saveReflection({
    required String moodId, required String moodLabel, required String moodEmoji,
    String? guidanceText, String? journalText,
  }) async {
    try {
      await ReflectionService.saveReflection(
        moodId: moodId, moodLabel: moodLabel, moodEmoji: moodEmoji,
        guidanceText: guidanceText, journalText: journalText,
      );
      _reflectionsCount++;
      await loadProfile();
      notifyListeners();
    } catch (e) { debugPrint('saveReflection error: $e'); }
  }
}