import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';

typedef OnOpenMailboxActionClick = void Function(PresentationMailbox);
typedef OnSelectMailboxActionClick = void Function(PresentationMailbox);

class MailboxSearchTileBuilder {

  final PresentationMailbox _presentationMailbox;
  final PresentationMailbox? lastMailbox;
  final SelectMode allSelectMode;
  final ImagePaths _imagePaths;

  bool isHoverIcon = false;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;
  OnSelectMailboxActionClick? _onSelectMailboxActionClick;

  MailboxSearchTileBuilder(
    this._imagePaths,
    this._presentationMailbox,
    {
      this.allSelectMode = SelectMode.INACTIVE,
      this.lastMailbox,
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
        key: const Key('mailbox_list_tile'),
        alignment: Alignment.center,
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.zero),
          child: Column(children: [
            ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => allSelectMode == SelectMode.ACTIVE
                    ? _onSelectMailboxActionClick?.call(_presentationMailbox)
                    : _onOpenMailboxActionClick?.call(_presentationMailbox),
                leading: _buildLeadingIcon(),
                title: Row(children: [
                      if (allSelectMode == SelectMode.ACTIVE)
                        Transform(
                            transform: Matrix4.translationValues(-24.0, 0.0, 0.0),
                            child: _buildMailboxIcon()),
                      Expanded(child: Transform(
                          transform: Matrix4.translationValues(allSelectMode == SelectMode.ACTIVE ? -16.0 : -20.0, 0.0, 0.0),
                          child: Text(
                            _presentationMailbox.name?.name ?? '',
                            maxLines: 1,
                            overflow:TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17, color: AppColor.colorNameEmail, fontWeight: FontWeight.normal),
                          ))),
                    ]),
                subtitle: _presentationMailbox.mailboxPath?.isNotEmpty == true
                    ? Transform(
                        transform: Matrix4.translationValues(allSelectMode == SelectMode.ACTIVE ? 12.0 : -20.0, 0.0, 0.0),
                        child: Text(
                          _presentationMailbox.mailboxPath ?? '',
                          maxLines: 1,
                          overflow:TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail),
                        ),
                      )
                    : null,
            ),
            if (lastMailbox?.id != _presentationMailbox.id && !kIsWeb)
              Padding(
                padding: EdgeInsets.only(left: allSelectMode == SelectMode.ACTIVE ? 50 : 35),
                child: const Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
          ]),
        )
      )
    );
  }

  Widget _buildLeadingIcon() {
    if (kIsWeb) {
      return _presentationMailbox.selectMode == SelectMode.ACTIVE ? _buildSelectModeIcon() : _buildMailboxIcon();
    } else {
      return allSelectMode == SelectMode.ACTIVE ? _buildSelectModeIcon() : _buildMailboxIcon();
    }
  }

  Widget _buildMailboxIcon() {
    if (kIsWeb) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return InkWell(
                onTap: () {},
                onHover: (value) => setState(() => isHoverIcon = value),
                child: isHoverIcon
                    ? _buildSelectModeIcon()
                    : SvgPicture.asset(_presentationMailbox.getMailboxIcon(_imagePaths), width: 28, height: 28, fit: BoxFit.fill)
            );
          });
    } else {
      return SvgPicture.asset(_presentationMailbox.getMailboxIcon(_imagePaths), width: 28, height: 28, fit: BoxFit.fill);
    }
  }

  Widget _buildSelectModeIcon() {
    return Container(
      color: Colors.transparent,
      child: Transform(
          transform: Matrix4.translationValues(kIsWeb ? -8.0 : -10.0, 0.0, 0.0),
          child: buildIconWeb(
              icon: SvgPicture.asset(
                  _presentationMailbox.selectMode == SelectMode.ACTIVE ? _imagePaths.icSelected : _imagePaths.icUnSelected,
                  width: kIsWeb ? 20 : 24,
                  height: kIsWeb ? 20 : 24,
                  fit: BoxFit.fill),
              onTap: () => _onSelectMailboxActionClick?.call(_presentationMailbox))),
    );
  }
}