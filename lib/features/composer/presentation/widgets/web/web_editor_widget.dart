import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:universal_html/html.dart' hide VoidCallback;

typedef OnChangeContentEditorAction = Function(String? text);
typedef OnInitialContentEditorAction = Function(String text);
typedef OnMouseDownEditorAction = Function(BuildContext context);
typedef OnEditorSettingsChange = Function(EditorSettings settings);
typedef OnEditorTextSizeChanged = Function(int? size);
typedef OnDragEnterListener = Function(List<dynamic>? types);
typedef OnPasteImageSuccessAction = Function(List<FileUpload> listFileUpload);
typedef OnPasteImageFailureAction = Function(
    List<FileUpload>? listFileUpload,
    String? base64,
    UploadError uploadError);
typedef OnInitialContentLoadComplete = Function(String text);

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
  final OnEditorTextSizeChanged? onEditorTextSizeChanged;
  final double? width;
  final double? height;
  final OnDragEnterListener? onDragEnter;
  final OnPasteImageSuccessAction? onPasteImageSuccessAction;
  final OnPasteImageFailureAction? onPasteImageFailureAction;
  final OnInitialContentLoadComplete? onInitialContentLoadComplete;

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
    this.onEditorTextSizeChanged,
    this.width,
    this.height,
    this.onDragEnter,
    this.onPasteImageSuccessAction,
    this.onPasteImageFailureAction,
    this.onInitialContentLoadComplete,
  });

  @override
  State<WebEditorWidget> createState() => _WebEditorState();
}

class _WebEditorState extends State<WebEditorWidget> {

  static const double _defaultHtmlEditorHeight = 550;

  late HtmlEditorController _editorController;
  final ValueNotifier<double> _htmlEditorHeight = ValueNotifier(_defaultHtmlEditorHeight);
  bool _dropListenerRegistered = false;
  Function(Event)? _dropListener;

  @override
  void initState() {
    super.initState();
    _editorController = widget.editorController;
    log('_WebEditorState::initState:height: ${widget.height} | width: ${widget.width}');
    if (widget.height != null) {
      _htmlEditorHeight.value = widget.height ?? _defaultHtmlEditorHeight;
    }
    _dropListener = (event) {
      if (event is MessageEvent) {
        if (jsonDecode(event.data)['name'] == HtmlUtils.registerDropListener.name) {
          _editorController.evaluateJavascriptWeb(HtmlUtils.lineHeight100Percent.name);
        }
      }
    };
    if (_dropListener != null) {
      window.addEventListener("message", _dropListener!);
    }
  }

  @override
  void didUpdateWidget(covariant WebEditorWidget oldWidget) {
    log('_EmailEditorState::didUpdateWidget():Old: ${oldWidget.direction} | current: ${widget.direction}');
    if (oldWidget.direction != widget.direction) {
      _editorController.updateBodyDirection(widget.direction.name);
    }

    log('_EmailEditorState::didUpdateWidget():Old: ${oldWidget.height} | current: ${widget.height}');

    if (oldWidget.height != widget.height) {
      _htmlEditorHeight.value = widget.height ?? _defaultHtmlEditorHeight;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _htmlEditorHeight.dispose();
    _editorController.evaluateJavascriptWeb(
      HtmlUtils.unregisterDropListener.name);
    if (_dropListener != null) {
      window.removeEventListener("message", _dropListener!);
      _dropListener = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _htmlEditorHeight,
      builder: (context, height, _) {
        return HtmlEditor(
          key: Key('web_editor_$height'),
          controller: _editorController,
          htmlEditorOptions: HtmlEditorOptions(
            shouldEnsureVisible: true,
            hint: '',
            darkMode: false,
            initialText: widget.content,
            customBodyCssStyle: HtmlUtils.customCssStyleHtmlEditor(direction: widget.direction),
            spellCheck: true,
            disableDragAndDrop: true,
            webInitialScripts: UnmodifiableListView([
              WebScript(
                name: HtmlUtils.lineHeight100Percent.name,
                script: HtmlUtils.lineHeight100Percent.script,
              ),
              WebScript(
                name: HtmlUtils.registerDropListener.name,
                script: HtmlUtils.registerDropListener.script,
              ),
              WebScript(
                name: HtmlUtils.unregisterDropListener.name,
                script: HtmlUtils.unregisterDropListener.script,
              )
            ])
          ),
          htmlToolbarOptions: const HtmlToolbarOptions(
            toolbarType: ToolbarType.hide,
            defaultToolbarButtons: [],
          ),
          otherOptions: OtherOptions(
            height: height,
            // dropZoneWidth: dropZoneWidth,
            // dropZoneHeight: dropZoneHeight,
          ),
          callbacks: Callbacks(
            onBeforeCommand: widget.onChangeContent,
            onChangeContent: widget.onChangeContent,
            onInit: () {
              widget.onInitial?.call(widget.content);
              if (!_dropListenerRegistered) {
                _editorController.evaluateJavascriptWeb(
                  HtmlUtils.registerDropListener.name);
                _dropListenerRegistered = true;
              }
            },
            onFocus: widget.onFocus,
            onBlur: widget.onUnFocus,
            onMouseDown: () => widget.onMouseDown?.call(context),
            onChangeSelection: widget.onEditorSettings,
            onChangeCodeview: widget.onChangeContent,
            onTextFontSizeChanged: widget.onEditorTextSizeChanged,
            onPaste: () => _editorController.evaluateJavascriptWeb(
              HtmlUtils.lineHeight100Percent.name
            ),
            onDragEnter: widget.onDragEnter,
            onDragLeave: (_) {},
            onImageUpload: widget.onPasteImageSuccessAction,
            onImageUploadError: widget.onPasteImageFailureAction,
            onInitialTextLoadComplete: widget.onInitialContentLoadComplete,
          ),
        );
      }
    );
  }
}