import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqlab/components/navigation/animated_tab_bar.dart';
import 'package:iqlab/core/theme_controller.dart';
import 'package:iqlab/screens/content_screen.dart';
import 'package:iqlab/screens/splash_view.dart';

void main() {
  testWidgets('SplashView renders logo and optional spinner',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashView(isProfileChecking: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AnimatedTabBar displays Konten, Beranda, Profil and switches tab',
      (WidgetTester tester) async {
    final themeController = ThemeController();
    int selectedIndex = 1;

    await tester.pumpWidget(
      ThemeScope(
        controller: themeController,
        child: StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    const ContentScreen(),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedTabBar(
                        currentIndex: selectedIndex,
                        onTabSelected: (i) => setState(() => selectedIndex = i),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Konten'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.text('Konten'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(selectedIndex, 0);

    themeController.dispose();
  });
}
