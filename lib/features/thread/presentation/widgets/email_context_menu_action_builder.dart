
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:model/model.dart';

class EmailContextMenuActionBuilder extends ContextMenuActionBuilder<List<PresentationEmail>> {
  final List<PresentationEmail> _listEmail;

  EmailContextMenuActionBuilder(
      Key key,
      SvgPicture actionIcon,
      String actionName,
      this._listEmail
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
          onContextMenuActionClick!(_listEmail);
        }
      }
    );
  }
}