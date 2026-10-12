typedef OnNewAssignment = void Function(Map<String, dynamic> data);

class CourierSocketService {
  OnNewAssignment? onNewAssignment;

  void connect(String courierId) {
    print("Web Stub: Connected as $courierId");
  }

  void disconnect() {
    print("Web Stub: Disconnected");
  }

  void emit(String event, dynamic data) {
    print("Web Stub: Emitted $event");
  }
}
