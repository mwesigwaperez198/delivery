// Facade for socket service — conditionally exports web or io implementations.
// Replace or extend implementations in socket_service_web.dart and socket_service_io.dart.

export 'socket_service_io.dart'
  if (dart.library.html) 'socket_service_web.dart';
