import 'package:dharma_guide/state/app_state.dart';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../../shared_widgets.dart';

class AartiDetailScreen extends StatelessWidget {
  final AppState state;
  const AartiDetailScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final aarti = state.currentAarti;
    if (aarti == null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => state.nav('aarti_list'));
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
          children: [
            // Header
            Row(children: [
              BackBtn(onTap: () => state.nav('aarti_list')),
              const SizedBox(width: 12),
              Text(aarti.emoji,
                  style: const TextStyle(fontSize: 28)),
            ]),
            const SizedBox(height: 20),

            // Title block
            Container(
              padding: const EdgeInsets.all(20),
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
                    aarti.deity.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        color: kAccent,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    aarti.name,
                    style: const TextStyle(
                        fontSize: 26,
                        color: kText,
                        fontWeight: FontWeight.w400,
                        height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aarti.sub,
                    style: const TextStyle(
                        fontSize: 13, color: kDim, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Verses
            ...List.generate(aarti.verses.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: kAccent,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          i == 0 ? 'मुखड़ा' : 'अन्तरा ${i}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: kDim,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Text(
                        aarti.verses[i],
                        style: const TextStyle(
                            fontSize: 17,
                            color: kRust,
                            height: 2.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Bottom blessing
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Text('🙏', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'जय ${aarti.deity} — May this aarti bring peace, prosperity and divine blessings.',
                    style: const TextStyle(
                        fontSize: 13, color: kDim, height: 1.6),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}