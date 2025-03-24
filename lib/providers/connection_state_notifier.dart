import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_state.dart';
import '../services/connect_to_k4.dart';

class ConnectionStateNotifier extends StateNotifier<ConnectionState> {
  final K4ConnectionService _connectionService;

  ConnectionStateNotifier(this._connectionService)
      : super(ConnectionState.initial()) {
    // Listen to responses from the K4 device
    _connectionService.responses.listen((response) {
      state = state.copyWith(response: response);
    });
  }

  Future<void> connect(String host, int port) async {
    try {
      print("Connecting to $host:$port from connection state notifier");
      await _connectionService.connect(host, port);
      state = state.copyWith(status: ConnectionStatus.connected);
    } catch (e) {
      state = state.copyWith(
        status: ConnectionStatus.error,
        error: e.toString(),
      );
    }
  }

  void initializeState() {
    // Check if the connection is already established
    if (_connectionService.isConnected()) {
      state = state.copyWith(status: ConnectionStatus.connected);
    } else {
      state = state.copyWith(status: ConnectionStatus.disconnected);
    }
  }

  void sendCommand(String command) {
    try {
      print("Sending command: $command from connection state notifier");
      _connectionService.sendCommand(command);  // delegate to the service
    } catch (e) {
      state = state.copyWith(
        status: ConnectionStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    await _connectionService.disconnect();
    state = state.copyWith(status: ConnectionStatus.disconnected);  //delegate to the service
  }
}

final connectionStateNotifierProvider =
    StateNotifierProvider<ConnectionStateNotifier, ConnectionState>(
  (ref) => ConnectionStateNotifier(K4ConnectionService()),
);

/*
K4ConnectionService Handles the "How":

It knows how to send a command or disconnect from the K4 device.
It provides the actual implementation for these actions.
ConnectionStateNotifier Handles the "When" and "Why":

It decides when to call sendCommand or disconnect based on the app's state or user actions.
It updates the app's state after performing these actions.

Responsibilities of K4ConnectionService
The K4ConnectionService is a service class that directly interacts with the TCP connection. It:

Manages the socket connection (e.g., connecting, sending commands, receiving responses, disconnecting).
Provides a StreamController to broadcast responses from the K4 device.
Handles low-level errors (e.g., socket errors) and ensures the connection is properly closed.
This class is reusable and independent of any state management logic. It focuses solely on managing the connection.
*/