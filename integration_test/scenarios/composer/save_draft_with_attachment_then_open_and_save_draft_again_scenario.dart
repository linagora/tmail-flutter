import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../utils/wait_for_condition.dart';
import 'base_save_draft_then_reopen_scenario.dart';
import 'composer_content_mixins.dart';

class SaveDraftWithAttachmentThenOpenAndSaveDraftAgainScenario
    extends BaseSaveDraftThenReopenScenario with WithAttachmentContentMixin {
  const SaveDraftWithAttachmentThenOpenAndSaveDraftAgainScenario(super.$, super.robots);

  @override
  Future<void> onAfterContentUploaded() async {
    final attachmentsUploadedMessage = $(AppLocalizations().attachments_uploaded_successfully);
    await $(attachmentsUploadedMessage).waitUntilVisible();
    await waitForCondition(
      () => !$(attachmentsUploadedMessage).exists,
    );
  }

  @override
  String get subject => 'Draft with attachment - second save';
}
