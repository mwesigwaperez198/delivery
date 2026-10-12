import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class MonitoringService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api/monitor',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  final Logger _logger = Logger();
  static const String appId = 'customer_app';

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

  // Convenience methods
  Future<void> trackHealth(String status) async {
    await logEvent(category: 'health', event: 'heartbeat', data: {'status': status});
  }

  Future<void> trackFinance(double amount, String transactionType) async {
    await logEvent(
      category: 'finance', 
      event: 'transaction', 
      data: {'amount': amount, 'type': transactionType}
    );
  }

  Future<void> trackBehavior(String action, String screenName) async {
    await logEvent(
      category: 'behavior', 
      event: 'user_action', 
      data: {'action': action, 'screen': screenName}
    );
  }
}
