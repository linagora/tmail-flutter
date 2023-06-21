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
      startActionPane:ActionPane(
        motion: const ScrollMotion(),
        children: [buildSwipeAction(imagePaths.icEmailOpen,textLeft),],
      ),
      endActionPane: ActionPane(motion: const ScrollMotion(),
        children: [buildSwipeAction(imagePaths.icMoveMailbox,textRight),],),
      child: child,
  );

  Widget buildSwipeAction(String? imagePaths , String? text ) => Container(
      alignment: Alignment.centerLeft,
      decoration: new BoxDecoration(
        color: AppColor.colorItemRecipientSelected,
      ),
      child: Row(children: [
        SizedBox(width: 10,),
        buildIconAvatarSwipe(imagePaths),
        SizedBox(width: 10,),
        buildTitleTileSwipe(text),
      ],)
  );
}
