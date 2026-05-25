import 'package:dharma_guide/constants/theme.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';

class PujaCompleteScreen extends StatefulWidget {
  final AppState state;
  const PujaCompleteScreen({super.key, required this.state});

  @override
  State<PujaCompleteScreen> createState() => _PujaCompleteScreenState();
}

class _PujaCompleteScreenState extends State<PujaCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _badgeFade;

  final _refController = TextEditingController();
  bool _saved = false;
  bool _saving = false;
  bool _sessionRecorded = false;

  // Streak is read directly from AppState after completePujaSession()
  int get _streak => widget.state.streak;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _badgeFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );
    _ctrl.forward();

    _recordSession();
  }

  Future<void> _recordSession() async {
    if (_sessionRecorded) return;
    _sessionRecorded = true;

    // completePujaSession updates streak server-side and calls loadProfile()
    // so widget.state.streak will be correct after this call.
    await widget.state.completePujaSession(
      linesCompleted: widget.state.selectedMantra?.lines.length ?? 0,
      avgScore: 1.0,
      durationSecs: 0,
      skipped: false,
    );

    if (mounted) setState(() {}); // rebuild to show updated streak
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _saveAndGoHome() async {
    if (_saving) return;
    setState(() => _saving = true);

    final reflection = _refController.text.trim();
    if (reflection.isNotEmpty) {
      await widget.state.completePujaSession(
        linesCompleted: widget.state.selectedMantra?.lines.length ?? 0,
        avgScore: 1.0,
        durationSecs: 0,
        reflectionText: reflection,
      );
    }

    setState(() {
      _saved = true;
      _saving = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) widget.state.nav('home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 48),

            // ── Animated lamp ──────────────────────────────────────────────
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: const Text('🪔', style: TextStyle(fontSize: 72)),
              ),
            ),
            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Practice Complete',
                style: TextStyle(
                    fontSize: 32,
                    color: kText,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(height: 8),

            Center(
              child: Text(
                widget.state.selectedMantra?.name ?? '',
                style: const TextStyle(fontSize: 14, color: kRust),
              ),
            ),
            const SizedBox(height: 6),

            const Center(
              child: Text(
                'May the vibrations of this mantra bring peace,\nclarity, and divine grace to your day.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kDim, height: 1.8),
              ),
            ),
            const SizedBox(height: 24),

            // ── Streak badge — always shown, 0 days until session loads ───
            FadeTransition(
              opacity: _badgeFade,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$_streak ${_streak == 1 ? 'day' : 'days'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _streak > 0 ? kAccent : kDim,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Reflection card ────────────────────────────────────────────
            DharmaCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text(
                  'ADD REFLECTION (OPTIONAL)',
                  style: TextStyle(
                      fontSize: 11,
                      color: kDim,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _refController,
                  maxLines: null,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'How did this practice feel?',
                    hintStyle: TextStyle(color: kDim),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: kText, height: 1.7),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Home button ────────────────────────────────────────────────
            DharmaBtn(
              label: _saving
                  ? 'Saving…'
                  : _saved
                      ? 'Saved ✓'
                      : 'Return Home 🙏',
              onTap: _saveAndGoHome,
            ),
          ],
        ),
      ),
    );
  }
}