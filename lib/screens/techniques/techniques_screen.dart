
import 'package:flutter/material.dart';

import '../../state/app_state.dart' show AppState;
import '../../constants/theme.dart';
import '../../shared_widgets.dart';
import '../../app_data.dart';

class TechniquesScreen extends StatelessWidget {
  final AppState state;
  const TechniquesScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            // Header
            Row(children: [
              GestureDetector(
                onTap: () => state.nav('home'),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: kDim),
              ),
              const SizedBox(width: 12),
              const Text('MANIFESTATION TECHNIQUES',
                  style: TextStyle(
                      fontSize: 11,
                      color: kDim,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 24),

            // All 5 technique cards
            ...kTechniques.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DharmaCard(
                    onTap: () {
                      state.setTechnique(t);
                      state.nav('technique_detail');
                    },
                    child: Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kAlt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                            child: Text(t.emoji,
                                style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(t.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: kText,
                                    fontSize: 14)),
                            Text('${t.listSub} · ${t.badges.first}',
                                style: const TextStyle(
                                    fontSize: 11, color: kDim)),
                          ])),
                      const Text('›',
                          style: TextStyle(color: kDim, fontSize: 18)),
                    ]),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}