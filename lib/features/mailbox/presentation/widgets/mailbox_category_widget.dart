import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnToggleMailboxCategories = Function(MailboxCategories, GlobalKey);

class MailboxCategoryWidget extends StatefulWidget {
  final MailboxCategories categories;
  final ExpandMode expandMode;
  final OnToggleMailboxCategories onToggleMailboxCategories;
  final bool isArrangeLTR;
  final EdgeInsetsGeometry? padding;

  const MailboxCategoryWidget({
    super.key,
    required this.categories,
    required this.expandMode,
    required this.onToggleMailboxCategories,
    this.isArrangeLTR = true,
    this.padding,
  });

  @override
  State<MailboxCategoryWidget> createState() => _MailboxCategoryWidgetState();
}

class _MailboxCategoryWidgetState extends State<MailboxCategoryWidget> {

  final _imagePaths = Get.find<ImagePaths>();

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final item = Row(
      key: _key,
      children: [
        if (!widget.isArrangeLTR)
          Flexible(
            child: Text(
              widget.categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
        TMailButtonWidget.fromIcon(
            icon: widget.expandMode.getIcon(
              _imagePaths,
              DirectionUtils.isDirectionRTLByLanguage(context),
            ),
            iconColor: Colors.black,
            iconSize: 20,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(5),
            tooltipMessage: widget.expandMode.getTooltipMessage(AppLocalizations.of(context)),
            onTapActionCallback: () =>
                widget.onToggleMailboxCategories(widget.categories, _key)),
        if (widget.isArrangeLTR)
          Expanded(
            child: Text(
              widget.categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
      ],
    );

    if (widget.padding != null) {
      return Padding(padding: widget.padding!, child: item);
    } else {
      return item;
    }
  }
}
