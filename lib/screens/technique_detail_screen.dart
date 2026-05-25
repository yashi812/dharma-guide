import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../state/app_state.dart';
import '../shared_widgets.dart';

class TechniqueDetailScreen extends StatelessWidget {
  final AppState state;
  const TechniqueDetailScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final t = state.currentTechnique!;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => state.nav('home'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 14, color: kText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(t.name,
                      style: const TextStyle(fontSize: 16, color: kText)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  // Hero card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kAccent, kRust]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.tag.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text(t.emoji,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 6),
                        Text(t.name,
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 6),
                        Text(t.sub,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.6)),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          children: t.badges
                              .map((b) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius:
                                          BorderRadius.circular(100),
                                    ),
                                    child: Text(b,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // What it is
                  const Text('WHAT IT IS',
                      style: TextStyle(
                          fontSize: 10,
                          color: kDim,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  DharmaCard(
                    child: Text(t.what,
                        style: const TextStyle(
                            fontSize: 14, color: kText, height: 1.75)),
                  ),

                  const SizedBox(height: 20),

                  // How to do it
                  const Text('HOW TO DO IT',
                      style: TextStyle(
                          fontSize: 10,
                          color: kDim,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      children: t.steps.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final step = entry.value;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: idx < t.steps.length - 1
                                ? Border(
                                    bottom: BorderSide(color: kBorder))
                                : null,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: kAlt,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text('${idx + 1}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: kAccent,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(step['t']!,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: kText)),
                                    const SizedBox(height: 2),
                                    Text(step['d']!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: kDim,
                                            height: 1.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tips
                  const Text('TIPS FOR BEST RESULTS',
                      style: TextStyle(
                          fontSize: 10,
                          color: kDim,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: kAccent.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: t.tips.map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(tip,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: kText,
                                        height: 1.55)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CTA
                  GestureDetector(
                    onTap: () => state.nav('manifestation_journal'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [kAccent, kRust]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Begin Practice',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
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