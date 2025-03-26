import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    await dotenv.load(fileName: ".env");
    print('LIVEKIT_URL: ${dotenv.env['LIVEKIT_URL']}');
    print('LIVEKIT_TOKEN: ${dotenv.env['LIVEKIT_TOKEN']}');
  } catch (e) {
    print('Failed to load .env file: $e');
  }
}