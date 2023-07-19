
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/cupertino.dart';

class ItemEmailTileStyles {

  static EdgeInsetsGeometry getSpaceCalendarEventIcon(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsetsDirectional.only(end: 4);
    } else if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 12);
    } else {
      return const EdgeInsetsDirectional.only(end: 8);
    }
  }
}