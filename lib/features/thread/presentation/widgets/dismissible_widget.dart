import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';

class DismissibleWidget<T> extends StatelessWidget with BaseEmailItemTile {
  final T? item;
  final Widget child;
  final DismissDirectionCallback? onDismissed;
  final String? textLeft;
  final String? textRight;

  DismissibleWidget(
    {
      super.key,
      this.item,
      this.onDismissed,
      this.textLeft,
      this.textRight,
      required this.child
    }
  );

  @override
  Widget build(BuildContext context) => Dismissible(
      key: ObjectKey(item),
      background: buildSwipeActionLeft(),
      secondaryBackground: buildSwipeActionRight(),
      onDismissed: onDismissed,
      child: child,
  );

  Widget buildSwipeActionLeft() => Container(
      alignment: Alignment.centerLeft,
      decoration: new BoxDecoration(
        color: AppColor.colorItemRecipientSelected,
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {},
            child: buildIconAvatarSwipe(imagePaths.icEmailOpen),
        ),
        title: buildTitleTileSwipe(textLeft),
      ),
  );

  Widget buildSwipeActionRight() => Container(
    alignment: Alignment.centerRight,
    decoration: new BoxDecoration(
      color: AppColor.colorItemRecipientSelected,
    ),
    child: ListTile(
      trailing: GestureDetector(
        onTap: () {},
        child: buildIconAvatarSwipe(imagePaths.icMoveMailbox),
      ),
      title: Row(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildTitleTileSwipe(textRight),
        ],
      ),
    ),
  );
}
