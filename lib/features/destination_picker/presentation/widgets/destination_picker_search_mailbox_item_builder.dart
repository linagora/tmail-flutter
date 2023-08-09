import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/utils/search_mailbox_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class DestinationPickerSearchMailboxItemBuilder extends StatelessWidget {

  final PresentationMailbox _presentationMailbox;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final MailboxActions? mailboxActions;
  final MailboxId? mailboxIdAlreadySelected;
  final OnClickOpenMailboxAction? onClickOpenMailboxAction;

  const DestinationPickerSearchMailboxItemBuilder(
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
    {
      Key? key,
      this.mailboxActions,
      this.mailboxIdAlreadySelected,
      this.onClickOpenMailboxAction
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_presentationMailbox.isActivated,
      child: Opacity(
        opacity: _presentationMailbox.isActivated ? 1.0 : 0.3,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onTapMailboxAction,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            hoverColor: AppColor.colorBgMailboxSelected,
            child: Padding(
              padding: SearchMailboxUtils.getPaddingItemListView(context, _responsiveUtils),
              child: Row(
                crossAxisAlignment: _presentationMailbox.mailboxPath?.isNotEmpty == true
                  || _presentationMailbox.isTeamMailboxes
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
                  _buildSelectedIcon(context)
                ]
              ),
            )
          ),
        )
      ),
    );
  }

  void _onTapMailboxAction() {
    if (!_isSelectActionNoValid && onClickOpenMailboxAction != null) {
      onClickOpenMailboxAction?.call(_presentationMailbox);
    }
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(
      _presentationMailbox.getMailboxIcon(_imagePaths),
      width: PlatformInfo.isWeb ? 20 : 24,
      height: PlatformInfo.isWeb ? 20 : 24,
      fit: BoxFit.fill
    );
  }

  Widget _buildTitleItem(BuildContext context) {
    return Text(
      _presentationMailbox.getDisplayName(context),
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
    if (_presentationMailbox.mailboxPath?.isNotEmpty == true) {
      return Text(
        _presentationMailbox.mailboxPath ?? '',
        maxLines: 1,
        overflow: CommonTextStyle.defaultTextOverFlow,
        softWrap: CommonTextStyle.defaultSoftWrap,
        style: const TextStyle(
          fontSize: 11,
          color: AppColor.colorMailboxPath,
          fontWeight: FontWeight.normal
        ),
      );
    } else if (_presentationMailbox.isTeamMailboxes) {
      return Text(
        _presentationMailbox.emailTeamMailBoxes,
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

  Widget _buildSelectedIcon(BuildContext context) {
    if (_isSelectActionNoValid) {
      return Padding(
        padding: EdgeInsets.only(
          right: AppUtils.isDirectionRTL(context) ? 0 : 8,
          left: AppUtils.isDirectionRTL(context) ? 8 : 0,
        ),
        child: SvgPicture.asset(
          _imagePaths.icSelectedSB,
          width: 20,
          height: 20,
          fit: BoxFit.fill
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  bool get _isSelectActionNoValid => _presentationMailbox.id == mailboxIdAlreadySelected &&
    (
      mailboxActions == MailboxActions.select ||
      mailboxActions == MailboxActions.create ||
      mailboxActions == MailboxActions.moveEmail
    );
}