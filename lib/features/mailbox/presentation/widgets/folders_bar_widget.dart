import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class FoldersBarWidget extends StatelessWidget {
  final VoidCallback onOpenSearchFolder;
  final VoidCallback onAddNewFolder;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;

  const FoldersBarWidget({
    super.key,
    required this.onOpenSearchFolder,
    required this.onAddNewFolder,
    required this.imagePaths,
    required this.responsiveUtils,
    this.height,
    this.padding,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    Widget searchBarIcon = TMailButtonWidget.fromIcon(
      icon: imagePaths.icSearchBar,
      backgroundColor: Colors.transparent,
      iconColor: AppColor.steelGrayA540,
      iconSize: 20,
      tooltipMessage: AppLocalizations.of(context).searchForFolders,
      onTapActionCallback: onOpenSearchFolder,
    );

    if (responsiveUtils.isWebDesktop(context)) {
      searchBarIcon = Transform(
        transform: Matrix4.translationValues(8, 0, 0),
        child: searchBarIcon,
      );
    }

    Widget newFolderIcon = TMailButtonWidget.fromIcon(
      icon: imagePaths.icAddNewFolder,
      backgroundColor: Colors.transparent,
      iconColor: AppColor.steelGrayA540,
      iconSize: 24,
      padding: const EdgeInsets.all(5),
      tooltipMessage: AppLocalizations.of(context).newFolder,
      onTapActionCallback: onAddNewFolder,
    );

    if (responsiveUtils.isWebDesktop(context)) {
      newFolderIcon = Transform(
        transform: Matrix4.translationValues(8, 0, 0),
        child: newFolderIcon,
      );
    }

    return Container(
      padding: padding ?? EdgeInsetsDirectional.only(
        start: responsiveUtils.isWebDesktop(context) ? 10 : 26,
        end: responsiveUtils.isWebDesktop(context) ? 0 : 8,
      ),
      height: height ?? 48,
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context).folders,
              style: labelStyle ?? ThemeUtils.textStyleInter700(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(children: [searchBarIcon, newFolderIcon]),
        ],
      ),
    );
  }
}
