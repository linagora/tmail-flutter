import 'base_save_template_then_reopen_scenario.dart';
import 'composer_content_mixins.dart';

class SaveTemplateWithAttachmentThenOpenAndSaveTemplateAgainScenario
    extends BaseSaveTemplateThenReopenScenario with WithAttachmentContentMixin {
  const SaveTemplateWithAttachmentThenOpenAndSaveTemplateAgainScenario(super.$, super.robots);

  @override
  String get subject => 'Template with attachment - second save';
}
