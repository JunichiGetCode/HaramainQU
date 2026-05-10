import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/haramainqu_logo.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _remember = false;
  String? _error;
  late AnimationController _entryCtrl;
  late Animation<Offset> _formSlide, _logoSlide;
  late Animation<double> _formFade, _logoFade;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _logoFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: const Interval(0, 0.5, curve: Curves.easeOut)));
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.3, 1, curve: Curves.easeOut)));
    _formFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.3, 0.9, curve: Curves.easeOut)));
    Future.delayed(const Duration(milliseconds: 100), () { if (mounted) _entryCtrl.forward(); });
  }

  @override
  void dispose() { _entryCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    HapticFeedback.mediumImpact();

    final result = await _api.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    
    if (result['success'] == true) {
      // Check profile
      final profileResult = await _api.getProfile();
      if (!mounted) return;
      setState(() => _loading = false);

      if (profileResult['success'] == true) {
        final pendaftaran = profileResult['pendaftaran'];
        final userRole = profileResult['user']?['role'];
        final isAdmin = userRole == 'admin' || userRole == 'superadmin';

        if (pendaftaran != null || isAdmin) {
          final storage = StorageService();
          final durasi = pendaftaran?['paket']?['durasi_hari'] ?? 9;
          await storage.saveUserData({
            ...(profileResult['user'] as Map<String, dynamic>),
            'durasi_hari': durasi,
          });

          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(userData: profileResult['user'] as Map<String, dynamic>?),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ));
        } else {
          await _api.logout();
          setState(() => _error = 'Anda belum memiliki paket ibadah aktif.');
          HapticFeedback.heavyImpact();
        }
      } else {
        await _api.logout();
        setState(() => _error = 'Gagal memuat profil. Coba lagi.');
        HapticFeedback.heavyImpact();
      }
    } else {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = result['message'] as String? ?? 'Login gagal. Coba lagi.';
      });
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final kbVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      resizeToAvoidBottomInset: true,
      body: Stack(fit: StackFit.expand, children: [
        Container(decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), AppColors.backgroundPrimary, AppColors.backgroundSecondary],
        ))),
        CustomPaint(painter: const IslamicPatternPainter(opacity: 0.055), size: size),
        Positioned(top: -size.width * 0.3, left: -size.width * 0.2,
          child: Container(width: size.width * 1.4, height: size.width * 0.8,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.accent.withValues(alpha: 0.06), Colors.transparent])))),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
              child: IntrinsicHeight(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SizedBox(height: kbVisible ? 20 : 48),
                  SlideTransition(position: _logoSlide, child: FadeTransition(opacity: _logoFade,
                    child: Column(children: [
                      const HaramainQuLogo(size: 80),
                      const SizedBox(height: 14),
                      Text('HaramainQu', style: AppTextStyles.brandName.copyWith(fontSize: 36, letterSpacing: 3,
                        shadows: const [Shadow(color: AppColors.accent, blurRadius: 16)])),
                      const SizedBox(height: 4),
                      Text(AppConstants.appTagline, style: AppTextStyles.tagline, textAlign: TextAlign.center),
                    ]),
                  )),
                  SizedBox(height: kbVisible ? 16 : 32),
                  SlideTransition(position: _formSlide, child: FadeTransition(opacity: _formFade, child: _buildLoginCard())),
                  const Spacer(),
                  FadeTransition(opacity: _formFade, child: _buildFooter()),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 10)),
          BoxShadow(color: AppColors.accent.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: -4),
        ],
      ),
      child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(width: 4, height: 24, decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.accentLight, AppColors.accent]),
            borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text('Masuk ke Akun', style: AppTextStyles.h3),
        ]),
        const SizedBox(height: 6),
        Padding(padding: const EdgeInsets.only(left: 14),
          child: Text('Gunakan akun Haramain Tour Anda', style: AppTextStyles.bodySmall)),
        const SizedBox(height: 20),
        if (_error != null) ...[
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3))),
            child: Row(children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 18), const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger))),
            ])),
          const SizedBox(height: 16),
        ],
        TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: AppTextStyles.bodyMedium,
          validator: (v) { if (v == null || v.isEmpty) return 'Email tidak boleh kosong'; if (!v.contains('@')) return 'Format email tidak valid'; return null; },
          decoration: const InputDecoration(labelText: 'Email', hintText: 'contoh@email.com', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20))),
        const SizedBox(height: 16),
        TextFormField(controller: _passCtrl, obscureText: _obscure, style: AppTextStyles.bodyMedium,
          validator: (v) { if (v == null || v.isEmpty) return 'Password tidak boleh kosong'; if (v.length < 4) return 'Password minimal 4 karakter'; return null; },
          decoration: InputDecoration(labelText: 'Password', hintText: 'Masukkan password',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
            suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure)))),
        const SizedBox(height: 14),
        Row(children: [
          SizedBox(width: 24, height: 24, child: Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
          const SizedBox(width: 8),
          Text('Ingat saya', style: AppTextStyles.bodySmall),
          const Spacer(),
          TextButton(onPressed: () {}, style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text('Lupa password?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 24),
        _buildLoginButton(),
      ])),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
        gradient: _loading ? null : const LinearGradient(colors: [AppColors.accentLight, AppColors.accent]),
        color: _loading ? AppColors.backgroundSecondary : null,
        boxShadow: _loading ? null : [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Material(color: Colors.transparent,
        child: InkWell(onTap: _loading ? null : _handleLogin, borderRadius: BorderRadius.circular(12),
          child: Container(height: 52, alignment: Alignment.center,
            child: _loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent)))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.login_rounded, color: AppColors.textDark, size: 20), const SizedBox(width: 8),
                  Text('Masuk', style: AppTextStyles.buttonPrimary.copyWith(letterSpacing: 0.8)),
                ])))),
    );
  }

  Widget _buildFooter() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.help_outline, size: 14, color: AppColors.textMuted), const SizedBox(width: 4),
        Text('Gunakan akun yang sama seperti web Haramain Tour', style: AppTextStyles.labelSmall),
      ]),
      const SizedBox(height: 12),
      Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 40), color: AppColors.divider),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Powered by ', style: AppTextStyles.labelSmall),
        Text(AppConstants.companyName, style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      Text('v${AppConstants.appVersion}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
    ]);
  }
}
