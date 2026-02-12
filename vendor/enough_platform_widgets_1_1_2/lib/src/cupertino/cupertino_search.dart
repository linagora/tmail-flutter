import 'package:flutter/cupertino.dart';

/// Displays a CupertinoSearchTextField with the expected UX flow that switches to a full-screen experience once editing starts.
class CupertinoSearchFlowTextField extends StatefulWidget {
  /// The optional hero tag
  final Object heroTag;

  /// The method that is called once the user submits the text
  final Function(String text) onSubmitted;

  /// The place holder shown when there is no text input
  final String? placeholder;

  /// The cancel text in the full screen experience
  final String cancelText;

  /// The optional text editing controller
  final TextEditingController? controller;

  /// Set to false to disable this search
  final bool enabled;

  /// The title of the fullscreen experience
  final String? title;

  /// Creates a new search flow
  const CupertinoSearchFlowTextField({
    Key? key,
    this.heroTag = '_search',
    required this.onSubmitted,
    required this.cancelText,
    this.placeholder,
    this.controller,
    this.enabled = true,
    this.title,
  }) : super(key: key);

  @override
  _CupertinoSearchFlowTextFieldState createState() =>
      _CupertinoSearchFlowTextFieldState();
}

class _CupertinoSearchFlowTextFieldState
    extends State<CupertinoSearchFlowTextField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
        Navigator.of(context).push(
          CupertinoDialogRoute(
            // CupertinoPageRoute(
            context: context,
            builder: (context) => _CupertinoSearchPage(
              heroTag: widget.heroTag,
              onSubmitted: (text) {
                Navigator.of(context).pop();
                widget.onSubmitted(text);
              },
              cancelText: widget.cancelText,
              placeholder: widget.placeholder,
              controller: _controller,
              title: widget.title,
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      // only dispose when managed by this widget
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag,
      child: CupertinoSearchTextField(
        focusNode: _focusNode,
        controller: widget.controller,
        enabled: widget.enabled,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onSubmitted,
      ),
    );
  }
}

class _CupertinoSearchPage extends StatelessWidget {
  final Object heroTag;
  final Function(String text) onSubmitted;
  final String? placeholder;
  final String? title;
  final String cancelText;
  final TextEditingController controller;

  const _CupertinoSearchPage({
    Key? key,
    required this.heroTag,
    required this.onSubmitted,
    required this.cancelText,
    this.placeholder,
    required this.controller,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const iconSize = 20.0;
    final titleText = title;
    return CupertinoPageScaffold(
      navigationBar: (titleText == null)
          ? null
          : CupertinoNavigationBar(
              middle: Text(titleText),
            ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: heroTag,
                      child: CupertinoTextField(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(3.8, 8, 5, 8),
                        controller: controller,
                        onSubmitted: onSubmitted,
                        autofocus: true,
                        prefix: const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(6, 0, 0, 5),
                          child: Icon(
                            CupertinoIcons.search,
                            size: iconSize,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        placeholder: placeholder,
                        placeholderStyle: const TextStyle(
                            color: CupertinoColors.secondaryLabel),
                        suffix: CupertinoButton(
                          minSize: 10,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 5, 2),
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: iconSize,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          onPressed: () => controller.text = '',
                        ),
                        suffixMode: OverlayVisibilityMode.editing,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: CupertinoColors.tertiarySystemFill,
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(cancelText),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
