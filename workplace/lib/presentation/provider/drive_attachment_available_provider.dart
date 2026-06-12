import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workplace/presentation/provider/drive_attachment_enabled_notifier.dart';
import 'package:workplace/presentation/provider/drive_attachment_user_preference_notifier.dart';
import 'package:workplace/presentation/provider/workplace_fqdn_notifier.dart';

part 'drive_attachment_available_provider.g.dart';

@riverpod
bool isDriveAttachmentAvailable(Ref ref) {
  final fqdn = ref.watch(workplaceFqdnProvider);
  final enabled = ref.watch(driveAttachmentEnabledProvider);
  final userPreference = ref.watch(driveAttachmentUserPreferenceProvider).asData?.value ?? false;
  return enabled && fqdn != null && fqdn.isNotEmpty && userPreference;
}
