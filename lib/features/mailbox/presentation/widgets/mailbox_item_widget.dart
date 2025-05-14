import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';

class MailboxItemWidget extends StatefulWidget {

  final MailboxNode mailboxNode;
  final SelectMode selectionMode;
  final MailboxDisplayed mailboxDisplayed;
  final PresentationMailbox? mailboxNodeSelected;
  final MailboxActions? mailboxActions;
  final MailboxId? mailboxIdAlreadySelected;

  final OnClickExpandMailboxNodeAction? onExpandFolderActionClick;
  final OnClickOpenMailboxNodeAction? onOpenMailboxFolderClick;
  final OnSelectMailboxNodeAction? onSelectMailboxFolderClick;
  final OnClickOpenMenuMailboxNodeAction? onMenuActionClick;
  final OnDragEmailToMailboxAccepted? onDragItemAccepted;
  final OnLongPressMailboxNodeAction? onLongPressMailboxNodeAction;
  final OnEmptyMailboxActionCallback? onEmptyMailboxActionCallback;

  const MailboxItemWidget({
    super.key,
    required this.mailboxNode,
    this.selectionMode = SelectMode.INACTIVE,
    this.mailboxDisplayed = MailboxDisplayed.mailbox,
    this.mailboxNodeSelected,
    this.mailboxActions,
    this.mailboxIdAlreadySelected,
    this.onExpandFolderActionClick,
    this.onOpenMailboxFolderClick,
    this.onSelectMailboxFolderClick,
    this.onMenuActionClick,
    this.onDragItemAccepted,
    this.onLongPressMailboxNodeAction,
    this.onEmptyMailboxActionCallback,
  });

  @override
  State<MailboxItemWidget> createState() => _MailboxItemWidgetState();
}

class _MailboxItemWidgetState extends State<MailboxItemWidget> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  bool _isItemHovered = false;
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (_responsiveUtils.isWebDesktop(context) && widget.mailboxDisplayed == MailboxDisplayed.mailbox) {
      return DragTarget<List<PresentationEmail>>(
        key: _key,
        builder: (context, candidateEmails, rejectedEmails) {
          return InkWell(
            onTap: () => widget.onOpenMailboxFolderClick?.call(widget.mailboxNode),
            onHover: (value) => setState(() => _isItemHovered = value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(MailboxItemWidgetStyles.borderRadius)),
                color: backgroundColorItem
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: MailboxItemWidgetStyles.itemPadding,
              ),
              height: widget.mailboxNode.item.isTeamMailboxes
                  ? MailboxItemWidgetStyles.teamMailboxHeight
                  : MailboxItemWidgetStyles.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: widget.mailboxNode.item.isTeamMailboxes
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
                children: [
                  MailboxIconWidget(
                    imagePaths: _imagePaths,
                    mailboxNode: widget.mailboxNode,
                    selectionMode: widget.selectionMode,
                    padding: EdgeInsetsDirectional.only(
                      end: widget.mailboxNode.item.isTeamMailboxes
                          ? MailboxItemWidgetStyles.teamMailboxLabelSpace
                          : MailboxItemWidgetStyles.labelIconSpace,
                    ),
                    onSelectMailboxFolderClick: widget.onSelectMailboxFolderClick,
                  ),
                  Expanded(
                    child: LabelMailboxItemWidget(
                      itemKey: _key,
                      responsiveUtils: _responsiveUtils,
                      mailboxNode: widget.mailboxNode,
                      imagePaths: _imagePaths,
                      isItemHovered: _isItemHovered,
                      isSelected: _isSelected,
                      onMenuActionClick: widget.onMenuActionClick,
                      onEmptyMailboxActionCallback: widget.onEmptyMailboxActionCallback,
                      onClickExpandMailboxNodeAction: widget.onExpandFolderActionClick,
                    )
                  ),
                ]
              )
            ),
          );
        },
        onAcceptWithDetails: (emails) => widget.onDragItemAccepted?.call(emails.data, widget.mailboxNode.item),
      );
    } else {
      if (widget.mailboxDisplayed == MailboxDisplayed.mailbox) {
        if (PlatformInfo.isWeb) {
          return InkWell(
            key: _key,
            onTap: () => widget.onOpenMailboxFolderClick?.call(widget.mailboxNode),
            onHover: (value) => setState(() => _isItemHovered = value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(MailboxItemWidgetStyles.borderRadius)),
                color: backgroundColorItem
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: MailboxItemWidgetStyles.itemPadding,
              ),
              height: widget.mailboxNode.item.isTeamMailboxes
                  ? MailboxItemWidgetStyles.teamMailboxHeight
                  : MailboxItemWidgetStyles.height,
              child: Row(
                children: [
                  MailboxIconWidget(
                    imagePaths: _imagePaths,
                    mailboxNode: widget.mailboxNode,
                    selectionMode: widget.selectionMode,
                    padding: EdgeInsetsDirectional.only(
                      end: widget.mailboxNode.item.isTeamMailboxes
                          ? MailboxItemWidgetStyles.teamMailboxLabelSpace
                          : MailboxItemWidgetStyles.labelIconSpace,
                    ),
                    onSelectMailboxFolderClick: widget.onSelectMailboxFolderClick,
                  ),
                  Expanded(
                    child: LabelMailboxItemWidget(
                      itemKey: _key,
                      responsiveUtils: _responsiveUtils,
                      mailboxNode: widget.mailboxNode,
                      imagePaths: _imagePaths,
                      isItemHovered: _isItemHovered,
                      isSelected: _isSelected,
                      onMenuActionClick: widget.onMenuActionClick,
                      onEmptyMailboxActionCallback: widget.onEmptyMailboxActionCallback,
                      onClickExpandMailboxNodeAction: widget.onExpandFolderActionClick,
                    )
                  ),
                ]
              )
            ),
          );
        } else {
          return Material(
            key: _key,
            color: Colors.transparent,
            child: InkWell(
              onLongPress: () => widget.onLongPressMailboxNodeAction?.call(widget.mailboxNode),
              onTap: () => widget.selectionMode == SelectMode.ACTIVE
                ? widget.onSelectMailboxFolderClick?.call(widget.mailboxNode)
                : widget.onOpenMailboxFolderClick?.call(widget.mailboxNode),
              borderRadius: const BorderRadius.all(Radius.circular(MailboxItemWidgetStyles.borderRadius)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(MailboxItemWidgetStyles.borderRadius)),
                  color: backgroundColorItem
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: MailboxItemWidgetStyles.itemPadding,
                ),
                height: widget.mailboxNode.item.isTeamMailboxes
                    ? MailboxItemWidgetStyles.teamMailboxHeight
                    : MailboxItemWidgetStyles.height,
                child: Row(
                  children: [
                    MailboxIconWidget(
                      imagePaths: _imagePaths,
                      mailboxNode: widget.mailboxNode,
                      selectionMode: widget.selectionMode,
                      padding: EdgeInsetsDirectional.only(
                        end: widget.mailboxNode.item.isTeamMailboxes
                            ? MailboxItemWidgetStyles.teamMailboxLabelSpace
                            : MailboxItemWidgetStyles.labelIconSpace,
                      ),
                      onSelectMailboxFolderClick: widget.onSelectMailboxFolderClick,
                    ),
                    Expanded(
                      child: LabelMailboxItemWidget(
                        itemKey: _key,
                        responsiveUtils: _responsiveUtils,
                        mailboxNode: widget.mailboxNode,
                        imagePaths: _imagePaths,
                        isItemHovered: _isItemHovered,
                        isSelected: _isSelected,
                        onMenuActionClick: widget.onMenuActionClick,
                        onEmptyMailboxActionCallback: widget.onEmptyMailboxActionCallback,
                        onClickExpandMailboxNodeAction: widget.onExpandFolderActionClick,
                    )
                    ),
                    if (_isSelectActionNoValid)
                      SvgPicture.asset(
                        _imagePaths.icSelectedSB,
                        width: MailboxItemWidgetStyles.selectionIconSize,
                        height: MailboxItemWidgetStyles.selectionIconSize,
                        fit: BoxFit.fill
                      )
                  ]
                ),
              ),
            ),
          );
        }
      } else {
        return AbsorbPointer(
          key: _key,
          absorbing: !widget.mailboxNode.isActivated,
          child: Opacity(
            opacity: widget.mailboxNode.isActivated ? 1.0 : 0.3,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => !_isSelectActionNoValid
                  ? widget.onOpenMailboxFolderClick?.call(widget.mailboxNode)
                  : null,
                customBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                hoverColor: AppColor.colorMailboxHovered,
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: MailboxItemWidgetStyles.itemPadding,
                  ),
                  height: widget.mailboxNode.item.isTeamMailboxes
                      ? MailboxItemWidgetStyles.teamMailboxHeight
                      : MailboxItemWidgetStyles.height,
                  color: widget.mailboxNode.isSelected
                      ? AppColor.colorItemSelected
                      : Colors.transparent,
                  child: Row(
                    children: [
                      MailboxIconWidget(
                        imagePaths: _imagePaths,
                        mailboxNode: widget.mailboxNode,
                        selectionMode: widget.selectionMode,
                        padding: EdgeInsetsDirectional.only(
                          end: widget.mailboxNode.item.isTeamMailboxes
                              ? MailboxItemWidgetStyles.teamMailboxLabelSpace
                              : MailboxItemWidgetStyles.labelIconSpace,
                        ),
                        onSelectMailboxFolderClick: widget.onSelectMailboxFolderClick,
                      ),
                      Expanded(
                        child: LabelMailboxItemWidget(
                          itemKey: _key,
                          responsiveUtils: _responsiveUtils,
                          mailboxNode: widget.mailboxNode,
                          imagePaths: _imagePaths,
                          showTrailing: false,
                          isSelected: _isSelected,
                          isItemHovered: _isItemHovered,
                          onMenuActionClick: widget.onMenuActionClick,
                          onEmptyMailboxActionCallback: widget.onEmptyMailboxActionCallback,
                          onClickExpandMailboxNodeAction: widget.onExpandFolderActionClick,
                        )
                      ),
                      if (_isSelectActionNoValid)
                        SvgPicture.asset(
                          _imagePaths.icSelectedSB,
                          width: MailboxItemWidgetStyles.selectionIconSize,
                          height: MailboxItemWidgetStyles.selectionIconSize,
                          fit: BoxFit.fill
                        ),
                    ]
                  )
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  bool get _isSelected =>
      widget.mailboxNodeSelected?.id == widget.mailboxNode.item.id;

  Color get backgroundColorItem {
    if (widget.mailboxDisplayed == MailboxDisplayed.destinationPicker) {
      return Colors.white;
    } else {
      if (_isSelected || _isItemHovered) {
        return AppColor.blue100;
      } else {
        return Colors.transparent;
      }
    }
  }

  bool get _isSelectActionNoValid => widget.mailboxNode.item.id == widget.mailboxIdAlreadySelected &&
    widget.mailboxDisplayed == MailboxDisplayed.destinationPicker &&
    (
      widget.mailboxActions == MailboxActions.select ||
      widget.mailboxActions == MailboxActions.create ||
      widget.mailboxActions == MailboxActions.moveEmail
    );
}