import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class MonitoringService {
  final Dio _dio = Dio(BaseOptions(
    // Use 10.0.2.2 for Android Emulator to hit localhost
    baseUrl: 'http://10.0.2.2:3000/api/monitor',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  final Logger _logger = Logger();
  static const String appId = 'admin_app';

  Future<void> logEvent({
    required String category,
    required String event,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'appId': appId,
        'category': category,
        'event': event,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _dio.post('/log', data: payload);
      _logger.i('Telemetry sent: $event');
    } catch (e) {
      _logger.e('Failed to send telemetry: $e');
    }
  }

  Future<Map<String, dynamic>?> getSystemSummary() async {
    try {
      final response = await _dio.get('/summary');
      return response.data;
    } catch (e) {
      _logger.e('Failed to fetch summary: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getWorkforceOverview() async {
    try {
      final response = await Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api/users')).get('/workforce');
      return response.data;
    } catch (e) {
      _logger.e('Failed to fetch workforce: $e');
      return null;
    }
  }

  Future<bool> assignManualDuty(String orderId, String courierId) async {
    try {
      await Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api/users')).post('/assign-duty', data: {
        'orderId': orderId,
        'courierId': courierId,
      });
      return true;
    } catch (e) {
      _logger.e('Failed to assign manual duty: $e');
      return false;
    }
  }

  Future<bool> activateCourier(String courierId, bool activate) async {
    try {
      await Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api/users')).post('/activate-courier', data: {
        'courierId': courierId,
        'isActivated': activate,
      });
      return true;
    } catch (e) {
      _logger.e('Failed to update courier activation: $e');
      return false;
    }
  }

  Future<void> trackHealth(String status) async {
    await logEvent(category: 'health', event: 'heartbeat', data: {'status': status});
  }
}
