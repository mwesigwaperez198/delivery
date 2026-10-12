// Web implementation of CourierTrackingService.
// On web, background services and native location APIs differ; this implementation provides
// a safe, permanent initialization that no-ops but can be extended to use browser APIs.

class CourierTrackingService {
  static Future<void> initializeService() async {
    // Optionally initialize browser-specific tracking (Geolocation API) here.
    // Keep as no-op to ensure web builds succeed and the app initializes.
    return;
  }
}
