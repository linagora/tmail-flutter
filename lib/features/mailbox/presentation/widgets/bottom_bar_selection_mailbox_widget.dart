import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';

typedef OnMailboxActionsClick = void Function(MailboxActions, List<PresentationMailbox>);

class BottomBarSelectionMailboxWidget extends StatelessWidget {

  final ResponsiveUtils _responsiveUtils;
  final ImagePaths _imagePaths;
  final List<PresentationMailbox> _listSelectionMailbox;
  final List<MailboxActions> _listMailboxActions;
  final OnMailboxActionsClick onMailboxActionsClick;

  const BottomBarSelectionMailboxWidget(
    this._responsiveUtils,
    this._imagePaths,
    this._listSelectionMailbox,
    this._listMailboxActions,
    {
      Key? key,
      required this.onMailboxActionsClick
    }
  ) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Row(children: _listMailboxActions
      .map((action) => _buildMailboxActionButton(context, action))
      .toList());
  }

  Widget _buildMailboxActionButton(BuildContext context, MailboxActions actions) {
    return Expanded(child: (ButtonBuilder(actions.getContextMenuIcon(_imagePaths))
      ..radiusSplash(8)
      ..padding(const EdgeInsets.all(8))
      ..tooltip(actions.getTitleContextMenu(context))
      ..textStyle(const TextStyle(fontSize: 12, color: AppColor.colorTextButton))
      ..iconColor(AppColor.colorTextButton)
      ..onPressActionClick(() => onMailboxActionsClick.call(actions, _listSelectionMailbox))
      ..text(
        _responsiveUtils.isLandscapeMobile(context) ? null : actions.getTitleContextMenu(context),
        isVertical: true
      )
    ).build());
  }
}