import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_state.dart';
import '../services/connect_to_k4.dart';
import '../services/livekit_connection_service.dart';

/// The ConnectionStateNotifier is responsible for managing the connection state for the K4 device.
/// It delegates the actual work to K4ConnectionService.
/// K4ConnectionService now requires a LiveKitConnectionService, so we supply it in the provider.
class ConnectionStateNotifier extends StateNotifier<ConnectionState> {
  final K4ConnectionService _connectionService;

  ConnectionStateNotifier(this._connectionService)
      : super(ConnectionState.initial()) {
    // Listen for responses coming from the K4 device.
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
    if (_connectionService.isConnected()) {
      state = state.copyWith(status: ConnectionStatus.connected);
    } else {
      state = state.copyWith(status: ConnectionStatus.disconnected);
    }
  }

  void sendCommand(String command) {
    try {
      print("Sending command: $command from connection state notifier");
      _connectionService.sendCommand(command); // delegate to the service
    } catch (e) {
      state = state.copyWith(
        status: ConnectionStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    await _connectionService.disconnect();
    state = state.copyWith(status: ConnectionStatus.disconnected);
  }
}

/// The provider now constructs ConnectionStateNotifier by passing a K4ConnectionService
/// that is created with an instance of LiveKitConnectionService.
final connectionStateNotifierProvider =
    StateNotifierProvider<ConnectionStateNotifier, ConnectionState>(
  (ref) => ConnectionStateNotifier(
      K4ConnectionService(LiveKitConnectionService())),
);