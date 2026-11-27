import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/feather_icon_mapper.dart';
import '../core/theme_controller.dart';

/// Exact 1:1 replica of `src/screens/AnnouncementDetailScreen.js`
class AnnouncementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcement,
  });

  String _formatDate(dynamic raw) {
    try {
      final parsed = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return raw?.toString() ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeScope.of(context);
    final isDarkMode = themeCtrl.isDarkMode;
    final theme = themeCtrl.theme;

    final imageUrl = announcement['image_url']?.toString() ?? '';
    final title = announcement['title']?.toString() ?? '';
    final iconName = announcement['icon']?.toString();
    final targetAudience = announcement['target_audience']?.toString();
    final htmlContent =
        announcement['content']?.toString() ?? '<p>Tidak ada detail konten.</p>';
    final formattedDate = _formatDate(announcement['published_at']);

    final strongHex = isDarkMode ? '#818cf8' : '#4f46e5';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.bgFull,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER IMAGE
                  SizedBox(
                    height: 350,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
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
                                Color.fromRGBO(0, 0, 0, 0.4),
                                Colors.transparent,
                                Color.fromRGBO(0, 0, 0, 0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                FeatherIcons.arrowLeft,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PENGUMUMAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 32 / 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT SECTION (overlapping header by -20px)
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 500),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 124),
                      decoration: BoxDecoration(
                        color: theme.bgFull,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color.fromRGBO(
                                          255, 255, 255, 0.05)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: DynamicFeatherIcon(
                                  name: iconName,
                                  size: 20,
                                  color: isDarkMode
                                      ? const Color(0xFF818CF8)
                                      : const Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textSub,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Untuk: ${targetAudience == 'semua' ? 'Semua Pengguna' : 'I-QLab Only'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: theme.divider,
                            margin: const EdgeInsets.only(bottom: 24),
                          ),
                          HtmlWidget(
                            htmlContent,
                            textStyle: TextStyle(
                              color: theme.textMain,
                              fontSize: 16,
                              height: 24 / 16,
                            ),
                            customStylesBuilder: (element) {
                              switch (element.localName) {
                                case 'p':
                                  return {'margin-bottom': '12px'};
                                case 'strong':
                                case 'b':
                                  return {
                                    'font-weight': 'bold',
                                    'color': strongHex,
                                  };
                                case 'ul':
                                  return {'margin-bottom': '12px'};
                                case 'li':
                                  return {'margin-bottom': '4px'};
                                case 'a':
                                  return {
                                    'color': '#4f46e5',
                                    'text-decoration': 'underline',
                                  };
                              }
                              return null;
                            },
                            onTapUrl: (url) async {
                              final uri = Uri.tryParse(url);
                              if (uri != null) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                              return true;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FLOATING CLOSE BUTTON
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(79, 70, 229, 0.3),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Selesai Membaca',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

