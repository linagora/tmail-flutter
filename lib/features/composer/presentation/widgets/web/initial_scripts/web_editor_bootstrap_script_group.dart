import 'package:core/utils/html/html_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_adapter.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';

final class WebEditorBootstrapScriptGroup implements WebEditorScriptGroup {
  const WebEditorBootstrapScriptGroup();

  @override
  List<WebEditorScriptDescriptor> build() => [
    _adapter.fromHtmlUtils(HtmlUtils.removeLineHeight1px),
  ];

  static const _adapter = WebEditorScriptAdapter();
}
