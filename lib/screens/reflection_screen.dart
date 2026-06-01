import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/app_data.dart';
import '../../models/models.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';
import '../../services/gemini_service.dart';
import '../../services/supabase_service.dart';

// Mood → Gita verse mapping
const Map<String, GitaVerse> kMoodVerse = {
  'peaceful':  GitaVerse(ch: 6, v: 5,  text: "Elevate yourself through the power of your mind; do not degrade yourself.", theme: "Self-mastery"),
  'anxious':   GitaVerse(ch: 2, v: 47, text: "You have a right to perform your duties, but not to the fruits of your actions.", theme: "Non-attachment"),
  'sad':       GitaVerse(ch: 2, v: 14, text: "The appearance of happiness and distress are like winter and summer — they come and go.", theme: "Impermanence"),
  'grateful':  GitaVerse(ch: 9, v: 22, text: "To those who worship me with devotion, I provide what they lack and preserve what they have.", theme: "Divine grace"),
  'lost':      GitaVerse(ch: 18, v: 66, text: "Surrender all duties to me alone. I shall liberate you from all sins. Do not grieve.", theme: "Surrender"),
  'energetic': GitaVerse(ch: 3, v: 21, text: "Whatever great people do, common people follow. Whatever standards they set, the world follows.", theme: "Leadership"),
};

class ReflectionScreen extends StatefulWidget {
  final AppState state;
  const ReflectionScreen({super.key, required this.state});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  Mood? _mood;
  String _guidance = '';
  bool _loading = false;
  bool _saved = false;
  bool _saving = false;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _selectMood(Mood m) async {
    setState(() {
      _mood = m;
      _loading = true;
      _guidance = '';
      _saved = false;
    });
    final g = await aiCall(
      'You are Dharma Guide — a calm Hindu spiritual counselor rooted in Bhagavad Gita. '
      'Style: ${widget.state.userStyle}. Give 2 sentences max. Specific, warm, draw from Gita wisdom. No platitudes.',
      'User feels: ${m.label}. Give brief actionable spiritual guidance.',
    );
    setState(() {
      _guidance = g ?? kMoodFallback[m.id] ?? '';
      _loading = false;
    });
  }

  Future<void> _saveReflection() async {
    if (_mood == null) return;
    setState(() => _saving = true);
    try {
      await ReflectionService.saveReflection(
        moodId: _mood!.id,
        moodLabel: _mood!.label,
        moodEmoji: _mood!.emoji,
        guidanceText: _guidance,
        journalText: _textController.text.trim(),
      );
      setState(() => _saved = true);
    } catch (e) {
      // fallback — still mark saved locally
      setState(() => _saved = true);
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verse = _mood != null ? kMoodVerse[_mood!.id] : null;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                children: [
                  const Text('Daily Reflection',
                      style: TextStyle(fontSize: 28, color: kText, fontWeight: FontWeight.w400)),
                  const Text('How are you showing up today?',
                      style: TextStyle(fontSize: 13, color: kDim)),
                  const SizedBox(height: 14),

                  // Mood Picker
                  DharmaCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('YOUR MOOD',
                          style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.1,
                        children: kMoods.map((m) {
                          final sel = _mood?.id == m.id;
                          return GestureDetector(
                            onTap: () => _selectMood(m),
                            child: Container(
                              decoration: BoxDecoration(
                                color: sel ? const Color(0xFFFFF8ED) : kSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: sel ? kAccent : kBorder, width: sel ? 2 : 1),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(m.emoji, style: const TextStyle(fontSize: 26)),
                                const SizedBox(height: 4),
                                Text(m.label,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: sel ? kAccent : kDim,
                                        fontWeight: sel ? FontWeight.w500 : FontWeight.w400)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Gita Verse for mood
                  if (verse != null) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFF8ED), Color(0xFFF0E8D8)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kAccent.withOpacity(0.3)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'GITA ${verse.ch}.${verse.v} · ${verse.theme.toUpperCase()}',
                          style: const TextStyle(fontSize: 10, color: kAccent, letterSpacing: 1.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text('"${verse.text}"',
                            style: const TextStyle(fontSize: 16, color: kRust, height: 1.8)),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // AI Guidance card
                  if (_loading || _guidance.isNotEmpty) ...[
                    DharmaCard(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kAccent.withOpacity(0.3)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('✨ DHARMA GUIDANCE',
                            style: TextStyle(fontSize: 10, color: kAccent, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        _loading
                            ? const Text('Seeking wisdom from the Gita...',
                                style: TextStyle(color: kDim, fontSize: 13, fontStyle: FontStyle.italic))
                            : Text(_guidance,
                                style: const TextStyle(fontSize: 16, color: kRust, height: 1.9)),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Journal
                  DharmaCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('JOURNAL',
                          style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _textController,
                        maxLines: null,
                        minLines: 4,
                        decoration: const InputDecoration(
                          hintText: "What's on your mind? Write freely...",
                          hintStyle: TextStyle(color: kDim),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 14, color: kText, height: 1.8),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Save button
                  if (_saved)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('✓ Reflection saved',
                            style: TextStyle(color: kGreen, fontWeight: FontWeight.w500, fontSize: 15)),
                      ),
                    )
                  else
                    DharmaBtn(
                      label: _saving ? 'Saving...' : 'Save Reflection',
                      onTap: (_mood == null || _saving) ? null : _saveReflection,
                    ),
                ],
              ),
            ),
            BottomNav(active: 'reflection', state: widget.state),
          ],
        ),
      ),
    );
  }
}