import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'state/app_state.dart';

// ─── Primary Button ───────────────────────────
class DharmaBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String variant;
  final EdgeInsets? padding;

  const DharmaBtn({
    super.key,
    required this.label,
    this.onTap,
    this.variant = 'primary',
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    Border? border;
    switch (variant) {
      case 'secondary':
        bg = kAlt;
        fg = kText;
        border = Border.all(color: kBorder);
        break;
      case 'ghost':
        bg = Colors.transparent;
        fg = kAccent;
        border = Border.all(color: kAccent, width: 1.5);
        break;
      default:
        bg = kAccent;
        fg = Colors.white;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
          border: border,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: fg,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────
class DharmaCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;

  const DharmaCard({
    super.key,
    required this.child,
    this.onTap,
    this.decoration,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: decoration ??
            BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                )
              ],
            ),
        child: child,
      ),
    );
  }
}

// ─── Back Button ──────────────────────────────
class BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const BackBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: const Text('←', style: TextStyle(fontSize: 22, color: kDim)),
      );
}

// ─── Bottom Navigation ────────────────────────
class BottomNav extends StatelessWidget {
  final String active;
  final AppState state;

  const BottomNav({super.key, required this.active, required this.state});

  static const _items = [
    ('home', '🏠', 'Home'),
    ('reflection', '📝', 'Reflect'),
    ('guidance', '💬', 'Guidance'),
    ('profile', '👤', 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: _items.map((item) {
          final isActive = active == item.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => state.nav(item.$1),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(top: 10, bottom: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.$2, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 3),
                    Text(
                      item.$3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? kAccent : kDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
