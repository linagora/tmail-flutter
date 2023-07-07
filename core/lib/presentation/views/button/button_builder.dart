
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnPressActionClick = void Function();
typedef OnPressActionWithPositionClick = void Function(RelativeRect? position);

class ButtonBuilder {
  OnPressActionClick? _onPressActionClick;
  OnPressActionWithPositionClick? _onPressActionWithPositionClick;

  BuildContext? _context;
  final String? _icon;
  String? _text;
  double? _size;
  EdgeInsets? _paddingIcon;
  bool? _isVertical;
  Key? _key;
  Color? _iconColor;
  TextStyle? _textStyle;
  BoxDecoration? _decoration;
  Widget? _iconAction;
  double? _radiusSplash;
  double? _maxWidth;
  EdgeInsets? _padding;
  EdgeInsets? _margin;
  String? _tooltip;
  BoxConstraints? _constraints;

  void key(Key key) {
    _key = key;
  }

  void context(BuildContext context) {
    _context = context;
  }

  void size(double? size) {
    _size = size;
  }

  void maxWidth(double? size) {
    _maxWidth = size;
  }

  void iconColor(Color color) {
    _iconColor = color;
  }

  void decoration(BoxDecoration decoration) {
    _decoration = decoration;
  }

  void addIconAction(Widget icon) {
    _iconAction = icon;
  }

  void radiusSplash(double? radius) {
    _radiusSplash = radius;
  }

  void padding(EdgeInsets? padding) {
    _padding = padding;
  }

  void margin(EdgeInsets? margin) {
    _margin = margin;
  }

  void textStyle(TextStyle style) {
    _textStyle = style;
  }

  void paddingIcon(EdgeInsets paddingIcon) {
    _paddingIcon = paddingIcon;
  }

  void text(String? text, {required bool isVertical}) {
    _text = text;
    _isVertical = isVertical;
  }

  void tooltip(String? message) {
    _tooltip = message;
  }

  void addBoxConstraints(BoxConstraints? constraints) {
    _constraints = constraints;
  }

  ButtonBuilder(this._icon);

  void onPressActionClick(OnPressActionClick onPressActionClick) {
    _onPressActionClick = onPressActionClick;
  }

  void addOnPressActionWithPositionClick(OnPressActionWithPositionClick onPressActionClick) {
    _onPressActionWithPositionClick = onPressActionClick;
  }

  Widget build() {
    return Padding(
      padding: _margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onPressActionClick,
          onTapDown: (detail) {
            if (_onPressActionWithPositionClick != null && _context != null) {
              final screenSize = MediaQuery.of(_context!).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              _onPressActionWithPositionClick?.call(position);
            }
          },
          borderRadius: BorderRadius.circular(_radiusSplash ?? 20),
          child: Tooltip(
            message: _tooltip ?? '',
            child: Container(
              key: _key,
              alignment: Alignment.center,
              color: _decoration == null ? Colors.transparent : null,
              decoration: _decoration,
              width: _maxWidth,
              constraints: _constraints,
              padding: _padding ?? EdgeInsets.zero,
              child: _buildBody()
            ),
          )
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_text != null) {
      return _isVertical!
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              _buildText(),
              if (_iconAction != null) _iconAction!
            ])
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              _buildText(),
              if (_iconAction != null) _iconAction!
            ]);
    } else {
      return _buildIcon();
    }
  }

  Widget _buildIcon() => Padding(
    padding: _paddingIcon ?? const EdgeInsets.all(10),
    child: SvgPicture.asset(
      _icon ?? '',
      width: _size ?? 24,
      height: _size ?? 24,
      fit: BoxFit.fill,
      colorFilter: _iconColor.asFilter()
    ));

  Widget _buildText() {
    return Text(
      _text ?? '',
      maxLines: 1,
      softWrap: CommonTextStyle.defaultSoftWrap,
      overflow: CommonTextStyle.defaultTextOverFlow,
      style: _textStyle ?? const TextStyle(
        fontSize: 12,
        color: AppColor.colorTextButton
      ),
    );
  }
}