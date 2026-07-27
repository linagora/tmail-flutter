import 'package:html_editor_enhanced/html_editor.dart';

/// Declares one editor script and whether it must also run at editor init.
final class WebEditorScriptDescriptor {
  const WebEditorScriptDescriptor({
    required this.script,
    this.runOnInit = false,
  });

  final WebScript script;
  final bool runOnInit;
}
