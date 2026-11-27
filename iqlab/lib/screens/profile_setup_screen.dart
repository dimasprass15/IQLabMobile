import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/supabase_client.dart';
import '../services/profile_service.dart';

/// Exact 1:1 replica of `src/screens/ProfileSetupScreen.js`
class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onProfileComplete;

  const ProfileSetupScreen({
    super.key,
    required this.onProfileComplete,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  bool _loading = false;
  final _fullNameCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Ikhwan';

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _whatsappCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _showAlert(String title, String message, {VoidCallback? onOk}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onOk?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final fullName = _fullNameCtrl.text.trim();
    final whatsapp = _whatsappCtrl.text.trim();
    final age = _ageCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (fullName.isEmpty ||
        whatsapp.isEmpty ||
        age.isEmpty ||
        address.isEmpty) {
      _showAlert('Eitss!', 'Mohon isi semua data ya Kak 😊');
      return;
    }

    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      await ProfileService.createProfile(
        id: user.id,
        fullName: fullName,
        whatsappNumber: whatsapp,
        age: age,
        gender: _gender,
        address: address,
      );

      if (!mounted) return;
      _showAlert(
        'Alhamdulillah!',
        'Profil Kakak sudah berhasil disimpan.',
        onOk: widget.onProfileComplete,
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (!mounted) return;
      _showAlert('Waduh!', 'Gagal menyimpan profil. Coba lagi ya.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0F172A),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ahlan wa Sahlan!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Yuk, lengkapi profil Kakak dulu untuk mulai belajar.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(30, 41, 59, 0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel('Nama Lengkap'),
                        _buildInput(
                          controller: _fullNameCtrl,
                          placeholder: 'Contoh: Dimas Prass',
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Nomor WhatsApp'),
                        _buildInput(
                          controller: _whatsappCtrl,
                          placeholder: 'Contoh: 08123456789',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Usia'),
                        _buildInput(
                          controller: _ageCtrl,
                          placeholder: 'Berapa umur Kakak?',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Jenis Kelamin'),
                        Row(
                          children: ['Ikhwan', 'Akhwat'].map((g) {
                            final active = _gender == g;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: g == 'Ikhwan' ? 12 : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () => setState(() => _gender = g),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? const Color.fromRGBO(
                                              56, 189, 248, 0.1)
                                          : const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: active
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFF334155),
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      g,
                                      style: TextStyle(
                                        color: active
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Tempat Tinggal'),
                        _buildInput(
                          controller: _addressCtrl,
                          placeholder: 'Alamat singkat Kakak...',
                          multiline: true,
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: _loading ? null : _handleSave,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(56, 189, 248, 0.3),
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Simpan & Lanjut',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
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
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    bool multiline = false,
  }) {
    return Container(
      height: multiline ? 100 : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: multiline ? 4 : 1,
        style: const TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

