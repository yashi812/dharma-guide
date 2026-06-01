import 'package:dharma_guide/constants/app_data.dart';
import 'package:dharma_guide/state/app_state.dart';
import 'package:dharma_guide/constants/theme.dart';
import 'package:flutter/material.dart';
import '../../shared_widgets.dart';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';
import '../services/vedastro_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Step indices
// ═══════════════════════════════════════════════════════════════════════════
//   0 → Welcome splash
//   1 → Name entry
//   2 → Guidance style
//   3 → Kundli / birth details  (optional — user can skip)

class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _nameController  = TextEditingController();
  final _placeController = TextEditingController();

  // ── Birth-detail state ───────────────────────────────────────────────────
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _gender = 'Male';

  // ── Loading ───────────────────────────────────────────────────────────────
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  // ── Pickers ───────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kAccent,
            onPrimary: Colors.white,
            onSurface: kText,
            surface: kSurface,
          ), dialogTheme: DialogThemeData(backgroundColor: kSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kAccent,
            onPrimary: Colors.white,
            onSurface: kText,
            surface: kSurface,
          ), dialogTheme: DialogThemeData(backgroundColor: kSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Format helpers ────────────────────────────────────────────────────────
  String get _dobFormatted {
    if (_selectedDate == null) return '';
    final d = _selectedDate!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get _timeFormatted {
    if (_selectedTime == null) return '';
    final h = _selectedTime!.hour.toString().padLeft(2, '0');
    final m = _selectedTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get _resolvedName {
    final t = _nameController.text.trim();
    return t.isEmpty ? 'Seeker' : t;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1 → 2 transition: save name, advance
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _saveName() async {
    await widget.state.setUserName(_resolvedName);
    // Persist name to Supabase immediately so it's never lost
    await GuidanceService.saveUserInput(
      screen: 'onboarding',
      fieldName: 'birth_name',
      value: _resolvedName,
    );
    if (mounted) widget.state.nextOnboardingStep(2);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2 → 3 transition: save style, advance
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _saveStyle() async {
    await GuidanceService.saveUserInput(
      screen: 'onboarding',
      fieldName: 'guidance_style',
      value: widget.state.userStyle,
    );
    if (mounted) widget.state.nextOnboardingStep(3);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Skip kundli — persist what we have and go home
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _skip() async {
    // Make sure name + style are persisted even if user never hit "Continue"
    await Future.wait([
      widget.state.setUserName(_resolvedName),
      widget.state.completeOnboarding(), // ← add this
      GuidanceService.upsertUserProfile(
        name: _resolvedName,
        guidanceStyle: widget.state.userStyle,
        birthDate: '',
        birthTime: '',
        birthPlace: '',
        birthGender: '',
      ),
    ]);
    if (mounted) widget.state.nav('home');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Illuminate — generate kundli profile, save everything, go home
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _illuminate() async {
    final name  = _resolvedName;
    final place = _placeController.text.trim();
    final dob   = _dobFormatted;
    final time  = _timeFormatted;

    await widget.state.setUserName(name);
    setState(() => _isGenerating = true);

    try {
      await widget.state.setBirthDetails(
        name:   name,
        date:   dob,
        time:   time,
        place:  place,
        gender: _gender,
      );

      // Persist all fields to Supabase in parallel
      await Future.wait([
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_name',     value: name),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_date',     value: dob),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_time',     value: time),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_place',    value: place),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_gender',   value: _gender),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'guidance_style', value: widget.state.userStyle),
        GuidanceService.upsertUserProfile(
          name:          name,
          guidanceStyle: widget.state.userStyle,
          birthDate:     dob,
          birthTime:     time,
          birthPlace:    place,
          birthGender:   _gender,
        ),
      ]);

      // Fetch VedAstro predictions
      String vedastroRaw = '';
      try {
        vedastroRaw = await VedAstroService.getRichPredictions(
          location: place, time: time, date: dob, maxPerCategory: 4,
        );
      } catch (e) {
        debugPrint('VedAstro error (continuing): $e');
      }

      // Build kundli prompt
      final sb = StringBuffer(
        'You are an expert Vedic astrologer. '
        'Birth details: Name = $name, Gender = $_gender, '
        'DOB = $dob, Time = $time, Place = $place. ',
      );
      if (vedastroRaw.isNotEmpty) {
        sb.write('VedAstro calculations:\n$vedastroRaw\n\nUsing these as primary source, ');
      }
      sb.write(
        'Write a comprehensive astrological profile covering: '
        '(a) Core personality & temperament, '
        '(b) Key strengths the soul possesses, '
        '(c) Karmic challenges to overcome, '
        '(d) Life-path themes (career, relationships, spirituality), '
        '(e) Periods of significant transformation. '
        'Be specific, insightful, and use astrological language. '
        'Return ONLY the profile text — no headings, no preamble.',
      );

      final kundli = await aiCall(
        'You are an expert Vedic astrologer producing private astrological profiles.',
        sb.toString(),
        tokens: 700,
      );

      if (kundli != null && kundli.isNotEmpty) {
        await widget.state.setKundliData(kundli);
        await GuidanceService.saveUserInput(
          screen: 'onboarding', fieldName: 'kundli_profile', value: kundli,
        );
      }
    } catch (e) {
      debugPrint('Onboarding kundli error: $e');
    }

    if (mounted) {
      setState(() => _isGenerating = false);
      await widget.state.completeOnboarding();
      widget.state.nav('home');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    switch (widget.state.onboardingStep) {
      case 0:  return _step0();
      case 1:  return _step1();
      case 2:  return _step2();
      default: return _step3();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 0: Welcome splash
  // ─────────────────────────────────────────────────────────────────────────
  Widget _step0() => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
        child: Column(
          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ॐ', style: TextStyle(fontSize: 88, height: 1)),
                  SizedBox(height: 16),
                  Text(
                    'Begin Your\nDharmic Journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42, color: kText,
                      fontWeight: FontWeight.w400, height: 1.15,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'A calm space for daily wisdom, guided practices, '
                    'and spiritual clarity rooted in ancient Gita teachings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kDim, fontSize: 15, height: 1.9),
                  ),
                ],
              ),
            ),
            DharmaBtn(
              label: 'Get Started →',
              onTap: () => widget.state.nextOnboardingStep(1),
            ),
          ],
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1: Enter name
  // ─────────────────────────────────────────────────────────────────────────
  Widget _step1() => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackBtn(onTap: () => widget.state.nextOnboardingStep(0)),
            const SizedBox(height: 20),
            const Text('STEP 1 OF 3',
                style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 1.5)),
            const SizedBox(height: 6),
            const Text('What shall we call you?',
                style: TextStyle(fontSize: 30, color: kText, fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            const Text('Your name personalises your guidance.',
                style: TextStyle(fontSize: 13, color: kDim)),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Your name…',
                hintStyle: const TextStyle(color: kDim),
                filled: true,
                fillColor: kSurface,
                prefixIcon: const Icon(Icons.person_outline, color: kDim, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kAccent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16, color: kText),
            ),
            const Spacer(),
            DharmaBtn(
              label: 'Continue →',
              onTap: _saveName,
            ),
          ],
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2: Choose guidance style
  // ─────────────────────────────────────────────────────────────────────────
  Widget _step2() => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackBtn(onTap: () => widget.state.nextOnboardingStep(1)),
            const SizedBox(height: 20),
            const Text('STEP 2 OF 3',
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
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
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
                                      color: kText, fontSize: 15)),
                              Text(gs.desc,
                                  style: const TextStyle(fontSize: 12, color: kDim)),
                            ],
                          ),
                        ),
                        if (selected)
                          const Text('✓', style: TextStyle(color: kAccent, fontSize: 18)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
            DharmaBtn(
              label: 'Continue →',
              onTap: _saveStyle,
            ),
          ],
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Step 3: Birth details (kundli)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _step3() {
    final allFilled = _selectedDate != null &&
        _selectedTime != null &&
        _placeController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row with back + skip ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackBtn(onTap: () => widget.state.nextOnboardingStep(2)),
                  if (!_isGenerating)
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Text('Skip', style: TextStyle(fontSize: 13, color: kDim)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('STEP 3 OF 3',
                  style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              const Text('Your Dharmic Profile',
                  style: TextStyle(fontSize: 30, color: kText, fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              const Text(
                'Birth details unlock personalised Vedic guidance. Completely private.',
                style: TextStyle(fontSize: 13, color: kDim, height: 1.5),
              ),
              const SizedBox(height: 28),

              // ── Date of Birth ─────────────────────────────────────────────
              _fieldLabel('Date of Birth'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _isGenerating ? null : _pickDate,
                child: _pickerTile(
                  icon: Icons.calendar_today_outlined,
                  text: _selectedDate == null ? 'Tap to select date' : _dobFormatted,
                  filled: _selectedDate != null,
                ),
              ),
              const SizedBox(height: 16),

              // ── Time of Birth ─────────────────────────────────────────────
              _fieldLabel('Time of Birth'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _isGenerating ? null : _pickTime,
                child: _pickerTile(
                  icon: Icons.schedule_outlined,
                  text: _selectedTime == null ? 'Tap to select time' : _timeFormatted,
                  filled: _selectedTime != null,
                ),
              ),
              const SizedBox(height: 16),

              // ── Place of Birth ────────────────────────────────────────────
              _fieldLabel('Place of Birth'),
              const SizedBox(height: 6),
              TextField(
                controller: _placeController,
                textCapitalization: TextCapitalization.words,
                enabled: !_isGenerating,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'City (e.g. Mumbai)',
                  hintStyle: const TextStyle(color: kDim),
                  filled: true,
                  fillColor: kSurface,
                  prefixIcon:
                      const Icon(Icons.location_on_outlined, color: kDim, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kAccent, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: kText),
              ),
              const SizedBox(height: 16),

              // ── Gender ────────────────────────────────────────────────────
              _fieldLabel('Gender'),
              const SizedBox(height: 6),
              Row(
                children: ['Male', 'Female', 'Other'].map((g) {
                  final sel = _gender == g;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _isGenerating ? null : () => setState(() => _gender = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFFFF8ED) : kSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? kAccent : kBorder,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(g,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: sel ? kAccent : kDim,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // ── Loading indicator ─────────────────────────────────────────
              if (_isGenerating) ...[
                const Center(child: CircularProgressIndicator(color: kAccent)),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '"The soul is eternal, the wisdom eternal —\nyour path is being illuminated…"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: kDim,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Illuminate button ─────────────────────────────────────────
              if (!_isGenerating && allFilled)
                DharmaBtn(label: 'Illuminate My Path 🙏', onTap: _illuminate),

              // ── Incomplete hint ───────────────────────────────────────────
              if (!_isGenerating && !allFilled)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Text(
                    'Fill in your date, time and place of birth above to unlock your personalised Vedic profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: kDim, height: 1.5),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared UI helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 12, color: kDim, letterSpacing: 0.5),
      );

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required bool filled,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? kAccent : kBorder,
            width: filled ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Icon(icon, color: filled ? kAccent : kDim, size: 20),
          const SizedBox(width: 12),
          Text(text,
              style: TextStyle(
                  fontSize: 15, color: filled ? kText : kDim)),
          const Spacer(),
          if (filled)
            const Icon(Icons.check_circle_rounded, color: kAccent, size: 18),
        ]),
      );
}