import 'package:core/utils/html/html_utils.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_adapter.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';

final class WebEditorSelectionScriptGroup
    with WebEditorScriptAdapterAware
    implements WebEditorScriptGroup {
  const WebEditorSelectionScriptGroup({required this.selectionChangeScript});

  final WebScript selectionChangeScript;

  @override
  List<WebEditorScriptDescriptor> build() => [
    WebEditorScriptDescriptor(script: selectionChangeScript, runOnInit: true),
    adapter.fromHtmlUtils(HtmlUtils.collapseSelectionToEnd),
    adapter.fromHtmlUtils(HtmlUtils.deleteSelectionContent),
    adapter.fromHtmlUtils(HtmlUtils.saveSelection),
    adapter.fromHtmlUtils(HtmlUtils.restoreSelection),
    adapter.fromHtmlUtils(HtmlUtils.getSavedSelection),
    adapter.fromHtmlUtils(HtmlUtils.clearSavedSelection),
  ];
}
