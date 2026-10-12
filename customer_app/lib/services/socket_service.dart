import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';

class SocketService {
  late IO.Socket socket;
  final Logger _logger = Logger();
  
  // Use 10.0.2.2 for Android Emulator to hit localhost
  final String _socketUrl = 'http://10.0.2.2:3000';

  void connect({String? userId, String? role, String? orderId}) {
    socket = IO.io(_socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    socket.connect();

    socket.onConnect((_) {
      _logger.i('Connected to Socket Server');
      socket.emit('join_room', {
        'role': role,
        'userId': userId,
        'orderId': orderId,
      });
    });

    socket.onDisconnect((_) => _logger.w('Disconnected from Socket Server'));
    socket.onConnectError((data) => _logger.e('Connect Error: $data'));
  }

  void listenToCourierLocation(Function(Map<String, dynamic>) onLocationUpdate) {
    socket.on('courier_location_update', (data) {
      onLocationUpdate(Map<String, dynamic>.from(data));
    });
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
