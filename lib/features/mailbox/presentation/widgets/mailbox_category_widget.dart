import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnToggleMailboxCategories = Function(MailboxCategories, GlobalKey);

class MailboxCategoryWidget extends StatefulWidget {
  final MailboxCategories categories;
  final ExpandMode expandMode;
  final OnToggleMailboxCategories onToggleMailboxCategories;
  final bool isArrangeLTR;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? iconSpace;
  final TextStyle? labelTextStyle;

  const MailboxCategoryWidget({
    super.key,
    required this.categories,
    required this.expandMode,
    required this.onToggleMailboxCategories,
    this.isArrangeLTR = true,
    this.showIcon = false,
    this.padding,
    this.height,
    this.iconSpace,
    this.labelTextStyle,
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
        if (widget.showIcon)
          ...[
            SvgPicture.asset(
              _imagePaths.icFolderMailbox,
              width: MailboxIconWidgetStyles.iconSize,
              height: MailboxIconWidgetStyles.iconSize,
              fit: BoxFit.fill,
            ),
            SizedBox(width: widget.iconSpace ?? MailboxItemWidgetStyles.labelIconSpace),
          ],
        if (!widget.isArrangeLTR)
          Flexible(
            child: Text(
              widget.categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.labelTextStyle ?? ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
        TMailButtonWidget.fromIcon(
            icon: widget.expandMode.getIcon(
              _imagePaths,
              DirectionUtils.isDirectionRTLByLanguage(context),
            ),
            iconColor: Colors.black,
            iconSize: 17,
            backgroundColor: Colors.transparent,
            margin: const EdgeInsetsDirectional.only(start: 8),
            padding: const EdgeInsets.all(3),
            tooltipMessage: widget.expandMode.getTooltipMessage(AppLocalizations.of(context)),
            onTapActionCallback: () =>
                widget.onToggleMailboxCategories(widget.categories, _key)),
        if (widget.isArrangeLTR)
          Expanded(
            child: Text(
              widget.categories.getTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.labelTextStyle ?? ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
      ],
    );

    if (widget.padding != null && widget.height != null) {
      return Container(
        padding: widget.padding!,
        height: widget.height!,
        child: item,
      );
    } else if (widget.padding != null) {
      return Padding(padding: widget.padding!, child: item);
    } else {
      return item;
    }
  }
}
