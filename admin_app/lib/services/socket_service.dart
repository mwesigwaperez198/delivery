import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';

class AdminSocketService {
  late IO.Socket socket;
  final Logger _logger = Logger();
  
  // Callbacks for UI updates
  Function(Map<String, dynamic>)? onSummaryUpdate;
  Function(Map<String, dynamic>)? onLocationUpdate;
  Function(Map<String, dynamic>)? onDispatchEvent;

  void connect(String adminId) {
    socket = IO.io('http://localhost:3000', IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    socket.connect();

    socket.onConnect((_) {
      _logger.i('Admin connected to WebSocket');
      // Join the admin room
      socket.emit('join_room', {'role': 'admin', 'userId': adminId});
    });

    socket.on('system_summary_update', (data) {
      if (onSummaryUpdate != null) onSummaryUpdate!(data);
    });

    socket.on('live_location_update', (data) {
      if (onLocationUpdate != null) onLocationUpdate!(data);
    });

    socket.on('dispatch_event', (data) {
      if (onDispatchEvent != null) onDispatchEvent!(data);
    });

    socket.onDisconnect((_) => _logger.w('Admin disconnected from WebSocket'));
  }

  void dispose() {
    socket.dispose();
  }
}
