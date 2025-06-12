import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class FoldersBarWidget extends StatelessWidget {
  final VoidCallback onOpenSearchFolder;
  final VoidCallback onAddNewFolder;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final ExpandMode? expandMode;
  final VoidCallback? onToggleExpandFolder;

  const FoldersBarWidget({
    super.key,
    required this.onOpenSearchFolder,
    required this.onAddNewFolder,
    required this.imagePaths,
    required this.responsiveUtils,
    this.height,
    this.padding,
    this.labelStyle,
    this.expandMode,
    this.onToggleExpandFolder,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = responsiveUtils.isDesktop(context);

    Widget searchBarIcon = TMailButtonWidget.fromIcon(
      icon: imagePaths.icSearchBar,
      backgroundColor: Colors.transparent,
      iconColor: AppColor.steelGrayA540,
      iconSize: 20,
      padding: const EdgeInsets.all(5),
      tooltipMessage: AppLocalizations.of(context).searchForFolders,
      onTapActionCallback: onOpenSearchFolder,
    );

    if (isDesktop) {
      searchBarIcon = Transform(
        transform: Matrix4.translationValues(8, 0, 0),
        child: searchBarIcon,
      );
    }

    Widget newFolderIcon = TMailButtonWidget.fromIcon(
      icon: imagePaths.icAddNewFolder,
      backgroundColor: Colors.transparent,
      iconColor: AppColor.steelGrayA540,
      iconSize: 20,
      padding: const EdgeInsets.all(5),
      tooltipMessage: AppLocalizations.of(context).newFolder,
      onTapActionCallback: onAddNewFolder,
    );

    if (isDesktop) {
      newFolderIcon = Transform(
        transform: Matrix4.translationValues(8, 0, 0),
        child: newFolderIcon,
      );
    }

    final labelFolder = Text(
      AppLocalizations.of(context).folders,
      style: labelStyle ?? ThemeUtils.textStyleInter700(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Container(
      padding: padding ?? EdgeInsetsDirectional.only(
        start: isDesktop ? 10 : 26,
        end: isDesktop ? 0 : 8,
      ),
      height: height ?? 48,
      child: Row(
        children: [
          if (expandMode != null)
            Expanded(child: Row(
              children: [
                Flexible(child: labelFolder),
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
                  tooltipMessage: expandMode!.getTooltipMessage(AppLocalizations.of(context)),
                  onTapActionCallback: () => onToggleExpandFolder?.call(),
                )
              ],
            ))
          else
            Expanded(child: labelFolder),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [searchBarIcon, newFolderIcon],
          ),
        ],
      ),
    );
  }
}
