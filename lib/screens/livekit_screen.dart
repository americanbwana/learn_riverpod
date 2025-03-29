// filepath: d:\flutter_projects\learn_riverpod\lib\screens\livekit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/livekit_connection_notifier.dart';

class LiveKitScreen extends ConsumerWidget {
  const LiveKitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(liveKitConnectionNotifierProvider);
    
    // Get the connection service using the public getter
    final connectionService = ref.read(liveKitConnectionNotifierProvider.notifier)
        .connectionService;
    
    // Get connection details if available
    final connectionDetails = connectionService.connectionDetails;
    
    // Get room information if connected
    final room = connectionService.room;
    final localParticipant = room?.localParticipant;
    final participants = room?.remoteParticipants.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LiveKit Status: ${connectionState.status}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              
              // Display connection details when connected
              if (connectionState.status == LiveKitConnectionStatus.connected) ...[
                // Room info
                const Text('Room Information:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Room Name: ${connectionDetails?.roomName ?? room?.name ?? 'Unknown'}'),
                Text('Participants: $participants other participants'),
                const SizedBox(height: 8),
                
                // Local participant info
                const Text('Your Information:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Participant Name: ${connectionDetails?.participantName ?? localParticipant?.identity ?? 'Unknown'}'),
                Text('Participant ID: ${localParticipant?.sid ?? 'Unknown'}'),
                const SizedBox(height: 16),
                
                // Information about command forwarding
                const Divider(),
                const Text('Commands from LiveKit will be automatically forwarded to K4 if connected',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Show message that commands are being forwarded
                const Text('Note: Responses from K4 are also sent to LiveKit participants',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
              
              // Display error if any
              if (connectionState.status == LiveKitConnectionStatus.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text('Error: ${connectionState.error}',
                      style: const TextStyle(color: Colors.red)),
                ),
              
              const SizedBox(height: 16),
              // Connect button  
              ElevatedButton(
                onPressed: connectionState.status == LiveKitConnectionStatus.disconnected
                    ? () => ref.read(liveKitConnectionNotifierProvider.notifier).connect()
                    : null,
                child: const Text('Connect to LiveKit'),
              ),
              const SizedBox(height: 8),
              
              // Disconnect button
              ElevatedButton(
                onPressed: connectionState.status == LiveKitConnectionStatus.connected
                    ? () => ref.read(liveKitConnectionNotifierProvider.notifier).disconnect()
                    : null,
                child: const Text('Disconnect from LiveKit'),
              ),
              const SizedBox(height: 8),
              
              // Send test message button
              ElevatedButton(
                onPressed: connectionState.status == LiveKitConnectionStatus.connected
                    ? () => ref.read(liveKitConnectionNotifierProvider.notifier)
                        .sendData('Test message from LiveKitScreen')
                    : null,
                child: const Text('Send Test Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}