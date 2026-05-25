import 'package:shared_preferences/shared_preferences.dart';

/// Persists practice reflections and streak data locally.
class PracticeStorage {
  PracticeStorage._();
  static final PracticeStorage instance = PracticeStorage._();

  static const _keyReflections = 'reflections';
  static const _keyStreak = 'streak';
  static const _keyLastDate = 'last_practice_date';

  // ── Reflections ──────────────────────────────────────────────────────────

  Future<void> saveReflection({
    required String mantraName,
    required String reflection,
  }) async {
    if (reflection.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_keyReflections) ?? [];
    final entry =
        '${DateTime.now().toIso8601String()}|$mantraName|${reflection.trim()}';
    existing.insert(0, entry); // newest first
    // Keep last 100 reflections
    await prefs.setStringList(
        _keyReflections, existing.take(100).toList());
  }

  Future<List<ReflectionEntry>> getReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyReflections) ?? [];
    return raw.map((s) {
      final parts = s.split('|');
      return ReflectionEntry(
        date: DateTime.tryParse(parts[0]) ?? DateTime.now(),
        mantraName: parts.length > 1 ? parts[1] : '',
        text: parts.length > 2 ? parts[2] : '',
      );
    }).toList();
  }

  // ── Streaks ──────────────────────────────────────────────────────────────

  Future<int> recordPracticeAndGetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateStr(DateTime.now());
    final lastDate = prefs.getString(_keyLastDate) ?? '';
    int streak = prefs.getInt(_keyStreak) ?? 0;

    if (lastDate == today) {
      // Already practiced today — streak unchanged
      return streak;
    }

    final yesterday =
        _dateStr(DateTime.now().subtract(const Duration(days: 1)));
    if (lastDate == yesterday) {
      streak += 1; // consecutive day
    } else {
      streak = 1; // streak broken
    }

    await prefs.setInt(_keyStreak, streak);
    await prefs.setString(_keyLastDate, today);
    return streak;
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class ReflectionEntry {
  final DateTime date;
  final String mantraName;
  final String text;
  const ReflectionEntry(
      {required this.date, required this.mantraName, required this.text});
}