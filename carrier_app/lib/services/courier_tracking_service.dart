// Facade for courier tracking service — exports platform-specific implementations.

export 'courier_tracking_service_io.dart'
  if (dart.library.html) 'courier_tracking_service_web.dart';
