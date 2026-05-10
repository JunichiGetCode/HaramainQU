import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Android emulator: 10.0.2.2 = host machine's localhost
  // Physical device: gunakan ngrok URL
  static const String _baseUrlLocal = 'http://192.168.1.12:8000/api';
  static const String _baseUrlNgrok =
      'https://ebony-persuaded-acid.ngrok-free.dev/api';

  // Gunakan local saat dev, ngrok saat testing di device fisik
  static String get baseUrl =>
      kDebugMode ? _baseUrlLocal : _baseUrlNgrok;

  static const String _tokenKey = 'sanctum_token';
  static const String _userKey = 'user_data';

  late final Dio _dio;
  String? _token;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor untuk attach token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('[API ERROR] ${error.requestOptions.path}: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  bool get isLoggedIn => _token != null;

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        if (fcmToken != null) 'fcm_token': fcmToken,
      });

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['token'] != null) {
        await setToken(data['token']);
      }
      return data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      await clearToken();
      return response.data;
    } on DioException catch (e) {
      await clearToken();
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final response = await _dio.put('/profile', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ─── Panduan Ibadah ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPanduanList() async {
    try {
      final response = await _dio.get('/ibadah/panduan');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPanduanDetail(String id) async {
    try {
      final response = await _dio.get('/ibadah/panduan/$id');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ─── Progress Ibadah ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getIbadahProgress() async {
    try {
      final response = await _dio.get('/ibadah/progress');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateIbadahProgress({
    required String ibadahId,
    required String status,
  }) async {
    try {
      final response = await _dio.post('/ibadah/progress', data: {
        'ibadah_id': ibadahId,
        'status': status,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ─── Tracking Ibadah ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTrackingData() async {
    try {
      final response = await _dio.get('/ibadah/tracking');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> saveTrackingData({
    required String type,
    required int current,
    required int target,
  }) async {
    try {
      final response = await _dio.post('/ibadah/tracking', data: {
        'type': type,
        'current': current,
        'target': target,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> resetTracking({
    required String type,
  }) async {
    try {
      final response = await _dio.post('/ibadah/tracking/reset', data: {
        'type': type,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ─── Doa & Dzikir ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDoaList({String? category}) async {
    try {
      final response = await _dio.get('/doa', queryParameters: {
        if (category != null) 'category': category,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ─── Kamus Arab ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getKamusEntries({
    String? category,
    String? search,
  }) async {
    try {
      final response = await _dio.get('/kamus', queryParameters: {
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ─── Error Handler ────────────────────────────────────────────────────────

  Map<String, dynamic> _handleError(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
    return {
      'success': false,
      'message': switch (e.type) {
        DioExceptionType.connectionTimeout => 'Koneksi timeout. Periksa internet Anda.',
        DioExceptionType.connectionError => 'Tidak dapat terhubung ke server.',
        DioExceptionType.receiveTimeout => 'Server tidak merespons.',
        _ => e.message ?? 'Terjadi kesalahan.',
      },
    };
  }
}
