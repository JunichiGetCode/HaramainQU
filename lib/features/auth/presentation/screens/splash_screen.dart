import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/haramainqu_logo.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _loadingController;
  late Animation<double> _logoFade, _logoScale, _textFade, _taglineFade;
  late Animation<double> _loadingFade, _loadingProgress;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _loadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _logoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: const Interval(0, 0.7, curve: Curves.elasticOut)));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: const Interval(0, 0.8, curve: Curves.easeOut)));
    _textFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _slideController, curve: const Interval(0, 0.7, curve: Curves.easeOut)));
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _slideController, curve: const Interval(0.3, 1, curve: Curves.easeOut)));
    _loadingFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _loadingController, curve: const Interval(0, 0.3, curve: Curves.easeOut)));
    _loadingProgress = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _loadingController, curve: const Interval(0.1, 0.9, curve: Curves.easeInOut)));

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _loadingController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final api = ApiService();
    Widget destination;

    if (api.isLoggedIn) {
      try {
        final result = await api.getProfile();
        if (result['success'] == true) {
          final pendaftaran = result['pendaftaran'];
          final userRole = result['user']?['role'];
          final isAdmin = userRole == 'admin' || userRole == 'superadmin';

          if (pendaftaran != null || isAdmin) {
            // Save durasi_hari and user data
            final storage = StorageService();
            final durasi = pendaftaran?['paket']?['durasi_hari'] ?? 9;
            await storage.saveUserData({
              ...result['user'],
              'durasi_hari': durasi,
            });
            destination = HomeScreen(userData: result['user'] as Map<String, dynamic>?);
          } else {
            // Logged in but no active package
            await api.logout();
            destination = const LoginScreen();
          }
        } else {
          destination = const LoginScreen();
        }
      } catch (_) {
        destination = const LoginScreen();
      }
    } else {
      destination = const LoginScreen();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(fit: StackFit.expand, children: [
        Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
        CustomPaint(painter: const IslamicPatternPainter(opacity: 0.05), size: size),
        ..._buildStarParticles(size),
        SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Spacer(flex: 2),
            AnimatedBuilder(
              animation: _fadeController,
              builder: (_, __) => FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(scale: _logoScale, child: const AnimatedHaramainQuLogo(size: 130)),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _slideController,
              builder: (_, __) => SlideTransition(
                position: _textSlide,
                child: Column(children: [
                  FadeTransition(
                    opacity: _textFade,
                    child: Text('HaramainQu', style: AppTextStyles.brandName.copyWith(
                      fontSize: 44, letterSpacing: 3,
                      shadows: const [Shadow(color: AppColors.accent, blurRadius: 20)],
                    )),
                  ),
                  const SizedBox(height: 6),
                  FadeTransition(
                    opacity: _textFade,
                    child: Text('Pendamping Ibadah Umroh', style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary, fontWeight: FontWeight.w400, letterSpacing: 1.5,
                    )),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(AppConstants.appTagline, style: AppTextStyles.tagline.copyWith(fontSize: 12, letterSpacing: 0.5), textAlign: TextAlign.center),
                    ),
                  ),
                ]),
              ),
            ),
            const Spacer(flex: 2),
            AnimatedBuilder(
              animation: _loadingController,
              builder: (_, __) => FadeTransition(
                opacity: _loadingFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: _loadingProgress.value,
                        backgroundColor: AppColors.backgroundCard,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_loadingText(_loadingProgress.value), style: AppTextStyles.labelSmall),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _taglineFade,
              child: Text('Powered by ${AppConstants.companyName}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ]),
    );
  }

  String _loadingText(double p) {
    if (p < 0.3) return 'Memuat data...';
    if (p < 0.6) return 'Menyiapkan layanan...';
    if (p < 0.9) return 'Hampir selesai...';
    return 'Bismillah! ✨';
  }

  List<Widget> _buildStarParticles(Size size) {
    const positions = [
      Offset(0.1, 0.08), Offset(0.85, 0.12), Offset(0.3, 0.05),
      Offset(0.7, 0.18), Offset(0.5, 0.03), Offset(0.15, 0.25),
      Offset(0.9, 0.3), Offset(0.05, 0.55), Offset(0.95, 0.6),
      Offset(0.2, 0.78), Offset(0.8, 0.82), Offset(0.45, 0.92),
    ];
    return positions.map((pos) => Positioned(
      left: pos.dx * size.width, top: pos.dy * size.height,
      child: _StarDot(delay: (pos.dx * 2000).toInt()),
    )).toList();
  }
}

class _StarDot extends StatefulWidget {
  final int delay;
  const _StarDot({required this.delay});
  @override
  State<_StarDot> createState() => _StarDotState();
}

class _StarDotState extends State<_StarDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 1500 + widget.delay % 1000))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay % 1500), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value * 0.6,
        child: Container(
          width: 3, height: 3,
          decoration: BoxDecoration(
            color: AppColors.accent, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.5 * _anim.value), blurRadius: 6, spreadRadius: 1)],
          ),
        ),
      ),
    );
  }
}
