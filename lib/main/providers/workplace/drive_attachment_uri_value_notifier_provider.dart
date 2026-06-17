import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_user_preference_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

part 'drive_attachment_uri_value_notifier_provider.g.dart';

@Riverpod(keepAlive: true)
ValueNotifier<Uri?> driveAttachmentUriValueNotifier(Ref ref) {
  final notifier = ValueNotifier<Uri?>(null);

  Uri? compute() {
    final fqdn = ref.read(workplaceFqdnProvider);
    final enabled = ref.read(driveAttachmentEnabledProvider);
    final userPref = ref.read(driveAttachmentUserPreferenceProvider).asData?.value ?? false;
    if (!enabled || fqdn == null || fqdn.isEmpty || !userPref) return null;
    return Uri.tryParse(fqdn);
  }

  void onUpdate(dynamic _, dynamic __) => notifier.value = compute();

  notifier.value = compute();
  ref.listen(workplaceFqdnProvider, onUpdate);
  ref.listen(driveAttachmentEnabledProvider, onUpdate);
  ref.listen(driveAttachmentUserPreferenceProvider, onUpdate);
  ref.onDispose(notifier.dispose);
  return notifier;
}
