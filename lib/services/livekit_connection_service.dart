import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service to manage the connection to the LiveKit server.
/// This class handles:
/// - Connecting using URL and token from the .env file
/// - Listening for data messages and participant events via Room.events
/// - Sending data via the local participant
/// - Disconnecting gracefully
class LiveKitConnectionService {
  Room? _room; // LiveKit Room instance

  /// Connect to the LiveKit server.
  Future<void> connect() async {
    final url = dotenv.env['LIVEKIT_URL'];
    final token = dotenv.env['LIVEKIT_TOKEN'];

    if (url == null || token == null) {
      throw Exception('LIVEKIT_URL or LIVEKIT_TOKEN is not defined in .env');
    }

    try {
      // Create a new Room instance.
      _room = Room();

      // Connect to the LiveKit server using the provided URL and token.
      await _room!.connect(url, token);
      print('Connected to LiveKit server at $url');

      // Listen to the Room's events stream for all relevant events
      _room!.events.listen((event) {
        // Handle data received events
        if (event is DataReceivedEvent) {
          final message = String.fromCharCodes(event.data);
          final sender = event.participant?.identity ?? 'unknown';
          print('Data received from $sender: $message');
        } 
        // Handle new participant connections
        else if (event is ParticipantConnectedEvent) {
          print('Participant connected: ${event.participant.identity}');
        }
        // Handle participant disconnections 
        else if (event is ParticipantDisconnectedEvent) {
          print('Participant disconnected: ${event.participant.identity}');
        }
      });
    } catch (e) {
      print('Failed to connect to LiveKit server: $e');
      rethrow;
    }
  }

  /// Send a message over the LiveKit data channel.
  Future<void> sendData(String message) async {
    if (_room == null || _room!.connectionState != ConnectionState.connected) {
      print('Cannot send data: Not connected to LiveKit');
      return;
    }

    try {
      // Publish data via the local participant.
      await _room!.localParticipant?.publishData(
        message.codeUnits, // Convert the message to a list of code units.
      );
      print('Data sent: $message');
    } catch (e) {
      print('Failed to send data: $e');
    }
  }

  /// Disconnect from the LiveKit server.
  Future<void> disconnect() async {
    await _room?.disconnect();
    _room = null;
    print('Disconnected from LiveKit server');
  }

  /// Check if connected to LiveKit.
  bool isConnected() {
    return _room?.connectionState == ConnectionState.connected;
  }

  /// Get the current Room instance.
  Room? get room => _room;
}