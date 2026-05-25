import 'package:dharma_guide/app_data.dart';
import 'package:dharma_guide/models.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../constants/theme.dart';
import '../constants/app_data.dart';
import '../models/models.dart';
import '../shared_widgets.dart';

class PujaDetailScreen extends StatefulWidget {
  final AppState state;
  const PujaDetailScreen({super.key, required this.state});

  @override
  State<PujaDetailScreen> createState() => _PujaDetailScreenState();
}

class _PujaDetailScreenState extends State<PujaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VistarPuja puja = widget.state.currentVistarPuja!;

    // Find linked aarti from kAartis
    final Aarti? linkedAarti = kAartis.cast<Aarti?>().firstWhere(
          (a) => a?.name == puja.linkedAartiName,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Row(children: [
                BackBtn(onTap: () => widget.state.nav('puja_vidhi')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(puja.name,
                          style: const TextStyle(
                              fontSize: 24,
                              color: kText,
                              fontWeight: FontWeight.w400)),
                      Text(puja.occasion,
                          style: const TextStyle(fontSize: 11, color: kDim),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text(puja.emoji, style: const TextStyle(fontSize: 30)),
              ]),
            ),

            // ── Tab Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: kAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: kRust,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: kDim,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Vidhi'),
                    Tab(text: 'Katha'),
                    Tab(text: 'Aarti'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tab Views ──
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _VidhiTab(puja: puja),
                  _KathaTab(puja: puja),
                  _AartiTab(aarti: linkedAarti, pujaName: puja.name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// VIDHI TAB
// ─────────────────────────────────────────
class _VidhiTab extends StatelessWidget {
  final VistarPuja puja;
  const _VidhiTab({required this.puja});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        // Samagri section
        _SectionHeader(title: '🛒  Samagri (Items Needed)'),
        const SizedBox(height: 8),
        DharmaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: puja.samagri.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ',
                      style: TextStyle(color: kRust, fontSize: 14)),
                  Expanded(
                    child: Text(item,
                        style: const TextStyle(
                            fontSize: 13, color: kText, height: 1.4)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Step-by-step vidhi
        _SectionHeader(title: '📿  Step-by-Step Vidhi'),
        const SizedBox(height: 8),

        ...puja.vidhi.asMap().entries.map((entry) {
          final int i = entry.key;
          final PujaVidhiStep step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DharmaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number + title
                  Row(children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: kRust,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(step.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kText)),
                    ),
                  ]),

                  const SizedBox(height: 10),

                  // Instruction
                  Text(step.instruction,
                      style: const TextStyle(
                          fontSize: 13, color: kText, height: 1.5)),

                  // Mantra (if present)
                  if (step.mantra != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: kRust.withOpacity(0.25), width: 1),
                      ),
                      child: Text(step.mantra!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: kRust,
                              height: 1.6,
                              fontStyle: FontStyle.italic)),
                    ),
                  ],

                  // Tip (if present)
                  if (step.tip != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ',
                            style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(step.tip!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: kDim,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────
// KATHA TAB
// ─────────────────────────────────────────
class _KathaTab extends StatelessWidget {
  final VistarPuja puja;
  const _KathaTab({required this.puja});

  @override
  Widget build(BuildContext context) {
    final katha = puja.katha;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        _SectionHeader(title: '📖  ${katha!.title}'),
        const SizedBox(height: 12),

        ...?katha?.paragraphs.map((para) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DharmaCard(
            child: Text(para,
                style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    height: 1.7)),
          ),
        )),

        // Phalashruti
        const SizedBox(height: 4),
        DharmaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🌸  फलश्रुति',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kRust)),
              const SizedBox(height: 8),
              Text(katha!.phalashruti,
                  style: const TextStyle(
                      fontSize: 13,
                      color: kText,
                      height: 1.6,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// AARTI TAB
// ─────────────────────────────────────────
class _AartiTab extends StatelessWidget {
  final Aarti? aarti;
  final String pujaName;
  const _AartiTab({required this.aarti, required this.pujaName});

  @override
  Widget build(BuildContext context) {
    if (aarti == null) {
      return Center(
        child: Text('No aarti linked for $pujaName',
            style: const TextStyle(color: kDim, fontSize: 14)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        // Aarti header card
        DharmaCard(
          child: Row(children: [
            Text(aarti!.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aarti!.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: kText)),
                  const SizedBox(height: 3),
                  Text(aarti!.sub,
                      style: const TextStyle(
                          fontSize: 12,
                          color: kDim,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ]),
        ),

        const SizedBox(height: 14),

        // Verses
        ...aarti!.verses.asMap().entries.map((entry) {
          final int i = entry.key;
          final String verse = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DharmaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('verse ${i + 1}',
                      style: const TextStyle(
                          fontSize: 10,
                          color: kDim,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text(verse,
                      style: const TextStyle(
                          fontSize: 14,
                          color: kText,
                          height: 1.8)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kDim,
            letterSpacing: 0.4));
  }
}