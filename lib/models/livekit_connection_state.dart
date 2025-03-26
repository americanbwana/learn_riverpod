// Enum to represent the connection status
enum LivekitConnectionStatus { connected, connecting, reconnecting, disconnected}

// Define a model to represent the connection state
class ConnectionState {
  final LivekitConnectionStatus status; // Connection status (e.g., connected, connecting, reconnecting, disconnectedr)
  final String? response;        // Latest response from livekit (optional)
  final String? error;           // Error message, if any (optional) - ConnectException string

  ConnectionState({
    required this.status,
    this.response,
    this.error,
  });

  // class to represent the connection state notifier 
  

  // Initial state (disconnected, no response, no error)
  ConnectionState.initial()
      : status = LivekitConnectionStatus.disconnected,
        response = null,
        error = null;

  // CopyWith method for immutability
  ConnectionState copyWith({
    LivekitConnectionStatus? status,
    String? response,
    String? error,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }
}

/*
Why These Changes?
Enum for status: Prevents invalid states and makes the code more readable and type-safe.
Optional Fields: Reflects real-world scenarios where response and error might not always be present.
Default State: Simplifies initialization and ensures a consistent starting point.
CopyWith Method: Makes it easier to update the state immutably, which is essential for state management in Riverpod.
This updated model is more robust, flexible, and aligned with best practices for state management in Flutter.

*/