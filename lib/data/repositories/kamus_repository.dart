import '../models/kamus_entry.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

class KamusRepository {
  final _api = ApiService();
  final _storage = StorageService();

  Future<List<KamusEntry>> getEntries({String? category, String? search}) async {
    try {
      final result = await _api.getKamusEntries(category: category, search: search);
      if (result['success'] == true && result['data'] != null) {
        final list = (result['data'] as List)
            .map((e) => KamusEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        await _storage.cacheKamus(list.map((e) => e.toJson()).toList());
        return list;
      }
    } catch (_) {}

    final cached = _storage.getCachedKamus();
    if (cached != null && cached.isNotEmpty) {
      var list = cached.map((e) => KamusEntry.fromJson(e)).toList();
      if (category != null) list = list.where((e) => e.category == category).toList();
      if (search != null) list = list.where((e) => e.matches(search)).toList();
      return list;
    }

    var list = fallbackEntries;
    if (category != null) list = list.where((e) => e.category == category).toList();
    if (search != null) list = list.where((e) => e.matches(search)).toList();
    return list;
  }

  List<Map<String, String>> get categories => [
    {'id': 'sapaan', 'label': 'Sapaan & Umum'},
    {'id': 'tempat', 'label': 'Tempat & Arah'},
    {'id': 'sehari', 'label': 'Sehari-hari'},
    {'id': 'angka', 'label': 'Angka'},
    {'id': 'darurat', 'label': 'Frasa Darurat'},
  ];

  static const fallbackEntries = [
    KamusEntry(arabic: 'السَّلاَمُ عَلَيْكُمْ', latin: "Assalamu'alaikum", indonesian: 'Semoga keselamatan atas kamu', category: 'sapaan'),
    KamusEntry(arabic: 'شُكْرًا', latin: 'Syukran', indonesian: 'Terima kasih', category: 'sapaan'),
    KamusEntry(arabic: 'عَفْوًا', latin: "'Afwan", indonesian: 'Maaf / Permisi', category: 'sapaan'),
    KamusEntry(arabic: 'نَعَمْ / لاَ', latin: "Na'am / Laa", indonesian: 'Ya / Tidak', category: 'sapaan'),
    KamusEntry(arabic: 'مِنْ فَضْلِكَ', latin: 'Min Fadhlika', indonesian: 'Tolong / Mohon', category: 'sapaan'),
    KamusEntry(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'Insya Allah', indonesian: 'Jika Allah menghendaki', category: 'sapaan'),
    KamusEntry(arabic: 'الْحَمْدُ لِلَّهِ', latin: 'Alhamdulillah', indonesian: 'Segala puji bagi Allah', category: 'sapaan'),
    KamusEntry(arabic: 'اَلْمَسْجِد', latin: 'Al-Masjid', indonesian: 'Masjid', category: 'tempat'),
    KamusEntry(arabic: 'اَلْفُنْدُق', latin: 'Al-Funduq', indonesian: 'Hotel', category: 'tempat'),
    KamusEntry(arabic: 'يَمِين / يَسَار', latin: 'Yamiin / Yasaar', indonesian: 'Kanan / Kiri', category: 'tempat'),
    KamusEntry(arabic: 'أَيْنَ؟', latin: 'Aina?', indonesian: 'Di mana?', category: 'tempat'),
    KamusEntry(arabic: 'اَلْحَمَّام', latin: 'Al-Hammaam', indonesian: 'Kamar mandi', category: 'tempat'),
    KamusEntry(arabic: 'اَلسُّوق', latin: 'As-Suuq', indonesian: 'Pasar', category: 'tempat'),
    KamusEntry(arabic: 'مَاء', latin: "Maa'", indonesian: 'Air', category: 'sehari'),
    KamusEntry(arabic: 'طَعَام', latin: "Tha'aam", indonesian: 'Makanan', category: 'sehari'),
    KamusEntry(arabic: 'بِكَمْ؟', latin: 'Bikam?', indonesian: 'Berapa harganya?', category: 'sehari'),
    KamusEntry(arabic: 'غَالِي', latin: 'Ghaalii', indonesian: 'Mahal', category: 'sehari'),
    KamusEntry(arabic: 'رَخِيص', latin: 'Rakhiish', indonesian: 'Murah', category: 'sehari'),
    KamusEntry(arabic: 'وَاحِد', latin: 'Waahid', indonesian: '1 (Satu)', category: 'angka'),
    KamusEntry(arabic: 'اِثْنَان', latin: 'Itsnaan', indonesian: '2 (Dua)', category: 'angka'),
    KamusEntry(arabic: 'ثَلاَثَة', latin: 'Tsalaatsah', indonesian: '3 (Tiga)', category: 'angka'),
    KamusEntry(arabic: 'أَرْبَعَة', latin: "Arba'ah", indonesian: '4 (Empat)', category: 'angka'),
    KamusEntry(arabic: 'خَمْسَة', latin: 'Khamsah', indonesian: '5 (Lima)', category: 'angka'),
    KamusEntry(arabic: 'سَاعِدْنِي!', latin: "Saa'idnii!", indonesian: 'Tolong saya!', category: 'darurat'),
    KamusEntry(arabic: 'أَنَا مَرِيض', latin: 'Ana mariidh', indonesian: 'Saya sakit', category: 'darurat'),
    KamusEntry(arabic: 'أَنَا ضَائِع', latin: "Ana dhaa'i'", indonesian: 'Saya tersesat', category: 'darurat'),
    KamusEntry(arabic: 'أَيْنَ الْمُسْتَشْفَى؟', latin: 'Aina al-mustasyfa?', indonesian: 'Di mana rumah sakit?', category: 'darurat'),
  ];
}
