import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/kamus_entry.dart';
import '../../../../data/repositories/kamus_repository.dart';

class KamusScreen extends StatefulWidget {
  const KamusScreen({super.key});
  @override
  State<KamusScreen> createState() => _KamusScreenState();
}

class _KamusScreenState extends State<KamusScreen> {
  final _repo = KamusRepository();
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCat = 'sapaan';
  List<KamusEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _repo.getEntries(
      category: _query.isNotEmpty ? null : _selectedCat,
      search: _query.isNotEmpty ? _query : null,
    );
    if (mounted) setState(() { _entries = entries; _loading = false; });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Kamus Bahasa Arab', style: AppTextStyles.appBarTitle),
          Text('قَامُوس عَرَبِي', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
        ])),
      body: Column(children: [
        _buildSearchBar(),
        _buildCategoryTabs(),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _entries.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.search_off, size: 56, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text('Tidak ditemukan', style: AppTextStyles.bodySmall)]))
            : _buildGrid()),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.backgroundSecondary,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(controller: _searchCtrl, style: AppTextStyles.bodyMedium,
        onChanged: (v) { _query = v; _load(); },
        decoration: InputDecoration(
          hintText: 'Cari kata Arab atau artinya...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          suffixIcon: _query.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                onPressed: () { _searchCtrl.clear(); _query = ''; _load(); })
            : null)),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.backgroundSecondary,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: _repo.categories.map((c) {
          final isActive = _selectedCat == c['id'] && _query.isEmpty;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _searchCtrl.clear();
              _query = ''; _selectedCat = c['id']!;
              _load();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppColors.backgroundPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: isActive ? AppColors.accent : AppColors.border)),
              child: Text(c['label']!, style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400))),
          );
        }).toList()),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3),
      itemCount: _entries.length,
      itemBuilder: (ctx, i) {
        final e = _entries[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(e.indonesian, style: AppTextStyles.labelMedium, textAlign: TextAlign.left)),
              const SizedBox(width: 8),
              Text(e.arabic, textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 20, color: AppColors.textPrimary, height: 1.4)),
            ]),
            const Spacer(),
            Text(e.latin, style: AppTextStyles.labelSmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
          ]),
        );
      },
    );
  }
}
