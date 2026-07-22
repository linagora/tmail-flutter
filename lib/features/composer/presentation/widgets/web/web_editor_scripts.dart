import 'package:core/utils/html/html_utils.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:workplace/presentation/utils/workplace_scripts.dart';

List<WebScript> buildWebEditorInitialScripts({
  required double maxHeight,
  required WebScript selectionChangeScript,
  required String driveCardDeleteOverlayRemoveLabel,
}) {
  final driveCardDeleteOverlayScript = WorkplaceScripts.registerDriveCardDeleteOverlay(
    driveCardDeleteOverlayRemoveLabel,
    isWebPlatform: true,
  );

  return [
    WebScript(
      name: HtmlUtils.removeLineHeight1px.name,
      script: HtmlUtils.removeLineHeight1px.script,
    ),
    WebScript(
      name: HtmlUtils.registerDropListener.name,
      script: HtmlUtils.registerDropListener.script,
    ),
    WebScript(
      name: HtmlUtils.unregisterDropListener.name,
      script: HtmlUtils.unregisterDropListener.script,
    ),
    WebScript(
      name: selectionChangeScript.name,
      script: selectionChangeScript.script,
    ),
    WebScript(
      name: HtmlUtils.collapseSelectionToEnd.name,
      script: HtmlUtils.collapseSelectionToEnd.script,
    ),
    WebScript(
      name: HtmlUtils.deleteSelectionContent.name,
      script: HtmlUtils.deleteSelectionContent.script,
    ),
    WebScript(
      name: HtmlUtils.saveSelection.name,
      script: HtmlUtils.saveSelection.script,
    ),
    WebScript(
      name: HtmlUtils.restoreSelection.name,
      script: HtmlUtils.restoreSelection.script,
    ),
    WebScript(
      name: HtmlUtils.getSavedSelection.name,
      script: HtmlUtils.getSavedSelection.script,
    ),
    WebScript(
      name: HtmlUtils.clearSavedSelection.name,
      script: HtmlUtils.clearSavedSelection.script,
    ),
    WebScript(
      name: HtmlUtils.recalculateEditorHeight(maxHeight: maxHeight).name,
      script: HtmlUtils.recalculateEditorHeight(maxHeight: maxHeight).script,
    ),
    WebScript(
      name: HtmlUtils.registerFileLinkRowEnterKeyHandler(
        isWebPlatform: true,
      ).name,
      script: HtmlUtils.registerFileLinkRowEnterKeyHandler(
        isWebPlatform: true,
      ).script,
    ),
    WebScript(
      name: HtmlUtils.registerFileLinkCardClickHandler(
        isWebPlatform: true,
      ).name,
      script: HtmlUtils.registerFileLinkCardClickHandler(
        isWebPlatform: true,
      ).script,
    ),
    WebScript(
      name: driveCardDeleteOverlayScript.name,
      script: driveCardDeleteOverlayScript.script,
    ),
    WebScript(
      name: WorkplaceScripts.unregisterDriveCardDeleteOverlay.name,
      script: WorkplaceScripts.unregisterDriveCardDeleteOverlay.script,
    ),
  ];
}
