import 'base_save_draft_then_reopen_scenario.dart';
import 'composer_content_mixins.dart';

class SaveDraftWithInlineImageThenOpenAndSaveDraftAgainScenario
    extends BaseSaveDraftThenReopenScenario with WithInlineImageContentMixin {
  const SaveDraftWithInlineImageThenOpenAndSaveDraftAgainScenario(super.$, super.robots);

  @override
  String get subject => 'Draft with inline image - second save';
}
