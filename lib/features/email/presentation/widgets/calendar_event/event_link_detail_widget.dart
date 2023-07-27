
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/hyper_link_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/event_location_detail_widget_styles.dart';
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
          width: EventLocationDetailWidgetStyles.maxWidth,
          child: Text(
            AppLocalizations.of(context).link,
            style: const TextStyle(
              fontSize: EventLocationDetailWidgetStyles.textSize,
              fontWeight: FontWeight.w500,
              color: AppColor.colorSubTitleEventActionText
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