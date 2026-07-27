import 'package:core/utils/html/html_utils.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_adapter.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';

final class WebEditorSelectionScriptGroup implements WebEditorScriptGroup {
  const WebEditorSelectionScriptGroup({required this.selectionChangeScript});

  final WebScript selectionChangeScript;

  @override
  List<WebEditorScriptDescriptor> build() => [
    WebEditorScriptDescriptor(script: selectionChangeScript, runOnInit: true),
    _adapter.fromHtmlUtils(HtmlUtils.collapseSelectionToEnd),
    _adapter.fromHtmlUtils(HtmlUtils.deleteSelectionContent),
    _adapter.fromHtmlUtils(HtmlUtils.saveSelection),
    _adapter.fromHtmlUtils(HtmlUtils.restoreSelection),
    _adapter.fromHtmlUtils(HtmlUtils.getSavedSelection),
    _adapter.fromHtmlUtils(HtmlUtils.clearSavedSelection),
  ];

  static const _adapter = WebEditorScriptAdapter();
}
