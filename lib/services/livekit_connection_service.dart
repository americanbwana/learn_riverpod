// handle the low level connections to livekit server
// will use basic sample from livekit dart client
// use the livekit_client package

import 'package:livekit_client/livekit_client.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LiveKitConnectionService {
  Room? _room;

  // Connect to the LiveKit server
  Future<void> connect() async {
    final url = dotenv.env['LIVEKIT_URL'];
    final token = dotenv.env['LIVEKIT_TOKEN'];

    if (url == null || token == null) {
      throw Exception('LIVEKIT_URL or LIVEKIT_TOKEN is not defined in .env');
    }

    try {
      // Create a new Room instance
      _room = Room();

      // Connect to the LiveKit server
      await _room!.connect(url, token);
      print('Connected to LiveKit server at $url');
    } catch (e) {
      print('Failed to connect to LiveKit server: $e');
      rethrow;
    }
  }

  // Disconnect from the LiveKit server
  Future<void> disconnect() async {
    await _room?.disconnect();
    _room = null;
    print('Disconnected from LiveKit server');
  }

  // Check if connected
  bool isConnected() {
    return _room?.connectionState == ConnectionState.connected;
  }

  // Get the current room instance
  Room? get room => _room;
}