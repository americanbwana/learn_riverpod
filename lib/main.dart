import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import your screens and services.
import 'screens/connection_screen.dart';
import 'screens/livekit_screen.dart';
import 'config.dart';
import 'services/connect_to_k4.dart';
import 'services/livekit_connection_service.dart';
import 'providers/connection_state_notifier.dart';
import 'providers/livekit_connection_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file.
  try {
    await dotenv.load(fileName: ".env");
    print('LIVEKIT_URL: ${dotenv.env['LIVEKIT_URL']}');
  } catch (e) {
    print('Failed to load .env file: $e');
  }

  // Create an instance of LiveKitConnectionService.
  final liveKitService = LiveKitConnectionService();
  // Pass that into the K4ConnectionService.
  final k4ConnectionService = K4ConnectionService(liveKitService);
  // The services are now circular references to each other

  runApp(
    ProviderScope(
      overrides: [
        // Override both providers consistently using overrideWith
        connectionStateNotifierProvider.overrideWith(
          (ref) => ConnectionStateNotifier(k4ConnectionService),
        ),
        liveKitConnectionNotifierProvider.overrideWith(
          (ref) => LiveKitConnectionNotifier(liveKitService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn Riverpod',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Connection Example'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'K4 Connection'),
                Tab(text: 'LiveKit'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ConnectionScreen(),
              LiveKitScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
