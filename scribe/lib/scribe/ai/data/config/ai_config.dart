import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIConfig {
  const AIConfig._();

  static bool get isAiEnabled => dotenv.get('AI_ENABLED', fallback: 'false') == 'true';
}
