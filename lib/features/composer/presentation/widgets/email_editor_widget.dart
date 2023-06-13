
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

class EmailEditorWidget extends StatefulWidget {

  final ComposerController controller;
  final String content;
  final TextDirection direction;

  const EmailEditorWidget({
    super.key,
    required this.controller,
    required this.content,
    required this.direction,
  });

  @override
  State<EmailEditorWidget> createState() => _EmailEditorState();
}

class _EmailEditorState extends State<EmailEditorWidget> {

  late ComposerController _controller;
  late HtmlEditorController _editorController;

  @override
  void initState() {
    _controller = widget.controller;
    _editorController = _controller.richTextWebController.editorController;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant EmailEditorWidget oldWidget) {
    log('_EmailEditorState::didUpdateWidget():Old: ${oldWidget.direction} | current: ${widget.direction}');
    if (oldWidget.direction != widget.direction) {
      _editorController.updateBodyDirection(widget.direction.name);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      key: const Key('composer_editor_web'),
      controller: _editorController,
      htmlEditorOptions: HtmlEditorOptions(
        shouldEnsureVisible: true,
        hint: '',
        darkMode: false,
        customBodyCssStyle: HtmlUtils.customCssStyleHtmlEditor(direction: widget.direction),
      ),
      blockQuotedContent: widget.content,
      htmlToolbarOptions: const HtmlToolbarOptions(
        toolbarType: ToolbarType.hide,
        defaultToolbarButtons: []
      ),
      otherOptions: const OtherOptions(height: 550),
      callbacks: Callbacks(
        onBeforeCommand: _controller.onChangeTextEditorWeb,
        onChangeContent: _controller.onChangeTextEditorWeb,
        onInit: () => _controller.handleInitHtmlEditorWeb(widget.content),
        onFocus: _controller.handleOnFocusHtmlEditorWeb,
        onBlur: _controller.handleOnUnFocusHtmlEditorWeb,
        onMouseDown: () => _controller.handleOnMouseDownHtmlEditorWeb(context),
        onChangeSelection: _controller.richTextWebController.onEditorSettingsChange,
        onChangeCodeview: _controller.onChangeTextEditorWeb
      ),
    );
  }
}