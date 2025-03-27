// filepath: d:\flutter_projects\learn_riverpod\lib\screens\livekit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/livekit_connection_notifier.dart';

/// Screen to manage LiveKit interactions
class LiveKitScreen extends ConsumerWidget {
  const LiveKitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(liveKitConnectionNotifierProvider);

    return SizedBox(  // Add a SizedBox with a fixed height
      height: 300,    // Give it a reasonable height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('LiveKit Status: ${connectionState.status}'),
          if (connectionState.status == LiveKitConnectionStatus.error)
            Text('Error: ${connectionState.error}'),
          ElevatedButton(
            onPressed: connectionState.status == LiveKitConnectionStatus.disconnected
                ? () => ref
                    .read(liveKitConnectionNotifierProvider.notifier)
                    .connect()
                : null,
            child: Text('Connect to LiveKit'),
          ),
          ElevatedButton(
            onPressed: connectionState.status == LiveKitConnectionStatus.connected
                ? () => ref
                    .read(liveKitConnectionNotifierProvider.notifier)
                    .disconnect()
                : null,
            child: Text('Disconnect from LiveKit'),
          ),
          ElevatedButton(
            onPressed: connectionState.status == LiveKitConnectionStatus.connected
                ? () => ref
                    .read(liveKitConnectionNotifierProvider.notifier)
                    .sendData('Test message from LiveKitScreen')
                : null,
            child: Text('Send Test Message'),
          ),
        ],
      ),
    );
  }
}