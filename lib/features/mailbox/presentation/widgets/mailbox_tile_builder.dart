import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';

typedef OnOpenMailboxActionClick = void Function(PresentationMailbox mailbox);

class MailboxTileBuilder {

  final PresentationMailbox _presentationMailbox;
  final SelectMode selectMode;
  final ImagePaths _imagePaths;
  final MailboxDisplayed mailboxDisplayed;
  final bool isLastElement;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;

  MailboxTileBuilder(
    this._imagePaths,
    this._presentationMailbox,
    {
      this.selectMode = SelectMode.INACTIVE,
      this.mailboxDisplayed = MailboxDisplayed.mailbox,
      this.isLastElement = false,
    }
  );

  void onOpenMailboxAction(OnOpenMailboxActionClick onOpenMailboxActionClick) {
    _onOpenMailboxActionClick = onOpenMailboxActionClick;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('mailbox_list_tile'),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          color: Colors.white
        ),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: Column(children: [
            ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => {
                  if (_onOpenMailboxActionClick != null) {
                    _onOpenMailboxActionClick!(_presentationMailbox)
                  }
                },
                leading: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SvgPicture.asset(
                        '${_presentationMailbox.getMailboxIcon(_imagePaths)}',
                        width: 28,
                        height: 28,
                        fit: BoxFit.fill)),
                title: Transform(
                    transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                    child: Row(children: [
                      Expanded(child: Text(
                        '${_presentationMailbox.name?.name ?? ''}',
                        maxLines: 1,
                        overflow:TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: AppColor.colorNameEmail),
                      )),
                      if (mailboxDisplayed == MailboxDisplayed.mailbox)
                        Transform(
                            transform: Matrix4.translationValues(40.0, 0.0, 0.0),
                            child: Text(
                                '${_presentationMailbox.getCountUnReadEmails()}',
                                maxLines: 1,
                                style: TextStyle(fontSize: 13, color: AppColor.colorNameEmail)))
                    ])),
                trailing: (mailboxDisplayed == MailboxDisplayed.mailbox)
                  ? Transform(
                      transform: Matrix4.translationValues(8.0, 0.0, 0.0),
                      child: IconButton(
                          color: AppColor.primaryColor,
                          icon: SvgPicture.asset(_imagePaths.icFolderArrow, color: AppColor.colorArrowUserMailbox, fit: BoxFit.fill),
                          onPressed: () {
                            if (_onOpenMailboxActionClick != null) {
                              _onOpenMailboxActionClick!(_presentationMailbox);
                            }
                          }
                      )
                    )
                  : null
            ),
            if (!isLastElement)
              Padding(
                padding: EdgeInsets.only(left: 45),
                child: Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
          ]),
        )
      )
    );
  }
}