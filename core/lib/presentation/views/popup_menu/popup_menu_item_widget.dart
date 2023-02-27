
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

@immutable
class PopupMenuItemWidget extends StatelessWidget {

  final Function onTapCallback;
  final String icon;
  final String name;
  final Color? iconColor;
  final String? iconSelection;

  const PopupMenuItemWidget(
    this.icon,
    this.name,
    this.onTapCallback,
    {Key? key,
      this.iconSelection,
      this.iconColor
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTapCallback.call(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
              child: Row(children: [
                SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                  colorFilter: iconColor.asFilter()
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(name,
                    style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500))),
                if (iconSelection != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: SvgPicture.asset(iconSelection!, width: 16, height: 16, fit: BoxFit.fill)),
              ])
          ),
        )
    );
  }
}