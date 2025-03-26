// Define a StateNotifierProvider to manage the connection state and logic
// This provider will expose the connection state and allow sending commands
// Tasks:
// - Create a StateNotifier class to manage the connection
// - Define a provider to expose the StateNotifier
// - Handle connection initialization, data reception, and command sending

import 'package:flutter_riverpod/flutter_riverpod.dart';

// import my models
import '../models/livekit_connection_state.dart';