import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/livekit_connection_details.dart';

/// Service responsible for fetching LiveKit tokens from the upstream token server
class TokenService {
  final String _baseUrl;

  /// Creates a new TokenService with the specified base URL
  TokenService(String baseUrl) : _baseUrl = baseUrl;

  // Get the API_KEY 
  static final String _apiKey = dotenv.env['APP_API_KEY'] ?? '';

  /// Fetches a new LiveKit token for the specified room and participant
  Future<LivekitConnectionDetails> getToken({
    required String roomName,
    required String participantName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey, // Include API key in headers
        },
        body: jsonEncode({
          'roomName': roomName,
          'participantName': participantName,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Received token response: ${jsonResponse.toString().substring(0, 50)}...'); // Log truncated response

        return LivekitConnectionDetails(
          url: jsonResponse['url'],
          token: jsonResponse['token'],
          roomName: roomName,
          participantName: participantName,
        );
      } else {
        throw Exception('Failed to get token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching token: $e');
      rethrow;
    }
  }
}

/// Provider for token service
final tokenServiceProvider = Provider<TokenService>((ref) {
  final baseUrl = dotenv.env['TOKEN_SERVER_URL'] ?? '';
  return TokenService(baseUrl);
});

/// Provider that exposes connection details
final connectionDetailsProvider = FutureProvider<LivekitConnectionDetails>((ref) async {
  final tokenService = ref.watch(tokenServiceProvider);
  final roomName = dotenv.env['LIVEKIT_ROOM_NAME'] ?? 'test-room';
  final participantName = 'user-${DateTime.now().millisecondsSinceEpoch}';
  return await tokenService.getToken(roomName: roomName, participantName: participantName);
});