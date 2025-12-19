
import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/utils/app_logger.dart';
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

  late String _createdViewId;

  @override
  void initState() {
    super.initState();
    _createdViewId = HtmlUtils.getRandString(10);
  }

  @override
  void Function(TextSelectionData?)? get onSelectionChanged => widget.onTextSelectionChanged;

  Future<void> _setupSelectionListener(HtmlEditorApi editorApi) async {
    final webViewController = editorApi.webViewController;

    final registerSelectionChange =
        HtmlUtils.registerSelectionChangeListener(_createdViewId);

    webViewController.addJavaScriptHandler(
      handlerName: registerSelectionChange.name,
      callback: (args) {
        if (!mounted) return;

        if (args.isNotEmpty) {
          final rawData = args[0];
          if (rawData is Map<dynamic, dynamic>) {
            handleSelectionChange(rawData);
          }
        }
      },
    );

    await webViewController.evaluateJavascript(
      source: registerSelectionChange.script,
    );
  }

  Future<void> _onWebViewCreated(HtmlEditorApi editorApi) async {
    widget.onCreatedEditorAction.call(context, editorApi, widget.content);
    try {
      await _setupSelectionListener(editorApi);
    } catch (e) {
      logError('Error onWebViewCreated: $e');
    }
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
      onCreated: _onWebViewCreated,
      onCompleted: widget.onLoadCompletedEditorAction,
      onContentHeightChanged: PlatformInfo.isIOS ? widget.onEditorContentHeightChanged : null,
    );
  }
}
