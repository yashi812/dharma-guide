import 'package:dharma_guide/constants/app_data.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../../models/models.dart';
import '../../services/ai_service.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';
import '../ai_service.dart';
import '../models/models.dart';
import '../theme.dart';

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

  @override
  Widget build(BuildContext context) {
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
                      style: TextStyle(
                          fontSize: 28,
                          color: kText,
                          fontWeight: FontWeight.w400)),
                  const Text('How are you showing up today?',
                      style: TextStyle(fontSize: 13, color: kDim)),
                  const SizedBox(height: 14),

                  // Mood Picker
                  DharmaCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR MOOD',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: kDim,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500)),
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
                                    color: sel
                                        ? const Color(0xFFFFF8ED)
                                        : kSurface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel ? kAccent : kBorder,
                                        width: sel ? 2 : 1),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(m.emoji,
                                          style:
                                              const TextStyle(fontSize: 26)),
                                      const SizedBox(height: 4),
                                      Text(m.label,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: sel ? kAccent : kDim,
                                              fontWeight: sel
                                                  ? FontWeight.w500
                                                  : FontWeight.w400)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 14),

                  // Guidance card
                  if (_loading || _guidance.isNotEmpty) ...[
                    DharmaCard(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: kAccent.withOpacity(0.3)),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✨ DHARMA GUIDANCE',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: kAccent,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            _loading
                                ? const Text(
                                    'Seeking wisdom from the Gita...',
                                    style: TextStyle(
                                        color: kDim,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic))
                                : Text(_guidance,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: kRust,
                                        height: 1.9)),
                          ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Journal
                  DharmaCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('JOURNAL',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: kDim,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500)),
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
                            style: const TextStyle(
                                fontSize: 14, color: kText, height: 1.8),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 14),

                  _saved
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('✓ Reflection saved',
                                style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15)),
                          ),
                        )
                      : DharmaBtn(
                          label: 'Save Reflection',
                          onTap: _mood == null
                              ? null
                              : () => setState(() => _saved = true),
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
