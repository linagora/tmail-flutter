
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/floating_button/scrolling_floating_button_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

mixin ComposeFloatingButtonMixin {

  Widget buildComposeFloatingButton(
    BuildContext context,
    ScrollController scrollController,
    {VoidCallback? onTap}
  ) {
    final imagePaths = getBinding<ImagePaths>();

    return Align(
      alignment: AppUtils.isDirectionRTL(context)
        ? Alignment.bottomLeft
        : Alignment.bottomRight,
      child: ScrollingFloatingButtonAnimated(
        icon: SvgPicture.asset(
          imagePaths!.icComposeWeb,
          width: 28,
          height: 28,
          fit: BoxFit.fill
        ),
        text: Padding(
          padding: EdgeInsets.only(
            right: AppUtils.isDirectionRTL(context) ? 0 : 16,
            left: AppUtils.isDirectionRTL(context) ? 16 : 0,
          ),
          child: Text(AppLocalizations.of(context).compose,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500
            )
          )
        ),
        onPress: onTap,
        scrollController: scrollController,
        color: AppColor.primaryColor,
        width: 154,
        height: 60,
        animateIcon: false
      )
    );
  }
}