
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/floating_button/scrolling_floating_button_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ComposeFloatingButton extends StatelessWidget {

  final ScrollController scrollController;
  final VoidCallback? onTap;

  const ComposeFloatingButton({
    super.key,
    required this.scrollController,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = getBinding<ImagePaths>();

    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: ScrollingFloatingButtonAnimated(
        icon: SvgPicture.asset(
          imagePaths!.icComposeWeb,
          width: 28,
          height: 28,
          fit: BoxFit.fill
        ),
        text: Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: Text(AppLocalizations.of(context).compose,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500
            )
          )
        ),
        onPress: onTap,
        scrollController: scrollController,
        color: AppColor.blue700,
        width: 154,
        height: 60,
        animateIcon: false
      )
    );
  }
}