import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_user_preference_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

part 'drive_attachment_uri_value_notifier_provider.g.dart';

bool _canBuildUri({
  required bool enabled,
  required String? fqdn,
  required bool userPref,
}) =>
    enabled && fqdn != null && fqdn.isNotEmpty && userPref;

Uri? _computeUri(Ref ref) {
  final fqdn = ref.read(workplaceFqdnProvider);
  final enabled = ref.read(driveAttachmentEnabledProvider);
  final userPref = ref.read(driveAttachmentUserPreferenceProvider).asData?.value ?? false;
  if (!_canBuildUri(enabled: enabled, fqdn: fqdn, userPref: userPref)) return null;
  return Uri.tryParse(fqdn!);
}

@Riverpod(keepAlive: true)
ValueNotifier<Uri?> driveAttachmentUriValueNotifier(Ref ref) {
  final notifier = ValueNotifier<Uri?>(_computeUri(ref));
  void onUpdate(dynamic _, dynamic __) => notifier.value = _computeUri(ref);
  ref.listen(workplaceFqdnProvider, onUpdate);
  ref.listen(driveAttachmentEnabledProvider, onUpdate);
  ref.listen(driveAttachmentUserPreferenceProvider, onUpdate);
  ref.onDispose(notifier.dispose);
  return notifier;
}
