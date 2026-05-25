import 'package:dharma_guide/constants/theme.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';

class SplashScreen extends StatefulWidget {
  final AppState state;
  const SplashScreen({super.key, required this.state});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulse, _fade1, _fade2;
  late Animation<double> _scaleAnim, _opacityAnim, _title, _sub;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _scaleAnim =
        Tween(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _opacityAnim =
        Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _fade1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _title = CurvedAnimation(parent: _fade1, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 300), () => _fade1.forward());

    _fade2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _sub = CurvedAnimation(parent: _fade2, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 600), () => _fade2.forward());
  }

  @override
  void dispose() {
    _pulse.dispose();
    _fade1.dispose();
    _fade2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Transform.scale(
                scale: _scaleAnim.value,
                child: Opacity(
                  opacity: _opacityAnim.value,
                  child: const Text('ॐ',
                      style: TextStyle(fontSize: 80, color: kAccent, height: 1)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _title,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.3), end: Offset.zero)
                    .animate(_fade1),
                child: const Text(
                  'Dharma Guide',
                  style: TextStyle(
                      fontSize: 34,
                      color: kText,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _sub,
              child: const Text(
                'YOUR SPIRITUAL COMPANION',
                style: TextStyle(fontSize: 12, color: kDim, letterSpacing: 2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
