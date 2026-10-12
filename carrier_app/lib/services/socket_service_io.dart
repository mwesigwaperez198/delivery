// IO / mobile placeholder implementation of CourierSocketService.
// Replace this with your existing mobile socket implementation (e.g., using socket_io_client or native plugins).

typedef OnNewAssignment = void Function(Map<String, dynamic> data);

class CourierSocketService {
  OnNewAssignment? onNewAssignment;

  CourierSocketService();

  Future<void> connect(String courierId) async {
    // TODO: provide real mobile socket connection logic here.
    // For now this throws to make the missing-implementation explicit during mobile builds.
    throw UnimplementedError('CourierSocketService.connect is not implemented for IO. Provide a mobile implementation in socket_service_io.dart');
  }

  void disconnect() {
    // TODO: implement disconnect for mobile
  }

  bool get isConnected => false;
}
