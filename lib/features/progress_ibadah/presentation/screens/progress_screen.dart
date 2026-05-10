import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/ibadah_progress.dart';
import '../../../../data/repositories/ibadah_repository.dart';
import '../../../../core/services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _repo = IbadahRepository();
  List<IbadahProgress> _progress = [];
  bool _loading = true;
  int _durasiHari = 9;
  int _selectedDay = 1;

  final _ibadahInfo = {
    'persiapan': {'title': 'Persiapan', 'icon': Icons.checklist},
    'perjalanan': {'title': 'Perjalanan ke Tanah Suci', 'icon': Icons.flight},
    'miqat': {'title': 'Menuju Miqat', 'icon': Icons.directions_bus},
    'ihram': {'title': 'Ihram', 'icon': Icons.checkroom},
    'tawaf': {'title': 'Tawaf', 'icon': Icons.refresh},
    'sai': {'title': "Sa'i", 'icon': Icons.directions_walk},
    'shalat_maqam': {'title': 'Shalat Maqam Ibrahim', 'icon': Icons.mosque},
    'tahallul': {'title': 'Tahallul', 'icon': Icons.content_cut},
    'tahajud': {'title': 'Shalat Tahajud', 'icon': Icons.nights_stay},
    'shalat_jamaah': {'title': 'Shalat Fardhu Berjamaah', 'icon': Icons.people},
    'tilawah': {'title': 'Tilawah Al-Quran', 'icon': Icons.menu_book},
    'tawaf_sunnah': {'title': 'Tawaf Sunnah', 'icon': Icons.sync},
    'sedekah': {'title': 'Sedekah', 'icon': Icons.volunteer_activism},
  };

  @override
  void initState() { 
    super.initState(); 
    final userData = StorageService().getUserData();
    if (userData != null && userData['durasi_hari'] != null) {
      _durasiHari = userData['durasi_hari'];
    }
    _load(_selectedDay); 
  }

  Future<void> _load(int hari) async {
    setState(() => _loading = true);
    final p = await _repo.getProgress(hari);
    if (mounted) setState(() { _progress = p; _loading = false; });
  }

  double get _overallProgress {
    if (_progress.isEmpty) return 0;
    final done = _progress.where((p) => p.status == IbadahStatus.selesai).length;
    return done / _progress.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Text('Progress Ibadah', style: AppTextStyles.appBarTitle)),
      body: Column(children: [
        // Horizontal Day Selector
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _durasiHari,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == _selectedDay;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDay = day);
                  _load(day);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.accent : AppColors.accent.withValues(alpha: 0.2)),
                    boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8)] : null,
                  ),
                  child: Center(child: Text('Hari $day', style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? AppColors.textDark : AppColors.textGold,
                  ))),
                ),
              );
            },
          ),
        ),
        
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(20), children: [
                _buildOverallProgress(),
                const SizedBox(height: 24),
                ..._progress.map((p) => _buildProgressItem(p)),
                const SizedBox(height: 40),
              ]),
        ),
      ]),
    );
  }

  Widget _buildOverallProgress() {
    final pct = _overallProgress;
    final done = _progress.where((p) => p.status == IbadahStatus.selesai).length;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1E3562), AppColors.backgroundCard]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
      child: Column(children: [
        SizedBox(width: 100, height: 100,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 100, height: 100,
              child: CircularProgressIndicator(value: pct, strokeWidth: 8,
                backgroundColor: AppColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation(pct >= 1.0 ? AppColors.statusSelesai : AppColors.accent))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(pct * 100).toInt()}%', style: AppTextStyles.h1.copyWith(color: AppColors.accent)),
              Text('Selesai', style: AppTextStyles.labelSmall),
            ]),
          ])),
        const SizedBox(height: 16),
        Text('$done dari ${_progress.length} aktivitas selesai', style: AppTextStyles.bodyMedium),
        if (pct >= 1.0) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.statusSelesai.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('🎉 Alhamdulillah!', style: AppTextStyles.labelMedium.copyWith(color: AppColors.statusSelesai))),
        ],
      ]),
    );
  }

  Widget _buildProgressItem(IbadahProgress p) {
    final info = _ibadahInfo[p.ibadahId];
    final title = info?['title'] as String? ?? p.ibadahId;
    final icon = info?['icon'] as IconData? ?? Icons.check_circle;
    final statusColor = switch (p.status) {
      IbadahStatus.belum => AppColors.statusBelum,
      IbadahStatus.sedang => AppColors.statusSedang,
      IbadahStatus.selesai => AppColors.statusSelesai,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            HapticFeedback.mediumImpact();
            p.nextStatus();
            await _repo.updateProgress(p);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.3))),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: statusColor, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(p.statusLabel, style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w600))),
              ])),
              Icon(
                p.status == IbadahStatus.selesai ? Icons.check_circle : p.status == IbadahStatus.sedang ? Icons.timelapse : Icons.radio_button_unchecked,
                color: statusColor, size: 28),
            ]),
          ),
        ),
      ),
    );
  }
}
