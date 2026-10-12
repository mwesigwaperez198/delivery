import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  final Logger _logger = Logger();

  Future<List<dynamic>> getPendingCarriers() async {
    try {
      final response = await _dio.get('/users/pending-carriers');
      return response.data as List<dynamic>;
    } catch (e) {
      _logger.e('Failed to fetch pending carriers: $e');
      return [];
    }
  }

  Future<bool> updateCourierStatus(String id, String status) async {
    try {
      await _dio.post('/users/update-courier-status', data: {
        'courierId': id,
        'status': status,
      });
      return true;
    } catch (e) {
      _logger.e('Failed to update courier status: $e');
      return false;
    }
  }
}
