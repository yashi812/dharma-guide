import 'package:dharma_guide/app_data.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../constants/theme.dart';
import '../shared_widgets.dart';

class PujaVidhiListScreen extends StatelessWidget {
  final AppState state;
  const PujaVidhiListScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              child: Row(children: [
                BackBtn(onTap: () => state.nav('puja_select')),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Puja Vidhi',
                        style: TextStyle(
                            fontSize: 28,
                            color: kText,
                            fontWeight: FontWeight.w400)),
                    Text('Choose a puja to perform',
                        style: TextStyle(fontSize: 13, color: kDim)),
                  ],
                ),
              ]),
            ),

            // ── Puja List ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: kVistarPujas.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DharmaCard(
                      onTap: () {
                        state.setVistarPuja(p);
                        state.nav('puja_detail');
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon box
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: kAlt,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(p.emoji,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: kText,
                                        fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.deity} · ${p.occasion.split('·').first.trim()}',
                                  style: const TextStyle(
                                      fontSize: 12, color: kDim),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(p.sub,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: kRust,
                                        fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),

                          // Arrow
                          const Padding(
                            padding: EdgeInsets.only(top: 14),
                            child: Text('›',
                                style: TextStyle(color: kDim, fontSize: 18)),
                          ),
                        ],
                      ),
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