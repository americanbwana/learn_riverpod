// main window
// will use flutter_riverpod for state management
// button will increment a value and update a text widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// my imports
import 'package:learn_riverpod/screens/connection_screen.dart';
import 'package:learn_riverpod/screens/livekit_screen.dart'; // Import LiveKit screen
import 'config.dart';
import 'services/connect_to_k4.dart';
import 'services/livekit_connection_service.dart'; // Import LiveKit service
import 'providers/connection_state_notifier.dart';
import 'providers/livekit_connection_notifier.dart'; // Import LiveKit notifier
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    // Load the .env file
    try {
    await dotenv.load(fileName: ".env");
    print('LIVEKIT_URL: ${dotenv.env['LIVEKIT_URL']}');
    print('LIVEKIT_TOKEN: ${dotenv.env['LIVEKIT_TOKEN']}');
  } catch (e) {
    print('Failed to load .env file: $e');
  }

  // Create the K4 connection service
  final k4ConnectionService = K4ConnectionService();

  // Initialize the K4 connection
  try {
    await k4ConnectionService.connect(k4Host, k4Port);
    print('Connected to K4 on $k4Host:$k4Port');
  } catch (e) {
    print('Failed to connect to K4: $e');
  }

  // Create the LiveKit connection service
  final liveKitConnectionService = LiveKitConnectionService();

  // Initialize the LiveKit connection
  try {
    await liveKitConnectionService.connect();
    print('Connected to LiveKit server');
  } catch (e) {
    print('Failed to connect to LiveKit server: $e');
  }

  // Pass the services to their respective providers
  runApp(
    ProviderScope(
      overrides: [
        connectionStateNotifierProvider.overrideWith(
          (ref) => ConnectionStateNotifier(k4ConnectionService)..initializeState(),
        ),
        liveKitConnectionNotifierProvider.overrideWith(
          (ref) => LiveKitConnectionNotifier(liveKitConnectionService),
        ),
      ],
      child: MyApp(),
    ),
  );
}

// this is the state provider, with initial value of 0
final counterProvider = StateProvider<int>((ref) => 0);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Counter App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('You have pushed the button this many times:'),
              Consumer(
                builder: (context, ref, child) {
                  // Watch the counterProvider state
                  final count = ref.watch(counterProvider);
                  return Text(
                    '$count',
                  );
                },
              ),
              // Add the K4 connection screen
              Expanded(child: ConnectionScreen()),
              // Add the LiveKit connection screen
              Expanded(child: LiveKitScreen()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
