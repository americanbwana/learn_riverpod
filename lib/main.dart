// main window
// will use flutter_riverpod for state management
// button will increment a value and update a text widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// my imports
import 'package:learn_riverpod/screens/connection_screen.dart';
import 'config.dart';
import 'services/connect_to_k4.dart';
import 'providers/connection_state_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the connection service
  final connectionService = K4ConnectionService();

  // Initialize the connection
  try {
    await connectionService.connect(k4Host, k4Port);
    print('Connected to K4 on $k4Host:$k4Port');
  } catch (e) {
    print('Failed to connect to K4: $e');
  }

  // Pass the connection service to the provider
  runApp(
    ProviderScope(
      overrides: [
        connectionStateNotifierProvider.overrideWith(
          (ref) => ConnectionStateNotifier(connectionService)..initializeState(),
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
                  /*
                  This tells Riverpod to "watch" the state of counterProvider. 
                  Whenever the state changes, Riverpod will automatically rebuild this part of the UI (the Text widget in this case) to reflect the new state.
                  */
                  final count = ref.watch(counterProvider);
                  return Text(
                    '$count',
                    // style: Theme.of(context).textTheme.headline4,
                  );
                },
              ),
              // add connection_screen here
              Expanded(child: ConnectionScreen(),),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          /* 
          ref.read(counterProvider.notifier): This gives you access to the StateController of the counterProvider. 
          The StateController is responsible for managing the state.
          .state++: This increments the current state of the counterProvider by 1.
          */
          onPressed: () => ref.read(counterProvider.notifier).state++,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
