// lib/screens/onboarding_screen.dart
import 'dart:convert';
import 'package:dharma_guide/constants/app_data.dart';
import 'package:dharma_guide/state/app_state.dart';
import 'package:dharma_guide/constants/theme.dart';
import 'package:flutter/material.dart';
import '../../shared_widgets.dart';
import '../services/supabase_service.dart';
import '../screens/kundli_service.dart';

// Steps:
//   0 → Welcome splash
//   1 → Name entry
//   2 → Guidance style
//   3 → Birth details → generates KundliData via KundliService (skippable)

class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController  = TextEditingController();
  final _placeController = TextEditingController();

  TimeOfDay? _selectedTime;
  int? _selectedDay;
int? _selectedMonth;
int? _selectedYear;
  String _gender    = 'Male';
  String _timezone  = '+05:30';
  bool _isGenerating = false;

  static const _timezones = [
    '+05:30', '+00:00', '+01:00', '+02:00', '+03:00',
    '+04:00', '+05:00', '+06:00', '+07:00', '+08:00',
    '+09:00', '+09:30', '+10:00', '-05:00', '-06:00',
    '-07:00', '-08:00',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  // ── Pickers ───────────────────────────────────────────────────────────────
  

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kAccent, onPrimary: Colors.white,
            onSurface: kText, surface: kSurface,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: kSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Format helpers ────────────────────────────────────────────────────────
  String get _dobFormatted {
  if (_selectedDay == null || _selectedMonth == null || _selectedYear == null) return '';
  return '${_selectedDay!.toString().padLeft(2,'0')}/'
         '${_selectedMonth!.toString().padLeft(2,'0')}/'
         '$_selectedYear';
}

  String get _timeFormatted {
    if (_selectedTime == null) return '';
    return '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
           '${_selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  String get _resolvedName {
    final t = _nameController.text.trim();
    return t.isEmpty ? 'Seeker' : t;
  }

  // ── Step transitions ──────────────────────────────────────────────────────
  Future<void> _saveName() async {
    await widget.state.setUserName(_resolvedName);
    await GuidanceService.saveUserInput(
      screen: 'onboarding', fieldName: 'birth_name', value: _resolvedName,
    );
    if (mounted) widget.state.nextOnboardingStep(2);
  }

  Future<void> _saveStyle() async {
    await GuidanceService.saveUserInput(
      screen: 'onboarding', fieldName: 'guidance_style',
      value: widget.state.userStyle,
    );
    if (mounted) widget.state.nextOnboardingStep(3);
  }

  // ── Skip kundli step ──────────────────────────────────────────────────────
  Future<void> _skip() async {
    await Future.wait([
      widget.state.setUserName(_resolvedName),
      widget.state.completeOnboarding(),
      GuidanceService.upsertUserProfile(
        name: _resolvedName,
        guidanceStyle: widget.state.userStyle,
        birthDate: '', birthTime: '', birthPlace: '', birthGender: '',
      ),
    ]);
    if (mounted) widget.state.nav('home');
  }

  // ── Generate full KundliData and finish onboarding ────────────────────────
  Future<void> _illuminate() async {
    final name  = _resolvedName;
    final place = _placeController.text.trim();
    final dob   = _dobFormatted;
    final time  = _timeFormatted;

    if (dob.isEmpty || time.isEmpty || place.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      // Persist birth details to AppState + Supabase first
      await widget.state.setBirthDetails(
        name: name, date: dob, time: time, place: place, gender: _gender,
      );

      // Generate full structured KundliData via VedAstro (direct HTTP)
      final kundli = await KundliService.generateKundli(
        name:     name,
        date:     dob,
        time:     time,
        location: place,
        timezone: _timezone,
      );

      // Store serialised KundliData in AppState + Supabase
      await widget.state.setKundliData(jsonEncode(kundli.toJson()));

      // Persist all raw fields for audit / re-generation
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
    } catch (e) {
      debugPrint('Onboarding kundli error: $e');
      // Non-fatal: birth details are already saved; kundli can be generated later
      // from guidance screen's "Show Kundli" pill
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

  // ── Step 0: Welcome ───────────────────────────────────────────────────────
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

  // ── Step 1: Name ──────────────────────────────────────────────────────────
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
            DharmaBtn(label: 'Continue →', onTap: _saveName),
          ],
        ),
      ),
    ),
  );

  // ── Step 2: Guidance style ────────────────────────────────────────────────
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
                            blurRadius: 12, offset: const Offset(0, 2),
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
                          const Text('✓',
                              style: TextStyle(color: kAccent, fontSize: 18)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
            DharmaBtn(label: 'Continue →', onTap: _saveStyle),
          ],
        ),
      ),
    ),
  );

  // ── Step 3: Birth details ─────────────────────────────────────────────────
  Widget _step3() {
    final allFilled = _selectedDay != null &&
    _selectedMonth != null &&
    _selectedYear != null &&
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
              // Header row
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
                  style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              const Text('Your Birth Chart',
                  style: TextStyle(fontSize: 30, color: kText,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              const Text(
                'Unlock personalised Vedic guidance. Completely private.',
                style: TextStyle(fontSize: 13, color: kDim, height: 1.5),
              ),
              const SizedBox(height: 28),

              // ── Date + Time row ─────────────────────────────────────────
              // ── Date ────────────────────────────────────────────────────────────
_fieldLabel('Date of Birth'),
const SizedBox(height: 6),
Row(children: [
  _numDropdown('DD', List.generate(31, (i) => i + 1), _selectedDay,
    (v) => setState(() => _selectedDay = v)),
  const SizedBox(width: 6),
  _monthDropdown(),
  const SizedBox(width: 6),
  _yearDropdown(),
]),
const SizedBox(height: 16),

// ── Time ─────────────────────────────────────────────────────────────
_fieldLabel('Time of Birth'),
const SizedBox(height: 6),
GestureDetector(
  onTap: _isGenerating ? null : _pickTime,
  child: _pickerTile(
    icon: Icons.access_time_rounded,
    text: _selectedTime == null ? 'Select time' : _timeFormatted,
    filled: _selectedTime != null,
  ),
),
              // ── Place ───────────────────────────────────────────────────
              _fieldLabel('Birth City'),
              const SizedBox(height: 6),
              TextField(
                controller: _placeController,
                textCapitalization: TextCapitalization.words,
                enabled: !_isGenerating,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'e.g. Mumbai, Raipur, London',
                  hintStyle: const TextStyle(color: kDim),
                  filled: true,
                  fillColor: kSurface,
                  prefixIcon: const Icon(
                      Icons.location_on_outlined, color: kDim, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: kAccent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: kText),
              ),
              const SizedBox(height: 16),

              // ── Timezone ────────────────────────────────────────────────
              _fieldLabel('Timezone'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _timezone,
                    isExpanded: true,
                    style:
                        const TextStyle(color: kText, fontSize: 14),
                    items: _timezones
                        .map((tz) => DropdownMenuItem(
                              value: tz,
                              child: Text('UTC $tz'),
                            ))
                        .toList(),
                    onChanged: _isGenerating
                        ? null
                        : (v) =>
                            setState(() => _timezone = v ?? '+05:30'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Gender ──────────────────────────────────────────────────
              _fieldLabel('Gender'),
              const SizedBox(height: 6),
              Row(
                children: ['Male', 'Female', 'Other'].map((g) {
                  final sel = _gender == g;
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
                            color: sel
                                ? const Color(0xFFFFF8ED) : kSurface,
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

              // ── Loading ─────────────────────────────────────────────────
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

              // ── CTA ─────────────────────────────────────────────────────
              if (!_isGenerating && allFilled)
                DharmaBtn(
                    label: 'Illuminate My Path 🙏',
                    onTap: _illuminate),

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
              const Text(
                'Calculated using Vedic (Sidereal) astrology · RAMAN ayanamsa',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: kDim),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 12, color: kDim, letterSpacing: 0.5),
      );

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required bool filled,
  }) =>
      Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  fontSize: 15,
                  color: filled ? kText : kDim)),
          const Spacer(),
          if (filled)
            const Icon(Icons.check_circle_rounded,
                color: kAccent, size: 18),
        ]),
      );

      static const _months = [
  'Jan','Feb','Mar','Apr','May','Jun',
  'Jul','Aug','Sep','Oct','Nov','Dec'
];

Widget _numDropdown(String hint, List<int> items, int? value, ValueChanged<int?> onChanged) =>
  Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? kAccent : kBorder,
          width: value != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: kDim, fontSize: 13)),
          isExpanded: true,
          style: const TextStyle(color: kText, fontSize: 14),
          items: items.map((n) =>
            DropdownMenuItem(value: n, child: Text(n.toString()))).toList(),
          onChanged: _isGenerating ? null : onChanged,
        ),
      ),
    ),
  );

Widget _monthDropdown() =>
  Expanded(
    flex: 2,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedMonth != null ? kAccent : kBorder,
          width: _selectedMonth != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonth,
          hint: const Text('Mon', style: TextStyle(color: kDim, fontSize: 13)),
          isExpanded: true,
          style: const TextStyle(color: kText, fontSize: 14),
          items: List.generate(12, (i) =>
            DropdownMenuItem(value: i + 1, child: Text(_months[i]))).toList(),
          onChanged: _isGenerating ? null :
            (v) => setState(() => _selectedMonth = v),
        ),
      ),
    ),
  );

Widget _yearDropdown() =>
  Expanded(
    flex: 2,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedYear != null ? kAccent : kBorder,
          width: _selectedYear != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          hint: const Text('Year', style: TextStyle(color: kDim, fontSize: 13)),
          isExpanded: true,
          style: const TextStyle(color: kText, fontSize: 14),
          items: List.generate(105, (i) => DateTime.now().year - i).map((y) =>
            DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
          onChanged: _isGenerating ? null :
            (v) => setState(() => _selectedYear = v),
        ),
      ),
    ),
  );
}