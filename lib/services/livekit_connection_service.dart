import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/livekit_connection_details.dart';
import 'token_service.dart';

/// Service to manage the connection to the LiveKit server.
/// This class handles:
/// - Connecting using URL from .env file and token from token server
/// - Listening for data messages and participant events
/// - Sending data via the local participant
/// - Disconnecting gracefully
class LiveKitConnectionService {
  Room? _room; // LiveKit Room instance
  TokenService? _tokenService;
  LivekitConnectionDetails? _connectionDetails;
  
  /// Creates a new LiveKitConnectionService
  ///
  /// By default, it will use the TokenService to fetch tokens.
  LiveKitConnectionService() {
    // Initialize token service with base URL from .env if available
    final tokenServerUrl = dotenv.env['TOKEN_SERVER_URL'];
    if (tokenServerUrl != null) {
      _tokenService = TokenService(tokenServerUrl); // Corrected: no named parameter
    }
  }

  /// Connect to the LiveKit server.
  Future<void> connect() async {
    // Get LiveKit URL from .env
    final url = dotenv.env['LIVEKIT_URL'];
    
    if (url == null) {
      throw Exception('LIVEKIT_URL is not defined in .env');
    }
    
    try {
      // If we have a token service, get a token
      if (_tokenService != null) {
        // Get room name and participant name from .env or use defaults
        final roomName = dotenv.env['LIVEKIT_ROOM_NAME'] ?? 'default-room';
        final participantName = dotenv.env['PARTICIPANT_NAME'] ?? 'flutter-client';
        
        // Get token from token service
        _connectionDetails = await _tokenService!.getToken(
          roomName: roomName,
          participantName: participantName,
        );
        
        // Now connect using the token and URL
        await _connectWithDetails(url, _connectionDetails!.token);
      } else {
        // Fall back to token in .env if token service is not available
        final token = dotenv.env['LIVEKIT_TOKEN'];
        if (token == null) {
          throw Exception('Neither TOKEN_SERVER_URL nor LIVEKIT_TOKEN is defined in .env');
        }
        
        await _connectWithDetails(url, token);
      }
    } catch (e) {
      print('Failed to connect to LiveKit server: $e');
      rethrow;
    }
  }
  
  /// Internal method to connect using the URL and token
  Future<void> _connectWithDetails(String url, String token) async {
    try {
      // Create a new Room instance with options
      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );

      // Connect to the LiveKit server using the provided URL and token.
      await _room!.connect(url, token);
      print('Connected to LiveKit server at $url');

      // Listen to the Room's events stream for all relevant events
      _room!.createListener().on<RoomEvent>((event) {
        print('Room event: ${event.runtimeType}');
      });

      // Set up specific listeners for different event types
      _room!.createListener()
        ..on<DataReceivedEvent>((event) {
          final message = String.fromCharCodes(event.data);
          final sender = event.participant?.identity ?? 'unknown';
          print('Data received from $sender: $message');
        })
        ..on<ParticipantConnectedEvent>((event) {
          print('Participant connected: ${event.participant.identity}');
        })
        ..on<ParticipantDisconnectedEvent>((event) {
          print('Participant disconnected: ${event.participant.identity}');
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
      // In LiveKit 2.4.1, LocalParticipant can be null, so use ?. operator
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
  
  /// Get the current connection details.
  LivekitConnectionDetails? get connectionDetails => _connectionDetails;
}