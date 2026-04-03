import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';

class PujaMeaningScreen extends StatelessWidget {
  final AppState state;
  const PujaMeaningScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final mantra = state.selectedMantra;
    if (mantra == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => state.nav('puja_select'));
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          children: [
            BackBtn(onTap: () => state.nav('puja_select')),
            const SizedBox(height: 20),
            Text(
              '${mantra.deity} · ${mantra.diff}'.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  color: kAccent,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              mantra.name,
              style: const TextStyle(
                  fontSize: 34,
                  color: kText,
                  fontWeight: FontWeight.w400,
                  height: 1.15),
            ),
            const SizedBox(height: 24),

            // Meaning card
            DharmaCard(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kAccent.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('MEANING',
                    style: TextStyle(
                        fontSize: 10,
                        color: kAccent,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(mantra.meaning,
                    style: const TextStyle(
                        fontSize: 16, color: kRust, height: 1.9)),
              ]),
            ),
            const SizedBox(height: 14),

            // Lines card
            DharmaCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('LINES TO PRACTICE',
                    style: TextStyle(
                        fontSize: 10,
                        color: kDim,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 14),
                ...List.generate(mantra.lines.length, (i) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(mantra.lines[i],
                        style: const TextStyle(fontSize: 17, color: kRust)),
                    const SizedBox(height: 4),
                    Text(mantra.tr[i],
                        style: const TextStyle(
                            fontSize: 12,
                            color: kDim,
                            fontStyle: FontStyle.italic)),
                    if (i < mantra.lines.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: kBorder, height: 1),
                      ),
                  ]);
                }),
              ]),
            ),
            const SizedBox(height: 14),

            // Instructions card
            DharmaCard(
              decoration: BoxDecoration(
                  color: kAlt, borderRadius: BorderRadius.circular(16)),
              child: const Text(
                '🎙 App speaks each line · Repeat it aloud · Evaluated after each line',
                style: TextStyle(fontSize: 13, color: kDim, height: 1.8),
              ),
            ),
            const SizedBox(height: 18),

            DharmaBtn(
              label: 'Begin Practice 🪔',
              onTap: () => state.nav('puja_session'),
            ),
          ],
        ),
      ),
    );
  }
}
