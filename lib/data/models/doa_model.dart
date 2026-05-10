/// Model for doa & dzikir entry
class DoaModel {
  final int id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String category;
  final int order;

  const DoaModel({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.category,
    this.order = 0,
  });

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      id: json['id'] as int,
      title: json['title'] as String,
      arabic: json['arabic'] as String,
      latin: json['latin'] as String,
      translation: json['translation'] as String,
      category: json['category'] as String,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'arabic': arabic,
        'latin': latin,
        'translation': translation,
        'category': category,
        'order': order,
      };
}
