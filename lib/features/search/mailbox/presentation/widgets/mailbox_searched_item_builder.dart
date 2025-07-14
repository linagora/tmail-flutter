import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focused_menu_custom/focused_menu.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/utils/search_mailbox_utils.dart';

class MailboxSearchedItemBuilder extends StatefulWidget {

  final PresentationMailbox presentationMailbox;
  final double? maxWidth;
  final OnClickOpenMailboxAction? onClickOpenMailboxAction;
  final OnClickOpenMenuMailboxAction? onClickOpenMenuMailboxAction;
  final OnDragEmailToMailboxAccepted? onDragEmailToMailboxAccepted;
  final OnLongPressMailboxAction? onLongPressMailboxAction;
  final List<FocusedMenuItem>? listPopupMenuItemAction;

  const MailboxSearchedItemBuilder({
    Key? key,
    required this.presentationMailbox,
    this.maxWidth,
    this.onClickOpenMailboxAction,
    this.onClickOpenMenuMailboxAction,
    this.onDragEmailToMailboxAccepted,
    this.onLongPressMailboxAction,
    this.listPopupMenuItemAction,
  }) : super(key: key);

  @override
  State<MailboxSearchedItemBuilder> createState() => _MailboxSearchedItemBuilderState();
}

class _MailboxSearchedItemBuilderState extends State<MailboxSearchedItemBuilder> {

  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();

  bool isHoverItem = false;
  bool _popupMenuVisible = false;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return DragTarget<List<PresentationEmail>>(
        builder: (_, __, ___) => _buildMailboxItem(context),
        onAcceptWithDetails: (emails) {
          widget.onDragEmailToMailboxAccepted?.call(emails.data, widget.presentationMailbox);
        }
      );
    } else {
      return _buildMailboxItem(context);
    }
  }

  Widget _buildMailboxItem(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return InkWell(
        onTap: _onTapMailboxAction,
        onLongPress: !PlatformInfo.isCanvasKit
            ? _onLongPressMailboxAction
            : null,
        onHover: (value) => setState(() => isHoverItem = value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: getBackgroundColorItem(context)
          ),
          padding: SearchMailboxUtils.getPaddingItemListView(context, _responsiveUtils),
          child: Row(
            crossAxisAlignment: widget.presentationMailbox.mailboxPath?.isNotEmpty == true
              || widget.presentationMailbox.isTeamMailboxes
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              _buildMailboxIcon(),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleItem(context),
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
        responsiveUtils: _responsiveUtils,
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
            padding: SearchMailboxUtils.getPaddingItemListView(context, _responsiveUtils),
            child: Row(
              crossAxisAlignment: widget.presentationMailbox.mailboxPath?.isNotEmpty == true
                || widget.presentationMailbox.isTeamMailboxes
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                _buildMailboxIcon(),
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleItem(context),
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
          padding: SearchMailboxUtils.getPaddingItemListView(context, _responsiveUtils),
          child: Row(
            crossAxisAlignment: widget.presentationMailbox.mailboxPath?.isNotEmpty == true
              || widget.presentationMailbox.isTeamMailboxes
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              _buildMailboxIcon(),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleItem(context),
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
    if (widget.presentationMailbox.allowedToDisplay) {
      widget.onClickOpenMailboxAction?.call(widget.presentationMailbox);
    }
  }

  void _onLongPressMailboxAction() {
    if (widget.listPopupMenuItemAction?.isNotEmpty == true) {
      widget.onLongPressMailboxAction?.call(widget.presentationMailbox);
    }
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(
      widget.presentationMailbox.allowedToDisplay
        ? widget.presentationMailbox.getMailboxIcon(_imagePaths)
        : _imagePaths.icHideFolder,
      width: 20,
      height: 20,
      fit: BoxFit.fill
    );
  }

  Widget _buildTitleItem(BuildContext context) {
    return TextOverflowBuilder(
      widget.presentationMailbox.getDisplayName(context),
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black
      ),
    );
  }

  Widget _buildSubtitleItem() {
    if (widget.presentationMailbox.mailboxPath?.isNotEmpty == true) {
      return TextOverflowBuilder(
        (widget.presentationMailbox.mailboxPath ?? ''),
        style: const TextStyle(
          fontSize: 11,
          color: AppColor.colorMailboxPath,
          fontWeight: FontWeight.normal
        ),
      );
    } else if (widget.presentationMailbox.isTeamMailboxes) {
      return TextOverflowBuilder(
        widget.presentationMailbox.emailTeamMailBoxes,
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
    if (widget.listPopupMenuItemAction?.isNotEmpty == true) {
      return Offstage(
        offstage: !_shouldShowPopupMenu,
        child: TMailButtonWidget.fromIcon(
          icon: _imagePaths.icMoreVertical,
          backgroundColor: _popupMenuVisible
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.08)
              : Colors.transparent,
          iconSize: 16,
          padding: const EdgeInsetsDirectional.all(2),
          onTapActionAtPositionCallback: (position) {
            if (PlatformInfo.isCanvasKit) {
              _onPopupMenuVisibleChange(true);
            }
            widget.onClickOpenMenuMailboxAction
              ?.call(position, widget.presentationMailbox)
              .whenComplete(() {
                if (context.mounted && PlatformInfo.isCanvasKit) {
                  _onPopupMenuVisibleChange(false);
                }
              });
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Color getBackgroundColorItem(BuildContext context) {
    if (isHoverItem) {
      return AppColor.colorBgMailboxSelected;
    } else {
      return _responsiveUtils.isDesktop(context)
        ? AppColor.colorBgDesktop
        : Colors.transparent;
    }
  }

  bool get _shouldShowPopupMenu =>
      (isHoverItem && widget.listPopupMenuItemAction?.isNotEmpty == true) ||
      _popupMenuVisible;

  void _onPopupMenuVisibleChange(bool visible) {
    if (_popupMenuVisible != visible) {
      setState(() => _popupMenuVisible = visible);
    }
  }
}