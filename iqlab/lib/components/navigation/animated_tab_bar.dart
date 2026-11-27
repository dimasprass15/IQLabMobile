import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../core/theme_controller.dart';

/// Exact 1:1 replica of `src/components/navigation/AnimatedTabBar.js`
class AnimatedTabBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AnimatedTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  double? _lastWidth;

  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 14.5, // Smooth elastic bounce matching RN bounciness: 12
  );

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController.unbounded(
      vsync: this,
      value: widget.currentIndex.toDouble(),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _slideController.animateWith(
        SpringSimulation(
          _spring,
          _slideController.value,
          widget.currentIndex.toDouble(),
          0.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final bottomInset = media.padding.bottom;
    final safeBottom = bottomInset > 0 ? bottomInset : 10.0;
    final totalHeight = 70.0 + safeBottom;
    _lastWidth = width;

    final isDarkMode = ThemeScope.of(context).isDarkMode;

    return SizedBox(
      width: width,
      height: totalHeight,
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, _) {
          final currentWidth = _lastWidth ?? width;
          final currentTabWidth = currentWidth / 3.0;
          final activeTabCenter =
              _slideController.value * currentTabWidth + (currentTabWidth / 2.0);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. LAYER BACKGROUND SOLID (Satu Path Mulus dengan lekukan Bezier & border atas bercahaya)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: CustomPaint(
                    painter: _CurvedNavBackgroundPainter(
                      dipCenter: activeTabCenter,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ),
              ),

              // 2. LAYER FOREGROUND (Lingkaran Melayang & Titik Bawah)
              Positioned(
                left: activeTabCenter - 28,
                top: -24,
                child: IgnorePointer(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(79, 70, 229, 0.4),
                          offset: Offset(0, 8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: activeTabCenter - 3,
                top: 46,
                child: IgnorePointer(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // 3. TOMBOL NAVIGASI (Content, Home, Profile)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: _TabIconItem(
                        isFocused: widget.currentIndex == 0,
                        icon: FeatherIcons.playCircle,
                        label: 'Konten',
                        isDarkMode: isDarkMode,
                        onTap: () => widget.onTabSelected(0),
                      ),
                    ),
                    Expanded(
                      child: _TabIconItem(
                        isFocused: widget.currentIndex == 1,
                        icon: FeatherIcons.home,
                        label: 'Beranda',
                        isDarkMode: isDarkMode,
                        onTap: () => widget.onTabSelected(1),
                      ),
                    ),
                    Expanded(
                      child: _TabIconItem(
                        isFocused: widget.currentIndex == 2,
                        icon: FeatherIcons.user,
                        label: 'Profil',
                        isDarkMode: isDarkMode,
                        onTap: () => widget.onTabSelected(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabIconItem extends StatefulWidget {
  final bool isFocused;
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _TabIconItem({
    required this.isFocused,
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<_TabIconItem> createState() => _TabIconItemState();
}

class _TabIconItemState extends State<_TabIconItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconYController;

  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _iconYController = AnimationController.unbounded(
      vsync: this,
      value: widget.isFocused ? -25.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _TabIconItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFocused != widget.isFocused) {
      _iconYController.animateWith(
        SpringSimulation(
          _spring,
          _iconYController.value,
          widget.isFocused ? -25.0 : 0.0,
          0.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _iconYController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
        widget.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Inactive center y = 29 (top: 13, height: 32); focused translates -25 -> center y = 4 (center of floatingCircle)
            Positioned(
              top: 13,
              child: AnimatedBuilder(
                animation: _iconYController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _iconYController.value),
                    child: child,
                  );
                },
                child: SizedBox(
                  height: 32,
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: widget.isFocused ? Colors.white : inactiveColor,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              child: AnimatedOpacity(
                opacity: widget.isFocused ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: inactiveColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvedNavBackgroundPainter extends CustomPainter {
  final double dipCenter;
  final bool isDarkMode;

  const _CurvedNavBackgroundPainter({
    required this.dipCenter,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = dipCenter;
    final path = Path()
      ..moveTo(-100, 0)
      ..lineTo(c - 70, 0)
      ..cubicTo(c - 50, 0, c - 30, 40, c, 40)
      ..cubicTo(c + 30, 40, c + 50, 0, c + 70, 0)
      ..lineTo(size.width + 100, 0)
      ..lineTo(size.width + 100, size.height + 100)
      ..lineTo(-100, size.height + 100)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color =
          isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isDarkMode
          ? const Color.fromRGBO(99, 102, 241, 0.3)
          : const Color.fromRGBO(79, 70, 229, 0.4);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNavBackgroundPainter oldDelegate) {
    return oldDelegate.dipCenter != dipCenter ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
