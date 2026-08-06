import 'package:core/utils/html/editor_script/quoted_reply_enter_handler_script.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_adapter.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';
import 'package:workplace/presentation/utils/workplace_scripts.dart';

final class WebEditorInteractionScriptGroup
    with WebEditorScriptAdapterAware
    implements WebEditorScriptGroup {
  const WebEditorInteractionScriptGroup({
    required this.driveCardDeleteOverlayRemoveLabel,
    required this.driveCardDeleteOverlayViewId,
  });

  final String driveCardDeleteOverlayRemoveLabel;
  final String driveCardDeleteOverlayViewId;

  @override
  List<WebEditorScriptDescriptor> build() => [
    adapter.fromHtmlUtils(
      HtmlUtils.registerFileLinkRowEnterKeyHandler(isWebPlatform: true),
      runOnInit: true,
    ),
    adapter.fromDefinition(
      const QuotedReplyEnterHandlerScript(),
      runOnInit: true,
    ),
    adapter.fromHtmlUtils(
      HtmlUtils.registerFileLinkCardClickHandler(isWebPlatform: true),
      runOnInit: true,
    ),
    adapter.fromHtmlUtils(
      WorkplaceScripts.registerDriveCardDeleteOverlay(
        driveCardDeleteOverlayRemoveLabel,
        viewId: driveCardDeleteOverlayViewId,
        isWebPlatform: true,
      ),
      runOnInit: true,
    ),
    adapter.fromHtmlUtils(WorkplaceScripts.unregisterDriveCardDeleteOverlay),
  ];
}
