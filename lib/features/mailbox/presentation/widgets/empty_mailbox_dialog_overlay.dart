import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/clipper/side_arrow_clipper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/empty_mailbox_dialog_overlay_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmptyMailboxDialogOverlay extends StatelessWidget {

  final MailboxNode mailboxNode;
  final OnEmptyMailboxActionCallback onEmptyMailboxActionCallback;
  final OnCancelActionClick onCancelActionClick;

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  EmptyMailboxDialogOverlay({
    Key? key,
    required this.mailboxNode,
    required this.onEmptyMailboxActionCallback,
    required this.onCancelActionClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: PhysicalShape(
        clipBehavior: Clip.antiAlias,
        clipper: SideArrowClipper(isRight: AppUtils.isDirectionRTL(context)),
        color: EmptyMailboxDialogOverlayStyles.backgroundColor,
        shadowColor: EmptyMailboxDialogOverlayStyles.shadowColor,
        elevation: EmptyMailboxDialogOverlayStyles.elevation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: _responsiveUtils.getSizeScreenHeight(context)
          ),
          width: EmptyMailboxDialogOverlayStyles.width,
          padding: EmptyMailboxDialogOverlayStyles.padding,
          margin: EmptyMailboxDialogOverlayStyles.margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                     AppLocalizations.of(context).clearFolder,
                     style: EmptyMailboxDialogOverlayStyles.titleTextStyle
                    ),
                  ),
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icClose,
                    iconSize: EmptyMailboxDialogOverlayStyles.closeButtonIconSize,
                    iconColor: EmptyMailboxDialogOverlayStyles.closeButtonColor,
                    backgroundColor: Colors.transparent,
                    padding: EmptyMailboxDialogOverlayStyles.iconPadding,
                    onTapActionCallback: onCancelActionClick,
                  )
                ]
              ),
              const SizedBox(height: EmptyMailboxDialogOverlayStyles.space),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).messageEmptyFolderDialog(mailboxNode.item.getDisplayName(context)),
                  style: EmptyMailboxDialogOverlayStyles.messageTextStyle
                ),
              ),
              const SizedBox(height: EmptyMailboxDialogOverlayStyles.space),
              Row(
                children: [
                  const Spacer(),
                  TMailButtonWidget.fromText(
                    text: AppLocalizations.of(context).cancel,
                    backgroundColor: EmptyMailboxDialogOverlayStyles.cancelButtonColor,
                    padding: EmptyMailboxDialogOverlayStyles.buttonPadding,
                    textStyle: EmptyMailboxDialogOverlayStyles.buttonTextStyle,
                    borderRadius: EmptyMailboxDialogOverlayStyles.buttonRadius,
                    onTapActionCallback: onCancelActionClick,
                  ),
                  const SizedBox(width: EmptyMailboxDialogOverlayStyles.buttonSpace),
                  TMailButtonWidget.fromText(
                    text: AppLocalizations.of(context).clean,
                    backgroundColor: EmptyMailboxDialogOverlayStyles.emptyButtonColor,
                    padding: EmptyMailboxDialogOverlayStyles.buttonPadding,
                    textStyle: EmptyMailboxDialogOverlayStyles.cleanButtonTextStyle,
                    borderRadius: EmptyMailboxDialogOverlayStyles.buttonRadius,
                    onTapActionCallback: () => onEmptyMailboxActionCallback.call(mailboxNode),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}