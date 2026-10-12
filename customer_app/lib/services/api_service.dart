import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

// ─── Server config ────────────────────────────────────────────────────────────
// Change this one constant when you move to production.
// Never read from .env or cloud config at runtime — keeps the APK safe.
const String _kBaseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
// const String _kBaseUrl = 'http://localhost:3000/api'; // iOS / Web / Desktop
// const String _kBaseUrl = 'https://api.dynamics.ug/api'; // Production

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final Logger _logger = Logger();

  String? _accessToken;
  String? _refreshToken;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 403 && _refreshToken != null) {
          try {
            final res = await _dio.post('/auth/refresh', data: {'refreshToken': _refreshToken});
            _accessToken = res.data['accessToken'];
            e.requestOptions.headers['Authorization'] = 'Bearer $_accessToken';
            return handler.resolve(await _dio.fetch(e.requestOptions));
          } catch (_) {
            _logger.e('Session expired');
          }
        }
        return handler.next(e);
      },
    ));
  }

  void setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<Response> login(String phone, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'phoneNumber': phone,
      'password': password,
      'deviceInfo': 'Dynamics Customer App',
    });
    if (res.statusCode == 200) setTokens(res.data['accessToken'], res.data['refreshToken']);
    return res;
  }

  Future<Response> register(Map<String, dynamic> data) => _dio.post('/auth/register', data: data);

  // ── Storefront ────────────────────────────────────────────────────────────
  Future<Response> getNearbyMerchants(double lat, double lng, {String? category}) =>
      _dio.get('/storefront/merchants/nearby', queryParameters: {
        'lat': lat, 'lng': lng,
        if (category != null) 'category': category,
      });

  Future<Response> getMerchantCatalog(String merchantId) =>
      _dio.get('/storefront/merchants/$merchantId/catalog');

  Future<Response> searchMerchants(String query) =>
      _dio.get('/storefront/search', queryParameters: {'q': query});

  // ── Cart & Orders ─────────────────────────────────────────────────────────
  Future<Response> createOrder(Map<String, dynamic> orderData) =>
      _dio.post('/orders/create', data: orderData);

  Future<Response> getOrderStatus(String orderId) =>
      _dio.get('/orders/$orderId');

  Future<Response> getOrderHistory() =>
      _dio.get('/orders/history');
}
