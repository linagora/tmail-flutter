import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:tmail_ui_user/features/ai/presentation/styles/ai_scribe_styles.dart';
import 'package:tmail_ui_user/features/ai/presentation/widgets/ai_scribe_menu_content.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mixins/ai_scribe_overlay_mixin.dart';

typedef OnCreatedEditorAction = Function(BuildContext context, HtmlEditorApi editorApi, String content);
typedef OnLoadCompletedEditorAction = Function(HtmlEditorApi editorApi, WebUri? url);
typedef OnEditorContentHeightChanged = Function(double height);
typedef OnTextSelectionChanged = Function(String? selectedText);
typedef OnAIScribeAction = Function(AIScribeMenuAction action);

class MobileEditorWidget extends StatefulWidget {
  final String content;
  final TextDirection direction;
  final OnCreatedEditorAction onCreatedEditorAction;
  final OnLoadCompletedEditorAction onLoadCompletedEditorAction;
  final OnEditorContentHeightChanged? onEditorContentHeightChanged;
  final ImagePaths? imagePaths;
  final OnTextSelectionChanged? onTextSelectionChanged;
  final OnAIScribeAction? onAIScribeAction;

  const MobileEditorWidget({
    super.key,
    required this.content,
    required this.direction,
    required this.onCreatedEditorAction,
    required this.onLoadCompletedEditorAction,
    this.onEditorContentHeightChanged,
    this.imagePaths,
    this.onTextSelectionChanged,
    this.onAIScribeAction,
  });

  @override
  State<MobileEditorWidget> createState() => _MobileEditorState();
}

class _MobileEditorState extends State<MobileEditorWidget> with AIScribeOverlayMixin {

  HtmlEditorApi? _editorApi;

  @override
  ImagePaths? get aiScribeImagePaths => widget.imagePaths;

  @override
  Function(AIScribeMenuAction)? get aiScribeActionCallback => widget.onAIScribeAction;

  @override
  Function(String?)? get textSelectionChangedCallback => widget.onTextSelectionChanged;

  @override
  Widget buildAIScribeMenu({
    required BuildContext context,
    required AIScribeActionCallback onActionSelected,
  }) {
    return Material(
      elevation: 1,
      borderRadius: const BorderRadius.all(Radius.circular(AIScribeSizes.menuBorderRadius)),
      child: Container(
        width: 240,
        constraints: const BoxConstraints(
          maxHeight: 400,
        ),
        child: SingleChildScrollView(
          child: AIScribeMenuContent(
            onActionSelected: onActionSelected,
            useSubmenuItemStyle: true,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    disposeAIScribeOverlays();
    super.dispose();
  }

  void _setupSelectionListener() async {
    if (_editorApi == null || widget.onAIScribeAction == null) {
      return;
    }

    final webViewController = _editorApi?.webViewController;
    if (webViewController == null) return;

    webViewController.addJavaScriptHandler(
      handlerName: HtmlUtils.registerSelectionChangeListener.name,
      callback: (args) {
        if (!mounted) return;

        if (args.isNotEmpty) {
          final data = args[0] as Map<dynamic, dynamic>;
          parseSelectionData(data);
        }
      },
    );

    await webViewController.evaluateJavascript(
      source: HtmlUtils.registerSelectionChangeListener.script,
    );
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
        if (widget.onAIScribeAction != null) {
          _setupSelectionListener();
        }
      },
      onCompleted: widget.onLoadCompletedEditorAction,
      onContentHeightChanged: PlatformInfo.isIOS ? widget.onEditorContentHeightChanged : null,
    );
  }
}
