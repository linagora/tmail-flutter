import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AttachmentListStyles {
  static const double headerBorderWidth = 1.0;
  static const double titleSpace = 8.0;
  static const double scrollbarThickness = 8.0;
  static const double buttonsSpaceBetween = 12.0;
  static const double dialogBottomSpace = 20.0;
  static const double buttonBorderWidth = 1.0;

  static const RoundedRectangleBorder shapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0))
  );
  static const EdgeInsets dialogPaddingWeb = EdgeInsets.symmetric(
    horizontal: 336.0,
    vertical: 112.0
  );
  static const EdgeInsets dialogPaddingTablet = EdgeInsets.symmetric(
    horizontal: 64.0,
    vertical: 160.0
  );
  static const EdgeInsetsGeometry headerPadding = EdgeInsets.only(
    top: 8,
    bottom: 8,
    right: 4
  );
  static const EdgeInsetsGeometry listAreaPadding = EdgeInsets.all(12.0);
  static const EdgeInsetsGeometry listAreaPaddingMobile = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsetsGeometry buttonsPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0
  );
  static const EdgeInsetsGeometry closeButtonPadding = EdgeInsets.all(12.0);
  static const EdgeInsetsGeometry actionButtonsRowPadding = EdgeInsets.only(top: 12);

  static const Color bodyBackgroundColor = Colors.white;
  static const Color headerBorderColor = AppColor.colorDividerEmailView;
  static const Color titleTextColor = Colors.black;
  static const Color subTitleTextColor = AppColor.colorSubtitle;
  static const Color scrollbarTrackColor = AppColor.colorScrollbarTrackColor;
  static const Color scrollbarThumbColor = AppColor.colorScrollbarThumbColor;
  static const Color scrollbarTrackBorderColor = Colors.transparent;
  static const Color separatorColor = AppColor.colorAttachmentBorder;
  static const Color downloadAllButtonColor = Colors.transparent;
  static const Color cancelButtonColor = Colors.transparent;
  static const Color downloadAllButtonTextColor = AppColor.textButtonColor;
  static const Color cancelButtonTextColor = AppColor.primaryColor;
  static const Color cancelButtonBorderColor = AppColor.colorButtonBorder;
  static const Color barrierColor = AppColor.colorDefaultCupertinoActionSheet;
  static const Color modalBackgroundColor = Colors.transparent;
  static const Color buttonBorderDefaultColor = Colors.transparent;

  static const BorderRadiusGeometry bodyBorderRadius = BorderRadius.all(Radius.circular(16.0));
  
  static const Radius scrollbarTrackRadius = Radius.circular(10.0);
  static const Radius scrollbarThumbRadius = Radius.circular(10.0);
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(10.0));
  static const BorderRadiusGeometry modalRadius = BorderRadius.only(
    topRight: Radius.circular(14),
    topLeft: Radius.circular(14),
  );

  static const BoxDecoration dialogBodyDecoration = BoxDecoration(
    color: bodyBackgroundColor,
    borderRadius: bodyBorderRadius
  );
  static const BoxDecoration dialogBodyDecorationMobile = BoxDecoration(
    border: Border(
      top: BorderSide(
        color: headerBorderColor,
        width: headerBorderWidth,
      )
    )
  );
  static const BoxDecoration headerDecoration = BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: headerBorderColor,
        width: headerBorderWidth
      )
    )
  );

  static const double titleFontSize = 17.0;
  static const double subTitleFontSize = 12.0;

  static const FontWeight titleFontWeight = FontWeight.w700;
  static const FontWeight subTitleFontWeight = FontWeight.w400;
  static const FontWeight buttonFontWeight = FontWeight.w500;

  static TextStyle titleTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: titleFontSize,
    fontWeight: titleFontWeight,
    color: titleTextColor,
  );
  static TextStyle subTitleTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: subTitleFontSize,
    fontWeight: subTitleFontWeight,
    color: subTitleTextColor,
  );
  static TextStyle downloadAllButtonTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: titleFontSize,
    fontWeight: buttonFontWeight,
    color: downloadAllButtonTextColor,
  );
  static TextStyle cancelButtonTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: titleFontSize,
    fontWeight: buttonFontWeight,
    color: cancelButtonTextColor,
  );
}