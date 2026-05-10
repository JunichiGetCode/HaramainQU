import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/repositories/ibadah_repository.dart';
import '../../../../data/models/ibadah_progress.dart';
import '../../../panduan_ibadah/presentation/screens/panduan_list_screen.dart';
import '../../../progress_ibadah/presentation/screens/progress_screen.dart';
import '../../../tracking_ibadah/presentation/screens/tracking_screen.dart';
import '../../../doa_dzikir/presentation/screens/doa_screen.dart';
import '../../../kamus_arab/presentation/screens/kamus_screen.dart';
import '../../../reminder/presentation/screens/reminder_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const HomeScreen({super.key, this.userData});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _fadeIn;
  late Animation<double> _fadeAnim;
  final _repo = IbadahRepository();
  List<IbadahProgress> _progress = [];

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeIn, curve: Curves.easeOut);
    _fadeIn.forward();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final p = _repo.getAllProgress();
    if (mounted) setState(() => _progress = p);
  }

  @override
  void dispose() { _fadeIn.dispose(); super.dispose(); }

  String get _userName => widget.userData?['name'] as String? ?? 'Jamaah';

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const TrackingScreen(),
      const DoaScreen(),
      ProfileScreen(userData: widget.userData),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: FadeTransition(opacity: _fadeAnim, child: IndexedStack(index: _navIndex, children: pages)),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda'),
      _NavItem(icon: Icons.touch_app_outlined, activeIcon: Icons.touch_app, label: 'Tracking'),
      _NavItem(icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories, label: 'Doa'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) => _buildNavItem(items[i], i)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index) {
    final selected = index == _navIndex;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _navIndex = index); },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(selected ? item.activeIcon : item.icon, color: selected ? AppColors.accent : AppColors.textMuted, size: 24),
          const SizedBox(height: 4),
          Text(item.label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.accent : AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _buildHomePage() {
    final size = MediaQuery.of(context).size;
    return Stack(children: [
      CustomPaint(painter: const IslamicPatternPainter(opacity: 0.035), size: size),
      CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              _buildGreetingCard(),
              const SizedBox(height: 20),
              _buildProgressSummary(),
              const SizedBox(height: 24),
              _buildSectionTitle('Fitur'),
              const SizedBox(height: 12),
              _buildFeatureGrid(),
              const SizedBox(height: 80),
            ])),
          ),
        ],
      ),
    ]);
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundPrimary,
      elevation: 0, floating: true, pinned: false,
      title: Row(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accentBorder, width: 1)),
          child: const Icon(Icons.mosque, color: AppColors.accent, size: 18)),
        const SizedBox(width: 8),
        Text('HaramainQu', style: AppTextStyles.appBarTitle),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.accent), onPressed: () {}),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildGreetingCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Selamat Pagi' : hour < 15 ? 'Selamat Siang' : hour < 18 ? 'Selamat Sore' : 'Selamat Malam';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E3562), AppColors.backgroundCard]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$greeting! 👋', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(_userName, style: AppTextStyles.h2.copyWith(color: AppColors.textGold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3))),
            child: Text('☪ Pendamping Ibadah Umroh', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentTealLight)),
          ),
        ])),
        const SizedBox(width: 12),
        Container(width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accentLight, AppColors.accent]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]),
          child: const Icon(Icons.person, color: AppColors.textDark, size: 28)),
      ]),
    );
  }

  Widget _buildProgressSummary() {
    final done = _progress.where((p) => p.status == IbadahStatus.selesai).length;
    final total = _progress.isEmpty ? 5 : _progress.length;
    final pct = total > 0 ? done / total : 0.0;

    return GlassCard(
      child: Row(children: [
        SizedBox(width: 64, height: 64,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 64, height: 64,
              child: CircularProgressIndicator(value: pct, strokeWidth: 5,
                backgroundColor: AppColors.backgroundSecondary,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent))),
            Text('${(pct * 100).toInt()}%', style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent, fontSize: 16)),
          ])),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Progress Umroh', style: AppTextStyles.h4),
          const SizedBox(height: 4),
          Text('$done dari $total ibadah selesai', style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Row(children: [
            _statusDot(AppColors.statusSelesai, '${_progress.where((p) => p.status == IbadahStatus.selesai).length} Selesai'),
            const SizedBox(width: 12),
            _statusDot(AppColors.statusSedang, '${_progress.where((p) => p.status == IbadahStatus.sedang).length} Sedang'),
          ]),
        ])),
      ]),
    );
  }

  Widget _statusDot(Color color, String label) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.labelSmall),
    ]);
  }

  Widget _buildSectionTitle(String title) {
    return Row(children: [
      Container(width: 3, height: 18,
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.accentLight, AppColors.accent]),
          borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.h4),
    ]);
  }

  Widget _buildFeatureGrid() {
    final features = [
      const _Feature(icon: Icons.menu_book, label: 'Panduan\nIbadah', color: AppColors.accent, screen: PanduanListScreen()),
      const _Feature(icon: Icons.checklist, label: 'Progress\nIbadah', color: AppColors.accentTeal, screen: ProgressScreen()),
      const _Feature(icon: Icons.touch_app, label: 'Tracking\nIbadah', color: AppColors.info, screen: TrackingScreen(), isMain: true),
      const _Feature(icon: Icons.auto_stories, label: 'Doa &\nDzikir', color: AppColors.success, screen: DoaScreen()),
      const _Feature(icon: Icons.translate, label: 'Kamus\nArab', color: AppColors.warning, screen: KamusScreen()),
      const _Feature(icon: Icons.alarm, label: 'Reminder\nIbadah', color: AppColors.danger, screen: ReminderScreen()),
    ];

    return GridView.count(
      crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,
      children: features.map((f) => _buildFeatureCard(f)).toList(),
    );
  }

  Widget _buildFeatureCard(_Feature f) {
    return GestureDetector(
      onTap: () { HapticFeedback.mediumImpact(); Navigator.push(context, MaterialPageRoute(builder: (_) => f.screen)); },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: f.isMain ? f.color.withValues(alpha: 0.5) : f.color.withValues(alpha: 0.2)),
          boxShadow: f.isMain ? [BoxShadow(color: f.color.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: f.color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(f.icon, color: f.color, size: 24)),
          const SizedBox(height: 8),
          Text(f.label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary, height: 1.3, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          if (f.isMain) ...[
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: f.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
              child: Text('UTAMA', style: TextStyle(fontFamily: 'Poppins', fontSize: 8, fontWeight: FontWeight.w700, color: f.color, letterSpacing: 0.5))),
          ],
        ]),
      ),
    );
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _Feature {
  final IconData icon;
  final String label;
  final Color color;
  final Widget screen;
  final bool isMain;
  const _Feature({required this.icon, required this.label, required this.color, required this.screen, this.isMain = false});
}
