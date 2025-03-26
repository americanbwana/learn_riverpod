import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/livekit_connection_service.dart';

enum LiveKitConnectionStatus { connected, disconnected, error }

class LiveKitConnectionState {
  final LiveKitConnectionStatus status;
  final String? error;

  LiveKitConnectionState({
    required this.status,
    this.error,
  });

  factory LiveKitConnectionState.initial() {
    return LiveKitConnectionState(status: LiveKitConnectionStatus.disconnected);
  }

  LiveKitConnectionState copyWith({
    LiveKitConnectionStatus? status,
    String? error,
  }) {
    return LiveKitConnectionState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class LiveKitConnectionNotifier extends StateNotifier<LiveKitConnectionState> {
  final LiveKitConnectionService _connectionService;

  LiveKitConnectionNotifier(this._connectionService)
      : super(LiveKitConnectionState.initial());

  Future<void> connect() async {
    try {
      await _connectionService.connect();
      state = state.copyWith(status: LiveKitConnectionStatus.connected);
    } catch (e) {
      state = state.copyWith(
        status: LiveKitConnectionStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    await _connectionService.disconnect();
    state = state.copyWith(status: LiveKitConnectionStatus.disconnected);
  }
}

final liveKitConnectionNotifierProvider =
    StateNotifierProvider<LiveKitConnectionNotifier, LiveKitConnectionState>(
  (ref) => LiveKitConnectionNotifier(LiveKitConnectionService()),
);