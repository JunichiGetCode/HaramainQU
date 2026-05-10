/// Model for ibadah reminder
class ReminderModel {
  final String id;
  String title;
  int hour;
  int minute;
  bool isActive;

  ReminderModel({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    this.isActive = true,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hour': hour,
        'minute': minute,
        'is_active': isActive,
      };

  String get timeFormatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Get a unique int ID for notification scheduling (hash-based)
  int get notificationId => id.hashCode.abs() % 100000;
}
