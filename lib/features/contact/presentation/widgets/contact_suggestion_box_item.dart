
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/contact/presentation/widgets/gradient_color_avatar_icon.dart';

typedef SelectedContactCallbackAction = Function(EmailAddress contactSelected);

class ContactSuggestionBoxItem extends StatelessWidget {

  final SuggestionEmailAddress suggestionEmailAddress;
  final SelectedContactCallbackAction? selectedContactCallbackAction;
  final EdgeInsets? padding;
  final ShapeBorder? shapeBorder;

  const ContactSuggestionBoxItem(this.suggestionEmailAddress, {
    Key? key,
    this.padding,
    this.shapeBorder,
    this.selectedContactCallbackAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    final itemChild = Row(children: [
      GradientColorAvatarIcon(
        suggestionEmailAddress.emailAddress.avatarColors,
        label: suggestionEmailAddress.emailAddress.labelAvatar,
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestionEmailAddress.emailAddress.asString(),
            maxLines: 1,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500)
          ),
          if (suggestionEmailAddress.emailAddress.displayName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                suggestionEmailAddress.emailAddress.emailAddress,
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
                style: const TextStyle(
                  color: AppColor.colorEmailAddressFull,
                  fontSize: 14,
                  fontWeight: FontWeight.normal)
              )
            )
        ]
      )),
      if (suggestionEmailAddress.state == SuggestionEmailState.duplicated)
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: SvgPicture.asset(imagePaths.icFilterSelected,
            width: 24,
            height: 24,
            fit: BoxFit.fill),
        )
    ]);

    if (selectedContactCallbackAction != null && suggestionEmailAddress.state == SuggestionEmailState.valid) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => selectedContactCallbackAction?.call(suggestionEmailAddress.emailAddress),
          customBorder: shapeBorder,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(12),
            child: itemChild,
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12),
          child: itemChild,
        ),
      );
    }
  }
}