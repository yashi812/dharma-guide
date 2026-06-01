// lib/screens/home/home_screen.dart
import 'package:dharma_guide/app_data.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart' show AppState;
import '../constants/theme.dart';
import '../../shared_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../screens/birth_details_screen.dart'; // ← new import

class HomeScreen extends StatelessWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  void _showTechniquesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TechniquesSheet(state: state),
    );
  }

  // ── Birth details: push the full-screen onboarding-style screen ─────────
  void _showBirthDetailsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BirthDetailsScreen(state: state),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final hr = DateTime.now().hour;
    final greet =
        hr < 12 ? 'Good morning' : hr < 17 ? 'Good afternoon' : 'Good evening';
    final verse = kGita[DateTime.now().weekday % kGita.length];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                children: [
                  // ── Header ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greet.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: kDim,
                                    letterSpacing: 1.5)),
                            Text('Namaste, ${state.userName}',
                                style: const TextStyle(
                                    fontSize: 26,
                                    color: kText,
                                    fontWeight: FontWeight.w400)),
                          ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(children: [
                          const Text('🔥'),
                          const SizedBox(width: 6),
                          Text('${state.streak} days',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kText)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Today's Verse ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFFF8ED), Color(0xFFF0E8D8)]),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: kAccent.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY\'S VERSE · GITA ${verse.ch}.${verse.v}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: kAccent,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text('"${verse.text}"',
                              style: const TextStyle(
                                  fontSize: 17, color: kRust, height: 1.8)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(verse.theme,
                                style: const TextStyle(
                                    fontSize: 11, color: kAccent)),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 14),

                  // ── Seek Guidance Banner ────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      // Has a kundli or at least birth details → go straight to guidance
                      if (state.kundliData != null && state.kundliData!.isNotEmpty) {
                        state.nav('guidance');
                      } else if (state.hasBirthDetails) {
                        state.nav('guidance');
                      } else {
                        // User skipped onboarding — show the full-screen birth details flow
                        _showBirthDetailsScreen(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: [kAccent, kRust]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        const Text('💬',
                            style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Seek Guidance',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16)),
                                Text(
                                  state.kundliData != null
                                      ? 'Your dharmic path is illuminated · Ask anything'
                                      : 'AI-guided wisdom from the Bhagavad Gita',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12),
                                ),
                              ]),
                        ),
                        const Text('›',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 20)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Quick action cards ──────────────────────────────────
                  Row(children: [
                    Expanded(
                      child: DharmaCard(
                        onTap: () => state.nav('reflection'),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📝',
                                  style: TextStyle(fontSize: 24)),
                              SizedBox(height: 8),
                              Text('Reflect Today',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: kText,
                                      fontSize: 14)),
                              Text('Log mood & thoughts',
                                  style: TextStyle(
                                      fontSize: 11, color: kDim)),
                            ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DharmaCard(
                        onTap: () => state.nav('puja_select'),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🪔',
                                  style: TextStyle(fontSize: 24)),
                              SizedBox(height: 8),
                              Text('AI Puja',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: kText,
                                      fontSize: 14)),
                              Text('Chant with guidance',
                                  style: TextStyle(
                                      fontSize: 11, color: kDim)),
                            ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DharmaCard(
                        onTap: () => _showTechniquesSheet(context),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✨',
                                  style: TextStyle(fontSize: 24)),
                              SizedBox(height: 8),
                              Text('Manifest',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: kText,
                                      fontSize: 14)),
                              Text('5 techniques',
                                  style: TextStyle(
                                      fontSize: 11, color: kDim)),
                            ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // ── Aarti Sangrah Banner ────────────────────────────────
                  GestureDetector(
                    onTap: () => state.nav('aarti_list'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🪭',
                              style: TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AARTI SANGRAH',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: kAccent,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 3),
                              Text('आरती संग्रह',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: kText,
                                      fontWeight: FontWeight.w400)),
                              SizedBox(height: 2),
                              Text('Devotional hymns for every deity',
                                  style:
                                      TextStyle(fontSize: 12, color: kDim)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: kAccent.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right,
                              color: kAccent, size: 18),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Techniques Bottom Sheet ───────────────────────────────────────────────────

class _TechniquesSheet extends StatelessWidget {
  final AppState state;
  const _TechniquesSheet({required this.state});

  Future<void> _openPinterest(BuildContext context, String userName) async {
    final query = Uri.encodeComponent(
        '$userName vision board manifestation aesthetic');
    final pinterestApp =
        Uri.parse('pinterest://search/pins/?q=$query');
    final pinterestWeb =
        Uri.parse('https://in.pinterest.com/search/pins/?q=$query');

    if (await canLaunchUrl(pinterestApp)) {
      await launchUrl(pinterestApp);
    } else {
      await launchUrl(pinterestWeb,
          mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Text('✨',
                        style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Manifestation Techniques',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: kText)),
                          Text('Choose a practice to begin',
                              style:
                                  TextStyle(fontSize: 12, color: kDim)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: kSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBorder),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: kDim),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: kBorder),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: kTechniques.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final t = kTechniques[i];
                    return GestureDetector(
                      onTap: () async {
                        await GuidanceService.saveUserInput(
                          screen: 'home_techniques',
                          fieldName: 'technique_selected',
                          value: t.name,
                        );
                        state.setTechnique(t);
                        Navigator.pop(context);
                        if (t.name == 'Vision Board') {
                          await _openPinterest(context, state.userName);
                        } else {
                          state.nav('technique_detail');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kAccent.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(t.emoji,
                                style:
                                    const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(t.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: kText)),
                                  if (t.name == 'Vision Board') ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE60023)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: const Text('Pinterest →',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFFE60023),
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 2),
                                Text(t.listSub,
                                    style: const TextStyle(
                                        fontSize: 12, color: kDim)),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: t.badges
                                      .map((b) => Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                            decoration: BoxDecoration(
                                              color: kAccent
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Text(b,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: kAccent)),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              color: kDim, size: 20),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}