import 'base_save_draft_then_reopen_scenario.dart';
import 'composer_content_mixins.dart';

class SaveDraftWithAttachmentThenOpenAndSaveDraftAgainScenario
    extends BaseSaveDraftThenReopenScenario with WithAttachmentContentMixin {
  const SaveDraftWithAttachmentThenOpenAndSaveDraftAgainScenario(super.$, super.robots);

  @override
  String get subject => 'Draft with attachment - second save';
}
