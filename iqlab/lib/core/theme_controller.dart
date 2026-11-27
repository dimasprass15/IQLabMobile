import 'dart:async';
import 'package:flutter/material.dart';

class AppThemeColors {
  final Color bgFull;
  final Color topBarBg;
  final Color textMain;
  final Color textSub;
  final Color cardBg;
  final Color border;
  final Color divider;
  final Color inputBg;
  final Color btnBg;

  const AppThemeColors({
    required this.bgFull,
    required this.topBarBg,
    required this.textMain,
    required this.textSub,
    required this.cardBg,
    required this.border,
    required this.divider,
    required this.inputBg,
    required this.btnBg,
  });

  static const dark = AppThemeColors(
    bgFull: Color(0xFF0F172A),
    topBarBg: Color(0xFF0F172A),
    textMain: Color(0xFFF8FAFC),
    textSub: Color(0xFF94A3B8),
    cardBg: Color(0xFF1E293B),
    border: Color(0xFF334155),
    divider: Color(0xFF334155),
    inputBg: Color(0xFF1E293B),
    btnBg: Color(0xFF334155),
  );

  static const light = AppThemeColors(
    bgFull: Color(0xFFF8FAFC),
    topBarBg: Color(0xFFF1F5F9),
    textMain: Color(0xFF0F172A),
    textSub: Color(0xFF64748B),
    cardBg: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFF1F5F9),
    inputBg: Color(0xFFFFFFFF),
    btnBg: Color(0xFFF1F5F9),
  );
}

/// Exact replica of `src/context/ThemeContext.js`:
/// - Auto dark mode from 18:00 to 05:59 unless manually toggled.
/// - Checks on startup, every 60 seconds, and on app resume from background.
class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  bool _isDarkMode = false;
  bool _hasManuallyToggled = false;
  Timer? _timer;

  ThemeController() {
    WidgetsBinding.instance.addObserver(this);
    _checkTimeAndSetTheme();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkTimeAndSetTheme();
    });
  }

  bool get isDarkMode => _isDarkMode;
  AppThemeColors get theme =>
      _isDarkMode ? AppThemeColors.dark : AppThemeColors.light;

  void _checkTimeAndSetTheme() {
    if (!_hasManuallyToggled) {
      final currentHour = DateTime.now().hour;
      final shouldBeDark = currentHour >= 18 || currentHour < 6;
      if (_isDarkMode != shouldBeDark) {
        _isDarkMode = shouldBeDark;
        notifyListeners();
      }
    }
  }

  void setIsDarkMode(bool value) {
    _isDarkMode = value;
    _hasManuallyToggled = true;
    notifyListeners();
  }

  void toggleDarkMode() {
    setIsDarkMode(!_isDarkMode);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkTimeAndSetTheme();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }
}

