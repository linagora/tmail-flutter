import 'package:flutter/foundation.dart';

// Mobile: the mock input owns the connection so the platform IME never overwrites entered text.
// Web profile drops text sent to client -1; web debug keeps the browser's.
bool get registerMockTextInput => !kIsWeb || !kDebugMode;
