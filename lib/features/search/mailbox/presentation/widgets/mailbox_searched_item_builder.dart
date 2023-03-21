import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focused_menu_custom/focused_menu.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/utils/search_mailbox_utils.dart';

class MailboxSearchedItemBuilder extends StatefulWidget {

  final PresentationMailbox _presentationMailbox;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final double? maxWidth;
  final OnClickOpenMailboxAction? onClickOpenMailboxAction;
  final OnClickOpenMenuMailboxAction? onClickOpenMenuMailboxAction;
  final OnDragEmailToMailboxAccepted? onDragEmailToMailboxAccepted;
  final OnLongPressMailboxAction? onLongPressMailboxAction;
  final List<FocusedMenuItem>? listPopupMenuItemAction;

  const MailboxSearchedItemBuilder(
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
    {
      Key? key,
      this.maxWidth,
      this.onClickOpenMailboxAction,
      this.onClickOpenMenuMailboxAction,
      this.onDragEmailToMailboxAccepted,
      this.onLongPressMailboxAction,
      this.listPopupMenuItemAction
    }
  ) : super(key: key);

  @override
  State<MailboxSearchedItemBuilder> createState() => _MailboxSearchedItemBuilderState();
}

class _MailboxSearchedItemBuilderState extends State<MailboxSearchedItemBuilder> {
  bool isHoverItem = false;

  @override
  Widget build(BuildContext context) {
    if (BuildUtils.isWeb) {
      return DragTarget<List<PresentationEmail>>(
        builder: (_, __, ___) => _buildMailboxItem(context),
        onAccept: (emails) {
          widget.onDragEmailToMailboxAccepted?.call(emails, widget._presentationMailbox);
        }
      );
    } else {
      return _buildMailboxItem(context);
    }
  }

  Widget _buildMailboxItem(BuildContext context) {
    if (BuildUtils.isWeb) {
      return InkWell(
        onTap: _onTapMailboxAction,
        onHover: (value) => setState(() => isHoverItem = value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: getBackgroundColorItem(context)
          ),
          padding: SearchMailboxUtils.getPaddingItemListView(context, widget._responsiveUtils),
          child: Row(
            crossAxisAlignment: widget._presentationMailbox.mailboxPath?.isNotEmpty == true
              || widget._presentationMailbox.isTeamMailboxes
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              _buildMailboxIcon(),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleItem(),
                    _buildSubtitleItem()
                  ]
                )
              )),
              _buildMenuIcon(context)
            ]
          ),
        )
      );
    } else {
      return ResponsiveWidget(
        responsiveUtils: widget._responsiveUtils,
        mobile: _buildMailboxItemMobile(),
        tablet: _buildMailboxItemTablet()
      );
    }
  }

  Widget _buildMailboxItemTablet() {
    return FocusedMenuHolder(
      onPressed: () {},
      menuWidth: widget.maxWidth,
      blurBackgroundColor: AppColor.colorInputBorderCreateMailbox,
      blurSize: 0.0,
      duration: const Duration(milliseconds: 100),
      menuOffset: 8.0,
      animateMenuItems: true,
      menuItems: widget.listPopupMenuItemAction ?? [],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onTapMailboxAction,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Padding(
            padding: SearchMailboxUtils.getPaddingItemListView(context, widget._responsiveUtils),
            child: Row(
              crossAxisAlignment: widget._presentationMailbox.mailboxPath?.isNotEmpty == true
                || widget._presentationMailbox.isTeamMailboxes
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                _buildMailboxIcon(),
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleItem(),
                      _buildSubtitleItem()
                    ]
                  )
                ))
              ]
            ),
          )
        ),
      ),
    );
  }

  Widget _buildMailboxItemMobile() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onTapMailboxAction,
        onLongPress: _onLongPressMailboxAction,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: SearchMailboxUtils.getPaddingItemListView(context, widget._responsiveUtils),
          child: Row(
            crossAxisAlignment: widget._presentationMailbox.mailboxPath?.isNotEmpty == true
              || widget._presentationMailbox.isTeamMailboxes
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              _buildMailboxIcon(),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleItem(),
                    _buildSubtitleItem()
                  ]
                )
              ))
            ]
          ),
        )
      ),
    );
  }

  void _onTapMailboxAction() {
    if (widget._presentationMailbox.allowedToDisplay) {
      widget.onClickOpenMailboxAction?.call(widget._presentationMailbox);
    }
  }

  void _onLongPressMailboxAction() {
    if (widget.listPopupMenuItemAction?.isNotEmpty == true) {
      widget.onLongPressMailboxAction?.call(widget._presentationMailbox);
    }
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(
      widget._presentationMailbox.allowedToDisplay
        ? widget._presentationMailbox.getMailboxIcon(widget._imagePaths)
        : widget._imagePaths.icHideFolder,
      width: 20,
      height: 20,
      fit: BoxFit.fill
    );
  }

  Widget _buildTitleItem() {
    return Text(
      widget._presentationMailbox.name?.name ?? '',
      maxLines: 1,
      overflow: CommonTextStyle.defaultTextOverFlow,
      softWrap: CommonTextStyle.defaultSoftWrap,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black
      ),
    );
  }

  Widget _buildSubtitleItem() {
    if (widget._presentationMailbox.mailboxPath?.isNotEmpty == true) {
      return Text(
        widget._presentationMailbox.mailboxPath ?? '',
        maxLines: 1,
        overflow: CommonTextStyle.defaultTextOverFlow,
        softWrap: CommonTextStyle.defaultSoftWrap,
        style: const TextStyle(
          fontSize: 11,
          color: AppColor.colorMailboxPath,
          fontWeight: FontWeight.normal
        ),
      );
    } else if (widget._presentationMailbox.isTeamMailboxes) {
      return Text(
        widget._presentationMailbox.emailTeamMailBoxes ?? '',
        maxLines: 1,
        softWrap: CommonTextStyle.defaultSoftWrap,
        overflow: CommonTextStyle.defaultTextOverFlow,
        style: const TextStyle(
          fontSize: 11,
          color: AppColor.colorEmailAddressFull,
          fontWeight: FontWeight.normal
        )
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMenuIcon(BuildContext context) {
    if (isHoverItem && widget.listPopupMenuItemAction?.isNotEmpty == true) {
      return InkWell(
        onTapDown: (detail) {
          final screenSize = MediaQuery.of(context).size;
          final offset = detail.globalPosition;
          final position = RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            screenSize.width - offset.dx,
            screenSize.height - offset.dy,
          );
          widget.onClickOpenMenuMailboxAction?.call(position, widget._presentationMailbox);
        },
        child: SvgPicture.asset(
          widget._imagePaths.icComposerMenu,
          width: 20,
          height: 20,
          fit: BoxFit.fill
        )
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Color getBackgroundColorItem(BuildContext context) {
    if (isHoverItem) {
      return AppColor.colorBgMailboxSelected;
    } else {
      return widget._responsiveUtils.isDesktop(context)
        ? AppColor.colorBgDesktop
        : Colors.transparent;
    }
  }
}