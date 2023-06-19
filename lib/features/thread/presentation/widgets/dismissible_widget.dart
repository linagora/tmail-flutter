import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import '../mixin/base_email_item_tile.dart';

class DismissibleWidget<T> extends StatelessWidget with BaseEmailItemTile {
  final T item;
  final Widget child;
  final DismissDirectionCallback onDismissed;

  DismissibleWidget(
      {super.key,
      required this.item,
      required this.onDismissed,
      required this.child});

  @override
  Widget build(BuildContext context) => Dismissible(
        direction: DismissDirection.startToEnd,
        key: ObjectKey(item),
        background: buildSwipeActionLeft(),
        child: child,
        onDismissed: onDismissed,
      );

  Widget buildSwipeActionLeft() => Container(
        alignment: Alignment.centerLeft,
        decoration: new BoxDecoration(
          color: AppColor.colorItemRecipientSelected,
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {},
            child: buildIconAvatarSwipe(),
          ),
          title: buildTitleTileSwipe("Marke as read"),
        ),
      );
}
