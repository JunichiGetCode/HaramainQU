import '../models/reminder_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';

class ReminderRepository {
  final _storage = StorageService();
  final _notif = NotificationService();

  List<ReminderModel> getAll() {
    final data = _storage.getAllReminders();
    return data.map((e) => ReminderModel.fromJson(e)).toList();
  }

  Future<void> save(ReminderModel reminder) async {
    await _storage.saveReminder(reminder.id, reminder.toJson());
    if (reminder.isActive) {
      await _notif.scheduleDaily(
        id: reminder.notificationId,
        title: 'HaramainQu - ${reminder.title}',
        body: 'Waktunya ${reminder.title} 🤲',
        hour: reminder.hour,
        minute: reminder.minute,
      );
    } else {
      await _notif.cancel(reminder.notificationId);
    }
  }

  Future<void> delete(String id) async {
    final data = _storage.reminderBox.get(id);
    if (data != null) {
      final reminder = ReminderModel.fromJson(Map<String, dynamic>.from(data));
      await _notif.cancel(reminder.notificationId);
    }
    await _storage.deleteReminder(id);
  }

  Future<void> toggleActive(ReminderModel reminder) async {
    reminder.isActive = !reminder.isActive;
    await save(reminder);
  }
}
