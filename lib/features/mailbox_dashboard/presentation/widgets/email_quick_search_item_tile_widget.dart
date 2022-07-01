
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class EmailQuickSearchItemTileWidget extends StatelessWidget {

  final imagePath = Get.find<ImagePaths>();

  final PresentationEmail _presentationEmail;
  final PresentationMailbox? _presentationMailbox;

  EmailQuickSearchItemTileWidget(
      this._presentationEmail,
      this._presentationMailbox,
      {Key? key}
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidthItem = constraints.maxWidth;
        log('EmailQuickSearchItemTileWidget::build(): maxWidthItem: $maxWidthItem');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SvgPicture.asset(
                    _presentationEmail.hasStarred ? imagePath.icStar : imagePath.icUnStar,
                    width: 18, height: 18, fit: BoxFit.fill),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                       Container(
                         constraints: BoxConstraints(maxWidth: maxWidthItem / 3),
                         child: Text(_getInformationSender(),
                             maxLines: 1,
                             overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
                             style: const TextStyle(
                                 fontSize: 15,
                                 fontWeight: FontWeight.w600,
                                 color: Colors.black)),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Text(_presentationEmail.getEmailTitle(),
                             maxLines: 1,
                             overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
                             style: const TextStyle(
                                 fontSize: 13,
                                 fontWeight: FontWeight.normal,
                                 color: Colors.black)),
                       ),
                       if (_presentationEmail.hasAttachment == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SvgPicture.asset(imagePath.icAttachment, width: 14, height: 14, fit: BoxFit.fill),
                        ),
                       Text(_presentationEmail.getReceivedAt(Localizations.localeOf(context).toLanguageTag()),
                           textAlign: TextAlign.right,
                           style: const TextStyle(
                               fontSize: 13,
                               fontWeight: FontWeight.normal,
                               color: Colors.black))
                     ]),
                    const SizedBox(height: 3),
                    Text(_presentationEmail.getPartialContent(),
                        maxLines: 1,
                        overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: AppColor.colorContentEmail))
                    ]
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  String _getInformationSender() {
    if (_presentationMailbox?.role == PresentationMailbox.roleSent
        || _presentationMailbox?.role == PresentationMailbox.roleDrafts
        || _presentationMailbox?.role == PresentationMailbox.roleOutbox) {
      return _presentationEmail.recipientsName();
    }
    return _presentationEmail.getSenderName();
  }
}