import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'components/navigation/animated_tab_bar.dart';
import 'core/supabase_client.dart';
import 'core/theme_controller.dart';
import 'core/toast_service.dart';
import 'screens/announcement_detail_screen.dart';
import 'screens/content_screen.dart';
import 'screens/home_screen.dart';
import 'screens/interactive_placeholder_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/splash_view.dart';
import 'services/profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('id_ID', null);
  await SupabaseClientManager.initialize();
  runApp(const IqlabRoot());
}

class IqlabRoot extends StatefulWidget {
  const IqlabRoot({super.key});

  @override
  State<IqlabRoot> createState() => _IqlabRootState();
}

class _IqlabRootState extends State<IqlabRoot> {
  final ThemeController _themeController = ThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _themeController,
      child: MaterialApp(
        title: 'I-QLab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF1E3A8A),
        ),
        builder: (context, child) {
          return ToastOverlayWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const _AppBootstrapCluster(),
      ),
    );
  }
}

/// Exact 1:1 replica of `App()` in `App.js`:
/// - 3000ms Splash Screen (`isShowSplash || isProfileChecking`)
/// - Supabase Auth session check + listener (including SIGNED_IN / SIGNED_OUT Toasts from `useHome.js`)
/// - Profile check (`ProfileSetupScreen` gate if logged in without a row in `profiles`)
/// - `MainTabs` (`Content`, `Home` [initial], `Profile`) with `AnimatedTabBar`
class _AppBootstrapCluster extends StatefulWidget {
  const _AppBootstrapCluster();

  @override
  State<_AppBootstrapCluster> createState() => _AppBootstrapClusterState();
}

class _AppBootstrapClusterState extends State<_AppBootstrapCluster> {
  bool _isShowSplash = true;
  Session? _session;
  bool _isProfileChecking = true;
  bool _hasProfile = false;
  bool _initialAuthChecked = false;

  Timer? _splashTimer;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initSplashTimer();
    _initAuth();
  }

  void _initSplashTimer() {
    // On Web returning from OAuth redirect, skip splash just like App.js lines 207-212
    if (kIsWeb && Uri.base.fragment.contains('access_token')) {
      _isShowSplash = false;
      return;
    }
    _splashTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _isShowSplash = false);
      }
    });
  }

  void _initAuth() {
    final currentSession = supabase.auth.currentSession;
    _session = currentSession;
    if (currentSession?.user != null) {
      _checkUserProfile(currentSession!.user.id);
    } else {
      _isProfileChecking = false;
    }
    _initialAuthChecked = true;

    _authSubscription = supabase.auth.onAuthStateChange.listen((authState) {
      final event = authState.event;
      final newSession = authState.session;

      if (!mounted) return;
      setState(() => _session = newSession);

      if (newSession?.user != null) {
        _checkUserProfile(newSession!.user.id);
      } else {
        setState(() {
          _hasProfile = false;
          _isProfileChecking = false;
        });
      }

      // Auth feedback Toasts matching useHome.js lines 36-60
      if (_initialAuthChecked) {
        if (event == AuthChangeEvent.signedIn) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            ToastService.show(
              type: ToastType.success,
              text1: 'Berhasil Login! 🎉',
              text2: 'Selamat datang di I-Qlab',
              position: ToastPosition.bottom,
              bottomOffset: 90,
            );
          });
        } else if (event == AuthChangeEvent.signedOut) {
          ToastService.show(
            type: ToastType.info,
            text1: 'Berhasil Logout',
            text2: 'Semoga belajarmu berkah, sampai jumpa lagi!',
            position: ToastPosition.bottom,
            bottomOffset: 90,
          );
        }
      }
    });
  }

  Future<void> _checkUserProfile(String userId) async {
    if (mounted) {
      setState(() => _isProfileChecking = true);
    }
    try {
      final profile = await ProfileService.getProfile(userId);
      if (mounted) {
        setState(() => _hasProfile = profile != null);
      }
    } catch (e) {
      debugPrint('Check Profile Error: $e');
      if (mounted) {
        setState(() => _hasProfile = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isProfileChecking = false);
      }
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isShowSplash || _isProfileChecking) {
      return SplashView(isProfileChecking: _isProfileChecking);
    }

    if (_session != null && !_hasProfile) {
      return ProfileSetupScreen(
        onProfileComplete: () {
          setState(() => _hasProfile = true);
        },
      );
    }

    return _MainTabsScaffold(session: _session);
  }
}

class _MainTabsScaffold extends StatefulWidget {
  final Session? session;

  const _MainTabsScaffold({required this.session});

  @override
  State<_MainTabsScaffold> createState() => _MainTabsScaffoldState();
}

class _MainTabsScaffoldState extends State<_MainTabsScaffold> {
  // Matches App.js `initialRouteName="Home"` where tabs are [Content, Home, Profile]
  int _currentIndex = 1;

  Route<T> _fadeFromBottomRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _openInteractiveQuran() {
    Navigator.of(context).push(
      _fadeFromBottomRoute(const InteractivePlaceholderScreen()),
    );
  }

  void _openAnnouncementDetail(Map<String, dynamic> announcement) {
    Navigator.of(context).push(
      _fadeFromBottomRoute(
        AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgFull = ThemeScope.of(context).theme.bgFull;

    return Scaffold(
      backgroundColor: bgFull,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const ContentScreen(),
              HomeScreen(
                session: widget.session,
                onOpenInteractiveQuran: _openInteractiveQuran,
                onOpenAnnouncement: _openAnnouncementDetail,
              ),
              ProfileScreen(
                session: widget.session,
                onNavigateHome: () => setState(() => _currentIndex = 1),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedTabBar(
              currentIndex: _currentIndex,
              onTabSelected: (index) {
                if (_currentIndex != index) {
                  setState(() => _currentIndex = index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
