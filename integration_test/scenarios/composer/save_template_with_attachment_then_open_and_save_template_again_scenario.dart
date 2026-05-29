import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../utils/wait_for_condition.dart';
import 'base_save_template_then_reopen_scenario.dart';
import 'composer_content_mixins.dart';

class SaveTemplateWithAttachmentThenOpenAndSaveTemplateAgainScenario
    extends BaseSaveTemplateThenReopenScenario with WithAttachmentContentMixin {
  const SaveTemplateWithAttachmentThenOpenAndSaveTemplateAgainScenario(super.$, super.robots);

  @override
  Future<void> onAfterContentUploaded() async {
    final attachmentsUploadedMessage = $(AppLocalizations().attachments_uploaded_successfully);
    await $(attachmentsUploadedMessage).waitUntilVisible();
    await waitForCondition(
      () => !$(attachmentsUploadedMessage).exists,
    );
  }

  @override
  String get subject => 'Template with attachment - second save';
}
