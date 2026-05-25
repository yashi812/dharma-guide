import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../../constants/app_data.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';



class ProfileScreen extends StatelessWidget {
  final AppState state;
  const ProfileScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final style = kStyles.firstWhere(
      (s) => s.id == state.userStyle,
      orElse: () => kStyles.last,
    );

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                children: [
                  const Text('Profile',
                      style: TextStyle(
                          fontSize: 28,
                          color: kText,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 20),

                  // User card
                  DharmaCard(
                    child: Row(children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: kAlt,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBorder, width: 2),
                        ),
                        child: const Center(
                            child:
                                Text('🧘', style: TextStyle(fontSize: 30))),
                      ),
                      const SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(state.userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: kText,
                                fontSize: 18)),
                        Text('${style.label} Path',
                            style:
                                const TextStyle(fontSize: 12, color: kDim)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Stats row
                  Row(children: [
                    Expanded(child: _statCard('🔥', '${state.streak}', 'Day streak')),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard('🪔', '12', 'Pujas done')),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard('📝', '8', 'Reflections')),
                  ]),
                  const SizedBox(height: 14),

                  // Premium / Free plan card
                  DharmaCard(
                    decoration: BoxDecoration(
                      color: state.isPremium
                          ? const Color(0xFFFFF8ED)
                          : kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: state.isPremium
                              ? kAccent.withOpacity(0.3)
                              : kBorder),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(children: [
                      Text(state.isPremium ? '⭐' : '🆓',
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                        Text(
                            state.isPremium
                                ? 'Dharma Premium'
                                : 'Free Plan',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: kText)),
                        Text(
                            state.isPremium
                                ? 'All features unlocked'
                                : '2 mantras · limited',
                            style: const TextStyle(
                                fontSize: 12, color: kDim)),
                      ])),
                      if (!state.isPremium)
                        GestureDetector(
                          onTap: () => state.nav('paywall'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                                color: kAccent,
                                borderRadius: BorderRadius.circular(100)),
                            child: const Text('Upgrade',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Guidance style picker
                  DharmaCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('GUIDANCE STYLE',
                          style: TextStyle(
                              fontSize: 11,
                              color: kDim,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.8,
                        children: kStyles.map((gs) {
                          final sel = state.userStyle == gs.id;
                          return GestureDetector(
                            onTap: () => state.setUserStyle(gs.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFFFFF8ED)
                                    : kSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: sel ? kAccent : kBorder,
                                    width: sel ? 2 : 1),
                              ),
                              child: Row(children: [
                                Text(gs.icon,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(gs.label,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: sel
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        color: sel ? kAccent : kText)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            BottomNav(active: 'profile', state: state),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String icon, String val, String lbl) => DharmaCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(val,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: kText)),
          const SizedBox(height: 2),
          Text(lbl,
              style: const TextStyle(fontSize: 10, color: kDim),
              textAlign: TextAlign.center),
        ]),
      );
}
