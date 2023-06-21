import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';

class DismissibleWidget<T> extends StatelessWidget with BaseEmailItemTile {
  final T? item;
  final Widget child;
  final DismissDirectionCallback? onDismissed;
  final String? textLeft;

  DismissibleWidget(
    {
      super.key,
      this.item,
      this.onDismissed,
      this.textLeft,
      required this.child
    }
  );

  @override
  Widget build(BuildContext context) => Dismissible(
      direction: DismissDirection.startToEnd,
      key: ObjectKey(item),
      background: buildSwipeActionLeft(),
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
}
