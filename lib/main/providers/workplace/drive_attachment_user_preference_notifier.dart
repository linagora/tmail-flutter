import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'drive_attachment_user_preference_notifier.g.dart';

@Riverpod(keepAlive: true)
Future<bool> driveAttachmentUserPreference(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('PREFERENCES_SETTING_DRIVE_ATTACHMENT');
  if (jsonString == null) return false;
  try {
    return (jsonDecode(jsonString) as Map<String, dynamic>)['isEnabled'] as bool? ?? false;
  } catch (_) {
    return false;
  }
}
