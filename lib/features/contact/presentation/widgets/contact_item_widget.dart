
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/avatar/gradient_circle_avatar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/contact/presentation/styles/contact_item_widget_style.dart';

typedef OnSelectContactAction = Function(EmailAddress emailAddress);
typedef OnDeleteContactAction = Function(EmailAddress emailAddress);

class ContactItemWidget extends StatelessWidget {

  final EmailAddress emailAddress;
  final List<EmailAddress> selectedContactList;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnSelectContactAction onSelectContactAction;
  final OnDeleteContactAction onDeleteContactAction;

  const ContactItemWidget({
    Key? key,
    required this.emailAddress,
    required this.selectedContactList,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onSelectContactAction,
    required this.onDeleteContactAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final childWidget = Padding(
      padding: ContactItemWidgetStyle.getItemPadding(
        context,
        responsiveUtils
      ),
      child: Row(
        children: [
          GradientCircleAvatarIcon(
            colors: emailAddress.avatarColors,
            label: emailAddress.labelAvatar,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emailAddress.asString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ContactItemWidgetStyle.nameAddressTextStyle
                ),
                if (emailAddress.displayName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      emailAddress.emailAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ContactItemWidgetStyle.emailAddressTextStyle
                    )
                  )
              ]
            )
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            child: SvgPicture.asset(
              _isSelectedEmailAddress
                ? imagePaths.icCheckboxSelected
                : imagePaths.icCheckboxUnselected,
              width: 20,
              height: 20,
              colorFilter: _isSelectedEmailAddress
                ? AppColor.primaryColor.asFilter()
                : AppColor.colorEmailTileCheckboxUnhover.asFilter(),
            ),
          ),
        ]
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _isSelectedEmailAddress
          ? onDeleteContactAction(emailAddress)
          : onSelectContactAction(emailAddress),
        child: childWidget,
      ),
    );
  }

  bool get _isSelectedEmailAddress => selectedContactList
    .any((contact) => contact.emailAddress == emailAddress.emailAddress);
}