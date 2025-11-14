import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_mart/flutter_emoji_mart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linagora_design_flutter/colors/linagora_ref_colors.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmojiSelected = Function(String emoji);

class EmojiButton extends StatefulWidget {
  final EmojiData emojiData;
  final String? emojiSvgAssetPath;
  final String? emojiSearchEmptySvgAssetPath;
  final OnEmojiSelected onEmojiSelected;
  final VoidCallback onPickerOpen;
  final double? iconSize;
  final Color? iconColor;
  final String? iconTooltipMessage;
  final EdgeInsetsGeometry? iconPadding;

  const EmojiButton({
    Key? key,
    required this.emojiData,
    required this.onEmojiSelected,
    required this.onPickerOpen,
    this.emojiSvgAssetPath,
    this.emojiSearchEmptySvgAssetPath,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.iconTooltipMessage,
  }) : super(key: key);

  @override
  State<EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<EmojiButton>
    with SingleTickerProviderStateMixin {
  static const double _dialogWidth = 400.0;
  static const double _dialogHeight = 360.0;

  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDialogVisible = false;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 0.9, end: 1.0).animate(_animationController);
  late final Animation<double> _fadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

  void _toggleEmojiDialog() {
    if (_isDialogVisible) {
      _closeDialog();
    } else {
      _openDialog();
    }
  }

  void _openDialog() {
    widget.onPickerOpen();

    if (!mounted || _isDialogVisible) return;

    final ctx = _buttonKey.currentContext;
    if (ctx == null) return;

    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.sizeOf(context);

    final double availableHeight = screenSize.height - 32;
    final double dialogHeight =
        availableHeight < _dialogHeight ? availableHeight : _dialogHeight;

    double start = buttonPosition.dx + buttonSize.width / 2 - _dialogWidth / 2;
    double top = buttonPosition.dy - dialogHeight - 8;

    if (start < 8) start = 8;
    if (start + _dialogWidth > screenSize.width - 8) {
      start = screenSize.width - _dialogWidth - 8;
    }
    if (top < 8) {
      top = buttonPosition.dy + buttonSize.height + 8;

      if (top + dialogHeight > screenSize.height - 8) {
        top = 8;
      }
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return PointerInterceptor(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeDialog,
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),
              PositionedDirectional(
                start: start,
                top: top,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: _dialogWidth,
                      height: dialogHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 24,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: EmojiPicker(
                        emojiData: widget.emojiData,
                        configuration: EmojiPickerConfiguration(
                          showRecentTab: true,
                          emojiStyle:
                              Theme.of(context).textTheme.headlineLarge ??
                                  ThemeUtils.defaultTextStyleInterFont,
                          searchEmptyTextStyle: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color:
                                    LinagoraRefColors.material().tertiary[30],
                              ),
                          searchEmptyWidget:
                              widget.emojiSearchEmptySvgAssetPath != null
                                  ? SvgPicture.asset(
                                      widget.emojiSearchEmptySvgAssetPath!,
                                    )
                                  : null,
                        ),
                        itemBuilder: (context, emojiId, emoji, callback) {
                          return MouseRegion(
                            onHover: (_) {},
                            child: EmojiItem(
                              textStyle:
                                  Theme.of(context).textTheme.headlineLarge ??
                                      ThemeUtils.defaultTextStyleInterFont,
                              onTap: () => callback(emojiId, emoji),
                              emoji: emoji,
                            ),
                          );
                        },
                        onEmojiSelected: (emojiId, emoji) {
                          widget.onEmojiSelected(emoji);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.maybeOf(context, rootOverlay: true)?.insert(_overlayEntry!);
    _animationController.forward(from: 0);
    setState(() => _isDialogVisible = true);
  }

  Future<void> _closeDialog() async {
    if (!_isDialogVisible) return;
    await _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isDialogVisible = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.emojiSvgAssetPath != null) {
      return TMailButtonWidget.fromIcon(
        key: _buttonKey,
        onTapActionCallback: _toggleEmojiDialog,
        icon: widget.emojiSvgAssetPath!,
        backgroundColor:
            _isDialogVisible ? AppColor.m3Primary95 : Colors.transparent,
        borderRadius: 10,
        iconColor: _isDialogVisible
            ? AppColor.primaryLinShare
            : widget.iconColor ?? Colors.grey.shade700,
        iconSize: widget.iconSize ?? 24,
        padding: widget.iconPadding,
        tooltipMessage:
            widget.iconTooltipMessage ?? AppLocalizations.of(context).emoji,
      );
    }

    return IconButton(
      key: _buttonKey,
      onPressed: _toggleEmojiDialog,
      icon: Icon(
        Icons.emoji_emotions,
        color: _isDialogVisible
            ? AppColor.primaryLinShare
            : widget.iconColor ?? Colors.grey.shade600,
      ),
      style: IconButton.styleFrom(
        backgroundColor:
            _isDialogVisible ? AppColor.m3Primary95 : Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      padding: widget.iconPadding,
      tooltip: widget.iconTooltipMessage ?? AppLocalizations.of(context).emoji,
    );
  }
}
