
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/hyper_link_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_link_detail_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EventLinkDetailWidget extends StatelessWidget {

  final List<String> listHyperLink;

  const EventLinkDetailWidget({
    super.key,
    required this.listHyperLink
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: EventLinkDetailWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).link,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: EventLinkDetailWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: EventLinkDetailWidgetStyles.labelColor
            ),
          ),
        ),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: listHyperLink.map((link) => HyperLinkWidget(urlString: link)).toList(),
        ))
      ],
    );
  }
}