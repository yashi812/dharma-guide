// lib/screens/birth_details_screen.dart
//
// A full-screen birth-details flow identical in UX to onboarding Step 3.
// Used from HomeScreen when a user who skipped onboarding taps "Seek Guidance".
//
// Usage:
//   Navigator.push(context,
//     MaterialPageRoute(builder: (_) => BirthDetailsScreen(state: state)));

import 'package:dharma_guide/state/app_state.dart';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../../shared_widgets.dart';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';
import '../services/vedastro_service.dart';

class BirthDetailsScreen extends StatefulWidget {
  final AppState state;

  const BirthDetailsScreen({super.key, required this.state});

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen> {
  final _nameCtrl  = TextEditingController();
  final _placeCtrl = TextEditingController();

  DateTime?  _selectedDate;
  TimeOfDay? _selectedTime;
  String     _gender      = 'Male';
  bool       _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill whatever we already know
    _nameCtrl.text = widget.state.birthName ?? widget.state.userName;
    _placeCtrl.text = widget.state.birthPlace ?? '';

    if (widget.state.birthDate != null) {
      final parts = widget.state.birthDate!.split('/');
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.tryParse(parts[2]) ?? 1995,
          int.tryParse(parts[1]) ?? 1,
          int.tryParse(parts[0]) ?? 1,
        );
      }
    }
    if (widget.state.birthTime != null) {
      final parts = widget.state.birthTime!.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
          hour:   int.tryParse(parts[0]) ?? 6,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    if (widget.state.birthGender != null) {
      _gender = widget.state.birthGender!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  // ── DOB picker — 3-column bottom sheet (Day · Month · Year) ─────────────
  Future<void> _showDobPicker() async {
    final now   = DateTime.now();
    final init  = _selectedDate ?? DateTime(1995, 6, 15);

    int selDay   = init.day;
    int selMonth = init.month;
    int selYear  = init.year;

    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];

    int daysInMonth(int m, int y) =>
        DateTime(y, m + 1, 0).day; // last day of month m

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final days = daysInMonth(selMonth, selYear);
          // Clamp day if month/year change made it invalid
          if (selDay > days) selDay = days;

          // Years: 1920 → current year
          final years = List.generate(
            now.year - 1920 + 1,
            (i) => now.year - i, // most-recent first
          );

          Widget col({
            required List<dynamic> items,
            required int selected,
            required ValueChanged<int> onChanged,
            double width = 80,
          }) {
            final ctrl = FixedExtentScrollController(
              initialItem: items.indexOf(selected),
            );
            return SizedBox(
              width: width,
              height: 180,
              child: ListWheelScrollView.useDelegate(
                controller: ctrl,
                itemExtent: 44,
                perspective: 0.003,
                diameterRatio: 1.6,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) =>
                    setSheet(() => onChanged(items[i] as int)),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: items.length,
                  builder: (_, i) {
                    final val   = items[i];
                    final isSel = val == selected;
                    return Center(
                      child: Text(
                        val is int && items == months
                            ? months[val - 1]
                            : '$val',
                        style: TextStyle(
                          fontSize: isSel ? 18 : 15,
                          fontWeight: isSel
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSel ? kAccent : kDim,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          // Month column separately (needs string labels)
          Widget monthCol() {
            final ctrl = FixedExtentScrollController(
              initialItem: selMonth - 1,
            );
            return SizedBox(
              width: 72,
              height: 180,
              child: ListWheelScrollView(
                controller: ctrl,
                itemExtent: 44,
                perspective: 0.003,
                diameterRatio: 1.6,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) =>
                    setSheet(() => selMonth = i + 1),
                children: List.generate(12, (i) {
                  final isSel = (i + 1) == selMonth;
                  return Center(
                    child: Text(
                      months[i],
                      style: TextStyle(
                        fontSize: isSel ? 18 : 15,
                        fontWeight:
                            isSel ? FontWeight.w600 : FontWeight.w400,
                        color: isSel ? kAccent : kDim,
                      ),
                    ),
                  );
                }),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              color: kBg,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text('Date of Birth',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kText)),
                const SizedBox(height: 4),
                const Text('Scroll to select',
                    style: TextStyle(fontSize: 12, color: kDim)),
                const SizedBox(height: 16),

                // column headers
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 72,
                        child: Center(child: Text('Day',   style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 0.8)))),
                    SizedBox(width: 16),
                    SizedBox(width: 72,
                        child: Center(child: Text('Month', style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 0.8)))),
                    SizedBox(width: 16),
                    SizedBox(width: 80,
                        child: Center(child: Text('Year',  style: TextStyle(fontSize: 11, color: kDim, letterSpacing: 0.8)))),
                  ],
                ),
                const SizedBox(height: 8),

                // highlight band
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // selection band
                    Container(
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: kAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: kAccent.withValues(alpha: 0.2)),
                      ),
                    ),
                    // wheels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day
                        col(
                          items: List.generate(days, (i) => i + 1),
                          selected: selDay,
                          onChanged: (v) => selDay = v,
                          width: 72,
                        ),
                        const SizedBox(width: 16),
                        // Month
                        monthCol(),
                        const SizedBox(width: 16),
                        // Year
                        col(
                          items: years,
                          selected: selYear,
                          onChanged: (v) => selYear = v,
                          width: 80,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final clamped = selDay.clamp(
                          1, daysInMonth(selMonth, selYear));
                      setState(() => _selectedDate =
                          DateTime(selYear, selMonth, clamped));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Confirm Date',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
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
          ), dialogTheme: const DialogThemeData(backgroundColor: kSurface),
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
    return '${d.day.toString().padLeft(2, '0')}/'
           '${d.month.toString().padLeft(2, '0')}/'
           '${d.year}';
  }

  String get _timeFormatted {
    if (_selectedTime == null) return '';
    return '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
           '${_selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  bool get _allFilled =>
      _selectedDate != null &&
      _selectedTime != null &&
      _placeCtrl.text.trim().isNotEmpty;

  // ── Skip — go to guidance without kundli ─────────────────────
  void _skip() {
    Navigator.pop(context);
    widget.state.nav('guidance');
  }

  // ── Illuminate ────────────────────────────────────────────────
  Future<void> _illuminate() async {
  // Guard: should never happen since button is hidden, but be safe
  if (_selectedDate == null || _selectedTime == null || _placeCtrl.text.trim().isEmpty) {
    return;
  }

  final name  = _nameCtrl.text.trim().isEmpty
      ? widget.state.userName
      : _nameCtrl.text.trim();
  final place = _placeCtrl.text.trim();
  final dob   = _dobFormatted;   // safe — _selectedDate != null
  final time  = _timeFormatted;  // safe — _selectedTime != null

    setState(() => _isGenerating = true);

    try {
      // ① Persist birth details
      await widget.state.setBirthDetails(
        name:   name,
        date:   dob,
        time:   time,
        place:  place,
        gender: _gender,
      );

      // ② Save to Supabase before any flaky API calls
      await Future.wait([
        GuidanceService.saveUserInput(screen: 'home_birth_details', fieldName: 'birth_name',   value: name),
        GuidanceService.saveUserInput(screen: 'home_birth_details', fieldName: 'birth_date',   value: dob),
        GuidanceService.saveUserInput(screen: 'home_birth_details', fieldName: 'birth_time',   value: time),
        GuidanceService.saveUserInput(screen: 'home_birth_details', fieldName: 'birth_place',  value: place),
        GuidanceService.saveUserInput(screen: 'home_birth_details', fieldName: 'birth_gender', value: _gender),
        GuidanceService.upsertUserProfile(
          name: name,
          guidanceStyle: widget.state.userStyle,
          birthDate: dob,
          birthTime: time,
          birthPlace: place,
          birthGender: _gender,
        ),
      ]);

      // ③ Fetch VedAstro predictions
      String vedastroRaw = '';
      try {
        vedastroRaw = await VedAstroService.getRichPredictions(
          location: place, time: time, date: dob, maxPerCategory: 4,
        );
      } catch (e) {
        debugPrint('VedAstro error (continuing): $e');
      }

      // ④ Generate kundli profile via LLM
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
          screen: 'home_birth_details',
          fieldName: 'kundli_profile',
          value: kundli,
        );
      }
    } catch (e) {
      debugPrint('BirthDetailsScreen kundli error: $e');
    }

    if (mounted) {
      setState(() => _isGenerating = false);
      Navigator.pop(context);       // close BirthDetailsScreen
      widget.state.nav('guidance'); // go to guidance
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackBtn(onTap: () => Navigator.pop(context)),
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
                        child: const Text('Skip for now',
                            style: TextStyle(fontSize: 13, color: kDim)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('YOUR DHARMIC PROFILE',
                  style: TextStyle(
                      fontSize: 11, color: kDim, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              const Text('Personalise Your Guidance',
                  style: TextStyle(
                      fontSize: 30, color: kText, fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              const Text(
                'Birth details unlock personalised Vedic guidance. '
                'This is kept completely private.',
                style: TextStyle(fontSize: 13, color: kDim, height: 1.5),
              ),
              const SizedBox(height: 28),

              // ── Name ───────────────────────────────────────────
              const Text('Your name',
                  style: TextStyle(fontSize: 12, color: kDim, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                enabled: !_isGenerating,
                decoration: InputDecoration(
                  hintText: 'e.g. Arjuna',
                  hintStyle: const TextStyle(color: kDim),
                  filled: true,
                  fillColor: kSurface,
                  prefixIcon: const Icon(Icons.person_outline, color: kDim, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kAccent, width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: kText),
              ),
              const SizedBox(height: 16),

              // ── Date of birth ──────────────────────────────────
              const Text('Date of birth',
                  style: TextStyle(fontSize: 12, color: kDim, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _isGenerating ? null : _showDobPicker,
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

              // ── Time of birth ──────────────────────────────────
              const Text('Time of birth',
                  style: TextStyle(fontSize: 12, color: kDim, letterSpacing: 0.5)),
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

              // ── Place of birth ─────────────────────────────────
              const Text('Place of birth',
                  style: TextStyle(fontSize: 12, color: kDim, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _placeCtrl,
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
                  style: TextStyle(fontSize: 12, color: kDim, letterSpacing: 0.5)),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

              // ── Loading indicator ──────────────────────────────
              if (_isGenerating) ...[
                const Center(
                    child: CircularProgressIndicator(color: kAccent)),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '"The soul is eternal, the wisdom eternal —\n'
                    'your path is being illuminated…"',
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

              // ── Primary CTA ────────────────────────────────────
              if (!_isGenerating && _allFilled)
                DharmaBtn(
                  label: 'Illuminate My Path 🙏',
                  onTap: _illuminate,
                ),

              // ── Hint when incomplete ───────────────────────────
              if (!_isGenerating && !_allFilled)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Text(
                    'Fill in your date, time and place of birth above '
                    'to unlock your personalised Vedic profile.',
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
}