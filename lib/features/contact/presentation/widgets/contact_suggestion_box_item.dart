
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';

typedef SelectedContactCallbackAction = Function(EmailAddress contactSelected);

class ContactSuggestionBoxItem extends StatelessWidget {

  final ImagePaths imagePaths;
  final SuggestionEmailAddress suggestionEmailAddress;
  final SelectedContactCallbackAction? selectedContactCallbackAction;
  final ShapeBorder? shapeBorder;

  const ContactSuggestionBoxItem(
    this.suggestionEmailAddress,
    this.imagePaths,
    {
      Key? key,
      this.shapeBorder,
      this.selectedContactCallbackAction,
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemChild = Row(children: [
      GradientCircleAvatarIcon(
        colors: suggestionEmailAddress.emailAddress.avatarColors,
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
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: ComposerStyle.suggestionItemHeight,
            child: itemChild,
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: ComposerStyle.suggestionItemHeight,
          child: itemChild,
        ),
      );
    }
  }
}