import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class InsertLinkDialogWidgetStyle {
  static const double actionOverFlowButtonSpacing = 8.0;
  static const double elevation = 10.0;
  static const double widthRatio = 0.3;
  static const double tittleToFieldSpace = 10.0;
  static const double fieldToFieldSpace = 20.0;
  static const double buttonRadius = 10.0;
  static const double buttonHeight = 40.0;
  
  static const int maxLines = 1;

  static const TextStyle tittleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.black
  );
  static const TextStyle fieldTitleStyle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Colors.black
  );
  static const TextStyle textInputStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black
  );
  static const TextStyle hintTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColor.colorHintSearchBar
  );
  static const TextStyle buttonCancelTextStyle = TextStyle(
    color: AppColor.primaryColor,
    fontSize: 17.0,
    fontWeight: FontWeight.w500
  );
  static const TextStyle buttonInsertTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17.0,
    fontWeight: FontWeight.w500
  );

  static const EdgeInsetsGeometry tittlePadding = EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 16
  );
  static const EdgeInsetsGeometry contentPadding = EdgeInsets.symmetric(
    horizontal: 16
  );
  static const EdgeInsetsGeometry actionsPadding = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 16
  );
  static const EdgeInsetsGeometry textInputContentPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 10.0
  );

  static const ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(15))
  );
  static const InputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColor.colorInputBorderCreateMailbox,
      width: 1.0
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0))
  );
  static const InputBorder focusedBorder = OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColor.primaryColor,
      width: 1.0
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0))
  );

  static const InputDecoration urlFieldDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: textInputContentPadding,
    enabledBorder: border,
    border: border,
    focusedBorder: focusedBorder,
    hintText: 'URL',
    hintStyle: hintTextStyle,
  );
}