import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';

part 'experimental_preferences_revealed_provider.g.dart';

@Riverpod(keepAlive: true)
Future<bool> experimentalPreferencesRevealed(Ref ref) async {
  return Get.find<PreferencesSettingManager>().getExperimentalPreferencesRevealed();
}
