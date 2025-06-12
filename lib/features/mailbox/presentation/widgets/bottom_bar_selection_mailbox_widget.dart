import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnMailboxActionsClick = void Function(MailboxActions, List<PresentationMailbox>);

class BottomBarSelectionMailboxWidget extends StatelessWidget {

  final List<PresentationMailbox> _listSelectionMailbox;
  final List<MailboxActions> _listMailboxActions;
  final OnMailboxActionsClick onMailboxActionsClick;

  const BottomBarSelectionMailboxWidget(
    this._listSelectionMailbox,
    this._listMailboxActions,
    {
      Key? key,
      required this.onMailboxActionsClick
    }
  ) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final imagePaths = Get.find<ImagePaths>();

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(
          color: AppColor.colorDividerHorizontal,
          width: 0.5,
        )),
      ),
      child: IntrinsicHeight(
        child: Row(children: _listMailboxActions
          .map((action) {
            return Expanded(child: TMailButtonWidget(
              key: Key('${action.name}_button'),
              text: responsiveUtils.isLandscapeMobile(context)
                ? ''
                : action.getTitleContextMenu(AppLocalizations.of(context)),
              icon: action.getContextMenuIcon(imagePaths),
              borderRadius: 0,
              backgroundColor: Colors.transparent,
              flexibleText: true,
              tooltipMessage: action.getTitleContextMenu(AppLocalizations.of(context)),
              textStyle: const TextStyle(fontSize: 12, color: AppColor.colorTextButton),
              onTapActionCallback: () => onMailboxActionsClick.call(action, _listSelectionMailbox),
            ));
          })
          .toList()
        ),
      ),
    );
  }
}