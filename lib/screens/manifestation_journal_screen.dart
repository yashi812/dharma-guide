// lib/screens/manifestation_journal_screen.dart
// Full replacement — only _save() and the import changed.

import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../state/app_state.dart';
import '../shared_widgets.dart';
import '../services/supabase_service.dart';
import '../screens/manifestation_animation_screen.dart'; // ← new

class ManifestationJournalScreen extends StatefulWidget {
  final AppState state;
  const ManifestationJournalScreen({super.key, required this.state});

  @override
  State<ManifestationJournalScreen> createState() =>
      _ManifestationJournalScreenState();
}

class _ManifestationJournalScreenState
    extends State<ManifestationJournalScreen> {
  final _controller = TextEditingController();
  bool _saving = false;
  bool _saved = false;
  List<Map<String, dynamic>> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
  final t = widget.state.currentTechnique;
  if (t == null) return;
  try {
    final entries = await ManifestationService.fetchForTechnique(t.name);
    if (mounted) setState(() { _history = entries; _loadingHistory = false; });
  } catch (e) {
    debugPrint('_loadHistory error: $e');
    if (mounted) setState(() { _loadingHistory = false; }); // ← spinner always clears
  }
}

  Future<void> _save() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;
  final t = widget.state.currentTechnique;
  if (t == null) return;

  // ── Animated sacred reveal for journaling techniques ─────────────────
  final bool useAnimation = t.name.contains('21') ||
      t.name.contains('3-6-9') ||
      t.name.contains('5×55') ||
      t.name.contains('Scripting');

  if (useAnimation) {
    setState(() => _saving = true);
    try {
      // Save the entry FIRST so it actually persists.
      await ManifestationService.saveEntry(
        techniqueName: t.name,
        journalText:   text,
      );
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Try again.')),
        );
      }
      return; // don't proceed to animation if save failed
    }

    setState(() => _saving = false);
    _controller.clear();

    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ManifestationAnimationScreen(
          intention:     text,
          techniqueName: t.name,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );

    if (mounted) {
      setState(() => _saved = true);
      await _loadHistory();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saved = false);
    }
    return;
  }

  // ── All other techniques: save directly (original behaviour) ──────────
  setState(() => _saving = true);
  try {
    await ManifestationService.saveEntry(
      techniqueName: t.name,
      journalText:   text,
    );
    _controller.clear();
    setState(() { _saved = true; _saving = false; });
    await _loadHistory();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  } catch (e) {
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Try again.')),
      );
    }
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.state.currentTechnique!;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.state.nav('technique_detail'),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 14, color: kText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${t.emoji}  ${t.name} Journal',
                        style: const TextStyle(fontSize: 15, color: kText)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  // Write section
                  const Text('TODAY\'S ENTRY',
                      style: TextStyle(
                          fontSize: 10, color: kDim,
                          letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _controller,
                      maxLines: 8,
                      style: const TextStyle(
                          fontSize: 14, color: kText, height: 1.7),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _hint(t.name),
                        hintStyle: const TextStyle(
                            fontSize: 14, color: kDim, height: 1.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Save button
                  GestureDetector(
                    onTap: _saving ? null : _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _saved
                            ? const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)])
                            : const LinearGradient(colors: [kAccent, kRust]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _saving
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                _saved
                                    ? '✓ Manifested'
                                    : _manifestButtonLabel(t.name),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // History
                  const Text('PAST ENTRIES',
                      style: TextStyle(
                          fontSize: 10, color: kDim,
                          letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),

                  if (_loadingHistory)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: kAccent),
                    ))
                  else if (_history.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Center(
                        child: Text('No entries yet.\nStart your practice today.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: kDim, height: 1.6)),
                      ),
                    )
                  else
                    ...(_history.map((entry) {
                      final date = entry['journaled_on'] as String;
                      final text = entry['journal_text'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(date,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: kAccent,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(text,
                                  style: const TextStyle(
                                      fontSize: 13, color: kText, height: 1.6)),
                            ],
                          ),
                        ),
                      );
                    })),
                ],
              ),
            ),

            BottomNav(active: 'home', state: widget.state),
          ],
        ),
      ),
    );
  }

  String _hint(String name) {
    if (name.contains('21')) {
      return 'Write your intention clearly and feel it as already real…\n\n'
          'e.g. "I am grateful that I now earn ₹1,00,000 per month doing work I love."';
    }
    if (name.contains('3-6-9')) return 'Write your affirmation and notice how it feels today...';
    if (name.contains('5×55')) return 'Write your affirmation 55 times. Start here...';
    if (name.contains('Script')) return 'Dear future me... today was incredible because...';
    return 'Describe your vision in vivid detail, as if it\'s already yours...';
  }

  String _manifestButtonLabel(String name) {
    if (name.contains('21'))       return 'Manifest ✨';
    if (name.contains('3-6-9'))    return 'Seal Intention 🔢';
    if (name.contains('5×55'))     return 'Send to Universe ✍️';
    if (name.contains('Scripting')) return 'Script My Future 🌟';
    return 'Save Entry';
  }
}