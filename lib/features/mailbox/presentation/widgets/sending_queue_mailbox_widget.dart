import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/trailing_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/count_of_emails_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SendingQueueMailboxWidget extends StatelessWidget {

  final List<SendingEmail> listSendingEmails;
  final bool isSelected;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final VoidCallback? onOpenSendingQueueAction;

  const SendingQueueMailboxWidget({
    super.key,
    required this.listSendingEmails,
    required this.imagePaths,
    required this.responsiveUtils,
    this.isSelected = false,
    this.onOpenSendingQueueAction
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenSendingQueueAction,
          borderRadius: const BorderRadius.all(
            Radius.circular(MailboxItemWidgetStyles.mobileBorderRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(MailboxItemWidgetStyles.mobileBorderRadius),
              ),
              color: backgroundColorItem,
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: MailboxItemWidgetStyles.mobileItemPadding,
            ),
            height: MailboxItemWidgetStyles.mobileHeight,
            child: Row(
              children: [
                MailboxIconWidget(
                  icon: imagePaths.icMailboxSendingQueue,
                  padding: const EdgeInsetsDirectional.only(
                    end: MailboxItemWidgetStyles.mobileLabelIconSpace,
                  ),
                  color: AppColor.iconFolder,
                ),
                Expanded(
                  child: TextOverflowBuilder(
                    AppLocalizations.of(context).sendingQueue,
                    style: _displayNameTextStyle,
                  ),
                ),
                Padding(
                  padding: TrailingMailboxItemWidgetStyles.mobileCountEmailsPadding,
                  child: CountOfEmailsWidget(value: _getCountSendingEmails()),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  Color get backgroundColorItem {
    if (isSelected) {
      return AppColor.blue100;
    } else {
      return Colors.transparent;
    }
  }

  String _getCountSendingEmails() {
    if (listSendingEmails.isEmpty) {
      return '';
    }
    return listSendingEmails.length <= 999 ? '${listSendingEmails.length}' : '999+';
  }

  TextStyle get _displayNameTextStyle {
    if (isSelected) {
      return ThemeUtils.textStyleInter700(
        color: AppColor.iconFolder,
        fontSize: 14,
      );
    } else {
      return ThemeUtils.textStyleInter500();
    }
  }
}