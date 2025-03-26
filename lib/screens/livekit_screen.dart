// filepath: d:\flutter_projects\learn_riverpod\lib\screens\livekit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/livekit_connection_notifier.dart';

class LiveKitScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(liveKitConnectionNotifierProvider);

    return Column(
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
      ],
    );
  }
}