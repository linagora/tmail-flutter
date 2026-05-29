import 'base_save_template_then_reopen_scenario.dart';
import 'composer_content_mixins.dart';

class SaveTemplateWithInlineImageThenOpenAndSaveTemplateAgainScenario
    extends BaseSaveTemplateThenReopenScenario with WithInlineImageContentMixin {
  const SaveTemplateWithInlineImageThenOpenAndSaveTemplateAgainScenario(super.$, super.robots);

  @override
  Future<void> onAfterContentUploaded() async {
    await $.pumpAndTrySettle(duration: const Duration(seconds: 2));
  }

  @override
  String get subject => 'Template with inline image - second save';
}
