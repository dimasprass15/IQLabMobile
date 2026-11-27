import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ionicons/ionicons.dart';

import '../core/theme_controller.dart';

/// Exact 1:1 replica of `src/screens/ContentScreen.js`
class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  static const _dummyReels = [
    {
      'id': 1,
      'title': 'Keutamaan Membaca Al-Kahfi',
      'views': '12K',
      'duration': '0:59',
      'image':
          'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=400&q=80',
    },
    {
      'id': 2,
      'title': 'Adab Berdoa Sesuai Sunnah',
      'views': '8.5K',
      'duration': '1:15',
      'image':
          'https://images.unsplash.com/photo-1590076215667-875d4ef2d7ad?w=400&q=80',
    },
    {
      'id': 3,
      'title': 'Sejarah Masjid Nabawi',
      'views': '20K',
      'duration': '0:45',
      'image':
          'https://images.unsplash.com/photo-1564352939794-436f4aa4c577?w=400&q=80',
    },
  ];

  static const _dummyArticles = [
    {
      'id': 1,
      'title': 'Memahami Makna Sabar dalam Al-Baqarah 153',
      'category': 'Tafsir',
      'readTime': '5 min',
      'image':
          'https://images.unsplash.com/photo-1609599006353-e629aaab31ce?w=400&q=80',
    },
    {
      'id': 2,
      'title': '5 Sunnah Harian yang Sering Terlupakan',
      'category': 'Fikih',
      'readTime': '3 min',
      'image':
          'https://images.unsplash.com/photo-1605335962804-0ee216962f3a?w=400&q=80',
    },
    {
      'id': 3,
      'title': 'Pentingnya Menjaga Lisan Menurut Hadits',
      'category': 'Akhlaq',
      'readTime': '4 min',
      'image':
          'https://images.unsplash.com/photo-1598288825227-2e11ee9cc2e4?w=400&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeScope.of(context);
    final isDarkMode = themeCtrl.isDarkMode;
    final theme = themeCtrl.theme;

    final actionCircleBg =
        isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: theme.topBarBg,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: ColoredBox(
        color: theme.bgFull,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Container(
                color: theme.topBarBg,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Eksplorasi Konten',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: theme.textMain,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: themeCtrl.toggleDarkMode,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: actionCircleBg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isDarkMode
                                  ? FeatherIcons.sun
                                  : FeatherIcons.moon,
                              size: 22,
                              color: isDarkMode
                                  ? const Color(0xFFEAB308)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: actionCircleBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            FeatherIcons.search,
                            size: 22,
                            color: isDarkMode
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. LIVE YOUTUBE SECTION
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kajian Langsung',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textMain,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: theme.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.border,
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.1),
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1519817914152-2a640166cb83?w=800&q=80',
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => Container(
                                          color: const Color(0xFF1E293B)),
                                    ),
                                    const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Color.fromRGBO(0, 0, 0, 0.8),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          color: Color.fromRGBO(
                                              239, 68, 68, 0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Ionicons.play,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      left: 20,
                                      right: 20,
                                      bottom: 20,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tadabbur Surat Al-Fatihah Bersama Ustadz Ahmad',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '1,234 sedang menonton • I-QLab Channel',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.8),
                                              fontSize: 13,
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

                      // 2. REELS SECTION
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'I-QLab Shorts',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.textMain,
                              ),
                            ),
                            const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _dummyReels.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final reel = _dummyReels[index];
                            return Container(
                              width: 130,
                              height: 220,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: reel['image'] as String,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => Container(
                                        color: const Color(0xFF1E293B)),
                                  ),
                                  const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Color.fromRGBO(0, 0, 0, 0.9),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  0, 0, 0, 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Ionicons.time_outline,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  reel['duration'] as String,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reel['title'] as String,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                height: 18 / 13,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Ionicons.eye_outline,
                                                  size: 14,
                                                  color: Color(0xFFCCCCCC),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${reel['views']} tayangan',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xFFCCCCCC),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // 3. ARTICLES SECTION
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Artikel Pilihan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.textMain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(_dummyArticles.length, (index) {
                              final article = _dummyArticles[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index == _dummyArticles.length - 1
                                          ? 0
                                          : 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: article['image'] as String,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, _, _) => Container(
                                            width: 80,
                                            height: 80,
                                            color: const Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                      right: 10),
                                                  decoration: BoxDecoration(
                                                    color: theme.btnBg,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    article['category']
                                                        as String,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: theme.textSub,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  FeatherIcons.clock,
                                                  size: 12,
                                                  color: theme.textSub,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    article['readTime']
                                                        as String,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: theme.textSub,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              article['title'] as String,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                height: 22 / 15,
                                                color: theme.textMain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
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

