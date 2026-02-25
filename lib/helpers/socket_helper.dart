import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketHelper {
  static final SocketHelper _instance = SocketHelper._internal();
  IO.Socket? _socket;

  factory SocketHelper() {
    return _instance;
  }

  SocketHelper._internal();

  void connect() {
    if (_socket != null && _socket!.connected) {
      if (kDebugMode) {
        print("Socket is already connected");
      }
      return;
    }

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            'access_key': ACCESS_KEY,
            'roomid': '',
          })
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((data) {
      if (kDebugMode) {
        print("Socket connected");
      }
    });

    _socket!.onConnectError((data) {
      if (kDebugMode) {
        print("Socket connection error");
      }
    });

    _socket!.onDisconnect((data) {
      if (kDebugMode) {
        print("Socket disconnected");
      }
    });

    _socket!.onError((data) {
      if (kDebugMode) {
        print("Socket error");
      }
    });
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket == null) {
      if (kDebugMode) {
        print("Socket not intialized. Please call connect() first.");
      }
      return;
    }
    _socket!.on(event, callback);
  }

  void emit(String event, dynamic data) {
    if (_socket == null) {
      if (kDebugMode) {
        print("Socket not intialized. Please call connect() first.");
      }
      return;
    }
    _socket!.emit(event, data);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  bool get isConnected => _socket?.connected ?? false;
}
