
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';

class ContextMenuDialogItem extends StatelessWidget {
  final ContextMenuItemAction menuAction;
  final OnContextMenuActionClick onContextMenuActionClick;

  const ContextMenuDialogItem({
    super.key,
    required this.menuAction,
    required this.onContextMenuActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => menuAction.onClick(onContextMenuActionClick),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 32,
                  width: 32,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    menuAction.actionIcon,
                    width: 20,
                    height: 20,
                    colorFilter: menuAction.actionIconColor.asFilter(),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  menuAction.actionName,
                  style: ThemeUtils.textStyleInter400.copyWith(
                    color: menuAction.actionNameColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
