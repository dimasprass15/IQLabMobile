import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

/// Maps dynamic Feather icon string names (e.g. from Supabase `announcements.icon`)
/// to exact `FeatherIcons`, plus a crisp Feather-style megaphone fallback.
class DynamicFeatherIcon extends StatelessWidget {
  final String? name;
  final double size;
  final Color color;

  const DynamicFeatherIcon({
    super.key,
    required this.name,
    this.size = 22,
    this.color = Colors.white,
  });

  static const Map<String, IconData> _iconMap = {
    'activity': FeatherIcons.activity,
    'alert-circle': FeatherIcons.alertCircle,
    'alert-triangle': FeatherIcons.alertTriangle,
    'award': FeatherIcons.award,
    'bell': FeatherIcons.bell,
    'book': FeatherIcons.book,
    'book-open': FeatherIcons.bookOpen,
    'bookmark': FeatherIcons.bookmark,
    'calendar': FeatherIcons.calendar,
    'check-circle': FeatherIcons.checkCircle,
    'clock': FeatherIcons.clock,
    'compass': FeatherIcons.compass,
    'feather': FeatherIcons.feather,
    'flag': FeatherIcons.flag,
    'gift': FeatherIcons.gift,
    'globe': FeatherIcons.globe,
    'heart': FeatherIcons.heart,
    'home': FeatherIcons.home,
    'info': FeatherIcons.info,
    'layers': FeatherIcons.layers,
    'mail': FeatherIcons.mail,
    'map-pin': FeatherIcons.mapPin,
    'message-circle': FeatherIcons.messageCircle,
    'mic': FeatherIcons.mic,
    'moon': FeatherIcons.moon,
    'play-circle': FeatherIcons.playCircle,
    'radio': FeatherIcons.radio,
    'send': FeatherIcons.send,
    'shield': FeatherIcons.shield,
    'smile': FeatherIcons.smile,
    'star': FeatherIcons.star,
    'sun': FeatherIcons.sun,
    'sunrise': FeatherIcons.sunrise,
    'sunset': FeatherIcons.sunset,
    'trending-up': FeatherIcons.trendingUp,
    'user': FeatherIcons.user,
    'users': FeatherIcons.users,
    'video': FeatherIcons.video,
    'volume-2': FeatherIcons.volume2,
    'zap': FeatherIcons.zap,
  };

  @override
  Widget build(BuildContext context) {
    final key = (name ?? 'megaphone').trim().toLowerCase();
    final mapped = _iconMap[key];
    if (mapped != null) {
      return Icon(mapped, size: size, color: color);
    }
    if (key == 'megaphone') {
      return CustomPaint(
        size: Size.square(size),
        painter: _FeatherMegaphonePainter(color: color),
      );
    }
    return Icon(FeatherIcons.bell, size: size, color: color);
  }
}

class _FeatherMegaphonePainter extends CustomPainter {
  final Color color;

  const _FeatherMegaphonePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(3 * scale, 11 * scale)
      ..lineTo(21 * scale, 5 * scale)
      ..lineTo(21 * scale, 19 * scale)
      ..lineTo(3 * scale, 13 * scale)
      ..close();

    final handle = Path()
      ..moveTo(11.6 * scale, 16.8 * scale)
      ..arcToPoint(
        Offset(6 * scale, 16 * scale),
        radius: Radius.circular(3 * scale),
      )
      ..lineTo(6 * scale, 14 * scale);

    canvas.drawPath(path, paint);
    canvas.drawPath(handle, paint);
  }

  @override
  bool shouldRepaint(covariant _FeatherMegaphonePainter oldDelegate) =>
      oldDelegate.color != color;
}

