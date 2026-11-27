import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../core/theme_controller.dart';

/// Header & frame shell matching `InteractiveQuranScreen.js` so navigation from
/// Beranda works seamlessly while Tahap 1 focuses on Splash + Menu Utama.
class InteractivePlaceholderScreen extends StatelessWidget {
  const InteractivePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeScope.of(context);
    final isDarkMode = themeCtrl.isDarkMode;
    final theme = themeCtrl.theme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: theme.topBarBg,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: theme.bgFull,
        body: SafeArea(
          child: Column(
            children: [
              // MODERN HEADER (matching InteractiveQuranScreen.js lines 185-205)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.topBarBg,
                  border: Border(
                    bottom: BorderSide(color: theme.topBarBg, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.btnBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          FeatherIcons.arrowLeft,
                          size: 22,
                          color: theme.textMain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ahlan Bikum! 👋',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: theme.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                'Tadabbur Bersama AI',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textSub,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        FeatherIcons.trash2,
                        size: 20,
                        color: theme.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(59, 130, 246, 0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            FeatherIcons.bookOpen,
                            size: 32,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Interactive Quran (Tahap Berikutnya)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: theme.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Halaman Splash Screen & Menu Utama sudah siap! Modul Chat Quran, Mushaf SQLite, Audio & Share Card akan dimigrasikan pada tahap selanjutnya.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 22 / 14,
                            color: theme.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

