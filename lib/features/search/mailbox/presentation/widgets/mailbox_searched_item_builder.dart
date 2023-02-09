import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';

class MailboxSearchedItemBuilder extends StatefulWidget {

  final PresentationMailbox _presentationMailbox;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final OnClickOpenMailboxAction? onClickOpenMailboxAction;
  final OnClickOpenMenuMailboxAction? onClickOpenMenuMailboxAction;
  final OnDragEmailToMailboxAccepted? onDragEmailToMailboxAccepted;
  final OnLongPressMailboxAction? onLongPressMailboxAction;

  const MailboxSearchedItemBuilder(
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
    {
      Key? key,
      this.onClickOpenMailboxAction,
      this.onClickOpenMenuMailboxAction,
      this.onDragEmailToMailboxAccepted,
      this.onLongPressMailboxAction
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
        builder: (_, __, ___) {
          return _buildMailboxItem(context);
        },
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
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              if (widget._presentationMailbox.isSubscribed?.value == true)
                _buildMenuIcon(context)
            ]
          ),
        )
      );
    } else {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: _onTapMailboxAction,
        onLongPress: _onLongPressMailboxAction,
        leading: _buildMailboxIcon(),
        title: _buildTitleItem(),
        subtitle: _buildSubtitleItem()
      );
    }
  }

  void _onTapMailboxAction() {
    if (widget._presentationMailbox.isSubscribed?.value == true) {
      widget.onClickOpenMailboxAction?.call(widget._presentationMailbox);
    }
  }

  void _onLongPressMailboxAction() {
    widget.onLongPressMailboxAction?.call(widget._presentationMailbox);
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(
      widget._presentationMailbox.isSubscribed?.value == true
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
          color: AppColor.colorMailboxPath
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMenuIcon(BuildContext context) {
    if (isHoverItem) {
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