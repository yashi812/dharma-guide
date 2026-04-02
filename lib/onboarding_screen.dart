import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/app_data.dart';
import '../state/app_state.dart';
import '../widgets/shared_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.state.onboardingStep;
    if (step == 0) return _step0();
    if (step == 1) return _step1();
    return _step2();
  }

  // ── Step 0: Welcome ──────────────────────────
  Widget _step0() => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('ॐ', style: TextStyle(fontSize: 88, height: 1)),
                      SizedBox(height: 16),
                      Text(
                        'Begin Your\nDharmic Journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 42,
                            color: kText,
                            fontWeight: FontWeight.w400,
                            height: 1.15),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'A calm space for daily wisdom, guided practices, and spiritual clarity rooted in ancient Gita teachings.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: kDim, fontSize: 15, height: 1.9),
                      ),
                    ],
                  ),
                ),
                DharmaBtn(
                  label: 'Get Started →',
                  onTap: () => widget.state.setOnboardingStep(1),
                ),
              ],
            ),
          ),
        ),
      );

  // ── Step 1: Choose Style ─────────────────────
  Widget _step1() => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackBtn(onTap: () => widget.state.setOnboardingStep(0)),
                const SizedBox(height: 20),
                const Text('STEP 1 OF 2',
                    style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                const Text('Choose Your Path',
                    style: TextStyle(fontSize: 30, color: kText, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                const Text('How should guidance reach you?',
                    style: TextStyle(fontSize: 13, color: kDim)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: kStyles.map((gs) {
                      final selected = widget.state.userStyle == gs.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DharmaCard(
                          onTap: () => widget.state.setUserStyle(gs.id),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFFFFF8ED) : kSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: selected ? kAccent : kBorder,
                                width: selected ? 2 : 1),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Row(children: [
                            Text(gs.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(gs.label,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: kText,
                                            fontSize: 15)),
                                    Text(gs.desc,
                                        style: const TextStyle(
                                            fontSize: 12, color: kDim)),
                                  ]),
                            ),
                            if (selected)
                              const Text('✓',
                                  style: TextStyle(color: kAccent, fontSize: 18)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                DharmaBtn(
                  label: 'Continue →',
                  onTap: () => widget.state.setOnboardingStep(2),
                ),
              ],
            ),
          ),
        ),
      );

  // ── Step 2: Enter Name ───────────────────────
  Widget _step2() => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackBtn(onTap: () => widget.state.setOnboardingStep(1)),
                const SizedBox(height: 20),
                const Text('STEP 2 OF 2',
                    style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                const Text('What shall we call you?',
                    style: TextStyle(
                        fontSize: 30, color: kText, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                const Text('Your name personalizes your guidance.',
                    style: TextStyle(fontSize: 13, color: kDim)),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Your name...',
                    hintStyle: const TextStyle(color: kDim),
                    filled: true,
                    fillColor: kSurface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: kAccent, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16, color: kText),
                ),
                const Spacer(),
                DharmaBtn(
                  label: 'Begin Journey 🙏',
                  onTap: () {
                    widget.state.setUserName(
                      _nameController.text.trim().isEmpty
                          ? 'Seeker'
                          : _nameController.text.trim(),
                    );
                    widget.state.nav('home');
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
