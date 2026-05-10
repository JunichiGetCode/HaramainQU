import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../data/models/ibadah_step.dart';
import '../../../../data/repositories/ibadah_repository.dart';
import 'panduan_detail_screen.dart';

class PanduanListScreen extends StatefulWidget {
  const PanduanListScreen({super.key});
  @override
  State<PanduanListScreen> createState() => _PanduanListScreenState();
}

class _PanduanListScreenState extends State<PanduanListScreen> {
  final _repo = IbadahRepository();
  List<IbadahStep> _steps = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final s = await _repo.getPanduanList();
    if (mounted) setState(() { _steps = s; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Panduan Ibadah Umroh', style: AppTextStyles.appBarTitle),
          Text('دَلِيلُ العُمْرَة', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
        ]),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : Stack(children: [
            CustomPaint(painter: const IslamicPatternPainter(opacity: 0.03), size: MediaQuery.of(context).size),
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: _steps.length + 1,
              itemBuilder: (ctx, i) {
                if (i == _steps.length) return const SizedBox(height: 40);
                return _buildStepCard(_steps[i], i);
              },
            ),
          ]),
    );
  }

  Widget _buildStepCard(IbadahStep step, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => PanduanDetailScreen(stepId: step.id)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Timeline dot + line
          Column(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.accentLight, AppColors.accent]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Center(child: Text('${index + 1}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)))),
            if (index < _steps.length - 1)
              Container(width: 2, height: 60, margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.accent.withValues(alpha: 0.6), AppColors.accent.withValues(alpha: 0.1)]))),
          ]),
          const SizedBox(width: 16),
          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(step.title, style: AppTextStyles.h4.copyWith(color: AppColors.textGold)),
                  const SizedBox(height: 4),
                  Text(step.subtitle, style: AppTextStyles.bodySmall),
                ])),
                Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(step.icon, color: AppColors.accent, size: 22)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
