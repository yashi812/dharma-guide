import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../state/app_state.dart';
import '../widgets/shared_widgets.dart';

class PaywallScreen extends StatefulWidget {
  final AppState state;
  const PaywallScreen({super.key, required this.state});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _sel = 'annual';

  static const _plans = [
    ('monthly', 'Monthly', '₹299', '/month', ''),
    ('annual', 'Annual', '₹1,999', '/year', 'SAVE 44%'),
    ('lifetime', 'Lifetime', '₹4,999', 'one-time', 'BEST VALUE'),
  ];

  static const _feats = [
    ('🪔', 'All 50+ mantras & pujas'),
    ('🧠', 'Unlimited AI guidance'),
    ('📖', 'Full Gita library'),
    ('🎧', 'Offline downloads'),
    ('🎯', 'Practice analytics'),
    ('✨', 'Early feature access'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => widget.state.nav('home'),
                  child: const Text('✕',
                      style: TextStyle(fontSize: 22, color: kDim)),
                ),
              ),
            ),

            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(children: [
                Text('ॐ', style: TextStyle(fontSize: 52)),
                SizedBox(height: 12),
                Text('Dharma Premium',
                    style: TextStyle(
                        fontSize: 32,
                        color: kText,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 8),
                Text(
                  'Unlock the full path to inner peace and wisdom',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: kDim, height: 1.7),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                // Features list
                DharmaCard(
                  child: Column(
                    children: _feats.map((f) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          Text(f.$1, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(f.$2,
                                  style: const TextStyle(
                                      fontSize: 14, color: kText))),
                          const Text('✓',
                              style: TextStyle(color: kGreen, fontSize: 14)),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Plan selector
                ..._plans.map((p) {
                  final sel = _sel == p.$1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _sel = p.$1),
                      child: DharmaCard(
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFFFFF8ED)
                              : kSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: sel ? kAccent : kBorder,
                              width: sel ? 2 : 1),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: sel ? kAccent : kBorder,
                                  width: 2),
                              color: sel ? kAccent : Colors.transparent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                            Text(p.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: kText,
                                    fontSize: 15)),
                            Text('${p.$3} ${p.$4}',
                                style: const TextStyle(
                                    fontSize: 12, color: kDim)),
                          ])),
                          if (p.$5.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius: BorderRadius.circular(100)),
                              child: Text(p.$5,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                        ]),
                      ),
                    ),
                  );
                }),

                DharmaBtn(
                  label: 'Start My Journey →',
                  onTap: () {
                    widget.state.setIsPremium(true);
                    widget.state.nav('home');
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  '7-day free trial · Cancel anytime · Restore purchase',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: kDim),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
