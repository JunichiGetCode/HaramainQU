import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../data/models/ibadah_progress.dart';
import '../../../../data/repositories/ibadah_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfileScreen({super.key, this.userData});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  final _storage = StorageService();
  final _repo = IbadahRepository();
  List<IbadahProgress> _progress = [];
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _name = widget.userData?['name'] as String? ?? 'Jamaah';
    _email = widget.userData?['email'] as String? ?? '-';
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final p = _repo.getAllProgress();
    if (mounted) setState(() => _progress = p);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: Text('Logout', style: AppTextStyles.h4),
      content: Text('Yakin ingin keluar?', style: AppTextStyles.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Logout', style: TextStyle(color: Colors.white))),
      ]));

    if (confirm != true || !mounted) return;
    await _api.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: Text('Reset Data', style: AppTextStyles.h4),
      content: Text('Semua progress, tracking, dan reminder akan dihapus. Lanjutkan?', style: AppTextStyles.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Reset', style: TextStyle(color: Colors.white))),
      ]));

    if (confirm != true || !mounted) return;
    await _storage.clearAll();
    _loadProgress();
    HapticFeedback.heavyImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Data berhasil direset'), backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  @override
  Widget build(BuildContext context) {
    final done = _progress.where((p) => p.status == IbadahStatus.selesai).length;
    final inProg = _progress.where((p) => p.status == IbadahStatus.sedang).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Text('Profil', style: AppTextStyles.appBarTitle)),
      body: ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(20), children: [
        // Profile header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1E3562), AppColors.backgroundCard]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
          child: Column(children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.accentLight, AppColors.accent]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 16)]),
              child: const Icon(Icons.person, color: AppColors.textDark, size: 40)),
            const SizedBox(height: 16),
            Text(_name, style: AppTextStyles.h2.copyWith(color: AppColors.textGold)),
            const SizedBox(height: 4),
            Text(_email, style: AppTextStyles.bodySmall),
          ])),
        const SizedBox(height: 20),

        // Stats
        Row(children: [
          Expanded(child: _statCard('$done', 'Selesai', AppColors.statusSelesai)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('$inProg', 'Sedang', AppColors.statusSedang)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('${_progress.length}', 'Total', AppColors.accent)),
        ]),
        const SizedBox(height: 24),

        // Progress history
        _buildSectionTitle('Riwayat Progress'),
        const SizedBox(height: 12),
        ..._progress.map(_buildProgressRow),
        const SizedBox(height: 24),

        // Settings
        _buildSectionTitle('Pengaturan'),
        const SizedBox(height: 12),
        _settingItem(Icons.edit, 'Edit Profil', () {}),
        _settingItem(Icons.info_outline, 'Tentang Aplikasi', () => _showAbout()),
        _settingItem(Icons.delete_outline, 'Reset Data', _resetData, danger: true),
        _settingItem(Icons.logout, 'Logout', _logout, danger: true),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall),
      ]));
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

  Widget _buildProgressRow(IbadahProgress p) {
    final titles = {'ihram': 'Ihram', 'tawaf': 'Tawaf', 'sai': "Sa'i", 'shalat_maqam': 'Shalat Maqam', 'tahallul': 'Tahallul'};
    final color = switch (p.status) {
      IbadahStatus.belum => AppColors.statusBelum,
      IbadahStatus.sedang => AppColors.statusSedang,
      IbadahStatus.selesai => AppColors.statusSelesai,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(p.status == IbadahStatus.selesai ? Icons.check_circle : Icons.circle_outlined, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(titles[p.ibadahId] ?? p.ibadahId, style: AppTextStyles.bodySmall)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(p.statusLabel, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600))),
      ]));
  }

  Widget _settingItem(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(children: [
            Icon(icon, color: color, size: 22), const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color))),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ]))));
  }

  void _showAbout() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: Text('Tentang HaramainQu', style: AppTextStyles.h4),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Versi ${AppConstants.appVersion}', style: AppTextStyles.bodySmall),
        const SizedBox(height: 8),
        Text('Aplikasi pendamping ibadah umroh oleh ${AppConstants.companyName}.', style: AppTextStyles.bodySmall),
        const SizedBox(height: 8),
        Text('Fitur: Panduan, Progress, Tracking, Doa, Kamus, Reminder.', style: AppTextStyles.bodySmall),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))]));
  }
}
