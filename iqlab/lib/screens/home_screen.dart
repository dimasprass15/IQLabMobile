import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/feather_icon_mapper.dart';
import '../core/supabase_client.dart';
import '../core/theme_controller.dart';
import '../core/toast_service.dart';

/// Exact 1:1 replica of `src/screens/HomeScreen.js` + `src/hooks/useHome.js`
class HomeScreen extends StatefulWidget {
  final Session? session;
  final VoidCallback onOpenInteractiveQuran;
  final ValueChanged<Map<String, dynamic>> onOpenAnnouncement;

  const HomeScreen({
    super.key,
    required this.session,
    required this.onOpenInteractiveQuran,
    required this.onOpenAnnouncement,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoadingAnnouncements = true;
  DateTime _currentTime = DateTime.now();

  Timer? _heartbeatTimer;
  RealtimeChannel? _realtimeChannel;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Heartbeat every 10s to reveal scheduled announcements right on time (useHome.js lines 109-114)
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    _fetchAnnouncements();
    _subscribeRealtimeAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      if (mounted) {
        setState(() => _isLoadingAnnouncements = true);
      }

      // 5-minute future buffer matching useHome.js line 123
      final futureBuffer =
          DateTime.now().toUtc().add(const Duration(minutes: 5)).toIso8601String();

      final data = await supabase
          .from('announcements')
          .select()
          .or('target_audience.eq.semua,target_audience.eq.iqlab')
          .lte('published_at', futureBuffer)
          .order('published_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _announcements = List<Map<String, dynamic>>.from(data);
          _currentTime = DateTime.now();
        });
      }
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAnnouncements = false);
      }
    }
  }

  void _subscribeRealtimeAnnouncements() {
    try {
      _realtimeChannel = supabase
          .channel('announcements_realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'announcements',
            callback: (_) => _fetchAnnouncements(),
          )
          .subscribe();
    } catch (e) {
      debugPrint('Realtime subscription error: $e');
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _shimmerController.dispose();
    if (_realtimeChannel != null) {
      supabase.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  List<Map<String, dynamic>> get _visibleAnnouncements {
    return _announcements.where((item) {
      final raw = item['published_at']?.toString();
      if (raw == null) return true;
      final publishedAt = DateTime.tryParse(raw);
      if (publishedAt == null) return true;
      return !publishedAt.toLocal().isAfter(_currentTime);
    }).toList();
  }

  void _showComingSoonToast(String desc) {
    ToastService.show(
      type: ToastType.info,
      text1: 'Segera Hadir!',
      text2: desc,
      position: ToastPosition.bottom,
      bottomOffset: 90,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeScope.of(context);
    final isDarkMode = themeCtrl.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40.0;

    // Exact per-screen colors from HomeScreen.js lines 46-76
    final bgFull =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final topBarBg =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final toggleBg =
        isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final textMain =
        isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSub =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg =
        isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final divider =
        isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final iconBgBlue = isDarkMode
        ? const Color.fromRGBO(99, 102, 241, 0.2)
        : const Color(0xFFEEF2FF);
    final iconBgPink = isDarkMode
        ? const Color.fromRGBO(219, 39, 119, 0.2)
        : const Color(0xFFFDF2F8);
    final iconColBlue =
        isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF6366F1);
    final iconColPink =
        isDarkMode ? const Color(0xFFF472B6) : const Color(0xFFDB2777);

    final visibleAnnouncements = _visibleAnnouncements;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: topBarBg,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: ColoredBox(
        color: bgFull,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // FIXED TOP BAR
              Container(
                color: topBarBg,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ahlan wa Sahlan! 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textMain,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mau belajar apa hari ini?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textSub,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: themeCtrl.toggleDarkMode,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: toggleBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isDarkMode ? FeatherIcons.sun : FeatherIcons.moon,
                          size: 22,
                          color: isDarkMode
                              ? const Color(0xFFEAB308)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, bottom: 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. SLIDER INFORMASI TERBARU
                      SizedBox(
                        height: 140,
                        child: _isLoadingAnnouncements
                            ? ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: 2,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  return _ShimmerSliderCard(
                                    width: cardWidth,
                                    cardBg: cardBg,
                                    isDarkMode: isDarkMode,
                                    animation: _shimmerController,
                                  );
                                },
                              )
                            : visibleAnnouncements.isNotEmpty
                                ? ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: _SnapIntervalScrollPhysics(
                                      snapInterval: cardWidth + 14.0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    itemCount: visibleAnnouncements.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 14),
                                    itemBuilder: (context, index) {
                                      final item = visibleAnnouncements[index];
                                      return _AnnouncementSliderCard(
                                        width: cardWidth,
                                        item: item,
                                        onTap: () =>
                                            widget.onOpenAnnouncement(item),
                                      );
                                    },
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Container(
                                      width: cardWidth,
                                      height: 140,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: divider,
                                          width: 1,
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: isDarkMode
                                              ? const [
                                                  Color(0xFF1E293B),
                                                  Color(0xFF0F172A),
                                                ]
                                              : const [
                                                  Color(0xFFFFFFFF),
                                                  Color(0xFFF8FAFC),
                                                ],
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                0, 0, 0, 0.08),
                                            offset: Offset(0, 6),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              color: iconBgBlue,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              FeatherIcons.smile,
                                              size: 24,
                                              color: iconColBlue,
                                            ),
                                          ),
                                          Text(
                                            'Belum ada pengumuman baru',
                                            style: TextStyle(
                                              color: textMain,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tetap semangat belajar Al-Quran hari ini ya! ✨',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: textSub,
                                              fontSize: 13,
                                              height: 18 / 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                      ),

                      const SizedBox(height: 24),

                      // 2. PEMBATAS ELEGAN (Fading Gradient Divider)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.70,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color.fromRGBO(79, 70, 229, 0.0),
                                    Color.fromRGBO(79, 70, 229, 0.25),
                                    Color.fromRGBO(79, 70, 229, 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 3. MAIN BENTO GRID - COMPACT
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // 3.1 Interactive Quran - WIDE CARD
                            _WideBentoCard(
                              colors: const [
                                Color(0xFF1E40AF),
                                Color(0xFF3B82F6),
                              ],
                              shadowColor: const Color(0xFF1E40AF),
                              icon: const Icon(
                                FeatherIcons.bookOpen,
                                size: 20,
                                color: Colors.white,
                              ),
                              title: 'Interactive Quran',
                              subtitle: 'Baca, Tadabbur & Dengar',
                              onTap: widget.onOpenInteractiveQuran,
                            ),
                            const SizedBox(height: 14),

                            // 3.2 Hadist Harian - WIDE CARD
                            _WideBentoCard(
                              colors: const [
                                Color(0xFF059669),
                                Color(0xFF34D399),
                              ],
                              shadowColor: const Color(0xFF059669),
                              icon: const Icon(
                                FeatherIcons.feather,
                                size: 20,
                                color: Colors.white,
                              ),
                              title: 'Hadist Harian',
                              subtitle: 'Inspirasi dari sabda Rasulullah',
                              onTap: () => _showComingSoonToast(
                                'Fitur Hadist Harian sedang kami siapkan.',
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 3.3 Zikir Pagi & Zikir Petang - HALF CARDS
                            Row(
                              children: [
                                Expanded(
                                  child: _HalfZikirCard(
                                    assetPath: 'assets/zikirpagi.png',
                                    icon: FeatherIcons.sunrise,
                                    title: 'Zikir Pagi',
                                    subtitle: "Al Ma'tsurat",
                                    onTap: () => _showComingSoonToast(
                                      'Fitur Zikir Pagi sedang kami siapkan.',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _HalfZikirCard(
                                    assetPath: 'assets/zikirpetang.png',
                                    icon: FeatherIcons.sunset,
                                    title: 'Zikir Petang',
                                    subtitle: "Al Ma'tsurat",
                                    onTap: () => _showComingSoonToast(
                                      'Fitur Zikir Petang sedang kami siapkan.',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 3.4 Doa-doa Pilihan - WIDE CARD
                            _WideBentoCard(
                              colors: const [
                                Color(0xFF7C3AED),
                                Color(0xFFA78BFA),
                              ],
                              shadowColor: const Color(0xFF7C3AED),
                              icon: const FaIcon(
                                FontAwesomeIcons.hands,
                                size: 18,
                                color: Colors.white,
                              ),
                              title: 'Doa-doa Pilihan',
                              subtitle: 'Kumpulan doa mustajab',
                              onTap: () => _showComingSoonToast(
                                'Kumpulan doa pilihan sedang kami siapkan.',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4. SECONDARY ACTIONS - PENGATURAN & INFO
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 14),
                              child: Text(
                                'Pengaturan & Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textSub,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: divider,
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.05),
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _SecondaryMenuItem(
                                    iconBg: iconBgBlue,
                                    icon: Icon(
                                      FeatherIcons.info,
                                      size: 18,
                                      color: iconColBlue,
                                    ),
                                    title: 'Tentang I-QLab',
                                    textMain: textMain,
                                    textSub: textSub,
                                    onTap: () {},
                                  ),
                                  Container(
                                    height: 1,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    color: divider,
                                  ),
                                  _SecondaryMenuItem(
                                    iconBg: iconBgPink,
                                    icon: FaIcon(
                                      FontAwesomeIcons.handHoldingHeart,
                                      size: 16,
                                      color: iconColPink,
                                    ),
                                    title: 'Infaq & Dukungan',
                                    textMain: textMain,
                                    textSub: textSub,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _ShimmerSliderCard extends StatelessWidget {
  final double width;
  final Color cardBg;
  final bool isDarkMode;
  final Animation<double> animation;

  const _ShimmerSliderCard({
    required this.width,
    required this.cardBg,
    required this.isDarkMode,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final dx = -width + (animation.value * width * 2.5);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: Container(
              color: isDarkMode
                  ? const Color.fromRGBO(255, 255, 255, 0.05)
                  : const Color.fromRGBO(0, 0, 0, 0.05),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromRGBO(0, 0, 0, 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementSliderCard extends StatelessWidget {
  final double width;
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _AnnouncementSliderCard({
    required this.width,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['image_url']?.toString() ?? '';
    final title = item['title']?.toString() ?? '';
    final summary = item['summary']?.toString() ?? '';
    final iconName = item['icon']?.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              offset: Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 500),
                  errorWidget: (_, _, _) =>
                      Container(color: const Color(0xFF1E3A8A)),
                )
              else
                Container(color: const Color(0xFF1E3A8A)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.1),
                      Color.fromRGBO(0, 0, 0, 0.8),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: DynamicFeatherIcon(
                        name: iconName,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'TERBARU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.9),
                              fontSize: 13,
                              height: 18 / 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideBentoCard extends StatelessWidget {
  final List<Color> colors;
  final Color shadowColor;
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WideBentoCard({
    required this.colors,
    required this.shadowColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.2),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              FeatherIcons.chevronRight,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _HalfZikirCard extends StatelessWidget {
  final String assetPath;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HalfZikirCard({
    required this.assetPath,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.1),
                      Color.fromRGBO(0, 0, 0, 0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 18,
                left: 18,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryMenuItem extends StatelessWidget {
  final Color iconBg;
  final Widget icon;
  final String title;
  final Color textMain;
  final Color textSub;
  final VoidCallback onTap;

  const _SecondaryMenuItem({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.textMain,
    required this.textSub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                ),
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              size: 16,
              color: textSub,
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapIntervalScrollPhysics extends ScrollPhysics {
  final double snapInterval;

  const _SnapIntervalScrollPhysics({
    required this.snapInterval,
    super.parent,
  });

  @override
  _SnapIntervalScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapIntervalScrollPhysics(
      snapInterval: snapInterval,
      parent: buildParent(ancestor),
    );
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / snapInterval;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return (page * snapInterval)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

