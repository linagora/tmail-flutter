import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';

class DismissibleWidget<T> extends StatelessWidget with BaseEmailItemTile {
  final T? item;
  final Widget child;
  final VoidCallback onDismissedLeft;
  final VoidCallback onDismissedRight;
  final String? iconLeft;
  final String? iconRight;
  final String? textLeft;
  final String? textRight;

  DismissibleWidget(
    {
      super.key,
      this.item,
      required this.onDismissedLeft,
      required this.onDismissedRight,
      this.textLeft,
      this.textRight,
      required this.child,
      this.iconRight,
      this.iconLeft
    }
  );

  @override
  Widget build(BuildContext context) => Slidable(
      key: ValueKey(item),
      startActionPane:ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed:(){
          onDismissedLeft();
          }
        ),
        children: [
          CustomSlidableAction(
            onPressed: (BuildContext context) {
              onDismissedLeft();
            },
            child: buildSwipeActionLeft(),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          onDismissedRight();
        }),
        children: [
          CustomSlidableAction(
            onPressed: (BuildContext context) {
              onDismissedRight();
            },
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
          child: buildIconAvatarSwipe(iconRight),
          onTap: () {
            onDismissedRight();
          },
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
        child: buildIconAvatarSwipe(iconLeft),
        onTap: () {
          onDismissedLeft();
        },
      ),
      title: buildTitleTileSwipe(textLeft),
    ),
  );
}
