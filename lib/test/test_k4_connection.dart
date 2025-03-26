// to run this test, use the command: dart test/test_k4_connection.dart

import 'dart:async';
import "package:learn_riverpod/services/connect_to_k4.dart";
import "package:learn_riverpod/services/livekit_connection_service.dart";

void main() async {
  // Create a LiveKitConnectionService to pass to K4ConnectionService
  final liveKitService = LiveKitConnectionService();
  
  // Create K4ConnectionService with the required LiveKitConnectionService
  final k4Service = K4ConnectionService(liveKitService);

  // Define the host and port for the K4 device
  const host = '192.168.1.16'; // Replace with the actual host
  const port = 9200;        // Replace with the actual port

  try {
    // Step 1: Connect to the K4 device
    print('Connecting to K4...');
    await k4Service.connect(host, port);

    // Step 2: Listen to responses from the K4 device
    final subscription = k4Service.responses.listen(
      (response) {
        print('Received response: $response');
      },
      onError: (error) {
        print('Error: $error');
      },
      onDone: () {
        print('Connection closed.');
      },
    );

    // Step 3: Send a test command
    print('Sending test command...');
    k4Service.sendCommand('FA;');

    // Wait for a few seconds to receive responses
    await Future.delayed(Duration(seconds: 5));

    // Step 4: Disconnect from the K4 device
    print('Disconnecting...');
    await k4Service.disconnect();

    // Cancel the subscription to the response stream
    await subscription.cancel();
  } catch (e) {
    print('An error occurred: $e');
  } finally {
    // If the K4ConnectionService has a dispose method,
    // uncomment the line below
    // k4Service.dispose();
  }
}
