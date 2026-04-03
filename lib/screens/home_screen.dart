// From a screen at lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../constants/app_data.dart';
import '../../theme.dart';
import '../../state/app_state.dart';
import '../../shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(greet.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11, color: kDim, letterSpacing: 1.5)),
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

                  // Today's Verse
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFFF8ED), Color(0xFFF0E8D8)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kAccent.withOpacity(0.3)),
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
                              color: kAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(verse.theme,
                                style: const TextStyle(
                                    fontSize: 11, color: kAccent)),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 14),

                  // Puja Banner
                  GestureDetector(
                    onTap: () => state.nav('puja_select'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [kAccent, kRust]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(children: [
                        Text('🪔', style: TextStyle(fontSize: 36)),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Begin Puja Practice',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16)),
                                Text('AI-guided mantra chanting · 5 min',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ]),
                        ),
                        Text('›',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick action cards
                  Row(children: [
                    Expanded(
                      child: DharmaCard(
                        onTap: () => state.nav('reflection'),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📝', style: TextStyle(fontSize: 24)),
                              SizedBox(height: 8),
                              Text('Reflect Today',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: kText,
                                      fontSize: 14)),
                              Text('Log mood & thoughts',
                                  style:
                                      TextStyle(fontSize: 11, color: kDim)),
                            ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DharmaCard(
                        onTap: () => state.nav('guidance'),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('💬', style: TextStyle(fontSize: 24)),
                              SizedBox(height: 8),
                              Text('Seek Guidance',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: kText,
                                      fontSize: 14)),
                              Text('Dharmic wisdom',
                                  style:
                                      TextStyle(fontSize: 11, color: kDim)),
                            ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Featured Mantras
                  const Text('FEATURED MANTRAS',
                      style: TextStyle(
                          fontSize: 11,
                          color: kDim,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  ...kMantras.take(2).map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DharmaCard(
                          onTap: () {
                            state.setMantra(m);
                            state.nav('puja_meaning');
                          },
                          child: Row(children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: kAlt,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                  child: Text('🎵',
                                      style: TextStyle(fontSize: 20))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(m.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: kText,
                                          fontSize: 14)),
                                  Text('${m.deity} · ${m.diff}',
                                      style: const TextStyle(
                                          fontSize: 11, color: kDim)),
                                ])),
                            const Text('›',
                                style: TextStyle(color: kDim, fontSize: 18)),
                          ]),
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            BottomNav(active: 'home', state: state),
          ],
        ),
      ),
    );
  }
}
