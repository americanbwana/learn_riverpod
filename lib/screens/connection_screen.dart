// Screen to display the connection status and responses from K4
// Tasks:
// - Use a ConsumerWidget to watch the connection state
// - Display the connection status and latest response
// - Provide a button or input field to send commands to K4

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_state.dart';
import '../providers/connection_state_notifier.dart'; // Make sure this is correct
import '../config.dart'; // Import config to get host and port

class ConnectionScreen extends ConsumerWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the connection state
    final connectionState = ref.watch(connectionStateNotifierProvider);
    // add livekit connection state
    // final liveKitConnectionState = ref.watch(liveKitConnectionNotifierProvider);

    // Remove the Scaffold and just use a container with padding
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use min to prevent expansion
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Status: ${connectionState.status}'),
              const SizedBox(height: 8),
              Text('Response: ${connectionState.response ?? 'No response'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                // Only allow connect if disconnected
                onPressed: connectionState.status == ConnectionStatus.disconnected
                    ? () => ref.read(connectionStateNotifierProvider.notifier)
                        .connect(k4Host, k4Port) // Use config values
                    : null,
                child: const Text('Connect'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: connectionState.status == ConnectionStatus.connected
                    ? () => ref.read(connectionStateNotifierProvider.notifier).sendCommand('FA;')
                    : null,
                child: const Text('Send Command'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: connectionState.status == ConnectionStatus.connected
                    ? () => ref.read(connectionStateNotifierProvider.notifier).disconnect()
                    : null,
                child: const Text('Disconnect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}