import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/livekit_connection_service.dart';

/// Represents the LiveKit connection state.
class LiveKitConnectionState {
  final bool isConnected;
  final String? error;

  LiveKitConnectionState({
    required this.isConnected,
    this.error,
  });

  factory LiveKitConnectionState.initial() {
    return LiveKitConnectionState(isConnected: false);
  }

  LiveKitConnectionState copyWith({
    bool? isConnected,
    String? error,
  }) {
    return LiveKitConnectionState(
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

/// A StateNotifier that wraps LiveKitConnectionService
/// to manage connection, disconnection and data sending.
class LiveKitConnectionNotifier extends StateNotifier<LiveKitConnectionState> {
  final LiveKitConnectionService _liveKitService;

  LiveKitConnectionNotifier(this._liveKitService)
      : super(LiveKitConnectionState.initial());

  /// Connects to the LiveKit server.
  Future<void> connect() async {
    try {
      await _liveKitService.connect();
      state = state.copyWith(isConnected: true, error: null);
    } catch (e) {
      state = state.copyWith(isConnected: false, error: e.toString());
    }
  }

  /// Disconnects from the LiveKit server.
  Future<void> disconnect() async {
    await _liveKitService.disconnect();
    state = state.copyWith(isConnected: false, error: null);
  }

  /// Sends a message over the LiveKit data channel.
  Future<void> sendData(String message) async {
    try {
      await _liveKitService.sendData(message);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// The LiveKitConnectionProvider, exposing the notifier and state.
final liveKitConnectionProvider =
    StateNotifierProvider<LiveKitConnectionNotifier, LiveKitConnectionState>(
  (ref) => LiveKitConnectionNotifier(LiveKitConnectionService()),
);

