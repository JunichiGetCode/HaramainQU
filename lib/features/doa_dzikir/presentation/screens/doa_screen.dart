import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/doa_model.dart';
import '../../../../data/repositories/doa_repository.dart';

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});
  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
  final _repo = DoaRepository();
  String _selectedCat = 'semua';
  int? _expandedIdx;
  List<DoaModel> _doaList = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final list = await _repo.getDoaList(category: _selectedCat == 'semua' ? null : _selectedCat);
    if (mounted) setState(() { _doaList = list; _loading = false; });
  }

  void _changeCategory(String cat) {
    setState(() { _selectedCat = cat; _expandedIdx = null; _loading = true; });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Doa & Dzikir', style: AppTextStyles.appBarTitle),
          Text('أَدْعِيَةٌ وَأَذْكَار', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
        ])),
      body: Column(children: [
        _buildCategoryFilter(),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _buildDoaList()),
      ]),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: AppColors.backgroundSecondary,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: _repo.categories.map((c) {
          final isActive = _selectedCat == c['id'];
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); _changeCategory(c['id']!); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: isActive ? AppColors.accent : AppColors.border)),
              child: Text(c['label']!, style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.textDark : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400))),
          );
        }).toList()),
      ),
    );
  }

  Widget _buildDoaList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _doaList.length,
      itemBuilder: (ctx, i) {
        final d = _doaList[i];
        final isOpen = _expandedIdx == i;
        return _buildDoaCard(d, i, isOpen);
      },
    );
  }

  Widget _buildDoaCard(DoaModel d, int idx, bool isOpen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOpen ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expandedIdx = isOpen ? null : idx),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isOpen ? 0 : 20), bottomRight: Radius.circular(isOpen ? 0 : 20)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0D1130), Color(0xFF283375)]),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isOpen ? 0 : 20), bottomRight: Radius.circular(isOpen ? 0 : 20))),
            child: Row(children: [
              Container(width: 30, height: 30,
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text('${d.id}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              Expanded(child: Text(d.title, style: AppTextStyles.labelLarge.copyWith(color: Colors.white))),
              AnimatedRotation(turns: isOpen ? 0.5 : 0, duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down, color: isOpen ? AppColors.accent : Colors.white54)),
            ]))),
        if (isOpen)
          Padding(padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.2))),
                child: Text(d.arabic, textAlign: TextAlign.center, textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'serif', fontSize: 26, color: AppColors.textPrimary, height: 2.2))),
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(12),
                  border: const Border(left: BorderSide(color: AppColors.accent, width: 3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('LATIN', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(d.latin, style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.textSecondary, height: 1.6)),
                ])),
              const SizedBox(height: 10),
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ARTINYA', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(d.translation, style: AppTextStyles.bodySmall.copyWith(height: 1.6)),
                ])),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: d.latin));
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Latin tersalin!'), backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.accentLight, AppColors.accent]),
                    borderRadius: BorderRadius.circular(50)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.copy_rounded, color: AppColors.textDark, size: 16), const SizedBox(width: 6),
                    Text('Salin Latin', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700)),
                  ]))),
            ])),
      ]),
    );
  }
}
