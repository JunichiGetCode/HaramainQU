import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/tracking_counter.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/api_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  final _storage = StorageService();
  final _api = ApiService();

  late TrackingCounter _tawaf, _sai, _dzikir;
  int _durasiHari = 9;
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    final userData = _storage.getUserData();
    if (userData != null && userData['durasi_hari'] != null) {
      _durasiHari = userData['durasi_hari'];
    }
    _loadCounters(_selectedDay);
  }

  void _loadCounters(int day) {
    final t = _storage.getTracking('tawaf_$day');
    final s = _storage.getTracking('sai_$day');
    final d = _storage.getTracking('dzikir_$day');
    _tawaf = t != null ? TrackingCounter.fromJson(t) : TrackingCounter(type: 'tawaf', hariKe: day, target: AppConstants.tawafTotal);
    _sai = s != null ? TrackingCounter.fromJson(s) : TrackingCounter(type: 'sai', hariKe: day, target: AppConstants.saiTotal);
    _dzikir = d != null ? TrackingCounter.fromJson(d) : TrackingCounter(type: 'dzikir', hariKe: day, target: AppConstants.defaultDzikirTarget);
  }

  Future<void> _save(TrackingCounter c) async {
    await _storage.saveTracking('${c.type}_${c.hariKe}', c.toJson());
    try { await _api.saveTrackingData(type: c.type, current: c.current, target: c.target); } catch (_) {}
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Text('Tracking Ibadah', style: AppTextStyles.appBarTitle)),
      body: Column(
        children: [
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
                    setState(() {
                      _selectedDay = day;
                      _loadCounters(day);
                    });
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
          
          TabBar(controller: _tabCtrl,
            indicatorColor: AppColors.accent, indicatorWeight: 3,
            labelColor: AppColors.accent, unselectedLabelColor: AppColors.textMuted,
            labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Tawaf'), Tab(text: "Sa'i"), Tab(text: 'Dzikir')]),
            
          Expanded(
            child: TabBarView(controller: _tabCtrl, children: [
              _buildCounterPage(_tawaf, 'Tawaf', 'Putaran mengelilingi Ka\'bah', Icons.refresh),
              _buildCounterPage(_sai, "Sa'i", 'Perjalanan Safa ↔ Marwah', Icons.directions_walk),
              _buildDzikirPage(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterPage(TrackingCounter counter, String title, String subtitle, IconData icon) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Text(title, style: AppTextStyles.h2.copyWith(color: AppColors.textGold)),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.bodySmall),
        const SizedBox(height: 40),
        // Circular counter
        SizedBox(width: 220, height: 220,
          child: Stack(alignment: Alignment.center, children: [
            // Background ring
            SizedBox(width: 220, height: 220,
              child: CustomPaint(painter: _RingPainter(
                progress: counter.progress,
                total: counter.target,
                current: counter.current,
                color: counter.isComplete ? AppColors.statusSelesai : AppColors.accent))),
            // Counter text
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${counter.current}', style: TextStyle(fontFamily: 'Poppins', fontSize: 64, fontWeight: FontWeight.w800,
                color: counter.isComplete ? AppColors.statusSelesai : AppColors.accent)),
              Container(height: 2, width: 40, color: AppColors.divider),
              const SizedBox(height: 4),
              Text('${counter.target}', style: AppTextStyles.h3.copyWith(color: AppColors.textMuted)),
            ]),
          ])),
        const SizedBox(height: 12),
        if (counter.isComplete)
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: AppColors.statusSelesai.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('✅ Selesai! Alhamdulillah', style: AppTextStyles.labelMedium.copyWith(color: AppColors.statusSelesai))),
        const SizedBox(height: 40),
        // +1 Button
        GestureDetector(
          onTap: counter.isComplete ? null : () {
            HapticFeedback.heavyImpact();
            setState(() => counter.increment());
            _save(counter);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: counter.isComplete ? null : const LinearGradient(colors: [AppColors.accentLight, AppColors.accent]),
              color: counter.isComplete ? AppColors.backgroundCard : null,
              shape: BoxShape.circle,
              boxShadow: counter.isComplete ? [] : [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))]),
            child: Icon(Icons.add, size: 48, color: counter.isComplete ? AppColors.textMuted : AppColors.textDark))),
        const SizedBox(height: 24),
        // Dot indicators
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(counter.target, (i) => Container(
            width: 14, height: 14, margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: i < counter.current ? AppColors.accent : AppColors.backgroundCard,
              border: Border.all(color: i < counter.current ? AppColors.accent : AppColors.border, width: 1.5),
              boxShadow: i < counter.current ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 4)] : [])))),
        const SizedBox(height: 24),
        // Reset button
        TextButton.icon(
          onPressed: () { HapticFeedback.mediumImpact(); setState(() => counter.reset()); _save(counter); },
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Reset'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildDzikirPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 10),
        Text('Dzikir / Doa', style: AppTextStyles.h2.copyWith(color: AppColors.textGold)),
        const SizedBox(height: 4),
        Text('Hitung dzikir sesuai target', style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        // Target selector
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: AppConstants.dzikirTargets.map((t) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text('$t', style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                fontWeight: _dzikir.target == t ? FontWeight.w700 : FontWeight.w400,
                color: _dzikir.target == t ? AppColors.textDark : AppColors.textSecondary)),
              selected: _dzikir.target == t,
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.backgroundCard,
              side: BorderSide(color: _dzikir.target == t ? AppColors.accent : AppColors.border),
              onSelected: (sel) { if (sel) setState(() { _dzikir.target = t; _dzikir.reset(); }); _save(_dzikir); },
            ),
          )).toList()),
        const SizedBox(height: 30),
        // Counter display
        SizedBox(width: 200, height: 200,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 200, height: 200,
              child: CircularProgressIndicator(value: _dzikir.progress, strokeWidth: 6,
                backgroundColor: AppColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation(_dzikir.isComplete ? AppColors.statusSelesai : AppColors.accentTeal))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${_dzikir.current}', style: TextStyle(fontFamily: 'Poppins', fontSize: 56, fontWeight: FontWeight.w800,
                color: _dzikir.isComplete ? AppColors.statusSelesai : AppColors.accentTealLight)),
              Text('/ ${_dzikir.target}', style: AppTextStyles.bodySmall),
            ]),
          ])),
        if (_dzikir.isComplete) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: AppColors.statusSelesai.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('✅ Target tercapai!', style: AppTextStyles.labelMedium.copyWith(color: AppColors.statusSelesai))),
        ],
        const SizedBox(height: 30),
        // Tap area
        GestureDetector(
          onTap: _dzikir.isComplete ? null : () {
            HapticFeedback.selectionClick();
            setState(() => _dzikir.increment());
            _save(_dzikir);
          },
          child: Container(width: 120, height: 120,
            decoration: BoxDecoration(
              gradient: _dzikir.isComplete ? null : const LinearGradient(colors: [AppColors.accentTealLight, AppColors.accentTeal]),
              color: _dzikir.isComplete ? AppColors.backgroundCard : null,
              shape: BoxShape.circle,
              boxShadow: _dzikir.isComplete ? [] : [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.touch_app, size: 36, color: _dzikir.isComplete ? AppColors.textMuted : AppColors.textDark),
              Text('TAP', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w800,
                color: _dzikir.isComplete ? AppColors.textMuted : AppColors.textDark)),
            ]))),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () { HapticFeedback.mediumImpact(); setState(() => _dzikir.reset()); _save(_dzikir); },
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Reset'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted)),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final int total, current;
  final Color color;
  _RingPainter({required this.progress, required this.total, required this.current, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background ring
    canvas.drawCircle(center, radius, Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = 8
      ..color = AppColors.backgroundSecondary);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = 8
      ..strokeCap = StrokeCap.round ..color = color;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false, progressPaint);

    // Segment dots
    for (int i = 0; i < total; i++) {
      final angle = -pi / 2 + (2 * pi * i / total);
      final dot = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawCircle(dot, 5, Paint()..color = i < current ? color : AppColors.backgroundCard);
      canvas.drawCircle(dot, 5, Paint()..style = PaintingStyle.stroke ..strokeWidth = 1.5
        ..color = i < current ? color : AppColors.border);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.current != current;
}
