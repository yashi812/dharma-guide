// lib/screens/manifestation_animation_screen.dart
//
// Called from ManifestationJournalScreen when technique is '21-Day Journaling'.
// Animates the user's intention with a sacred reveal, then saves it and returns.
//
// Usage:
//   final saved = await Navigator.push<bool>(context,
//     MaterialPageRoute(builder: (_) => ManifestationAnimationScreen(
//       intention: text, techniqueName: t.name)));
//   if (saved == true) { /* refresh history */ }

import 'dart:math';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ManifestationAnimationScreen extends StatefulWidget {
  final String intention;
  final String techniqueName;

  const ManifestationAnimationScreen({
    super.key,
    required this.intention,
    required this.techniqueName,
  });

  @override
  State<ManifestationAnimationScreen> createState() =>
      _ManifestationAnimationScreenState();
}

class _ManifestationAnimationScreenState
    extends State<ManifestationAnimationScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers ─────────────────────────────────────
  late final AnimationController _bgCtrl;      // background glow pulse
  late final AnimationController _textCtrl;    // text fade + rise
  late final AnimationController _orbitCtrl;   // orbiting particles
  late final AnimationController _sealCtrl;    // final seal / stamp

  late final Animation<double> _bgGlow;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _sealScale;
  late final Animation<double> _sealOpacity;

  // ── State ─────────────────────────────────────────────────────
  late String _statusText;

  // Particle definitions (generated once)
  late final List<_Particle> _particles;

  // ── Technique-aware helpers ───────────────────────────────────────────
  String get _cardLabel {
    final n = widget.techniqueName;
    if (n.contains('3-6-9'))    return '✦  MY AFFIRMATION  ✦';
    if (n.contains('5×55'))     return '✦  MY AFFIRMATION  ✦';
    if (n.contains('Scripting')) return '✦  MY SCRIPT  ✦';
    return '✦  MY INTENTION  ✦';
  }

  String get _sealingText {
    final n = widget.techniqueName;
    if (n.contains('3-6-9'))    return 'Sealing with Tesla\'s sacred numbers…';
    if (n.contains('5×55'))     return 'Imprinting 55 times into the universe…';
    if (n.contains('Scripting')) return 'Scripting your future into existence…';
    return 'Sealing your intention…';
  }

  String get _savedText {
    final n = widget.techniqueName;
    if (n.contains('3-6-9'))    return 'Sealed with 3 · 6 · 9 ✨';
    if (n.contains('5×55'))     return 'Sent to the universe ✍️';
    if (n.contains('Scripting')) return 'Your future has been scripted 🌟';
    return 'Your intention has been set ✨';
  }

  String get _sealEmoji {
    final n = widget.techniqueName;
    if (n.contains('3-6-9'))    return '🔢';
    if (n.contains('5×55'))     return '✍️';
    if (n.contains('Scripting')) return '🌟';
    return '🙏';
  }

  String get _initialStatusText {
    final n = widget.techniqueName;
    if (n.contains('3-6-9'))    return 'Aligning with 3 · 6 · 9 energy…';
    if (n.contains('5×55'))     return 'Charging your 55-fold intention…';
    if (n.contains('Scripting')) return 'Entering your future timeline…';
    return 'Setting your intention into the universe…';
  }

  @override
  void initState() {
    super.initState();

    // Must initialise _statusText after widget is available
    _statusText = _initialStatusText;
    _particles = List.generate(18, (i) => _Particle(i));

    // Background breathe — loops
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _bgGlow = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    // Text reveal — runs once after short delay
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide   = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // Orbiting particles — loops
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Seal — plays after text is up
    _sealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _sealScale   = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _sealCtrl, curve: Curves.elasticOut));
    _sealOpacity = CurvedAnimation(parent: _sealCtrl, curve: Curves.easeIn);

    _runSequence();
  }

 Future<void> _runSequence() async {
  // 1. Let background breathe for a beat
  await Future.delayed(const Duration(milliseconds: 400));

  // 2. Text rises
  _textCtrl.forward();
  await Future.delayed(const Duration(milliseconds: 1600));

  // 3. Show sealing status (no save here — caller already saved)
  setState(() => _statusText = _sealingText);
  await Future.delayed(const Duration(milliseconds: 800));
  setState(() => _statusText = _savedText);

  // 4. Seal stamp
  _sealCtrl.forward();
  await Future.delayed(const Duration(milliseconds: 900));

  // 5. Brief pause then auto-return
  await Future.delayed(const Duration(milliseconds: 1800));
  if (mounted) Navigator.pop(context, true);
}

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Animated background glow ──────────────────────────
          AnimatedBuilder(
            animation: _bgGlow,
            builder: (_, __) {
              return CustomPaint(
                painter: _GlowPainter(_bgGlow.value),
              );
            },
          ),

          // ── Orbiting particles ────────────────────────────────
          AnimatedBuilder(
            animation: _orbitCtrl,
            builder: (_, __) {
              return CustomPaint(
                painter: _ParticlePainter(
                  _particles,
                  _orbitCtrl.value,
                ),
              );
            },
          ),

          // ── Main content ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Om symbol — breathes with bg
                AnimatedBuilder(
                  animation: _bgGlow,
                  builder: (_, __) {
                    return Opacity(
                      opacity: 0.55 + 0.45 * _bgGlow.value,
                      child: const Text(
                        'ॐ',
                        style: TextStyle(
                          fontSize: 52,
                          color: Color(0xFFE8C97A),
                          height: 1,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                const Text(
                  'MANIFESTATION',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF8A7A5A),
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 48),

                // ── Intention text card ───────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1509),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE8C97A).withValues(alpha: 0.25),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE8C97A).withValues(alpha: 0.08),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _cardLabel,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFE8C97A),
                                    letterSpacing: 2.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '"${widget.intention}"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFF5EDD8),
                                    height: 1.85,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Decorative divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xFFE8C97A).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '✦',
                                        style: TextStyle(
                                          color: Color(0xFFE8C97A),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xFFE8C97A).withValues(alpha: 0.15),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Seal stamp ────────────────────────────────
                ScaleTransition(
                  scale: _sealScale,
                  child: FadeTransition(
                    opacity: _sealOpacity,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE8C97A).withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                        color: const Color(0xFF1A1509),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8C97A).withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(_sealEmoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Status text ───────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _statusText,
                    key: ValueKey(_statusText),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A7A5A),
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Custom painters
// ══════════════════════════════════════════════════════════════════════════════

/// Soft radial glow that pulses behind the content
class _GlowPainter extends CustomPainter {
  final double t; // 0..1 animated value
  _GlowPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;
    final radius = size.width * (0.55 + 0.12 * t);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE8C97A).withValues(alpha: 0.10 + 0.06 * t),
          const Color(0xFFA0722A).withValues(alpha: 0.04 + 0.02 * t),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.t != t;
}

/// Orbiting gold dust particles
class _Particle {
  final double angle;     // base angle offset
  final double radius;    // orbit radius (fraction of screen)
  final double speed;     // orbit speed multiplier
  final double size;      // dot size
  final double opacity;

  _Particle(int seed)
      : angle   = seed * 0.349 + 0.1,        // evenly spread, slight offset
        radius  = 0.22 + (seed % 5) * 0.048,
        speed   = 0.6 + (seed % 4) * 0.22,
        size    = 1.5 + (seed % 3) * 1.2,
        opacity = 0.25 + (seed % 4) * 0.12;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0..1 loop
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final theta = (p.angle + t * p.speed * 2 * pi) % (2 * pi);
      final r     = size.width * p.radius;
      final x     = cx + r * cos(theta);
      final y     = cy + r * sin(theta) * 0.45; // flatten into ellipse

      paint.color = const Color(0xFFE8C97A).withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}