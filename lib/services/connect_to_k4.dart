import 'dart:io';
import 'dart:async';
import 'livekit_connection_service.dart';

/// Service to manage the connection to the K4 device.
/// Requires a LiveKitConnectionService to forward responses via the data channel.
class K4ConnectionService {
  Socket? _socket; // TCP socket for the connection
  final StreamController<String> _responseController =
      StreamController.broadcast(); // Make it a broadcast controller
  // LiveKit service for sending data.
  final LiveKitConnectionService _liveKitService;

  /// Constructor now requires a LiveKitConnectionService.
  K4ConnectionService(this._liveKitService) {
    // Set the K4 service in LiveKit to enable command forwarding
    _liveKitService.setK4Service(this);
    
    // Listen for data received from LiveKit to forward to K4
    _liveKitService.dataReceived.listen((message) {
      if (isConnected()) {
        // If message doesn't end with a semicolon, add it
        final formattedCommand = message.trim().endsWith(';') 
            ? message.trim() 
            : '${message.trim()};';
        sendCommand(formattedCommand);
      }
    });
  }

  Future<void> connect(String host, int port) async {
    // If already connected, don't reconnect
    if (_socket != null) {
      print('Already connected to K4');
      return;
    }

    try {
      print('Connecting to K4 on $host:$port');
      _socket = await Socket.connect(host, port);
      print('Connected to K4 on $host:$port');

      // Use a single stream subscription
      _socket!.listen(
        (data) {
          final response = String.fromCharCodes(data);
          print('Response received: $response');
          _responseController.add(response);
          
          // If LiveKit is connected, forward the response
          if (_liveKitService.isConnected()) {
            _liveKitService.sendData(response);
          } else {
            print('Cannot send data: Not connected to LiveKit');
          }
        },
        onError: (error) {
          print('Socket error: $error');
          _responseController.addError(error);
        },
        onDone: () {
          print('Socket closed');
          _socket = null;
        },
      );

      // Send initial command
      sendCommand('IF;');
    } catch (e) {
      print('Failed to connect to K4: $e');
      rethrow;
    }
  }

  void sendCommand(String command) {
    if (_socket != null) {
      _socket!.write(command);
      print('Command sent: $command');
    } else {
      print('Cannot send command: Socket is not connected');
    }
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    print('Disconnected from K4');
  }

  bool isConnected() => _socket != null;

  Stream<String> get responses => _responseController.stream;

  /// Dispose resources to avoid memory leaks
  void dispose() {
    _responseController.close();
  }
}
