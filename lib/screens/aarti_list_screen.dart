import 'package:dharma_guide/state/app_state.dart';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../../shared_widgets.dart';
import '../../app_data.dart';

class AartiListScreen extends StatelessWidget {
  final AppState state;
  const AartiListScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
              child: Row(children: [
                BackBtn(onTap: () => state.nav('home')),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AARTI SANGRAH',
                        style: TextStyle(
                            fontSize: 11,
                            color: kDim,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500)),
                    Text('आरती संग्रह',
                        style: TextStyle(
                            fontSize: 26,
                            color: kText,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount: kAartis.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final a = kAartis[i];
                  return DharmaCard(
                    onTap: () {
                      state.setAarti(a);
                      state.nav('aarti_detail');
                    },
                    child: Row(children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(a.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: kText)),
                            const SizedBox(height: 3),
                            Text(a.deity,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: kAccent,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(a.sub,
                                style: const TextStyle(
                                    fontSize: 11, color: kDim),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('›',
                              style:
                                  TextStyle(color: kDim, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('${a.verses.length} verses',
                              style: const TextStyle(
                                  fontSize: 10, color: kDim)),
                        ],
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}