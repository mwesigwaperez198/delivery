import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  
  // Use 10.0.2.2 for Android Emulator, localhost for Web/iOS/Windows
  final String _baseUrl = 'http://localhost:3000/api';
  
  String? _accessToken;
  String? _refreshToken;

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
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
            final response = await _dio.post('/auth/refresh', data: {
              'refreshToken': _refreshToken
            });
            _accessToken = response.data['accessToken'];
            
            e.requestOptions.headers['Authorization'] = 'Bearer $_accessToken';
            final retryResponse = await _dio.fetch(e.requestOptions);
            return handler.resolve(retryResponse);
          } catch (refreshError) {
            _logger.e('Session expired. Please login again.');
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> login(String phoneNumber, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'phoneNumber': phoneNumber,
      'password': password,
      'deviceInfo': 'Flutter Customer App'
    });
    
    if (response.statusCode == 200) {
      _accessToken = response.data['accessToken'];
      _refreshToken = response.data['refreshToken'];
    }
    return response;
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post('/auth/register', data: userData);
  }

  Future<Response> getNearbyMerchants(double lat, double lng, {String? category}) async {
    return await _dio.get('/storefront/merchants/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      if (category != null) 'category': category
    });
  }

  Future<Response> getNearbyProducts(double lat, double lng, {String? category}) async {
    return await _dio.get('/storefront/products/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      if (category != null) 'category': category
    });
  }

  Future<Response> getMerchantCatalog(String merchantId) async {
    return await _dio.get('/storefront/merchants/$merchantId/catalog');
  }

  Future<Response> syncCart(String merchantId, List<Map<String, dynamic>> items) async {
    return await _dio.post('/storefront/cart/sync', data: {
      'merchantId': merchantId,
      'items': items
    });
  }

  Future<Response> createOrder(Map<String, dynamic> orderData) async {
    return await _dio.post('/orders/create', data: orderData);
  }

  Future<Response> getOrderStatus(String orderId) async {
    return await _dio.get('/orders/$orderId');
  }
}
