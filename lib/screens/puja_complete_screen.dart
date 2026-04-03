import 'package:dharma_guide/theme.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';

class PujaCompleteScreen extends StatefulWidget {
  final AppState state;
  const PujaCompleteScreen({super.key, required this.state});

  @override
  State<PujaCompleteScreen> createState() => _PujaCompleteScreenState();
}

class _PujaCompleteScreenState extends State<PujaCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  final _refController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 60),
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: const Text('🪔', style: TextStyle(fontSize: 72)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('Practice Complete',
                  style: TextStyle(
                      fontSize: 32,
                      color: kText,
                      fontWeight: FontWeight.w400)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.state.selectedMantra?.name ?? '',
                style: const TextStyle(fontSize: 14, color: kRust),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'May the vibrations of this mantra bring peace, clarity, and divine grace to your day.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kDim, height: 1.8),
              ),
            ),
            const SizedBox(height: 32),

            // Optional reflection
            DharmaCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('ADD REFLECTION (OPTIONAL)',
                    style: TextStyle(
                        fontSize: 11,
                        color: kDim,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                TextField(
                  controller: _refController,
                  maxLines: null,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'How did this practice feel?',
                    hintStyle: TextStyle(color: kDim),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: kText, height: 1.7),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            DharmaBtn(
              label: 'Return Home 🙏',
              onTap: () => widget.state.nav('home'),
            ),
          ],
        ),
      ),
    );
  }
}
