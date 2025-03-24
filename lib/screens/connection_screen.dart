// Screen to display the connection status and responses from K4
// Tasks:
// - Use a ConsumerWidget to watch the connection state
// - Display the connection status and latest response
// - Provide a button or input field to send commands to K4

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
// import '../providers/connection_provider.dart';
import '../models/connection_state.dart';
import '../providers/connection_state_notifier.dart';

class ConnectionScreen extends ConsumerWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('K4 Connection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Status: ${connectionState.status}'),
            Text('Response: ${connectionState.response ?? "No response"}'),
            if (connectionState.status == ConnectionStatus.error)
              Text('Error: ${connectionState.error ?? "Unknown error"}'),
            ElevatedButton(
              onPressed: connectionState.status == ConnectionStatus.connected
                  ? () {
                      ref.read(connectionStateNotifierProvider.notifier).sendCommand('FA;');
                    }
                  : null,
              child: Text('Send Test Command'),
            ),
          ],
        ),
      ),
    );
  }
}
// The `ConnectionScreen` widget displays the connection status and responses from the K4 device. It uses a `ConsumerWidget` to watch the connection state provided by `connectionStateNotifierProvider`. The widget shows the connection status, the latest response received from the K4 device, and any errors that occurred during the connection process.