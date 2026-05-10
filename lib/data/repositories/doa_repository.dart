import '../models/doa_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

class DoaRepository {
  final _api = ApiService();
  final _storage = StorageService();

  Future<List<DoaModel>> getDoaList({String? category}) async {
    try {
      final result = await _api.getDoaList(category: category);
      if (result['success'] == true && result['data'] != null) {
        final list = (result['data'] as List)
            .map((e) => DoaModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        await _storage.cacheDoa(list.map((d) => d.toJson()).toList());
        return list;
      }
    } catch (_) {}

    final cached = _storage.getCachedDoa();
    if (cached != null && cached.isNotEmpty) {
      var list = cached.map((e) => DoaModel.fromJson(e)).toList();
      if (category != null) list = list.where((d) => d.category == category).toList();
      return list;
    }

    if (category != null) return fallbackDoa.where((d) => d.category == category).toList();
    return fallbackDoa;
  }

  List<Map<String, String>> get categories => [
    {'id': 'semua', 'label': 'Semua Doa'},
    {'id': 'masjid', 'label': 'Masjid'},
    {'id': 'tawaf', 'label': 'Tawaf'},
    {'id': 'sai', 'label': "Sa'i"},
    {'id': 'umum', 'label': 'Umum'},
  ];

  static const fallbackDoa = [
    DoaModel(id: 1, category: 'masjid', title: 'Doa Masuk Masjidil Haram',
      arabic: 'بِسْمِ اللَّهِ وَالصَّلاَةُ وَالسَّلاَمُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      latin: "Bismillahi wash-shalaatu was-salaamu 'ala Rasulillah, Allahummaf-tah li abwaaba rahmatik",
      translation: 'Dengan nama Allah, shalawat dan salam atas Rasulullah. Ya Allah bukakanlah untukku pintu-pintu rahmat-Mu.'),
    DoaModel(id: 2, category: 'masjid', title: "Doa Melihat Ka'bah",
      arabic: 'اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ فَحَيِّنَا رَبَّنَا بِالسَّلاَمِ',
      latin: 'Allahumma antas-salaam, wa minkas-salaam, fa hayyinaa rabbanaa bis-salaam',
      translation: 'Ya Allah, Engkaulah As-Salaam, dari-Mu segala kesejahteraan.'),
    DoaModel(id: 3, category: 'masjid', title: 'Doa Keluar Masjid',
      arabic: 'بِسْمِ اللَّهِ وَالصَّلاَةُ وَالسَّلاَمُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      latin: "Bismillahi wash-shalaatu was-salaamu 'ala Rasulillah, Allahumma inni as'aluka min fadlik",
      translation: 'Dengan nama Allah. Ya Allah, aku memohon keutamaan dari-Mu.'),
    DoaModel(id: 4, category: 'tawaf', title: 'Doa Memulai Tawaf',
      arabic: 'بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ',
      latin: 'Bismillahi wallahu akbar',
      translation: 'Dengan nama Allah dan Allah Maha Besar.'),
    DoaModel(id: 5, category: 'tawaf', title: 'Doa Rukun Yamani-Hajar Aswad',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      latin: "Rabbanaa aatinaa fid-dunyaa hasanah, wa fil-aakhirati hasanah, wa qinaa 'adzaaban-naar",
      translation: 'Ya Tuhan kami, berilah kami kebaikan di dunia dan akhirat, dan lindungilah kami dari azab neraka.'),
    DoaModel(id: 6, category: 'sai', title: "Doa di Bukit Shafa & Marwah",
      arabic: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ',
      latin: "Innash-shafaa wal-marwata min sya'aa'irillah",
      translation: "Sesungguhnya Shafa dan Marwah adalah sebagian dari syi'ar Allah."),
    DoaModel(id: 7, category: 'sai', title: 'Doa Minum Air Zamzam',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا وَاسِعًا وَشِفَاءً مِنْ كُلِّ دَاءٍ',
      latin: "Allahumma inni as'aluka 'ilman naafi'an, wa rizqan waasi'an, wa syifaa'an min kulli daa'",
      translation: 'Ya Allah, aku memohon ilmu yang bermanfaat, rezeki yang luas, dan kesembuhan dari segala penyakit.'),
    DoaModel(id: 8, category: 'umum', title: 'Bacaan Talbiyah',
      arabic: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ',
      latin: "Labbaikallahumma labbaik, labbaika laa syariika laka labbaik",
      translation: 'Aku penuhi panggilan-Mu ya Allah. Tiada sekutu bagi-Mu.'),
    DoaModel(id: 9, category: 'umum', title: 'Doa Terbaik (Arafah)',
      arabic: 'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
      latin: "Laa ilaaha illallahu wahdahu laa syariika lah",
      translation: 'Tiada Tuhan selain Allah semata, tiada sekutu bagi-Nya.'),
  ];
}
