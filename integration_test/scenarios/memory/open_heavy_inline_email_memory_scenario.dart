import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../memory/heavy_png.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import 'memory_leak_scenario.dart';

class OpenHeavyInlineEmailMemoryScenario extends MemoryLeakScenario {
  const OpenHeavyInlineEmailMemoryScenario(super.$, super.robots);

  static const _user = String.fromEnvironment('BASIC_AUTH_EMAIL');
  static const _imageLoadWait = Duration(seconds: 5);

  @override
  String get caseId => 'open_heavy_inline_email';

  @override
  Future<void> runCycle(MemoryCycle cycle) async {
    final subject = 'Memory heavy inline ${cycle.name}';
    await robots.commonRobot().provisionEmail([
      ProvisioningEmail(
        toEmail: _user,
        subject: subject,
        content: '<p>heavy</p><img src="cid:{{inline0}}">',
        inlineFileInfos: [
          FileBytesInfo(bytes: heavyImageBytes, fileName: 'heavy.png'),
        ],
      ),
    ]);

    await robots.threadRobot().openEmailWithSubject(subject);
    await waitForCondition(
      () =>
          $(HtmlContentViewer).evaluate().isNotEmpty ||
          $(HtmlContentViewerOnWeb).evaluate().isNotEmpty,
      timeout: TestTimeouts.long,
      reason: 'The opened email should render its HTML body',
    );
    // The inline image is fetched after the body renders.
    await $.pumpAndTrySettle(duration: _imageLoadWait);

    await _declineReadReceipt();
    await _leaveEmail();
  }

  /// The provisioned mail requests a read receipt; its prompt blocks the page.
  Future<void> _declineReadReceipt() async {
    final prompt = $(#confirm_dialog_action);
    if (!prompt.exists) return;
    await prompt.$(AppLocalizations().no).tap();
  }

  /// Closes the email with its back button; a web side pane without one is
  /// closed by switching folder and coming back.
  Future<void> _leaveEmail() async {
    if (PlatformInfo.isMobile || $(EmailViewBackButton).exists) {
      await EmailRobot($).onTapBackButton();
      return;
    }
    final l10n = AppLocalizations();
    final menu = robots.mailboxMenuRobot();
    for (final folder in [l10n.sentMailboxDisplayName, l10n.inboxMailboxDisplayName]) {
      await menu.navigation.openFolder(menu.mailboxItemByName(folder));
    }
  }
}
