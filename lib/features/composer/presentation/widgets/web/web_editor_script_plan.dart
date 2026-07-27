import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_bootstrap_script_group.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_drop_script_group.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_height_script_group.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_interaction_script_group.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_selection_script_group.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/web_editor_scripts_factory.dart';

final class WebEditorScriptPlan {
  WebEditorScriptPlan({
    required this.maxHeight,
    required this.selectionChangeScript,
    required this.driveCardDeleteOverlayRemoveLabel,
    required this.driveCardDeleteOverlayViewId,
  });

  final double maxHeight;
  final WebScript selectionChangeScript;
  final String driveCardDeleteOverlayRemoveLabel;
  final String driveCardDeleteOverlayViewId;

  late final WebEditorScriptsFactory _factory = WebEditorScriptsFactory(
    groups: [
      const WebEditorBootstrapScriptGroup(),
      const WebEditorDropScriptGroup(),
      WebEditorSelectionScriptGroup(
        selectionChangeScript: selectionChangeScript,
      ),
      WebEditorHeightScriptGroup(maxHeight: maxHeight),
      WebEditorInteractionScriptGroup(
        driveCardDeleteOverlayRemoveLabel: driveCardDeleteOverlayRemoveLabel,
        driveCardDeleteOverlayViewId: driveCardDeleteOverlayViewId,
      ),
    ],
  );

  late final List<WebScript> initialScripts = _factory.buildInitialScripts();

  late final List<String> initializationScriptNames =
      _factory.buildInitializationScriptNames();
}
