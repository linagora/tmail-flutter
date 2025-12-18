
import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/text_selection_mixin.dart';

typedef OnCreatedEditorAction = Function(BuildContext context, HtmlEditorApi editorApi, String content);
typedef OnLoadCompletedEditorAction = Function(HtmlEditorApi editorApi, WebUri? url);
typedef OnEditorContentHeightChanged = Function(double height);
typedef OnTextSelectionChanged = Function(TextSelectionData?);

class MobileEditorWidget extends StatefulWidget {
  final String content;
  final TextDirection direction;
  final OnCreatedEditorAction onCreatedEditorAction;
  final OnLoadCompletedEditorAction onLoadCompletedEditorAction;
  final OnEditorContentHeightChanged? onEditorContentHeightChanged;
  final OnTextSelectionChanged? onTextSelectionChanged;

  const MobileEditorWidget({
    super.key,
    required this.content,
    required this.direction,
    required this.onCreatedEditorAction,
    required this.onLoadCompletedEditorAction,
    this.onEditorContentHeightChanged,
    this.onTextSelectionChanged,
  });

  @override
  State<MobileEditorWidget> createState() => _MobileEditorState();
}

class _MobileEditorState extends State<MobileEditorWidget> with TextSelectionMixin {

  HtmlEditorApi? _editorApi;
  late String _createdViewId;

  @override
  void initState() {
    super.initState();
    _createdViewId = HtmlUtils.getRandString(10);
  }

  @override
  void Function(TextSelectionData?)? get onSelectionChanged => widget.onTextSelectionChanged;

  void _setupSelectionListener() async {
    final webViewController = _editorApi?.webViewController;
    if (webViewController == null) return;

    final registerSelectionChange =
        HtmlUtils.registerSelectionChangeListener(_createdViewId);

    webViewController.addJavaScriptHandler(
      handlerName: registerSelectionChange.name,
      callback: (args) {
        if (!mounted) return;

        if (args.isNotEmpty) {
          final data = args[0] as Map<dynamic, dynamic>;
          handleSelectionChange(data);
        }
      },
    );

    await webViewController.evaluateJavascript(
      source: registerSelectionChange.script,
    );
  }

  @override
  void dispose() {
    _editorApi = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      key: const Key('mobile_editor'),
      minHeight: 550,
      maxHeight: PlatformInfo.isIOS ? ConstantsUI.composerHtmlContentMaxHeight : null,
      addDefaultSelectionMenuItems: false,
      initialContent: widget.content,
      customStyleCss: HtmlTemplate.mobileCustomInternalStyleCSS(
        direction: widget.direction,
        useDefaultFontStyle: true,
      ),
      onCreated: (editorApi) {
        _editorApi = editorApi;
        widget.onCreatedEditorAction.call(context, editorApi, widget.content);
        _setupSelectionListener();
      },
      onCompleted: widget.onLoadCompletedEditorAction,
      onContentHeightChanged: PlatformInfo.isIOS ? widget.onEditorContentHeightChanged : null,
    );
  }
}
