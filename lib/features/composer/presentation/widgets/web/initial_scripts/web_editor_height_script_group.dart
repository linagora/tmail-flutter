import 'package:core/utils/html/html_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_adapter.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';

final class WebEditorHeightScriptGroup
    with WebEditorScriptAdapterAware
    implements WebEditorScriptGroup {
  const WebEditorHeightScriptGroup({required this.maxHeight});

  final double maxHeight;

  @override
  List<WebEditorScriptDescriptor> build() => [
    adapter.fromHtmlUtils(
      HtmlUtils.recalculateEditorHeight(maxHeight: maxHeight),
    ),
  ];
}
