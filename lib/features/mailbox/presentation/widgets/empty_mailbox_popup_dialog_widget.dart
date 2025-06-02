import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/empty_mailbox_popup_dialog_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/empty_mailbox_dialog_overlay.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPopupVisibleChange = void Function(bool visible);

class EmptyMailboxPopupDialogWidget extends StatefulWidget {

  final MailboxNode mailboxNode;
  final OnEmptyMailboxActionCallback onEmptyMailboxActionCallback;
  final OnPopupVisibleChange? onPopupVisibleChange;

  const EmptyMailboxPopupDialogWidget({
    super.key,
    required this.mailboxNode,
    required this.onEmptyMailboxActionCallback,
    this.onPopupVisibleChange,
  });

  @override
  State<EmptyMailboxPopupDialogWidget> createState() => _EmptyMailboxPopupDialogWidgetState();
}

class _EmptyMailboxPopupDialogWidgetState extends State<EmptyMailboxPopupDialogWidget> {

  bool _visible = false;

  void _setVisible(bool visible) {
    if (_visible != visible) {
      setState(() => _visible = visible);
      widget.onPopupVisibleChange?.call(visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _visible,
      portalFollower: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _setVisible(false),
      ),
      child: PortalTarget(
        anchor: const Aligned(
          follower: Alignment.bottomLeft,
          target: Alignment.topRight,
          offset: EmptyMailboxPopupDialogWidgetStyles.dialogOverlayOffset
        ),
        portalFollower: EmptyMailboxDialogOverlay(
          mailboxNode: widget.mailboxNode,
          onCancelActionClick: () => _setVisible(false),
          onEmptyMailboxActionCallback: (mailboxNode) {
            _setVisible(false);
            widget.onEmptyMailboxActionCallback.call(mailboxNode);
          },
        ),
        visible: _visible,
        child: TMailButtonWidget.fromText(
          text: AppLocalizations.of(context).clean,
          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColor.steelGrayA540,
          ),
          backgroundColor: Colors.transparent,
          padding: EmptyMailboxPopupDialogWidgetStyles.emptyButtonPadding,
          onTapActionCallback: () => _setVisible(true),
        )
      )
    );
  }
}