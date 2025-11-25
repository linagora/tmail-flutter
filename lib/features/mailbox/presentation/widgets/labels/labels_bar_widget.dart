import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LabelsBarWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final bool isDesktop;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final ExpandMode? expandMode;
  final VoidCallback? onToggleLabelListState;
  final VoidCallback? onAddNewLabel;

  const LabelsBarWidget({
    super.key,
    required this.imagePaths,
    this.isDesktop = false,
    this.height,
    this.padding,
    this.labelStyle,
    this.expandMode,
    this.onToggleLabelListState,
    this.onAddNewLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget addNewLabelIcon = TMailButtonWidget.fromIcon(
      icon: imagePaths.icAddNewFolder,
      backgroundColor: Colors.transparent,
      iconColor: AppColor.steelGrayA540,
      iconSize: 20,
      padding: const EdgeInsets.all(5),
      tooltipMessage: AppLocalizations.of(context).newLabel,
      onTapActionCallback: onAddNewLabel,
    );

    if (isDesktop) {
      addNewLabelIcon = Transform(
        transform: Matrix4.translationValues(8, 0, 0),
        child: addNewLabelIcon,
      );
    }

    final labelText = Text(
      AppLocalizations.of(context).labels,
      style: labelStyle ?? ThemeUtils.textStyleInter700(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Container(
      padding: padding ??
          EdgeInsetsDirectional.only(
            start: isDesktop ? 10 : 26,
            end: isDesktop ? 0 : 8,
          ),
      height: height ?? 48,
      child: Row(
        children: [
          if (expandMode != null)
            Expanded(
              child: Row(
                children: [
                  Flexible(child: labelText),
                  TMailButtonWidget.fromIcon(
                    icon: expandMode!.getIcon(
                      imagePaths,
                      DirectionUtils.isDirectionRTLByLanguage(context),
                    ),
                    iconColor: Colors.black,
                    iconSize: 17,
                    margin: isDesktop
                        ? const EdgeInsetsDirectional.only(start: 8)
                        : null,
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(3),
                    tooltipMessage: expandMode!
                        .getTooltipMessage(AppLocalizations.of(context)),
                    onTapActionCallback: onToggleLabelListState,
                  ),
                ],
              ),
            )
          else
            Expanded(child: labelText),
          if (onAddNewLabel != null)
            addNewLabelIcon,
        ],
      ),
    );
  }
}
