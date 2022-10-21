
import 'package:core/presentation/views/context_menu/context_menu_action_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SimpleContextMenuActionBuilder extends ContextMenuActionBuilder<void> {
  SimpleContextMenuActionBuilder(
    Key key,
    SvgPicture actionIcon,
    String actionName
  ) : super(key, actionIcon, actionName);

  @override
  ListTile build() {
    return ListTile(
      key: key,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: actionIcon),
      title: Text(actionName, style: actionTextStyle()),
      onTap: () {
        if (onContextMenuActionClick != null) {
          onContextMenuActionClick!(null);
        }
      });
  }
}
