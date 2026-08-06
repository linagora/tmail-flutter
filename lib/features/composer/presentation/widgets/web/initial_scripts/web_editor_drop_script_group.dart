import 'package:core/utils/html/html_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_adapter.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';

final class WebEditorDropScriptGroup
    with WebEditorScriptAdapterAware
    implements WebEditorScriptGroup {
  const WebEditorDropScriptGroup();

  @override
  List<WebEditorScriptDescriptor> build() => [
    adapter.fromHtmlUtils(HtmlUtils.registerDropListener, runOnInit: true),
    adapter.fromHtmlUtils(HtmlUtils.unregisterDropListener),
  ];
}
