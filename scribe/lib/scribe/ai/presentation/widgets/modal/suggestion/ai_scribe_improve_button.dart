import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe.dart';

class AiScribeImproveButton extends StatefulWidget {
  final ImagePaths imagePaths;
  final String suggestionText;
  final OnLoadSuggestion onLoadSuggestion;

  const AiScribeImproveButton({
    super.key,
    required this.imagePaths,
    required this.suggestionText,
    required this.onLoadSuggestion,
  });

  @override
  State<AiScribeImproveButton> createState() => _AiScribeImproveButtonState();
}

class _AiScribeImproveButtonState extends State<AiScribeImproveButton> {
  final GlobalKey _improveButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget(
      key: _improveButtonKey,
      text: ScribeLocalizations.of(context).improve,
      padding: AIScribeSizes.improveButtonPadding,
      borderRadius: AIScribeSizes.improveButtonBorderRadius,
      backgroundColor: AppColor.colorBackgroundTagFilter.withValues(alpha: 0.08),
      icon: widget.imagePaths.icChevronDown,
      iconColor: AppColor.colorTextButtonHeaderThread,
      iconAlignment: TextDirection.rtl,
      onTapActionCallback: _handleImproveButtonTap,
    );
  }

  Future<void> _handleImproveButtonTap() async {
    final renderBox = _improveButtonKey.currentContext?.findRenderObject();
    Offset? position;
    Size? size;

    if (renderBox != null && renderBox is RenderBox) {
      position = renderBox.localToGlobal(Offset.zero);
      size = renderBox.size;
    }

    final AIAction? aiAction = await AiScribeModalManager.showAIScribeMenuModal(
      isScribeMobile: AiScribeMobileUtils.isScribeInMobileMode(context),
      imagePaths: widget.imagePaths,
      availableCategories: AIScribeMenuCategory.values,
      content: widget.suggestionText,
      buttonPosition: position,
      buttonSize: size,
      showCustomPromptBar: false,
    );

    if (!mounted) {
      return;
    }

    if (aiAction != null) {
      widget.onLoadSuggestion(aiAction, widget.suggestionText);
    }
  }
}
