import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/reminder_model.dart';
import '../../../../data/repositories/reminder_repository.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});
  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _repo = ReminderRepository();
  List<ReminderModel> _reminders = [];

  @override
  void initState() { super.initState(); _load(); }

  void _load() { setState(() => _reminders = _repo.getAll()); }

  Future<void> _addReminder() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: AppColors.accent, surface: AppColors.backgroundCard)),
        child: child!));
    if (time == null || !mounted) return;

    final titleCtrl = TextEditingController();
    final title = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: Text('Nama Reminder', style: AppTextStyles.h4),
      content: TextField(controller: titleCtrl, style: AppTextStyles.bodyMedium, autofocus: true,
        decoration: const InputDecoration(hintText: 'Contoh: Shalat Dhuha')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, titleCtrl.text.isNotEmpty ? titleCtrl.text : 'Reminder'),
          child: const Text('Simpan')),
      ]));

    if (title == null || !mounted) return;

    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title, hour: time.hour, minute: time.minute);
    await _repo.save(reminder);
    _load();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(backgroundColor: AppColors.backgroundPrimary, elevation: 0,
        title: Text('Reminder Ibadah', style: AppTextStyles.appBarTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.textDark)),
      body: _reminders.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.alarm_off, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Belum ada reminder', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text('Tekan + untuk menambahkan', style: AppTextStyles.bodySmall),
          ]))
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: _reminders.length,
            itemBuilder: (ctx, i) => _buildReminderCard(_reminders[i]),
          ),
    );
  }

  Widget _buildReminderCard(ReminderModel r) {
    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) async { await _repo.delete(r.id); _load(); },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: AppColors.danger)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: r.isActive ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (r.isActive ? AppColors.accent : AppColors.textMuted).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.alarm, color: r.isActive ? AppColors.accent : AppColors.textMuted, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.title, style: AppTextStyles.labelLarge.copyWith(
              color: r.isActive ? AppColors.textPrimary : AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(r.timeFormatted, style: AppTextStyles.h3.copyWith(
              color: r.isActive ? AppColors.accent : AppColors.textMuted)),
          ])),
          Switch(
            value: r.isActive,
            onChanged: (v) async {
              HapticFeedback.selectionClick();
              await _repo.toggleActive(r);
              _load();
            },
            activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.accent : AppColors.textMuted),
            inactiveThumbColor: AppColors.textMuted),
        ])),
    );
  }
}
