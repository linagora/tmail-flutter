import 'package:core/utils/html/editor_script/web_editor_script.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';

final class WebEditorScriptAdapter {
  const WebEditorScriptAdapter();

  WebEditorScriptDescriptor fromDefinition(
    WebEditorScript definition, {
    bool runOnInit = false,
  }) => _build(definition.name, definition.script, runOnInit);

  WebEditorScriptDescriptor fromHtmlUtils(
    ({String name, String script}) definition, {
    bool runOnInit = false,
  }) => _build(definition.name, definition.script, runOnInit);

  WebEditorScriptDescriptor _build(
    String name,
    String script,
    bool runOnInit,
  ) => WebEditorScriptDescriptor(
    script: WebScript(name: name, script: script),
    runOnInit: runOnInit,
  );
}

/// Shares a single [WebEditorScriptAdapter] with every script group so the
/// adapter is declared once instead of being duplicated per group.
mixin WebEditorScriptAdapterAware {
  WebEditorScriptAdapter get adapter => const WebEditorScriptAdapter();
}
