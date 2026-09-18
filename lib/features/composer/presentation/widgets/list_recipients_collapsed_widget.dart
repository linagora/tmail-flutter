import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_tag_item_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_collapsed_item_widget.dart';

class RecipientsCollapsedComposerWidget extends StatelessWidget {
  final List<EmailAddress> listEmailAddress;
  final VoidCallback onShowAllRecipientsAction;
  final EdgeInsetsGeometry? margin;

  /// Lower-cased addresses the server reported as `invalidRecipients` on the
  /// last send attempt.
  final Set<String> invalidRecipients;

  const RecipientsCollapsedComposerWidget({
    super.key,
    required this.listEmailAddress,
    required this.onShowAllRecipientsAction,
    this.invalidRecipients = const {},
    this.margin,
  });

  bool _isRejectedByServer(EmailAddress emailAddress) =>
      invalidRecipients.contains(emailAddress.emailAddress.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double usedWidth = 0;
        const double spacing = 8.0;

        List<Widget> visibleChips = [];
        int hiddenCount = 0;

        if (listEmailAddress.length == 1) {
          visibleChips.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(end: spacing),
              child: RecipientCollapsedItemWidget(
                emailAddress: listEmailAddress.first,
                isRejectedByServer: _isRejectedByServer(listEmailAddress.first),
              ),
            ),
          );
        } else {
          for (var emailAddress in listEmailAddress) {
            final textWidth =
                _estimateTextWidth(context, emailAddress.asString()) + 80;
            if (usedWidth + textWidth > maxWidth - 60) {
              hiddenCount = listEmailAddress.length - visibleChips.length;
              break;
            }
            usedWidth += textWidth + spacing;
            visibleChips.add(
              Padding(
                padding: const EdgeInsetsDirectional.only(end: spacing),
                child: RecipientCollapsedItemWidget(
                  emailAddress: emailAddress,
                  isRejectedByServer: _isRejectedByServer(emailAddress),
                ),
              ),
            );
          }
        }

        if (hiddenCount > 0) {
          final label = hiddenCount > 999 ? '999+' : '+$hiddenCount';
          visibleChips.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(RecipientTagItemWidgetStyle.radius),
                ),
                color: AppColor.grayBackgroundColor,
              ),
              height: 32,
              alignment: Alignment.center,
              child: Text(
                label,
                style: RecipientTagItemWidgetStyle.labelTextStyle,
              ),
            ),
          );
        }

        return MouseRegion(
          cursor: SystemMouseCursors.text,
          child: GestureDetector(
            onTap: onShowAllRecipientsAction,
            child: Container(
              margin: margin,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: RecipientComposerWidgetStyle.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(children: visibleChips),
            ),
          ),
        );
      },
    );
  }

  double _estimateTextWidth(BuildContext context, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
