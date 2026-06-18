import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';
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
  final userPref = ref
      .read(localSettingsProvider)
      .driveAttachmentConfig
      .isEnabled;
  if (!_canBuildUri(enabled: enabled, fqdn: fqdn, userPref: userPref)) return null;
  return Uri.tryParse(fqdn!);
}

@Riverpod(keepAlive: true)
ValueNotifier<Uri?> driveAttachmentUriValueNotifier(Ref ref) {
  final notifier = ValueNotifier<Uri?>(_computeUri(ref));
  void onUpdate(dynamic _, dynamic __) => notifier.value = _computeUri(ref);
  final subscriptions = <ProviderSubscription>[];
  subscriptions.add(ref.listen(workplaceFqdnProvider, onUpdate));
  subscriptions.add(ref.listen(driveAttachmentEnabledProvider, onUpdate));
  subscriptions.add(ref.listen(localSettingsProvider, onUpdate));
  ref.onDispose(() {
    notifier.dispose();
    for (var s in subscriptions) {
      s.close();
    }
  });
  return notifier;
}
