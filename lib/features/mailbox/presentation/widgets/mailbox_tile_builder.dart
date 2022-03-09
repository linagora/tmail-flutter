import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';

typedef OnOpenMailboxActionClick = void Function(PresentationMailbox);
typedef OnSelectMailboxActionClick = void Function(PresentationMailbox);

class MailboxTileBuilder {

  final PresentationMailbox _presentationMailbox;
  final SelectMode allSelectMode;
  final ImagePaths _imagePaths;
  final MailboxDisplayed mailboxDisplayed;
  final bool isLastElement;
  final bool isSearchActive;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;
  OnSelectMailboxActionClick? _onSelectMailboxActionClick;

  MailboxTileBuilder(
    this._imagePaths,
    this._presentationMailbox,
    {
      this.allSelectMode = SelectMode.INACTIVE,
      this.mailboxDisplayed = MailboxDisplayed.mailbox,
      this.isLastElement = false,
      this.isSearchActive = false,
    }
  );

  void addOnOpenMailboxAction(OnOpenMailboxActionClick onOpenMailboxActionClick) {
    _onOpenMailboxActionClick = onOpenMailboxActionClick;
  }

  void addOnSelectMailboxActionClick(OnSelectMailboxActionClick onSelectMailboxActionClick) {
    _onSelectMailboxActionClick = onSelectMailboxActionClick;
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
                onTap: () => allSelectMode == SelectMode.ACTIVE
                    ? _onSelectMailboxActionClick?.call(_presentationMailbox)
                    : _onOpenMailboxActionClick?.call(_presentationMailbox),
                leading: allSelectMode == SelectMode.ACTIVE
                    ? _buildSelectModeIcon()
                    : _buildMailboxIcon(),
                title: Transform(
                    transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                    child: Row(children: [
                      if (allSelectMode == SelectMode.ACTIVE)
                        Transform(
                            transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                            child: _buildMailboxIcon()),
                      Expanded(child: Text(
                        '${_presentationMailbox.name?.name ?? ''}',
                        maxLines: 1,
                        overflow:TextOverflow.ellipsis,
                        style: TextStyle(fontSize: isSearchActive ? 17 : 15, color: AppColor.colorNameEmail),
                      )),
                      if (mailboxDisplayed == MailboxDisplayed.mailbox && !isSearchActive)
                        Transform(
                            transform: Matrix4.translationValues(40.0, 0.0, 0.0),
                            child: Text(
                                '${_presentationMailbox.getCountUnReadEmails()}',
                                maxLines: 1,
                                style: TextStyle(fontSize: 13, color: AppColor.colorNameEmail)))
                    ])),
                subtitle: isSearchActive && _presentationMailbox.mailboxPath?.isNotEmpty == true
                    ? Transform(
                        transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                        child: Text(
                          _presentationMailbox.mailboxPath ?? '',
                          maxLines: 1,
                          overflow:TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail),
                        ),
                      )
                    : null,
                trailing: (mailboxDisplayed == MailboxDisplayed.mailbox && !isSearchActive)
                  ? Transform(
                      transform: Matrix4.translationValues(8.0, 0.0, 0.0),
                      child: IconButton(
                          color: AppColor.primaryColor,
                          icon: SvgPicture.asset(_imagePaths.icFolderArrow, color: AppColor.colorArrowUserMailbox, fit: BoxFit.fill),
                          onPressed: () => _onOpenMailboxActionClick?.call(_presentationMailbox)
                      )
                    )
                  : null
            ),
            if (!isLastElement)
              Padding(
                padding: EdgeInsets.only(left: allSelectMode == SelectMode.ACTIVE ? 50 : 45),
                child: Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
          ]),
        )
      )
    );
  }

  Widget _buildMailboxIcon() {
    return Padding(
        padding: EdgeInsets.only(
            left: allSelectMode == SelectMode.ACTIVE ? 4 : 8,
            right: allSelectMode == SelectMode.ACTIVE ? 4 : 0),
        child: SvgPicture.asset(
          '${_presentationMailbox.getMailboxIcon(_imagePaths)}',
          width: 28,
          height: 28,
          fit: BoxFit.fill
        )
    );
  }

  Widget _buildSelectModeIcon() {
    return Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        child: IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
                _presentationMailbox.selectMode == SelectMode.ACTIVE ? _imagePaths.icSelected : _imagePaths.icUnSelected,
                width: 20,
                height: 20,
                fit: BoxFit.fill),
            onPressed: () => _onSelectMailboxActionClick?.call(_presentationMailbox)
        )
    );
  }
}