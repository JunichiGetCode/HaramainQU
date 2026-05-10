import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Centralized Hive storage service for local persistence
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  bool _initialized = false;

  /// Initialize all Hive boxes. Call in main() before runApp()
  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox(AppConstants.hiveBoxProgress),
      Hive.openBox(AppConstants.hiveBoxTracking),
      Hive.openBox(AppConstants.hiveBoxReminder),
      Hive.openBox(AppConstants.hiveBoxDoa),
      Hive.openBox(AppConstants.hiveBoxKamus),
      Hive.openBox(AppConstants.hiveBoxUser),
    ]);

    _initialized = true;
    debugPrint('[StorageService] Hive boxes initialized');
  }

  // ─── Generic Box Access ───────────────────────────────────────────────────

  Box _box(String name) => Hive.box(name);

  // ─── Progress ─────────────────────────────────────────────────────────────

  Box get progressBox => _box(AppConstants.hiveBoxProgress);

  Future<void> saveProgress(String ibadahId, Map<String, dynamic> data) async {
    await progressBox.put(ibadahId, data);
  }

  Map<String, dynamic>? getProgress(String ibadahId) {
    final data = progressBox.get(ibadahId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  List<Map<String, dynamic>> getAllProgress() {
    return progressBox.keys.map((key) {
      return Map<String, dynamic>.from(progressBox.get(key));
    }).toList();
  }

  // ─── Tracking ─────────────────────────────────────────────────────────────

  Box get trackingBox => _box(AppConstants.hiveBoxTracking);

  Future<void> saveTracking(String type, Map<String, dynamic> data) async {
    await trackingBox.put(type, data);
  }

  Map<String, dynamic>? getTracking(String type) {
    final data = trackingBox.get(type);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // ─── Reminders ────────────────────────────────────────────────────────────

  Box get reminderBox => _box(AppConstants.hiveBoxReminder);

  Future<void> saveReminder(String id, Map<String, dynamic> data) async {
    await reminderBox.put(id, data);
  }

  Future<void> deleteReminder(String id) async {
    await reminderBox.delete(id);
  }

  List<Map<String, dynamic>> getAllReminders() {
    return reminderBox.keys.map((key) {
      final data = Map<String, dynamic>.from(reminderBox.get(key));
      data['id'] = key;
      return data;
    }).toList();
  }

  // ─── Doa Cache ────────────────────────────────────────────────────────────

  Box get doaBox => _box(AppConstants.hiveBoxDoa);

  Future<void> cacheDoa(List<Map<String, dynamic>> doaList) async {
    await doaBox.put('cached_doa', doaList);
    await doaBox.put('cached_at', DateTime.now().toIso8601String());
  }

  List<Map<String, dynamic>>? getCachedDoa() {
    final data = doaBox.get('cached_doa');
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  // ─── Kamus Cache ──────────────────────────────────────────────────────────

  Box get kamusBox => _box(AppConstants.hiveBoxKamus);

  Future<void> cacheKamus(List<Map<String, dynamic>> entries) async {
    await kamusBox.put('cached_kamus', entries);
    await kamusBox.put('cached_at', DateTime.now().toIso8601String());
  }

  List<Map<String, dynamic>>? getCachedKamus() {
    final data = kamusBox.get('cached_kamus');
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  // ─── User Data ────────────────────────────────────────────────────────────

  Box get userBox => _box(AppConstants.hiveBoxUser);

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await userBox.put('user', data);
  }

  Map<String, dynamic>? getUserData() {
    final data = userBox.get('user');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // ─── Clear All ────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await progressBox.clear();
    await trackingBox.clear();
    await reminderBox.clear();
    await doaBox.clear();
    await kamusBox.clear();
    await userBox.clear();
    debugPrint('[StorageService] All data cleared');
  }
}
