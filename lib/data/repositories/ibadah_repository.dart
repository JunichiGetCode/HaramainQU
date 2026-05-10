import 'package:flutter/material.dart';
import '../models/ibadah_step.dart';
import '../models/ibadah_progress.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

/// Repository for ibadah steps and progress
/// API-first with local fallback data
class IbadahRepository {
  final _api = ApiService();
  final _storage = StorageService();

  // ─── Panduan Steps ────────────────────────────────────────────────────────

  /// Get ibadah steps list — API first, fallback to local
  Future<List<IbadahStep>> getPanduanList() async {
    try {
      final result = await _api.getPanduanList();
      if (result['success'] == true && result['data'] != null) {
        return (result['data'] as List)
            .map((e) => IbadahStep.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return _fallbackSteps;
  }

  /// Get step detail — API first, fallback to local
  Future<IbadahStep?> getPanduanDetail(String id) async {
    try {
      final result = await _api.getPanduanDetail(id);
      if (result['success'] == true && result['data'] != null) {
        return IbadahStep.fromJson(Map<String, dynamic>.from(result['data']));
      }
    } catch (_) {}
    return _fallbackStepsDetailed.firstWhere(
      (s) => s.id == id,
      orElse: () => _fallbackSteps.firstWhere((s) => s.id == id),
    );
  }

  // ─── Progress ─────────────────────────────────────────────────────────────

  /// Get all progress across all days (for overall stats)
  List<IbadahProgress> getAllProgress() {
    return _storage.getAllProgress()
        .map((e) => IbadahProgress.fromJson(e))
        .toList();
  }

  /// Get progress for a specific day
  Future<List<IbadahProgress>> getProgress(int hariKe) async {
    try {
      final result = await _api.getIbadahProgress(); // Ideally send ?hari_ke=$hariKe
      if (result['success'] == true && result['data'] != null) {
        final list = (result['data'] as List)
            .map((e) => IbadahProgress.fromJson(Map<String, dynamic>.from(e)))
            .where((e) => e.hariKe == hariKe)
            .toList();
        
        for (final p in list) {
          await _storage.saveProgress('${p.hariKe}_${p.ibadahId}', p.toJson());
        }
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}

    // Fallback to local
    final local = _storage.getAllProgress()
        .map((e) => IbadahProgress.fromJson(e))
        .where((e) => e.hariKe == hariKe)
        .toList();
        
    if (local.isNotEmpty) {
      return local;
    }

    // Default template based on hariKe
    return _generateDefaultProgress(hariKe);
  }

  /// Update progress — save local + sync API
  Future<void> updateProgress(IbadahProgress progress) async {
    await _storage.saveProgress('${progress.hariKe}_${progress.ibadahId}', progress.toJson());
    try {
      await _api.updateIbadahProgress(
        ibadahId: progress.ibadahId,
        status: progress.status.name,
      );
    } catch (_) {
      // Offline — saved locally, will sync later
    }
  }

  // ─── Fallback Data ────────────────────────────────────────────────────────

  static List<IbadahProgress> _generateDefaultProgress(int hariKe) {
    if (hariKe == 1) {
      return [
        IbadahProgress(ibadahId: 'persiapan', hariKe: hariKe),
        IbadahProgress(ibadahId: 'perjalanan', hariKe: hariKe),
        IbadahProgress(ibadahId: 'miqat', hariKe: hariKe),
      ];
    } else if (hariKe == 2 || hariKe == 3) {
      return [
        IbadahProgress(ibadahId: 'ihram', hariKe: hariKe),
        IbadahProgress(ibadahId: 'tawaf', hariKe: hariKe),
        IbadahProgress(ibadahId: 'sai', hariKe: hariKe),
        IbadahProgress(ibadahId: 'shalat_maqam', hariKe: hariKe),
        IbadahProgress(ibadahId: 'tahallul', hariKe: hariKe),
      ];
    } else {
      return [
        IbadahProgress(ibadahId: 'tahajud', hariKe: hariKe),
        IbadahProgress(ibadahId: 'shalat_jamaah', hariKe: hariKe),
        IbadahProgress(ibadahId: 'tilawah', hariKe: hariKe),
        IbadahProgress(ibadahId: 'tawaf_sunnah', hariKe: hariKe),
        IbadahProgress(ibadahId: 'sedekah', hariKe: hariKe),
      ];
    }
  }

  static final _fallbackSteps = [
    const IbadahStep(
      id: 'persiapan', title: 'Persiapan', subtitle: 'Dokumen & Perlengkapan',
      icon: Icons.checklist, order: 1,
    ),
    const IbadahStep(
      id: 'ihram', title: 'Niat Ihram', subtitle: 'Awal memulai ibadah umroh',
      icon: Icons.front_hand, order: 2,
    ),
    const IbadahStep(
      id: 'tawaf', title: 'Tawaf', subtitle: 'Mengelilingi Ka\'bah 7 kali',
      icon: Icons.sync, order: 3,
    ),
    const IbadahStep(
      id: 'sai', title: 'Sa\'i', subtitle: 'Berjalan Shafa-Marwah 7 kali',
      icon: Icons.directions_walk, order: 4,
    ),
    const IbadahStep(
      id: 'tahallul', title: 'Tahallul', subtitle: 'Mencukur/memotong rambut',
      icon: Icons.content_cut, order: 5,
    ),
    const IbadahStep(
      id: 'ziarah', title: 'Ziarah & Tips', subtitle: 'Tempat bersejarah & tips penting',
      icon: Icons.mosque, order: 6,
    ),
  ];

  static final _fallbackStepsDetailed = [
    const IbadahStep(
      id: 'persiapan', title: 'Persiapan', subtitle: 'Dokumen & Perlengkapan',
      icon: Icons.checklist, order: 1,
      details: [
        StepDetail(number: 1, title: 'Dokumen Penting',
          description: '• Paspor (berlaku minimal 6 bulan)\n• Visa umroh\n• Tiket pesawat PP\n• Voucher hotel\n• Kartu vaksin (meningitis & COVID-19)\n• Fotokopi semua dokumen\n• Travel document dari biro'),
        StepDetail(number: 2, title: 'Barang Penting',
          description: '• Kain ihram 2 set (pria) / Mukena & jilbab (wanita)\n• Sandal yang nyaman (tidak menutupi punggung kaki untuk pria)\n• Obat-obatan pribadi & vitamin\n• Tas pinggang untuk dokumen & uang\n• Power bank & charger\n• Pakaian ganti secukupnya\n• Uang riyal & rupiah secukupnya'),
        StepDetail(number: 3, title: 'Mental & Fisik',
          description: '• Niat karena Allah semata\n• Istirahat yang cukup sebelum berangkat\n• Selesaikan hutang & minta maaf pada keluarga\n• Pelajari manasik umroh\n• Kondisi kesehatan fit (medical check up jika perlu)\n• Perbanyak doa & istighfar'),
      ],
    ),
    const IbadahStep(
      id: 'ihram', title: 'Niat Ihram', subtitle: 'Awal memulai ibadah umroh',
      icon: Icons.front_hand, order: 2,
      details: [
        StepDetail(number: 1, title: 'Cara Berihram',
          description: '• Mandi sunnah (sangat dianjurkan)\n• Pakai wewangian di badan (sebelum pakai ihram)\n• Pakai kain ihram (pria: 2 kain putih tanpa jahitan, wanita: pakaian sopan menutup aurat)\n• Shalat sunnah 2 rakaat (opsional tapi dianjurkan)\n• Niat ihram dan bacakan talbiyah'),
        StepDetail(number: 2, title: 'Niat & Doa',
          description: '• Bacakan niat di dalam hati\n• Ucapkan talbiyah dengan lantang (pria) / lirih (wanita)\n• Terus ucapkan talbiyah sampai tiba di Masjidil Haram',
          arabicText: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً',
          translation: 'Labbaikallahumma umratan (Aku penuhi panggilan-Mu ya Allah untuk melaksanakan umroh)'),
        StepDetail(number: 3, title: 'Larangan Saat Ihram',
          description: '❌ Tidak boleh memakai wewangian (parfum, minyak wangi)\n❌ Tidak boleh potong rambut atau kuku\n❌ Tidak boleh berburu atau membunuh hewan\n❌ Tidak boleh akad nikah atau menikahkan\n❌ Khusus pria: tidak boleh pakai pakaian berjahit & tutup kepala\n❌ Khusus wanita: tidak boleh tutup muka dengan cadar'),
      ],
    ),
    const IbadahStep(
      id: 'tawaf', title: 'Tawaf', subtitle: 'Mengelilingi Ka\'bah 7 kali',
      icon: Icons.sync, order: 3,
      details: [
        StepDetail(number: 1, title: 'Persiapan Tawaf',
          description: '• Pastikan dalam keadaan suci (wudhu)\n• Pria mengatur kain ihram: idhtiba\' (buka bahu kanan)\n• Masuk Masjidil Haram dari pintu Bani Syaibah (dianjurkan)\n• Saat pertama lihat Ka\'bah, angkat tangan & berdoa\n• Menuju Hajar Aswad untuk memulai tawaf'),
        StepDetail(number: 2, title: 'Cara Tawaf',
          description: '• Mulai dari Hajar Aswad (pojok timur Ka\'bah)\n• Istilam (cium) Hajar Aswad jika memungkinkan, atau cukup isyarat tangan\n• Ucapkan: Bismillahi wallahu akbar\n• Keliling Ka\'bah berlawanan arah jarum jam\n• Lakukan ramal (jalan cepat) untuk pria di 3 putaran pertama\n• Baca doa & dzikir sepanjang tawaf\n• Istilam setiap melewati Hajar Aswad\n• Ulangi hingga 7 putaran'),
        StepDetail(number: 3, title: 'Setelah Tawaf',
          description: '• Shalat sunnah 2 rakaat di belakang Maqam Ibrahim\n• Minum air zamzam sambil berdoa\n• Kembali ke Hajar Aswad untuk istilam (jika memungkinkan)\n• Siap untuk melanjutkan ke Sa\'i',
          arabicText: 'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى',
          translation: 'Wattakhidzuu min maqaami Ibraahiima mushalla (Dan jadikanlah sebagian maqam Ibrahim tempat shalat)'),
      ],
    ),
    const IbadahStep(
      id: 'sai', title: 'Sa\'i', subtitle: 'Berjalan Shafa-Marwah 7 kali',
      icon: Icons.directions_walk, order: 4,
      details: [
        StepDetail(number: 1, title: 'Cara Sa\'i',
          description: '• Mulai dari bukit Shafa\n• Menghadap Ka\'bah dan bertakbir 3x serta berdoa\n• Berjalan menuju Marwah\n• Pria berlari kecil di antara 2 lampu hijau\n• Wanita berjalan biasa saja (tidak perlu berlari)\n• Sampai di Marwah, menghadap Ka\'bah, takbir & berdoa\n• Kembali ke Shafa (ini hitungan putaran ke-2)\n• Ulangi hingga 7 putaran (berakhir di Marwah)'),
        StepDetail(number: 2, title: 'Doa di Shafa & Marwah',
          description: 'Bacakan ayat di bawah saat naik Shafa. Ucapkan takbir 3x: Allahu Akbar. Berdoa dengan khusyu\' menghadap Ka\'bah.',
          arabicText: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ',
          translation: 'Innash-shafaa wal-marwata min sya\'aa\'irillah (Sesungguhnya Shafa dan Marwah adalah sebagian dari syi\'ar Allah)'),
        StepDetail(number: 3, title: 'Tips Sa\'i',
          description: '💡 Gunakan lantai atas jika bawah penuh\n💡 Boleh istirahat sejenak jika lelah\n💡 Minum air zamzam untuk stamina\n💡 Jaga konsentrasi & perbanyak doa'),
      ],
    ),
    const IbadahStep(
      id: 'tahallul', title: 'Tahallul', subtitle: 'Mencukur/memotong rambut',
      icon: Icons.content_cut, order: 5,
      details: [
        StepDetail(number: 1, title: 'Cara Tahallul',
          description: '• Potong atau cukur rambut minimal 3 helai\n• Pria: dianjurkan cukur gundul (lebih afdhal)\n• Wanita: potong ujung rambut sepanjang ujung jari (sekitar 3 cm)\n• Lakukan setelah selesai Sa\'i\n• Bisa dilakukan di Masjidil Haram atau hotel'),
        StepDetail(number: 2, title: 'Setelah Tahallul',
          description: '✅ Umroh selesai, semua larangan ihram sudah halal\n✅ Boleh pakai pakaian biasa\n✅ Boleh pakai wewangian\n✅ Sudah boleh melakukan aktivitas normal\n✅ Dianjurkan perbanyak ibadah di Masjidil Haram'),
        StepDetail(number: 3, title: 'Ibadah Setelah Umroh',
          description: '• Perbanyak tawaf sunnah\n• Shalat tahajud di Masjidil Haram\n• Baca Al-Qur\'an\n• Doa di tempat-tempat mustajab\n• Bersedekah kepada yang membutuhkan'),
      ],
    ),
    const IbadahStep(
      id: 'ziarah', title: 'Ziarah & Tips', subtitle: 'Tempat bersejarah & tips penting',
      icon: Icons.mosque, order: 6,
      details: [
        StepDetail(number: 1, title: 'Tempat Ziarah di Makkah',
          description: '• Jabal Nur (Gua Hira) - tempat turunnya wahyu pertama\n• Jabal Tsur - tempat Nabi bersembunyi saat hijrah\n• Jabal Rahmah di Arafah - tempat Nabi Adam & Hawa bertemu\n• Masjid Jin - tempat Nabi berdakwah kepada jin\n• Gua Tsur - sejarah hijrah Nabi'),
        StepDetail(number: 2, title: 'Tempat Ziarah di Madinah',
          description: '• Raudhah - taman surga di Masjid Nabawi (shalat sangat berkah)\n• Makam Rasulullah, Abu Bakar, & Umar\n• Masjid Quba - shalat 2 rakaat = pahala umroh\n• Makam Baqi\' - pemakaman para sahabat\n• Gunung Uhud - tempat perang Uhud\n• Masjid Qiblatain - tempat perubahan arah kiblat'),
        StepDetail(number: 3, title: 'Tips Penting',
          description: '💡 Pilih waktu tawaf saat tidak ramai (dini hari 02:00-05:00)\n💡 Selalu bawa air zamzam & minum yang cukup\n💡 Pakai payung/topi saat keluar masjid (cuaca panas)\n💡 Simpan nomor pembimbing & selalu dalam kelompok\n💡 Bawa obat-obatan pribadi\n💡 Manfaatkan waktu untuk doa & ibadah maksimal\n💡 Jaga kesehatan & istirahat cukup'),
      ],
    ),
  ];
}
