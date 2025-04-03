
import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_composer/rich_text_composer.dart';

typedef OnCreatedEditorAction = Function(BuildContext context, HtmlEditorApi editorApi, String content);
typedef OnLoadCompletedEditorAction = Function(HtmlEditorApi editorApi, WebUri? url);
typedef OnEditorContentHeightChanged = Function(double height);

class MobileEditorWidget extends StatelessWidget {

  final String content;
  final TextDirection direction;
  final OnCreatedEditorAction onCreatedEditorAction;
  final OnLoadCompletedEditorAction onLoadCompletedEditorAction;
  final OnEditorContentHeightChanged? onEditorContentHeightChanged;

  const MobileEditorWidget({
    super.key,
    required this.content,
    required this.direction,
    required this.onCreatedEditorAction,
    required this.onLoadCompletedEditorAction,
    this.onEditorContentHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      key: const Key('mobile_editor'),
      minHeight: 550,
      maxHeight: PlatformInfo.isIOS ? ConstantsUI.composerHtmlContentMaxHeight : null,
      addDefaultSelectionMenuItems: false,
      initialContent: content,
      customStyleCss: HtmlUtils.customCssStyleHtmlEditor(
        direction: direction,
        useDefaultFont: true,
      ),
      onCreated: (editorApi) => onCreatedEditorAction.call(context, editorApi, content),
      onCompleted: onLoadCompletedEditorAction,
      onContentHeightChanged: PlatformInfo.isIOS ? onEditorContentHeightChanged : null,
    );
  }
}
