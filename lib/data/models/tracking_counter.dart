/// Model for tracking counters (tawaf, sa'i, dzikir)
class TrackingCounter {
  final String type; // 'tawaf', 'sai', 'dzikir'
  final int hariKe;
  int current;
  int target;
  DateTime? lastUpdated;

  TrackingCounter({
    required this.type,
    required this.hariKe,
    this.current = 0,
    required this.target,
    this.lastUpdated,
  });

  factory TrackingCounter.fromJson(Map<String, dynamic> json) {
    return TrackingCounter(
      type: json['type'] as String,
      hariKe: json['hari_ke'] as int? ?? 1,
      current: json['current'] as int? ?? 0,
      target: json['target'] as int? ?? 7,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'hari_ke': hariKe,
        'current': current,
        'target': target,
        'last_updated': lastUpdated?.toIso8601String(),
      };

  bool get isComplete => current >= target;
  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  String get display => '$current/$target';

  void increment() {
    if (current < target) {
      current++;
      lastUpdated = DateTime.now();
    }
  }

  void reset() {
    current = 0;
    lastUpdated = DateTime.now();
  }
}
