import '../../base/test_base.dart';
import '../../scenarios/download_all_attachments_scenario.dart';
import '../../scenarios/login_with_basic_auth_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see save dialog when download all attachments successfully',
    test: ($) async {
      final loginWithBasicAuthScenario = LoginWithBasicAuthScenario($,
        username: const String.fromEnvironment('USERNAME'),
        hostUrl: const String.fromEnvironment('BASIC_AUTH_URL'),
        email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        password: const String.fromEnvironment('PASSWORD'),
      );

      final downloadAllAttachmentsScenario = DownloadAllAttachmentsScenario($,
        loginWithBasicAuthScenario: loginWithBasicAuthScenario,
        attachmentContents: ['file1', 'file2', 'file3'],
      );

      await downloadAllAttachmentsScenario.execute();
    }
  );
}