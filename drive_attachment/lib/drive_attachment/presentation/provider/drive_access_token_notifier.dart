import 'package:core/utils/app_logger.dart';
import 'package:drive_attachment/drive_attachment/presentation/provider/drive_attachment_providers.dart';
import 'package:drive_attachment/drive_attachment/presentation/provider/workplace_fqdn_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drive_access_token_notifier.g.dart';

@riverpod
class DriveAccessTokenNotifier extends _$DriveAccessTokenNotifier {
  @override
  Future<String?> build() async {
    final fqdn = ref.watch(workplaceFqdnProvider);
    if (fqdn == null) return null;

    final oidcIdToken = getDriveOidcIdToken();
    if (oidcIdToken == null) return null;
    final platformUrl = Uri.parse(fqdn.startsWith('http') ? fqdn : 'https://$fqdn');
    try {
      return await ref.read(driveAttachmentRepositoryProvider).exchangeToken(platformUrl, oidcIdToken);
    } catch (e) {
      logError('DriveAccessTokenNotifier: token exchange failed: $e');
      return null;
    }
  }

  void onUnauthorized() => ref.invalidateSelf();
}
