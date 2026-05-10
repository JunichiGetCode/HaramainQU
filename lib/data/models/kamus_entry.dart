/// Model for Arabic dictionary entry
class KamusEntry {
  final int? id;
  final String arabic;
  final String latin;
  final String indonesian;
  final String category;
  final String? searchText;

  const KamusEntry({
    this.id,
    required this.arabic,
    required this.latin,
    required this.indonesian,
    required this.category,
    this.searchText,
  });

  factory KamusEntry.fromJson(Map<String, dynamic> json) {
    return KamusEntry(
      id: json['id'] as int?,
      arabic: json['arabic'] as String,
      latin: json['latin'] as String,
      indonesian: json['indonesian'] as String,
      category: json['category'] as String,
      searchText: json['search_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'latin': latin,
        'indonesian': indonesian,
        'category': category,
      };

  /// Check if entry matches a search query
  bool matches(String query) {
    final q = query.toLowerCase();
    return arabic.contains(q) ||
        latin.toLowerCase().contains(q) ||
        indonesian.toLowerCase().contains(q) ||
        (searchText?.toLowerCase().contains(q) ?? false);
  }
}
