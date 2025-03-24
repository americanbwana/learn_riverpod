import 'dart:io';
import 'dart:async';

class K4ConnectionService {
  Socket? _socket; // TCP socket for the connection
  final StreamController<String> _responseController =
      StreamController.broadcast();

  // Step 1: Define a method to establish the connection
  // - Use Socket.connect() to connect to the K4 device on the specified host and port.
  // - Handle connection errors and update the state accordingly.
  Future<void> connect(String host, int port) async {
    try {
      _socket = await Socket.connect(host, port);
      print('Connected to K4 on $host:$port');
      sendCommand("IF;");

      // Step 3: Listen for incoming data from the socket
      // - Use _socket.listen() to handle incoming data.
      // - Convert the data to a string and add it to the _responseController stream.
      _socket!.listen(
        (data) {
          final response = String.fromCharCodes(data);
          _responseController.add(response); // Broadcast the response
        },
        onError: (error) {
          print('Socket error: $error');
          disconnect(); // Handle errors by disconnecting
        },
        onDone: () {
          print('Socket closed by the server');
          disconnect(); // Handle socket closure
        },
      );
    } catch (e) {
      print('Failed to connect: $e');
      rethrow; // Re-throw the error to handle it in the calling code
    }
  }

  // Step 4: Define a method to send commands to K4
  // - Write the command to the socket.
  // - Ensure the socket is connected before sending.
  void sendCommand(String command) {
    if (_socket != null) {
      _socket!.write(command);
      print('Command sent: $command');
    } else {
      print('Cannot send command: Socket is not connected');
    }
  }

  // Step 5: Define a method to disconnect
  // - Close the socket and clean up resources.
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    print('Disconnected from K4');
  }

  // Step 6: Expose the response stream
  // - Provide a getter for the _responseController's stream so other parts of the app can listen to responses.
  Stream<String> get responses => _responseController.stream;

  // Step 7: Dispose resources
  // - Close the StreamController when the service is no longer needed.
  void dispose() {
    _responseController.close();
  }

  // Check if the socket is connected
  bool isConnected() {
    return _socket != null;
  }
}

/*
Explanation of Steps
Establish the Connection:

Use Socket.connect() to connect to the K4 device.
Handle errors (e.g., connection failures) and update the state accordingly.
Send the Initial Command:

After the connection is established, send the initial command "IF;" to the K4 device.
Listen for Incoming Data:

Use _socket.listen() to listen for responses from the K4 device.
Convert the incoming data to a string and broadcast it using _responseController.
Send Commands:

Provide a method to send commands to the K4 device.
Ensure the socket is connected before attempting to send data.
Disconnect:

Provide a method to close the connection and clean up resources.
Expose the Response Stream:

Use a StreamController to broadcast incoming data so other parts of the app can listen to it.
Dispose Resources:

Close the StreamController when the service is no longer needed to avoid memory leaks.
Next Steps
Integrate with ConnectionStateNotifier:

Use this service in your ConnectionStateNotifier to manage the connection and update the state reactively.
For example, call connect() in the notifier and listen to the responses stream to update the state with incoming data.
Test the Connection:

Write a simple test script to verify that the connection works and responses are received correctly.
Handle Edge Cases:

Handle scenarios like reconnection, timeouts, and invalid responses.
*/
