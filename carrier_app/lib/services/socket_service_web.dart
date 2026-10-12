// Web implementation of CourierSocketService using WebSocket (dart:html).
// This is a permanent web-friendly implementation. Configure `WS_ENDPOINT` in your web environment
// or replace the connect logic to match your backend.

import 'dart:async';
import 'dart:convert';
import 'dart:html';

typedef OnNewAssignment = void Function(Map<String, dynamic> data);

class CourierSocketService {
  WebSocket? _ws;
  OnNewAssignment? onNewAssignment;
  final _ready = Completer<void>();

  // Provide a default endpoint; override by setting window.__WS_ENDPOINT__ in index.html
  static String get _defaultEndpoint {
    try {
      final v = window.localStorage['WS_ENDPOINT'];
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
    return 'wss://example.com/socket';
  }

  Future<void> connect(String courierId) async {
    final endpoint = _defaultEndpoint;
    try {
      _ws = WebSocket(endpoint);
      _ws!.onOpen.listen((_) {
        _ready.complete();
        // Optionally send an authentication/identify message
        _ws!.send(jsonEncode({'type': 'identify', 'id': courierId}));
      });

      _ws!.onMessage.listen((MessageEvent e) {
        try {
          final data = jsonDecode(e.data.toString());
          if (onNewAssignment != null && data is Map && data['type'] == 'assignment') {
            onNewAssignment!(Map<String, dynamic>.from(data['payload'] ?? {}));
          }
        } catch (_) {
          // ignore malformed messages
        }
      });

      _ws!.onClose.listen((_) {
        _ws = null;
      });
    } catch (e) {
      // Failed to open websocket; leave as no-op but log to console
      // ignore:avoid_print
      print('CourierSocketService: failed to connect to $endpoint -> $e');
    }
  }

  void disconnect() {
    _ws?.close();
    _ws = null;
  }

  bool get isConnected => _ws != null;
}
