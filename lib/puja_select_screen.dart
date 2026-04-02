import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/app_data.dart';
import '../state/app_state.dart';
import '../widgets/shared_widgets.dart';

class PujaSelectScreen extends StatelessWidget {
  final AppState state;
  const PujaSelectScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              child: Row(children: [
                BackBtn(onTap: () => state.nav('home')),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Choose Mantra',
                      style: TextStyle(
                          fontSize: 28,
                          color: kText,
                          fontWeight: FontWeight.w400)),
                  Text('Select your practice for today',
                      style: TextStyle(fontSize: 13, color: kDim)),
                ]),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: kMantras.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DharmaCard(
                      onTap: () {
                        if (m.premium && !state.isPremium) {
                          state.nav('paywall');
                          return;
                        }
                        state.setMantra(m);
                        state.nav('puja_meaning');
                      },
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: kAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                              child: Text('🎵',
                                  style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Text(m.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: kText,
                                      fontSize: 15)),
                              if (m.premium) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kAccent,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text('PRO',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ]),
                            const SizedBox(height: 4),
                            Text(
                                '${m.deity} · ${m.diff} · ${m.lines.length} lines',
                                style: const TextStyle(
                                    fontSize: 12, color: kDim)),
                            const SizedBox(height: 6),
                            Text(m.lines[0],
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: kRust,
                                    fontStyle: FontStyle.italic)),
                          ]),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Text('›',
                              style: TextStyle(color: kDim, fontSize: 18)),
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
