
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

mixin FilterEmailPopupMenuMixin {
  final _imagePaths = Get.find<ImagePaths>();

  List<PopupMenuEntry> popupMenuFilterEmailActionTile(
    BuildContext context,
    FilterMessageOption optionSelected,
    Function(FilterMessageOption)? onCallBack,
    {
      bool isSearchEmailRunning = false
    }
  ) {
    return [
      if (!isSearchEmailRunning)
       ...[
         PopupMenuItem(
           padding: EdgeInsets.zero,
           child: _filterEmailAction(
             context,
             optionSelected,
             FilterMessageOption.attachments,
             onCallBack)),
         const PopupMenuDivider(height: 0.5)
       ],
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: _filterEmailAction(
          context,
          optionSelected,
          FilterMessageOption.unread,
          onCallBack)),
      const PopupMenuDivider(height: 0.5),
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: _filterEmailAction(
          context,
          optionSelected,
          FilterMessageOption.starred,
          onCallBack)),
    ];
  }

  Widget _filterEmailAction(
    BuildContext context,
    FilterMessageOption optionSelected,
    FilterMessageOption option,
    Function(FilterMessageOption)? onCallBack
  ) {
    return InkWell(
      onTap: () => onCallBack?.call(option),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
            child: Row(children: [
              SvgPicture.asset(option.getContextMenuIcon(_imagePaths),
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                  colorFilter: option != FilterMessageOption.starred
                      ? AppColor.colorTextButton.asFilter()
                      : null),
              const SizedBox(width: 12),
              Expanded(child: Text(
                  option.getName(context),
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500))),
              if (optionSelected == option)
                ... [
                  const SizedBox(width: 12),
                  SvgPicture.asset(_imagePaths.icFilterSelected,
                      width: 16,
                      height: 16,
                      fit: BoxFit.fill),
                ]
            ])
        ),
      )
    );
  }
}