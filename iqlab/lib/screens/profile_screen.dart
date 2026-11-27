import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme_controller.dart';
import '../core/toast_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

/// Exact 1:1 replica of `src/screens/ProfileScreen.js`
class ProfileScreen extends StatefulWidget {
  final Session? session;
  final VoidCallback onNavigateHome;

  const ProfileScreen({
    super.key,
    required this.session,
    required this.onNavigateHome,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = false;
  bool _isEditing = false;

  final _fullNameCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Ikhwan';

  @override
  void initState() {
    super.initState();
    if (widget.session?.user != null) {
      _loadProfile();
    }
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session?.user.id != widget.session?.user.id) {
      if (widget.session?.user != null) {
        _loadProfile();
      } else {
        setState(() {
          _profile = null;
          _isEditing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _whatsappCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = widget.session?.user.id;
    if (userId == null) return;
    setState(() => _loading = true);
    try {
      final data = await ProfileService.getProfile(userId);
      if (!mounted) return;
      setState(() {
        _profile = data;
        if (data != null) {
          _fullNameCtrl.text = data['full_name']?.toString() ?? '';
          _whatsappCtrl.text = data['whatsapp_number']?.toString() ?? '';
          _ageCtrl.text = data['age']?.toString() ?? '';
          _gender = data['gender']?.toString() ?? 'Ikhwan';
          _addressCtrl.text = data['address']?.toString() ?? '';
        }
      });
    } catch (e) {
      debugPrint('Load Profile Error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleUpdate() async {
    final userId = widget.session?.user.id;
    if (userId == null) return;
    setState(() => _loading = true);
    try {
      await ProfileService.updateProfile(
        userId: userId,
        fullName: _fullNameCtrl.text.trim(),
        whatsappNumber: _whatsappCtrl.text.trim(),
        age: _ageCtrl.text.trim(),
        gender: _gender,
        address: _addressCtrl.text.trim(),
      );
      ToastService.show(
        type: ToastType.success,
        text1: 'Berhasil!',
        text2: 'Profil Anda telah diperbarui.',
      );
      if (mounted) {
        setState(() => _isEditing = false);
      }
      await _loadProfile();
    } catch (e) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Gagal memperbarui profil.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleAuth() async {
    try {
      if (widget.session != null) {
        await AuthService.signOut();
        widget.onNavigateHome();
      } else {
        await AuthService.signInWithGoogle();
      }
    } catch (e) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gagal Login'),
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeScope.of(context);
    final isDarkMode = themeCtrl.isDarkMode;
    final session = widget.session;

    // Exact colors from ProfileScreen.js lines 26-58
    final bgFull =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final topBarBg =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textMain =
        isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSub =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg =
        isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final cardBorder =
        isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final border =
        isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final iconEmptyBg =
        isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final actionIconBgRed = isDarkMode
        ? const Color.fromRGBO(225, 29, 72, 0.2)
        : const Color(0xFFFFF1F2);
    final actionIconBgGreen = isDarkMode
        ? const Color.fromRGBO(22, 163, 74, 0.2)
        : const Color(0xFFF0FDF4);
    final toggleBg =
        isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final accent =
        isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final inputInner =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    final fullName = _profile?['full_name']?.toString();
    final initial = (fullName != null && fullName.isNotEmpty)
        ? fullName[0].toUpperCase()
        : 'U';

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
              // Top Header
              Container(
                color: topBarBg,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profil Saya',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: textMain,
                      ),
                    ),
                    Row(
                      children: [
                        if (session != null) ...[
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isEditing = !_isEditing),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _isEditing
                                    ? const Color(0xFFEF4444)
                                    : accent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _isEditing
                                    ? FeatherIcons.x
                                    : FeatherIcons.edit2,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
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
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (session != null) ...[
                        // Header Profile Card
                        Container(
                          padding: const EdgeInsets.all(30),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: cardBorder, width: 1),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.2),
                                      offset: Offset(0, 4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                fullName ?? 'Memuat...',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                      56, 189, 248, 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color.fromRGBO(
                                        56, 189, 248, 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  (_profile?['role']?.toString() ??
                                          'user_iqlab')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Info Details Section
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      _isEditing
                                          ? 'Edit Data Profil'
                                          : 'Informasi Detail',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: textMain,
                                      ),
                                    ),
                                  ),
                                  if (_isEditing)
                                    GestureDetector(
                                      onTap: _loading ? null : _handleUpdate,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Simpan',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(24),
                                  border:
                                      Border.all(color: cardBorder, width: 1),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _isEditing
                                    ? Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _EditInput(
                                              label: 'Nama Lengkap',
                                              controller: _fullNameCtrl,
                                              icon: FeatherIcons.user,
                                              textMain: textMain,
                                              textSub: textSub,
                                              inputInner: inputInner,
                                              border: border,
                                              accent: accent,
                                            ),
                                            const SizedBox(height: 16),
                                            _EditInput(
                                              label: 'WhatsApp',
                                              controller: _whatsappCtrl,
                                              icon: FeatherIcons.phone,
                                              keyboardType: TextInputType.phone,
                                              textMain: textMain,
                                              textSub: textSub,
                                              inputInner: inputInner,
                                              border: border,
                                              accent: accent,
                                            ),
                                            const SizedBox(height: 16),
                                            _EditInput(
                                              label: 'Usia',
                                              controller: _ageCtrl,
                                              icon: FeatherIcons.calendar,
                                              keyboardType:
                                                  TextInputType.number,
                                              textMain: textMain,
                                              textSub: textSub,
                                              inputInner: inputInner,
                                              border: border,
                                              accent: accent,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'JENIS KELAMIN',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: textSub,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: ['Ikhwan', 'Akhwat']
                                                  .map((g) {
                                                final selected = _gender == g;
                                                return Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      right: g == 'Ikhwan'
                                                          ? 10
                                                          : 0,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () => setState(
                                                          () => _gender = g),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 12,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: selected
                                                              ? accent
                                                                  .withValues(
                                                                      alpha:
                                                                          0.12)
                                                              : inputInner,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: selected
                                                                ? accent
                                                                : border,
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          g,
                                                          style: TextStyle(
                                                            color: selected
                                                                ? accent
                                                                : textSub,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 16),
                                            _EditInput(
                                              label: 'Alamat',
                                              controller: _addressCtrl,
                                              icon: FeatherIcons.mapPin,
                                              multiline: true,
                                              textMain: textMain,
                                              textSub: textSub,
                                              inputInner: inputInner,
                                              border: border,
                                              accent: accent,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          _DetailItem(
                                            icon: FeatherIcons.mail,
                                            label: 'Email',
                                            value:
                                                session.user.email ?? '-',
                                            bgFull: bgFull,
                                            border: border,
                                            accent: accent,
                                            textMain: textMain,
                                            textSub: textSub,
                                          ),
                                          _DetailItem(
                                            icon: FeatherIcons.phone,
                                            label: 'WhatsApp',
                                            value: _profile?['whatsapp_number']
                                                    ?.toString() ??
                                                '-',
                                            bgFull: bgFull,
                                            border: border,
                                            accent: accent,
                                            textMain: textMain,
                                            textSub: textSub,
                                          ),
                                          _DetailItem(
                                            icon: FeatherIcons.user,
                                            label: 'Jenis Kelamin',
                                            value: _profile?['gender']
                                                    ?.toString() ??
                                                '-',
                                            bgFull: bgFull,
                                            border: border,
                                            accent: accent,
                                            textMain: textMain,
                                            textSub: textSub,
                                          ),
                                          _DetailItem(
                                            icon: FeatherIcons.calendar,
                                            label: 'Usia',
                                            value: _profile?['age'] != null
                                                ? '${_profile!['age']} Tahun'
                                                : '-',
                                            bgFull: bgFull,
                                            border: border,
                                            accent: accent,
                                            textMain: textMain,
                                            textSub: textSub,
                                          ),
                                          _DetailItem(
                                            icon: FeatherIcons.mapPin,
                                            label: 'Alamat',
                                            value: _profile?['address']
                                                    ?.toString() ??
                                                '-',
                                            bgFull: bgFull,
                                            border: border,
                                            accent: accent,
                                            textMain: textMain,
                                            textSub: textSub,
                                            last: true,
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Empty Guest State
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: iconEmptyBg,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  FeatherIcons.userX,
                                  size: 40,
                                  color: textSub,
                                ),
                              ),
                              Text(
                                'Belum Masuk Akun',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Silakan daftar atau masuk untuk menyimpan progres belajar kamu dan mengakses fitur premium.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 24 / 15,
                                    color: textSub,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Menu Aksi Tambahan (Akses Cepat)
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 16),
                              child: Text(
                                'Akses Cepat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textMain,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _handleAuth,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: border, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      margin: const EdgeInsets.only(right: 14),
                                      decoration: BoxDecoration(
                                        color: session != null
                                            ? actionIconBgRed
                                            : actionIconBgGreen,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        session != null
                                            ? FeatherIcons.logOut
                                            : FeatherIcons.userPlus,
                                        size: 18,
                                        color: session != null
                                            ? const Color(0xFFE11D48)
                                            : const Color(0xFF16A34A),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        session != null
                                            ? 'Keluar Akun'
                                            : 'Daftar / Masuk Akun',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: session != null
                                              ? const Color(0xFFE11D48)
                                              : textMain,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      FeatherIcons.chevronRight,
                                      size: 18,
                                      color: textSub,
                                    ),
                                  ],
                                ),
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

class _EditInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final bool multiline;
  final Color textMain;
  final Color textSub;
  final Color inputInner;
  final Color border;
  final Color accent;

  const _EditInput({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.multiline = false,
    required this.textMain,
    required this.textSub,
    required this.inputInner,
    required this.border,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textSub,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: inputInner,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: multiline ? null : 1,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bgFull;
  final Color border;
  final Color accent;
  final Color textMain;
  final Color textSub;
  final bool last;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.bgFull,
    required this.border,
    required this.accent,
    required this.textMain,
    required this.textSub,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(color: border, width: 1),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: bgFull,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accent),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSub,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

