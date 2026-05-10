import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/ibadah_step.dart';
import '../../../../data/repositories/ibadah_repository.dart';

class PanduanDetailScreen extends StatefulWidget {
  final String stepId;
  const PanduanDetailScreen({super.key, required this.stepId});
  @override
  State<PanduanDetailScreen> createState() => _PanduanDetailScreenState();
}

class _PanduanDetailScreenState extends State<PanduanDetailScreen> {
  final _repo = IbadahRepository();
  IbadahStep? _step;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final s = await _repo.getPanduanDetail(widget.stepId);
    if (mounted) setState(() { _step = s; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Text(_step?.title ?? 'Detail', style: AppTextStyles.appBarTitle),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : _step == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: _step!.details.length + 2,
              itemBuilder: (ctx, i) {
                if (i == 0) return _buildHeader();
                if (i == _step!.details.length + 1) return const SizedBox(height: 40);
                return _buildDetailCard(_step!.details[i - 1]);
              },
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1E3562), AppColors.backgroundCard]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(_step!.icon, color: AppColors.accent, size: 30)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_step!.title, style: AppTextStyles.h2.copyWith(color: AppColors.textGold)),
          const SizedBox(height: 4),
          Text(_step!.subtitle, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text('${_step!.details.length} langkah', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentTealLight)),
        ])),
      ]),
    );
  }

  Widget _buildDetailCard(StepDetail detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 30, height: 30,
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text('${detail.number}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.w800))),
          const SizedBox(width: 12),
          Expanded(child: Text(detail.title, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary))),
        ]),
        const SizedBox(height: 12),
        Text(detail.description, style: AppTextStyles.bodySmall.copyWith(height: 1.6)),
        if (detail.arabicText != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
            child: Text(detail.arabicText!, textAlign: TextAlign.center, textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'serif', fontSize: 22, color: AppColors.textPrimary, height: 2.0))),
        ],
        if (detail.translation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(10),
              border: const Border(left: BorderSide(color: AppColors.accent, width: 3))),
            child: Text(detail.translation!, style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, height: 1.5))),
        ],
      ]),
    );
  }
}
