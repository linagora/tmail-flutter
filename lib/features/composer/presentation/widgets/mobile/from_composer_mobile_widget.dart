import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/from_composer_mobile_widget_style.dart';

class FromComposerMobileWidget extends StatelessWidget {

  final Identity? selectedIdentity;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final void Function()? onTap;

  const FromComposerMobileWidget({
    super.key,
    required this.imagePaths,
    required this.responsiveUtils,
    this.selectedIdentity,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: FromComposerMobileWidgetStyle.border
      ),
      padding: padding,
      margin: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16),
            child: Text(
              '${PrefixEmailAddress.from.asName(context)}:',
              style: FromComposerMobileWidgetStyle.prefixTextStyle,
            ),
          ),
          const SizedBox(width: FromComposerMobileWidgetStyle.space),
          Flexible(
            child: Padding(
              padding: FromComposerMobileWidgetStyle.identityButtonInkWellPadding,
              child: InkWell(
                borderRadius: FromComposerMobileWidgetStyle.identityButtonInkWellBorderRadius,
                onTap: onTap,
                child: Container(
                  height: FromComposerMobileWidgetStyle.identityButtonHeight,
                  padding: FromComposerMobileWidgetStyle.identityButtonPadding,
                  decoration: FromComposerMobileWidgetStyle.identityButtonDecoration,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedIdentity != null)
                        Flexible(
                          child: RichText(
                            maxLines: 1,
                            softWrap: false,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            text: TextSpan(
                              children: [
                                if (selectedIdentity!.name!.isNotEmpty)
                                  TextSpan(
                                    text: '${selectedIdentity!.name} ',
                                    style: FromComposerMobileWidgetStyle.buttonTitleTextStyle,
                                  ),
                                  TextSpan(
                                    text: '(${selectedIdentity!.email})',
                                    style: selectedIdentity!.name!.isNotEmpty
                                      ? FromComposerMobileWidgetStyle.buttonSubTitleTextStyle
                                      : FromComposerMobileWidgetStyle.buttonTitleTextStyle
                                  )
                              ]
                            ),
                          ),
                        )
                      else 
                        const SizedBox.shrink(),
                      SvgPicture.asset(imagePaths.icDropDown),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}