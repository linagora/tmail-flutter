
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

typedef OnChangeContentEditorAction = Function(String? text);
typedef OnInitialContentEditorAction = Function(String text);
typedef OnMouseDownEditorAction = Function(BuildContext context);
typedef OnEditorSettingsChange = Function(EditorSettings settings);

class WebEditorWidget extends StatefulWidget {

  final String content;
  final TextDirection direction;
  final HtmlEditorController editorController;
  final OnInitialContentEditorAction? onInitial;
  final OnChangeContentEditorAction? onChangeContent;
  final VoidCallback? onFocus;
  final VoidCallback? onUnFocus;
  final OnMouseDownEditorAction? onMouseDown;
  final OnEditorSettingsChange? onEditorSettings;

  const WebEditorWidget({
    super.key,
    required this.content,
    required this.direction,
    required this.editorController,
    this.onInitial,
    this.onChangeContent,
    this.onFocus,
    this.onUnFocus,
    this.onMouseDown,
    this.onEditorSettings,
  });

  @override
  State<WebEditorWidget> createState() => _WebEditorState();
}

class _WebEditorState extends State<WebEditorWidget> {

  late HtmlEditorController _editorController;

  @override
  void initState() {
    _editorController = widget.editorController;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WebEditorWidget oldWidget) {
    log('_EmailEditorState::didUpdateWidget():Old: ${oldWidget.direction} | current: ${widget.direction}');
    if (oldWidget.direction != widget.direction) {
      _editorController.updateBodyDirection(widget.direction.name);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      key: const Key('web_editor'),
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
        onBeforeCommand: widget.onChangeContent,
        onChangeContent: widget.onChangeContent,
        onInit: () => widget.onInitial?.call(widget.content),
        onFocus: widget.onFocus,
        onBlur: widget.onUnFocus,
        onMouseDown: () => widget.onMouseDown?.call(context),
        onChangeSelection: widget.onEditorSettings,
        onChangeCodeview: widget.onChangeContent
      ),
    );
  }
}