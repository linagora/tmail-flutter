import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIConfig {
  const AIConfig._();

  static bool get isAiEnabled => dotenv.get('AI_ENABLED', fallback: 'false') == 'true';

  static String get aiApiKey => dotenv.get('AI_API_KEY', fallback: '');

  static String get aiApiUrl => dotenv.get('AI_API_URL', fallback: '');
}
