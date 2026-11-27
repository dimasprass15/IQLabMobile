import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

enum ToastType { success, error, info }

enum ToastPosition { top, bottom }

class ToastData {
  final ToastType type;
  final String text1;
  final String? text2;
  final ToastPosition position;
  final double bottomOffset;
  final double topOffset;

  const ToastData({
    required this.type,
    required this.text1,
    this.text2,
    this.position = ToastPosition.top,
    this.bottomOffset = 40,
    this.topOffset = 40,
  });
}

/// Global Toast controller & overlay matching `src/lib/toastConfig.js`
class ToastService {
  static final ValueNotifier<ToastData?> currentToast =
      ValueNotifier<ToastData?>(null);
  static Timer? _dismissTimer;

  static void show({
    required ToastType type,
    required String text1,
    String? text2,
    ToastPosition position = ToastPosition.top,
    double bottomOffset = 40,
    double topOffset = 40,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    _dismissTimer?.cancel();
    // Reset briefly if already showing so the spring slide-in replays cleanly
    currentToast.value = null;
    scheduleMicrotask(() {
      currentToast.value = ToastData(
        type: type,
        text1: text1,
        text2: text2,
        position: position,
        bottomOffset: bottomOffset,
        topOffset: topOffset,
      );
      _dismissTimer = Timer(duration, hide);
    });
  }

  static void hide() {
    _dismissTimer?.cancel();
    currentToast.value = null;
  }
}

class ToastOverlayWrapper extends StatelessWidget {
  final Widget child;

  const ToastOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<ToastData?>(
          valueListenable: ToastService.currentToast,
          builder: (context, toast, _) {
            if (toast == null) return const SizedBox.shrink();
            return _CustomToastWidget(
              key: ValueKey(
                  '${toast.type}_${toast.text1}_${toast.text2}_${DateTime.now().microsecondsSinceEpoch}'),
              toast: toast,
            );
          },
        ),
      ],
    );
  }
}

class _CustomToastWidget extends StatefulWidget {
  final ToastData toast;

  const _CustomToastWidget({super.key, required this.toast});

  @override
  State<_CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<_CustomToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1.0);
    // Matches Animated.spring(slideAnim, { toValue: 0, tension: 20, friction: 7 })
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 140.0,
      damping: 14.0,
    );
    _controller.animateWith(SpringSimulation(spring, 1.0, 0.0, 0.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;

    final Color backgroundColor;
    final IconData iconData;
    switch (widget.toast.type) {
      case ToastType.success:
        backgroundColor = const Color.fromRGBO(16, 185, 129, 0.95);
        iconData = FeatherIcons.checkCircle;
      case ToastType.error:
        backgroundColor = const Color.fromRGBO(239, 68, 68, 0.95);
        iconData = FeatherIcons.alertCircle;
      case ToastType.info:
        backgroundColor = const Color.fromRGBO(30, 58, 138, 0.95);
        iconData = FeatherIcons.info;
    }

    final isBottom = widget.toast.position == ToastPosition.bottom;

    return Positioned(
      top: isBottom ? null : media.padding.top + widget.toast.topOffset,
      bottom: isBottom ? widget.toast.bottomOffset : null,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_controller.value * screenWidth, 0),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: ToastService.hide,
              onHorizontalDragEnd: (_) => ToastService.hide(),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                        offset: Offset(0, 10),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          iconData,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.toast.text1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.toast.text2 != null &&
                                widget.toast.text2!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.toast.text2!,
                                style: const TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 20 / 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

