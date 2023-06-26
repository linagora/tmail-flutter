import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  Widget build(BuildContext context) => Slidable(
      key: const ValueKey(0),
      startActionPane:ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          CustomSlidableAction(
            onPressed: (BuildContext context) {  },
            child: buildSwipeActionLeft(),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          CustomSlidableAction(
            onPressed: (BuildContext context) {  },
            child: buildSwipeActionRight()
          ),
        ],
      ),
      child: child,
  );

  Widget buildSwipeActionRight() => Container(
      alignment: Alignment.centerRight,
      decoration: new BoxDecoration(
      color: AppColor.colorItemRecipientSelected,
      ),
      child: ListTile(
        title: buildTitleTileSwipe(textRight),
        leading: GestureDetector(
          child: buildIconAvatarSwipe(imagePaths.icMoveMailbox),
          onTap: () {},
        ),
      ),
  );

  Widget buildSwipeActionLeft() => Container(
    alignment: Alignment.centerLeft,
    decoration: new BoxDecoration(
      color: AppColor.colorItemRecipientSelected,
    ),
    child: ListTile(
      leading: GestureDetector(
        child: buildIconAvatarSwipe(imagePaths.icEmailOpen),
        onTap: () {},
      ),
      title: buildTitleTileSwipe(textLeft),
    ),
  );
}
