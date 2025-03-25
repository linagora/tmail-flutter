import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/email_address_action_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MobileEditRecipientsView extends StatelessWidget {
  final EmailAddress emailAddress;
  final ImagePaths imagePaths;
  final double width;
  final VoidCallback onCopyAction;
  final VoidCallback onEditAction;
  final VoidCallback onCreateRuleAction;

  const MobileEditRecipientsView({
    super.key,
    required this.emailAddress,
    required this.imagePaths,
    required this.width,
    required this.onCopyAction,
    required this.onEditAction,
    required this.onCreateRuleAction,
  });

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsetsDirectional.only(bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  UserAvatarBuilder(
                    username: emailAddress.asString().firstLetterToUpperCase,
                    size: 28,
                    textStyle: ThemeUtils.textStyleInter600().copyWith(
                      fontSize: 11,
                      height: 22 / 11,
                      letterSpacing: -0.41,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsetsDirectional.only(end: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (emailAddress.displayName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 24),
                            child: Text(
                              emailAddress.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppColor.textPrimary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        Text(
                          emailAddress.emailAddress,
                          style: ThemeUtils.textStyleInter400.copyWith(
                            color: AppColor.steelGray400,
                            fontSize: 11,
                            height: 14 / 11,
                            letterSpacing: 0.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ..._buildActions(AppLocalizations.of(context)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(AppLocalizations appLocalizations) {
    return EmailAddressActionType.values.map((type) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColor.gray424244.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        child: EmailAddressActionWidget(
          imagePaths: imagePaths,
          actionType: type,
          onClick: _handleEmailAddressActionTypeClick,
        ),
      );
    }).toList();
  }

  void _handleEmailAddressActionTypeClick(EmailAddressActionType actionType) {
    switch (actionType) {
      case EmailAddressActionType.copy:
        onCopyAction();
        break;
      case EmailAddressActionType.edit:
        onEditAction();
        break;
      case EmailAddressActionType.createRule:
        onCreateRuleAction();
        break;
    }
  }
}
