import 'package:dharma_guide/constants/app_data.dart';
import 'package:dharma_guide/state/app_state.dart';
import 'package:dharma_guide/constants/theme.dart';
import 'package:flutter/material.dart';
import '../../shared_widgets.dart';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';
import '../services/vedastro_service.dart';

class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController  = TextEditingController();
  final _placeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _gender = 'Male';
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────────
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
          ),
          dialogBackgroundColor: kSurface,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Time picker ───────────────────────────────────────────────
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
          ),
          dialogBackgroundColor: kSurface,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Format helpers ────────────────────────────────────────────
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

  // ── Skip — go home without kundli ────────────────────────────
  Future<void> _skip() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Seeker'
        : _nameController.text.trim();
    await widget.state.setUserName(name);
    if (mounted) widget.state.nav('home');
  }

  // ── Illuminate — generate kundli then go home ─────────────────
  Future<void> _illuminate() async {
    final name  = _nameController.text.trim().isEmpty
        ? 'Seeker'
        : _nameController.text.trim();
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

      await Future.wait([
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_name',   value: name),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_date',   value: dob),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_time',   value: time),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_place',  value: place),
        GuidanceService.saveUserInput(screen: 'onboarding', fieldName: 'birth_gender', value: _gender),
        GuidanceService.upsertUserProfile(
          name: name, guidanceStyle: widget.state.userStyle,
          birthDate: dob, birthTime: time, birthPlace: place, birthGender: _gender,
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
      widget.state.nav('home');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final step = widget.state.onboardingStep;
    if (step == 0) return _step0();
    if (step == 1) return _step1();
    if (step == 2) return _step2();
    return _step3();
  }

  // ── Step 0: Welcome ───────────────────────────────────────────
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

  // ── Step 1: Choose Style ──────────────────────────────────────
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
                                        style: const TextStyle(fontSize: 12, color: kDim)),
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
                  onTap: () => widget.state.nextOnboardingStep(2),
                ),
              ],
            ),
          ),
        ),
      );

  // ── Step 2: Enter Name ────────────────────────────────────────
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
                const Text('What shall we call you?',
                    style: TextStyle(
                        fontSize: 30, color: kText, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                const Text('Your name personalizes your guidance.',
                    style: TextStyle(fontSize: 13, color: kDim)),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Your name...',
                    hintStyle: const TextStyle(color: kDim),
                    filled: true,
                    fillColor: kSurface,
                    prefixIcon:
                        const Icon(Icons.person_outline, color: kDim, size: 20),
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
                  label: 'Continue →',
                  onTap: () => widget.state.nextOnboardingStep(3),
                ),
              ],
            ),
          ),
        ),
      );

  // ── Step 3: Birth Details ─────────────────────────────────────
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
              // ── Header row with skip ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackBtn(onTap: () => widget.state.nextOnboardingStep(2)),
                  if (!_isGenerating)
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Text('Skip',
                            style: TextStyle(fontSize: 13, color: kDim)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('STEP 3 OF 3',
                  style: TextStyle(
                      fontSize: 11, color: kDim, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              const Text('Your Dharmic Profile',
                  style: TextStyle(
                      fontSize: 30,
                      color: kText,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              const Text(
                'Birth details unlock personalised Vedic guidance. Completely private.',
                style: TextStyle(fontSize: 13, color: kDim, height: 1.5),
              ),
              const SizedBox(height: 28),

              // ── Date of Birth ──────────────────────────────────
              const Text('Date of Birth',
                  style: TextStyle(
                      fontSize: 12, color: kDim, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _isGenerating ? null : _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _selectedDate != null ? kAccent : kBorder,
                        width: _selectedDate != null ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined,
                        color: _selectedDate != null ? kAccent : kDim,
                        size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null ? 'Tap to select date' : _dobFormatted,
                      style: TextStyle(
                          fontSize: 15,
                          color: _selectedDate == null ? kDim : kText),
                    ),
                    const Spacer(),
                    if (_selectedDate != null)
                      const Icon(Icons.check_circle_rounded,
                          color: kAccent, size: 18),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // ── Time of Birth ──────────────────────────────────
              const Text('Time of Birth',
                  style: TextStyle(
                      fontSize: 12, color: kDim, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _isGenerating ? null : _pickTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _selectedTime != null ? kAccent : kBorder,
                        width: _selectedTime != null ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Icon(Icons.schedule_outlined,
                        color: _selectedTime != null ? kAccent : kDim,
                        size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime == null ? 'Tap to select time' : _timeFormatted,
                      style: TextStyle(
                          fontSize: 15,
                          color: _selectedTime == null ? kDim : kText),
                    ),
                    const Spacer(),
                    if (_selectedTime != null)
                      const Icon(Icons.check_circle_rounded,
                          color: kAccent, size: 18),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // ── Place of Birth ─────────────────────────────────
              const Text('Place of Birth',
                  style: TextStyle(
                      fontSize: 12, color: kDim, letterSpacing: 0.5)),
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
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: kDim, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: kAccent, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: kText),
              ),
              const SizedBox(height: 16),

              // ── Gender ─────────────────────────────────────────
              const Text('Gender',
                  style: TextStyle(
                      fontSize: 12, color: kDim, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Row(
                children: ['Male', 'Female', 'Other'].map((g) {
                  final selected = _gender == g;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _isGenerating
                            ? null
                            : () => setState(() => _gender = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFFF8ED)
                                : kSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: selected ? kAccent : kBorder,
                                width: selected ? 1.5 : 1),
                          ),
                          child: Center(
                            child: Text(g,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: selected ? kAccent : kDim,
                                    fontWeight: selected
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

              // ── Loading ────────────────────────────────────────
              if (_isGenerating) ...[
                const Center(
                    child: CircularProgressIndicator(color: kAccent)),
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

              // ── Illuminate button (only when all filled) ───────
              if (!_isGenerating && allFilled)
                DharmaBtn(
                  label: 'Illuminate My Path 🙏',
                  onTap: _illuminate,
                ),

              // ── Hint when fields incomplete ────────────────────
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
                    style: TextStyle(
                        fontSize: 13, color: kDim, height: 1.5),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}