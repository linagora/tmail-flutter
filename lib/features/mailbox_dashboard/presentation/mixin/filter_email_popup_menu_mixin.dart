
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/filter_message_option_extension.dart';

mixin FilterEmailPopupMenuMixin {
  final _imagePaths = Get.find<ImagePaths>();

  List<PopupMenuEntry> popupMenuFilterEmailActionTile(BuildContext context,
      FilterMessageOption optionSelected, Function(FilterMessageOption)? onCallBack) {
    return [
      PopupMenuItem(
          padding: EdgeInsets.zero,
          child: _filterEmailAction(context, optionSelected, FilterMessageOption.attachments, onCallBack)),
      const PopupMenuDivider(height: 0.5),
      PopupMenuItem(
          padding: EdgeInsets.zero,
          child: _filterEmailAction(context, optionSelected, FilterMessageOption.unread, onCallBack)),
      const PopupMenuDivider(height: 0.5),
      PopupMenuItem(
          padding: EdgeInsets.zero,
          child: _filterEmailAction(context, optionSelected, FilterMessageOption.starred, onCallBack)),
    ];
  }

  Widget _filterEmailAction(BuildContext context, FilterMessageOption optionSelected,
      FilterMessageOption option, Function(FilterMessageOption)? onCallBack) {
    return InkWell(
      onTap: () => onCallBack?.call(option == optionSelected ? FilterMessageOption.all : option),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
            child: Row(children: [
              SvgPicture.asset(option.getIcon(_imagePaths),
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                  color: option != FilterMessageOption.starred ? AppColor.colorTextButton : null),
              const SizedBox(width: 12),
              Expanded(child: Text(
                  option.getName(context),
                  style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500))),
              if (optionSelected == option)
                const SizedBox(width: 12),
              if (optionSelected == option)
                SvgPicture.asset(_imagePaths.icFilterSelected, width: 16, height: 16, fit: BoxFit.fill),
            ])
        ),
      )
    );
  }
}