import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/signature_tooltip_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:universal_html/html.dart' hide VoidCallback;

typedef OnChangeContentEditorAction = Function(String? text);
typedef OnInitialContentEditorAction = Function(String text);
typedef OnMouseDownEditorAction = Function();
typedef OnEditorSettingsChange = Function(EditorSettings settings);
typedef OnEditorTextSizeChanged = Function(int? size);
typedef OnDragEnterListener = Function(List<dynamic>? types);
typedef OnDragOverListener = Function(List<dynamic>? types);
typedef OnPasteImageSuccessAction = Function(List<FileUpload> listFileUpload);
typedef OnPasteImageFailureAction = Function(
    List<FileUpload>? listFileUpload,
    String? base64,
    UploadError uploadError);
typedef OnInitialContentLoadComplete = Function(String text);
typedef OnKeyDownEditorAction = Function(int? keyCode);

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
  final double? height;
  final double? horizontalPadding;
  final LinkOverlayOptions? linkOverlayOptions;
  final OnDragEnterListener? onDragEnter;
  final OnDragOverListener? onDragOver;
  final OnPasteImageSuccessAction? onPasteImageSuccessAction;
  final OnPasteImageFailureAction? onPasteImageFailureAction;
  final OnInitialContentLoadComplete? onInitialContentLoadComplete;
  final OnKeyDownEditorAction? onKeyDownEditorAction;

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
    this.height,
    this.horizontalPadding,
    this.linkOverlayOptions,
    this.onDragEnter,
    this.onDragOver,
    this.onPasteImageSuccessAction,
    this.onPasteImageFailureAction,
    this.onInitialContentLoadComplete,
    this.onKeyDownEditorAction,
  });

  @override
  State<WebEditorWidget> createState() => _WebEditorState();
}

class _WebEditorState extends State<WebEditorWidget> {

  static const double _defaultHtmlEditorHeight = 550;

  late HtmlEditorController _editorController;
  bool _dropListenerRegistered = false;
  Function(Event)? _dropListener;

  OverlayEntry? _signatureTooltipEntry;
  final GlobalKey _signatureTooltipKey = GlobalKey();
  double _signatureTooltipLeft = 0;
  bool _signatureTooltipReady = false;

  @override
  void initState() {
    super.initState();
    _editorController = widget.editorController;
    _dropListener = (event) {
      if (event is MessageEvent) {
        if (jsonDecode(event.data)['name'] == HtmlUtils.registerDropListener.name) {
          _editorController.evaluateJavascriptWeb(HtmlUtils.removeLineHeight1px.name);
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
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _editorController.evaluateJavascriptWeb(
      HtmlUtils.unregisterDropListener.name);
    if (_dropListener != null) {
      window.removeEventListener("message", _dropListener!);
      _dropListener = null;
    }
    _hideSignatureTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = widget.height ?? _defaultHtmlEditorHeight;
    return HtmlEditor(
      controller: _editorController,
      htmlEditorOptions: HtmlEditorOptions(
        shouldEnsureVisible: true,
        hint: '',
        darkMode: false,
        cacheHTMLAssetOffline: true,
        initialText: widget.content,
        customBodyCssStyle: HtmlUtils.customInlineBodyCssStyleHtmlEditor(
          direction: widget.direction,
          horizontalPadding: widget.horizontalPadding,
        ),
        customInternalCSS: HtmlTemplate.webCustomInternalStyleCSS(
          useDefaultFontStyle: true,
          customScrollbar: true,
        ),
        useLinkTooltipOverlay: true,
        linkOverlayOptions: widget.linkOverlayOptions
            ?? const LinkOverlayOptions(),
        spellCheck: true,
        disableDragAndDrop: true,
        normalizeHtmlTextWhenDropping: true,
        normalizeHtmlTextWhenPasting: true,
        webInitialScripts: UnmodifiableListView([
          WebScript(
            name: HtmlUtils.removeLineHeight1px.name,
            script: HtmlUtils.removeLineHeight1px.script,
          ),
          WebScript(
            name: HtmlUtils.registerDropListener.name,
            script: HtmlUtils.registerDropListener.script,
          ),
          WebScript(
            name: HtmlUtils.unregisterDropListener.name,
            script: HtmlUtils.unregisterDropListener.script,
          ),
          WebScript(
            name: HtmlUtils.recalculateEditorHeight(maxHeight: maxHeight).name,
            script: HtmlUtils.recalculateEditorHeight(maxHeight: maxHeight).script,
          ),
        ])
      ),
      htmlToolbarOptions: const HtmlToolbarOptions(
        toolbarType: ToolbarType.hide,
        defaultToolbarButtons: [],
      ),
      otherOptions: OtherOptions(height: maxHeight),
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
        onUnFocus: widget.onUnFocus,
        onMouseDown:widget.onMouseDown,
        onChangeSelection: widget.onEditorSettings,
        onChangeCodeview: widget.onChangeContent,
        onTextFontSizeChanged: widget.onEditorTextSizeChanged,
        onPaste: () => _editorController.evaluateJavascriptWeb(
          HtmlUtils.removeLineHeight1px.name
        ),
        onDragEnter: widget.onDragEnter,
        onDragOver: widget.onDragOver,
        onDragLeave: (_) {},
        onImageUpload: widget.onPasteImageSuccessAction,
        onImageUploadError: widget.onPasteImageFailureAction,
        onInitialTextLoadComplete: widget.onInitialContentLoadComplete,
        onSignatureHoverIn: (position, isContentVisible) {
          log('_WebEditorState::build: onSignatureHoverIn position: $position');
          _showSignatureTooltipAtPosition(
            position,
            isContentVisible
              ? AppLocalizations.of(context).hideSignature
              : AppLocalizations.of(context).showSignature,
          );
        },
        onSignatureHoverOut: () {
          log('_WebEditorState::build: onSignatureHoverOut');
          _hideSignatureTooltip();
        },
        onKeyDown: widget.onKeyDownEditorAction,
      ),
    );
  }

  void _showSignatureTooltipAtPosition(
    SignaturePosition position,
    String message,
  ) {
    try {
      final overlay = Overlay.maybeOf(context);
      _signatureTooltipEntry?.remove();

      _signatureTooltipReady = false;
      _signatureTooltipLeft = position.left;

      _signatureTooltipEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: position.top + position.height + 8,
            left: _signatureTooltipLeft,
            child: Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: _signatureTooltipReady ? 1 : 0,
                child: SignatureTooltipWidget(
                  key: _signatureTooltipKey,
                  message: message,
                ),
              ),
            ),
          );
        },
      );

      overlay?.insert(_signatureTooltipEntry!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final renderBox = _signatureTooltipKey.currentContext
              ?.findRenderObject() as RenderBox?;
          if (renderBox == null) return;

          final tooltipWidth = renderBox.size.width;
          final screenWidth = MediaQuery.of(context).size.width;

          final centerLeft =
              position.left + (position.width / 2) - (tooltipWidth / 2);
          final leftAligned = position.left;
          final rightAligned = position.left + position.width - tooltipWidth;

          if (centerLeft < 8) {
            _signatureTooltipLeft = leftAligned;
          } else if (centerLeft + tooltipWidth > screenWidth - 8) {
            _signatureTooltipLeft = rightAligned;
          } else {
            _signatureTooltipLeft = centerLeft;
          }

          _signatureTooltipReady = true;
          _signatureTooltipEntry?.markNeedsBuild();
        } catch (e) {
          logError(
            '_WebEditorState::_showTooltipAtPosition:addPostFrameCallback:Exception = $e',
          );
        }
      });
    } catch (e) {
      logError('_WebEditorState::_showTooltipAtPosition:Exception = $e');
    }
  }

  void _hideSignatureTooltip() {
    _signatureTooltipEntry?.remove();
    _signatureTooltipEntry = null;
  }
}