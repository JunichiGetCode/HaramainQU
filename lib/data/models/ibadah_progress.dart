/// Status progress ibadah
enum IbadahStatus { belum, sedang, selesai }

/// Model for tracking ibadah completion progress
class IbadahProgress {
  final String ibadahId;
  final int hariKe;
  IbadahStatus status;
  DateTime? startedAt;
  DateTime? completedAt;

  IbadahProgress({
    required this.ibadahId,
    required this.hariKe,
    this.status = IbadahStatus.belum,
    this.startedAt,
    this.completedAt,
  });

  factory IbadahProgress.fromJson(Map<String, dynamic> json) {
    return IbadahProgress(
      ibadahId: json['ibadah_id'] as String,
      hariKe: json['hari_ke'] as int? ?? 1,
      status: _statusFromString(json['status'] as String? ?? 'belum'),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'ibadah_id': ibadahId,
        'hari_ke': hariKe,
        'status': status.name,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  static IbadahStatus _statusFromString(String s) {
    return switch (s) {
      'sedang' => IbadahStatus.sedang,
      'selesai' => IbadahStatus.selesai,
      _ => IbadahStatus.belum,
    };
  }

  /// Cycle to next status: belum → sedang → selesai
  void nextStatus() {
    switch (status) {
      case IbadahStatus.belum:
        status = IbadahStatus.sedang;
        startedAt = DateTime.now();
        break;
      case IbadahStatus.sedang:
        status = IbadahStatus.selesai;
        completedAt = DateTime.now();
        break;
      case IbadahStatus.selesai:
        status = IbadahStatus.belum;
        startedAt = null;
        completedAt = null;
        break;
    }
  }

  String get statusLabel => switch (status) {
        IbadahStatus.belum => 'Belum',
        IbadahStatus.sedang => 'Sedang',
        IbadahStatus.selesai => 'Selesai',
      };
}
