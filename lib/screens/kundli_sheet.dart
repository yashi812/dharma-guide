// ─────────────────────────────────────────────────────────────────────────────
// kundli_sheet.dart
//
// A bottom-sheet that:
//   1. Collects birth details (name, date, time, location, timezone)
//   2. Calls KundliService.generateKundli()
//   3. Displays the full birth chart — Lagna, Rashi, Nakshatra, planet table,
//      house table, and grouped predictions
//
// Usage (from guidance_screen.dart):
//   final kundli = await KundliSheet.show(context);
//   if (kundli != null) widget.state.setKundliData(kundli.toJson());
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants/theme.dart';   // kAccent, kRust, kBg, kSurface, kText, kDim, kBorder, kAlt
import 'kundli_service.dart';

// ── Rashi symbol map ──────────────────────────────────────────────────────────
const _rashiSymbols = <String, String>{
  'Aries': '♈', 'Taurus': '♉', 'Gemini': '♊', 'Cancer': '♋',
  'Leo': '♌', 'Virgo': '♍', 'Libra': '♎', 'Scorpio': '♏',
  'Sagittarius': '♐', 'Capricorn': '♑', 'Aquarius': '♒', 'Pisces': '♓',
};

// ── Rashi Hindi name map ──────────────────────────────────────────────────────
const _rashiHindi = <String, String>{
  'Aries':       'मेष',
  'Taurus':      'वृषभ',
  'Gemini':      'मिथुन',
  'Cancer':      'कर्क',
  'Leo':         'सिंह',
  'Virgo':       'कन्या',
  'Libra':       'तुला',
  'Scorpio':     'वृश्चिक',
  'Sagittarius': 'धनु',
  'Capricorn':   'मकर',
  'Aquarius':    'कुंभ',
  'Pisces':      'मीन',
};

/// Returns  "♈ मेष"  style label — symbol + Hindi name.
String _rashiLabel(String rashi) {
  final sym   = _rashiSymbols[rashi] ?? '';
  final hindi = _rashiHindi[rashi] ?? rashi;
  return '$sym $hindi';
}

// ── Planet emoji map ──────────────────────────────────────────────────────────
const _planetIcons = <String, String>{
  'Sun': '☀️', 'Moon': '🌙', 'Mars': '♂️', 'Mercury': '☿️',
  'Jupiter': '♃', 'Venus': '♀️', 'Saturn': '♄',
  'Rahu': '☊', 'Ketu': '☋', 'Ascendant': '⬆️',
};

// ── Zodiac colour (subtle) ────────────────────────────────────────────────────
Color _rashiColor(String rashi) {
  const map = <String, Color>{
    'Aries': Color(0xFFE57373), 'Taurus': Color(0xFF81C784),
    'Gemini': Color(0xFFFFD54F), 'Cancer': Color(0xFF4FC3F7),
    'Leo': Color(0xFFFF8A65), 'Virgo': Color(0xFFA5D6A7),
    'Libra': Color(0xFFF48FB1), 'Scorpio': Color(0xFFCE93D8),
    'Sagittarius': Color(0xFF80DEEA), 'Capricorn': Color(0xFF90A4AE),
    'Aquarius': Color(0xFF80CBC4), 'Pisces': Color(0xFF9FA8DA),
  };
  return map[rashi] ?? kAccent;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY POINT
// ═══════════════════════════════════════════════════════════════════════════════

// AFTER
class KundliSheet {
  static Future<KundliData?> show(
    BuildContext context, {
    KundliInitialValues? initialValues,
  }) {
    return showModalBottomSheet<KundliData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KundliSheetContent(initialValues: initialValues),
    );
  }
  static Future<void> showChart(BuildContext context, KundliData kundli) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KundliSheetContent(preloadedKundli: kundli),
    );
  }
}




/// Pre-filled values extracted from the guidance chat history.
class KundliInitialValues {
  final String? name;
  final String? location;
  final DateTime? date;
  final TimeOfDay? time;

  const KundliInitialValues({this.name, this.location, this.date, this.time});
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHEET CONTENT — stateful
// ═══════════════════════════════════════════════════════════════════════════════

class _KundliSheetContent extends StatefulWidget {
  final KundliInitialValues? initialValues;
  final KundliData? preloadedKundli;
  const _KundliSheetContent({this.initialValues, this.preloadedKundli});

  @override
  State<_KundliSheetContent> createState() => _KundliSheetContentState();
}

class _KundliSheetContentState extends State<_KundliSheetContent> {
  // ── State machine ──────────────────────────────────────────────
  _Phase _phase = _Phase.form;
  KundliData? _kundli;
  String? _error;

  // ── Form controllers ───────────────────────────────────────────
 // AFTER
final _nameCtrl = TextEditingController();
final _locCtrl  = TextEditingController();
DateTime? _date;
TimeOfDay? _time;
String _timezone = '+05:30';

@override
void initState() {
  super.initState();
  // If a chart was passed in directly, skip the form
  if (widget.preloadedKundli != null) {
    _kundli = widget.preloadedKundli;
    _phase = _Phase.chart;
  }
  final iv = widget.initialValues;
  if (iv != null) {
    if (iv.name     != null) _nameCtrl.text = iv.name!;
    if (iv.location != null) _locCtrl.text  = iv.location!;
    if (iv.date     != null) _date = iv.date;
    if (iv.time     != null) _time = iv.time;
  }
}

  // ── Common timezones ───────────────────────────────────────────
  static const _timezones = [
    '+05:30', '+00:00', '+01:00', '+02:00', '+03:00',
    '+04:00', '+05:00', '+06:00', '+07:00', '+08:00',
    '+09:00', '+09:30', '+10:00', '-05:00', '-06:00',
    '-07:00', '-08:00',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: kAccent),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  // ── Time picker ────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: kAccent),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _time = t);
  }

  // ── Generate ───────────────────────────────────────────────────
  Future<void> _generate() async {
    final name = _nameCtrl.text.trim();
    final loc  = _locCtrl.text.trim();

    if (name.isEmpty || loc.isEmpty || _date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() { _phase = _Phase.loading; _error = null; });

    // Format for edge function
    final dateStr =
        '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}';
    final timeStr =
        '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

    try {
      final kundli = await KundliService.generateKundli(
        name: name,
        date: dateStr,
        time: timeStr,
        location: loc,
        timezone: _timezone,
      );
      setState(() { _kundli = kundli; _phase = _Phase.chart; });
    } catch (e) {
      setState(() {
        _error = 'Could not generate your birth chart.\n\n$e';
        _phase = _Phase.error;
      });
    }
  }
Widget _northIndianChart(KundliData k) {
  // Map rashi number (1=Aries) to house number based on lagna
  final rashiOrder = [
    'Aries','Taurus','Gemini','Cancer','Leo','Virgo',
    'Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces',
  ];
  final lagnaIndex = rashiOrder.indexOf(k.lagna);

  // Build house→planets map
  final housePlanets = <int, List<String>>{};
  for (int i = 1; i <= 12; i++) housePlanets[i] = [];
  for (final p in k.planets) {
    if (p.house >= 1 && p.house <= 12) {
      final abbr = _planetAbbr(p.name);
      housePlanets[p.house]!.add(p.isRetrograde ? '$abbr(R)' : abbr);
    }
  }

  // House number for each cell position (North Indian fixed sign layout)
  // Positions 0–11 clockwise from top-center
  // Rashi stays fixed; house = (position - lagnaIndex) mod 12 + 1
  int houseForPos(int pos) {
    // pos 0 = top-center cell = rashi index based on fixed layout
    // North Indian: fixed rashi positions, lagna moves
    // Standard fixed rashi positions (0=Aries at top-center going clockwise):
    // top row L-R: 12,1,2 | middle: 11,_,3 | middle: 10,_,4 | bottom: 9,8,7,6,5
    // Actually North Indian fixed positions:
    const rashiPos = [0,1,2,3,4,5,6,7,8,9,10,11]; // Aries=0 at pos index
    final rashiAtPos = (pos) => rashiPos[pos];
    final house = ((rashiAtPos(pos) - lagnaIndex) % 12 + 12) % 12 + 1;
    return house;
  }

  // North Indian grid: 4x4 with corners and center cut out
  // Cell positions mapped to rashi (fixed):
  // Row0: [Pisces(11), Aries(0), Taurus(1), Gemini(2)]
  // Row1: [Aquarius(10), —,       —,         Cancer(3)]
  // Row2: [Capricorn(9), —,       —,         Leo(4)]
  // Row3: [Sagittarius(8), Scorpio(7), Libra(6), Virgo(5)]
  // Rashi index (0=Aries) for each grid cell, -1 = empty center
  final gridRashi = [
    [11, 0,  1, 2],
    [10, -1,-1, 3],
    [ 9, -1,-1, 4],
    [ 8,  7, 6, 5],
  ];

  String cellPlanets(int rashiIdx) {
    if (lagnaIndex < 0) return '';
    final house = ((rashiIdx - lagnaIndex) % 12 + 12) % 12 + 1;
    final planets = housePlanets[house] ?? [];
    // Mark lagna house
    if (house == 1) {
      return ['L', ...planets].join('\n');
    }
    return planets.join('\n');
  }

  String cellHouseNum(int rashiIdx) {
    if (lagnaIndex < 0) return '';
    final house = ((rashiIdx - lagnaIndex) % 12 + 12) % 12 + 1;
    return '$house';
  }

  String cellRashi(int rashiIdx) {
    const names = [
      'Ari','Tau','Gem','Can','Leo','Vir',
      'Lib','Sco','Sag','Cap','Aqu','Pis',
    ];
    return names[rashiIdx];
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder, width: 1.5),
    ),
    child: AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _NorthIndianChartPainter(
          gridRashi: gridRashi,
          cellPlanets: cellPlanets,
          cellHouseNum: cellHouseNum,
          cellRashi: cellRashi,
          lagnaIndex: lagnaIndex,
        ),
      ),
    ),
  );
}

String _planetAbbr(String name) {
  const abbrs = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa',
    'Rahu': 'Ra', 'Ketu': 'Ke', 'Ascendant': 'As',
  };
  return abbrs[name] ?? name.substring(0, 2);
}
  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _phase == _Phase.chart ? 0.95 : 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.97,
      builder: (_, sc) {
        return Container(
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Expanded(child: _buildBody(sc)),
          ]),
        );
      },
    );
  }

  Widget _buildBody(ScrollController sc) {
    return switch (_phase) {
      _Phase.form    => _buildForm(sc),
      _Phase.loading => _buildLoading(),
      _Phase.chart   => _buildChart(sc),
      _Phase.error   => _buildError(),
    };
  }

  // ── FORM PHASE ────────────────────────────────────────────────────────────
  Widget _buildForm(ScrollController sc) {
    return ListView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Header
        const Text('✨ Birth Chart (Kundli)',
            style: TextStyle(fontSize: 22, color: kText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('Enter your birth details to reveal your Vedic chart',
            style: TextStyle(fontSize: 13, color: kDim)),
        const SizedBox(height: 24),

        // Name
        _label('Your Name'),
        _textField(_nameCtrl, 'e.g. Arjun Sharma'),
        const SizedBox(height: 16),

        // Location
        _label('Birth City'),
        _textField(_locCtrl, 'e.g. Mumbai, New Delhi, London'),
        const SizedBox(height: 16),

        // Date + Time row
        Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Date of Birth'),
              _pickerTile(
                icon: Icons.calendar_today_outlined,
                value: _date == null
                    ? 'Select date'
                    : '${_date!.day.toString().padLeft(2, '0')}/'
                      '${_date!.month.toString().padLeft(2, '0')}/'
                      '${_date!.year}',
                onTap: _pickDate,
              ),
            ],
          )),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Time of Birth'),
              _pickerTile(
                icon: Icons.access_time_rounded,
                value: _time == null
                    ? 'Select time'
                    : '${_time!.hour.toString().padLeft(2, '0')}:'
                      '${_time!.minute.toString().padLeft(2, '0')}',
                onTap: _pickTime,
              ),
            ],
          )),
        ]),
        const SizedBox(height: 16),

        // Timezone
        _label('Timezone'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _timezone,
              isExpanded: true,
              style: const TextStyle(color: kText, fontSize: 14),
              items: _timezones.map((tz) => DropdownMenuItem(
                value: tz,
                child: Text('UTC $tz'),
              )).toList(),
              onChanged: (v) => setState(() => _timezone = v ?? '+05:30'),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Generate button
        GestureDetector(
          onTap: _generate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [kAccent, kRust],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: kAccent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('Generate Birth Chart',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3)),
            ),
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          'Calculated using Vedic (Sidereal) astrology with RAMAN ayanamsa',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: kDim),
        ),
      ],
    );
  }

  // ── LOADING PHASE ─────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56, height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: kAccent),
            ),
            const SizedBox(height: 24),
            const Text('Reading the cosmic blueprint…',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kText)),
            const SizedBox(height: 8),
            Text('Calculating planetary positions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kDim.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  // ── ERROR PHASE ───────────────────────────────────────────────────────────
  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: kRust),
          const SizedBox(height: 16),
          const Text('Chart unavailable',
              style: TextStyle(fontSize: 18, color: kText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(_error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kDim, height: 1.6)),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: () => setState(() => _phase = _Phase.form),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kAccent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Try Again',
                style: TextStyle(color: kAccent)),
          ),
        ],
      ),
    );
  }

  // ── CHART PHASE ───────────────────────────────────────────────────────────
  Widget _buildChart(ScrollController sc) {
    final k = _kundli!;
    return ListView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        // ── Header ─────────────────────────────────────────────
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🪐 ${k.name}\'s Birth Chart',
                  style: const TextStyle(
                      fontSize: 20, color: kText, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('${k.date} · ${k.time} · ${k.location}',
                  style: const TextStyle(fontSize: 12, color: kDim)),
            ]),
          ),
          // Use chart button — pops with KundliData
          GestureDetector(
            onTap: () => Navigator.of(context).pop(_kundli),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('Use Chart',
                  style: TextStyle(
                      color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),

        const SizedBox(height: 20),

        // ── Key Trinity ────────────────────────────────────────
        _sectionTitle('मुख्य बिंदु  ·  Key Points'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _trinityCard('लग्न', 'Ascendant', k.lagna)),
          const SizedBox(width: 10),
          Expanded(child: _trinityCard('राशि', 'Moon Sign', k.rashi)),
          const SizedBox(width: 10),
          Expanded(child: _trinityCard('नक्षत्र', 'Birth Star', '${k.nakshatra}\nPada ${k.nakshatraPada}')),
        ]),

        const SizedBox(height: 24),

        // ── Planet table ───────────────────────────────────────
        _sectionTitle('ग्रह स्थिति  ·  Planetary Positions'),
        const SizedBox(height: 10),
        _planetTable(k.planets),

        if (k.houses.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionTitle('भाव  ·  House Cusps'),
          const SizedBox(height: 10),
          _houseTable(k.houses),
        ],

        if (k.predictions.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionTitle('योग एवं भविष्यवाणी  ·  Yogas & Predictions'),
          const SizedBox(height: 10),
          ...k.predictions.entries.map((e) => _predictionSection(e.key, e.value)),
        ],

        const SizedBox(height: 24),

        // ── Use chart CTA (bottom) ─────────────────────────────
        GestureDetector(
          onTap: () => Navigator.of(context).pop(_kundli),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [kAccent, kRust],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Text('Use Chart for Guidance',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This will personalise your dharmic guidance with your birth chart',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: kDim),
        ),
      ],
    );
  }

  // ── Widgets helpers ────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, color: kDim, fontWeight: FontWeight.w500,
                letterSpacing: 0.3)),
      );

  Widget _textField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kDim, fontSize: 14),
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAccent, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        style: const TextStyle(fontSize: 14, color: kText),
      );

  Widget _pickerTile({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: kDim),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      color: value.contains('Select') ? kDim : kText)),
            ),
          ]),
        ),
      );

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 14, color: kText,
          fontWeight: FontWeight.w600, letterSpacing: 0.5));

  Widget _trinityCard(String title, String subtitle, String value) {
    // value for Lagna/Rashi is an English rashi name; for Nakshatra it's "Name\nPada N"
    final firstLine = value.split('\n').first;
    final color  = _rashiColor(firstLine);
    final symbol = _rashiSymbols[firstLine] ?? '';
    final hindi  = _rashiHindi[firstLine];          // null for Nakshatra card
    final restLines = value.contains('\n')
        ? value.substring(value.indexOf('\n') + 1)
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(fontSize: 10, color: kDim)),
        const SizedBox(height: 6),
        // Hindi name (large) on first line if available
        if (hindi != null) ...[
          Text('$symbol $hindi',
              style: TextStyle(
                  fontSize: 15, color: kText,
                  fontWeight: FontWeight.w700, height: 1.2)),
          Text(firstLine,
              style: TextStyle(
                  fontSize: 10, color: color.withValues(alpha: 0.8),
                  height: 1.3)),
        ] else ...[
          Text('$symbol $firstLine',
              style: TextStyle(
                  fontSize: 13, color: kText,
                  fontWeight: FontWeight.w600, height: 1.3)),
          if (restLines != null)
            Text(restLines,
                style: const TextStyle(
                    fontSize: 11, color: kDim, height: 1.3)),
        ],
      ]),
    );
  }

  Widget _planetTable(List<PlanetData> planets) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: const [
              Expanded(flex: 3, child: Text('ग्रह / Planet',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
              Expanded(flex: 3, child: Text('राशि / Rashi',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Text('भाव',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
              Expanded(flex: 3, child: Text('नक्षत्र',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
            ]),
          ),
          const Divider(height: 1, color: kBorder),
          ...planets.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final icon = _planetIcons[p.name] ?? '●';
            final color = _rashiColor(p.rashi);
            return Container(
              color: i.isOdd ? kAlt : kSurface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(children: [
                  Expanded(flex: 3, child: Row(children: [
                    Text(icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.isRetrograde ? '${p.name} (R)' : p.name,
                        style: TextStyle(
                          fontSize: 13, color: kText,
                          fontStyle: p.isRetrograde
                              ? FontStyle.italic : FontStyle.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ])),
                  Expanded(flex: 3, child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _rashiLabel(p.rashi),
                      style: TextStyle(fontSize: 11, color: color,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  Expanded(flex: 2, child: Text(
                    p.house > 0 ? '${p.house}वाँ' : '—',
                    style: const TextStyle(fontSize: 13, color: kText),
                  )),
                  Expanded(flex: 3, child: Text(
                    p.nakshatra.isNotEmpty
                        ? '${p.nakshatra} पाद ${p.nakshatraPada}'
                        : '—',
                    style: const TextStyle(fontSize: 11, color: kDim),
                    overflow: TextOverflow.ellipsis,
                  )),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _houseTable(List<HouseData> houses) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: const [
              Expanded(flex: 2, child: Text('भाव',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
              Expanded(flex: 3, child: Text('राशि',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Text('अंश',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Text('स्वामी',
                  style: TextStyle(fontSize: 11, color: kDim, fontWeight: FontWeight.w600))),
            ]),
          ),
          const Divider(height: 1, color: kBorder),
          ...houses.asMap().entries.map((entry) {
            final i = entry.key;
            final h = entry.value;
            final color = _rashiColor(h.rashi);
            return Container(
              color: i.isOdd ? kAlt : kSurface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                child: Row(children: [
                  Expanded(flex: 2, child: Text(
                    '${h.number}वाँ',
                    style: const TextStyle(fontSize: 13, color: kText,
                        fontWeight: FontWeight.w600),
                  )),
                  Expanded(flex: 3, child: Text(
                    _rashiLabel(h.rashi),
                    style: TextStyle(fontSize: 12, color: color,
                        fontWeight: FontWeight.w500),
                  )),
                  Expanded(flex: 2, child: Text(
                    '${h.degree}°',
                    style: const TextStyle(fontSize: 12, color: kDim),
                  )),
                  Expanded(flex: 2, child: Text(
                    h.lord.isNotEmpty ? h.lord : '—',
                    style: const TextStyle(fontSize: 12, color: kText),
                  )),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _predictionSection(String category, List<String> items) {
    const categoryIcons = <String, String>{
      'Personality': '👤', 'General': '🌟', 'Career': '💼',
      'Finance': '💰', 'Relationships': '❤️', 'Marriage': '💍',
      'Family': '🏠', 'Education': '📚', 'Spirituality': '🕉️',
      'Travel': '✈️', 'Luck': '🍀', 'Character': '🧠',
      'Health': '💚', 'Mind': '🧘', 'Intelligence': '💡',
    };
    final icon = categoryIcons[category] ?? '✦';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(category,
                    style: const TextStyle(
                        fontSize: 13, color: kText,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            const Divider(height: 1, color: kBorder),
            ...items.map((desc) => Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•',
                          style: TextStyle(
                              color: kAccent.withValues(alpha: 0.7),
                              fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(desc,
                            style: const TextStyle(
                                fontSize: 13, color: kDim, height: 1.6)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _NorthIndianChartPainter extends CustomPainter {
  final List<List<int>> gridRashi;
  final String Function(int) cellPlanets;
  final String Function(int) cellHouseNum;
  final String Function(int) cellRashi;
  final int lagnaIndex;

  const _NorthIndianChartPainter({
    required this.gridRashi,
    required this.cellPlanets,
    required this.cellHouseNum,
    required this.cellRashi,
    required this.lagnaIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cw = w / 4;
    final ch = h / 4;

    final borderPaint = Paint()
      ..color = const Color(0xFFD4B483)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bgPaint = Paint()..style = PaintingStyle.fill;
    final lagnaPaint = Paint()
      ..color = const Color(0xFFFFF8ED)
      ..style = PaintingStyle.fill;
    final emptyPaint = Paint()
      ..color = const Color(0xFFFAF5EC)
      ..style = PaintingStyle.fill;

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final rashi = gridRashi[row][col];
        final rect = Rect.fromLTWH(col * cw, row * ch, cw, ch);

        if (rashi == -1) {
          // Center cells — draw diagonal lines to form diamond
          canvas.drawRect(rect, emptyPaint);
          canvas.drawRect(rect, borderPaint);
          continue;
        }

        // Determine if lagna house
        final house = lagnaIndex >= 0
            ? ((rashi - lagnaIndex) % 12 + 12) % 12 + 1
            : 0;
        final isLagna = house == 1;

        bgPaint.color = isLagna
            ? const Color(0xFFFFF8ED)
            : const Color(0xFFFFFFFF);
        canvas.drawRect(rect, bgPaint);
        canvas.drawRect(rect, borderPaint);

        // Draw diagonal lines for corner cells
        if ((row == 0 && col == 0) || (row == 0 && col == 3) ||
            (row == 3 && col == 0) || (row == 3 && col == 3)) {
          final diagPaint = Paint()
            ..color = const Color(0xFFD4B483)
            ..strokeWidth = 1.0;
          if (row == 0 && col == 0) {
            canvas.drawLine(rect.topRight, rect.bottomLeft, diagPaint);
          } else if (row == 0 && col == 3) {
            canvas.drawLine(rect.topLeft, rect.bottomRight, diagPaint);
          } else if (row == 3 && col == 0) {
            canvas.drawLine(rect.topLeft, rect.bottomRight, diagPaint);
          } else if (row == 3 && col == 3) {
            canvas.drawLine(rect.topRight, rect.bottomLeft, diagPaint);
          }
        }

        // House number (top-left, small)
        final houseNum = cellHouseNum(rashi);
        _drawText(canvas, houseNum, rect.left + 5, rect.top + 4,
            fontSize: 9, color: const Color(0xFFB8860B), bold: true);

        // Rashi abbreviation (top-right, small)
        final rashiStr = cellRashi(rashi);
        _drawTextRight(canvas, rashiStr, rect.right - 5, rect.top + 4,
            fontSize: 9, color: const Color(0xFF888780));

        // Planet abbreviations (center)
        final planets = cellPlanets(rashi);
        if (planets.isNotEmpty) {
          final lines = planets.split('\n');
          final centerY = rect.center.dy - (lines.length * 9.0) / 2;
          for (int i = 0; i < lines.length; i++) {
            final isL = lines[i] == 'L';
            _drawTextCenter(
              canvas, lines[i],
              rect.center.dx, centerY + i * 11,
              fontSize: isL ? 11 : 12,
              color: isL
                  ? const Color(0xFFB8860B)
                  : const Color(0xFF444441),
              bold: isL,
            );
          }
        }
      }
    }

    // Draw center diamond lines
    final cx = w / 2;
    final cy = h / 2;
    final diagPaint = Paint()
      ..color = const Color(0xFFD4B483)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cw, ch), Offset(cx, cy), diagPaint);
    canvas.drawLine(Offset(3 * cw, ch), Offset(cx, cy), diagPaint);
    canvas.drawLine(Offset(cw, 3 * ch), Offset(cx, cy), diagPaint);
    canvas.drawLine(Offset(3 * cw, 3 * ch), Offset(cx, cy), diagPaint);
  }

  void _drawText(Canvas canvas, String text, double x, double y,
      {double fontSize = 11, Color color = const Color(0xFF444441), bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }

  void _drawTextRight(Canvas canvas, String text, double x, double y,
      {double fontSize = 11, Color color = const Color(0xFF444441)}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width, y));
  }

  void _drawTextCenter(Canvas canvas, String text, double cx, double cy,
      {double fontSize = 12, Color color = const Color(0xFF444441), bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// ── Phase enum ────────────────────────────────────────────────────────────────
enum _Phase { form, loading, chart, error }