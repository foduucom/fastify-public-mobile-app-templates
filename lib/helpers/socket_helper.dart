import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class SocketHelper {
  static final SocketHelper _instance = SocketHelper._internal();
  IO.Socket? _socket;
  final List<String> _activeListeners = [];
  final isConnectedObs = false.obs;

  factory SocketHelper() {
    return _instance;
  }

  SocketHelper._internal();

  void connect() {
    if (_socket != null && _socket!.connected) {
      print("✅ Socket is already connected");
      print("🔗 Socket URL: $socketUrl");
      print("📡 Connection Status: CONNECTED");
      isConnectedObs.value = true;
      return;
    }

    if (_socket != null) {
      print("🔄 Socket already initialized, reconnecting...");
      print("🔗 Socket URL: $socketUrl");
      _socket!.connect();
      return;
    }

    _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({'access_key': ACCESS_KEY})
            .build());

    _socket!.connect();

    _socket!.onConnect((data) {
      isConnectedObs.value = true;
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("✅ Socket CONNECTED successfully!");
      print("🔗 Connected to: $socketUrl");
      print("🆔 Socket ID: ${_socket?.id}");
      print("📡 Connection Status: CONNECTED");
      print("👂 Active Listeners (${_activeListeners.length}):");
      for (var listener in _activeListeners) {
        print("   - $listener");
      }
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    });

    _socket!.onConnectError((data) {
      isConnectedObs.value = false;
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("❌ Socket CONNECTION ERROR");
      print("🔗 Attempted URL: $socketUrl");
      print("📄 Error Details: $data");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    });

    _socket!.onDisconnect((data) {
      isConnectedObs.value = false;
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("⚠️  Socket DISCONNECTED");
      print("🔗 Was connected to: $socketUrl");
      print("📄 Disconnect Reason: $data");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    });

    _socket!.onError((data) {
      isConnectedObs.value = false;
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("❌ Socket ERROR");
      print("📄 Error Details: $data");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    });
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket == null) {
      print("❌ Socket not initialized. Please call connect() first.");
      return;
    }

    try {
      _socket!.on(event, (data) {
        callback(data);
      });

      if (!_activeListeners.contains(event)) {
        _activeListeners.add(event);
      }
    } catch (e) {
      print("❌ Error setting up listener for event: '$event'");
      print("📄 Error: $e");
    }
  }

  void emit(String event, dynamic data) {
    if (_socket == null) {
      print("Socket not intialized. Please call connect() first.");
      return;
    }
    _socket!.emit(event, data);
  }

  void off(String event) {
    _socket?.off(event);
    _activeListeners.remove(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnectedObs.value = false;
  }

  bool get isConnected => _socket?.connected ?? false;
}
