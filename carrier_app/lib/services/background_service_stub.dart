// carrier_app/lib/services/background_service_stub.dart

class FlutterBackgroundService {
  FlutterBackgroundService();

  /// When compiled for web, always report not running.
  Future<bool> isRunning() async => false;

  /// Return false for startService on web by default.
  Future<bool> startService() async => false;

  /// No-op invoke for web.
  void invoke(String method, [dynamic args]) {}

  /// Optional stop helper for parity.
  Future<void> stopService() async {}
}
