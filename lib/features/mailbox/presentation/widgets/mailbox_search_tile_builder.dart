import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';

typedef OnOpenMailboxActionClick = void Function(PresentationMailbox);
typedef OnSelectMailboxActionClick = void Function(PresentationMailbox);
typedef OnOpenMenuActionClick = void Function(RelativeRect, PresentationMailbox);

class MailboxSearchTileBuilder {

  final PresentationMailbox _presentationMailbox;
  final PresentationMailbox? lastMailbox;
  final SelectMode allSelectMode;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final BuildContext _context;

  bool isHoverItem = false;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;
  OnSelectMailboxActionClick? _onSelectMailboxActionClick;
  OnOpenMenuActionClick? _onMenuActionClick;

  MailboxSearchTileBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
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

  void addOnMenuActionClick(OnOpenMenuActionClick onOpenMenuActionClick) {
    _onMenuActionClick = onOpenMenuActionClick;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: _buildMailboxItem()
    );
  }

  Widget _buildMailboxItem() {
    if (BuildUtils.isWeb) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return InkWell(
                onTap: () {},
                onHover: (value) => setState(() => isHoverItem = value),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: backgroundColorItem),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 8),
                    onTap: () => _onOpenMailboxActionClick?.call(_presentationMailbox),
                    leading: _buildLeadingIcon(),
                    title: _buildTitleItem(),
                    subtitle: _buildSubtitleItem(),
                    trailing: _buildMenuIcon(),
                  ),
                )
            );
          });
    } else {
      return Column(children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => allSelectMode == SelectMode.ACTIVE
              ? _onSelectMailboxActionClick?.call(_presentationMailbox)
              : _onOpenMailboxActionClick?.call(_presentationMailbox),
          leading: _buildLeadingIcon(),
          title: _buildTitleItem(),
          subtitle: _buildSubtitleItem(),
        ),
        if (lastMailbox?.id != _presentationMailbox.id)
          Padding(
              padding: EdgeInsets.only(left: allSelectMode == SelectMode.ACTIVE ? 50 : 35),
              child: const Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
      ]);
    }
  }

  Widget _buildLeadingIcon() {
    if (BuildUtils.isWeb) {
      return _buildMailboxIcon();
    } else {
      return allSelectMode == SelectMode.ACTIVE ? _buildSelectModeIcon() : _buildMailboxIcon();
    }
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(_presentationMailbox.getMailboxIcon(_imagePaths),
        width: BuildUtils.isWeb ? 20 : 24,
        height: BuildUtils.isWeb ? 20 : 24,
        fit: BoxFit.fill);
  }

  Widget _buildSelectModeIcon() {
    return Container(
      color: Colors.transparent,
      child: Transform(
          transform: Matrix4.translationValues(BuildUtils.isWeb ? -8.0 : -10.0, 0.0, 0.0),
          child: buildIconWeb(
              icon: SvgPicture.asset(
                  _presentationMailbox.selectMode == SelectMode.ACTIVE ? _imagePaths.icSelected : _imagePaths.icUnSelected,
                  width: BuildUtils.isWeb ? 20 : 24,
                  height: BuildUtils.isWeb ? 20 : 24,
                  fit: BoxFit.fill),
              onTap: () => _onSelectMailboxActionClick?.call(_presentationMailbox))),
    );
  }

  Widget _buildTitleItem() {
    return Row(children: [
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
    ]);
  }

  Widget? _buildSubtitleItem() {
    if (_presentationMailbox.mailboxPath?.isNotEmpty == true) {
      return Transform(
        transform: Matrix4.translationValues(allSelectMode == SelectMode.ACTIVE ? 12.0 : -20.0, 0.0, 0.0),
        child: Text(
          _presentationMailbox.mailboxPath ?? '',
          maxLines: 1,
          overflow:TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail),
        ),
      );
    }
    return null;
  }

  Widget? _buildMenuIcon() {
    if (isHoverItem) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
            onTapDown: (detail) {
              final screenSize = MediaQuery.of(_context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              _onMenuActionClick?.call(position, _presentationMailbox);
            },
            onTap: () => {},
            child: SvgPicture.asset(_imagePaths.icComposerMenu,
                width: 20,
                height: 20,
                fit: BoxFit.fill)),
      );
    }
    return null;
  }

  Color get backgroundColorItem {
    if (isHoverItem) {
      return AppColor.colorBgMailboxSelected;
    } else {
      return _responsiveUtils.isDesktop(_context)
          ? AppColor.colorBgDesktop
          : Colors.white;
    }
  }
}