
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ReceivedTimeBuilder extends StatelessWidget {

  final PresentationEmail emailSelected;
  final EdgeInsetsGeometry? padding;
  final bool showDaysAgo;

  const ReceivedTimeBuilder({
    Key? key,
    required this.emailSelected,
    this.padding,
    this.showDaysAgo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final daysPast = getDaysPast(emailSelected.receivedAt, appLocalizations);
    
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.only(start: 16),
      child: Text(
        emailSelected.getReceivedAt(
          Localizations.localeOf(context).toLanguageTag(),
          pattern: emailSelected.receivedAt?.value.toLocal().toPatternForEmailView()
        ).toLowerCase() + daysPast,
        maxLines: 1,
        overflow: CommonTextStyle.defaultTextOverFlow,
        softWrap: CommonTextStyle.defaultSoftWrap,
        style: ThemeUtils.textStyleInter400.copyWith(
          fontSize: 14,
          height: 1,
          letterSpacing: -0.14,
          color: AppColor.gray6D7885,
        ),
      ),
    );
  }

  String getDaysPast(UTCDate? utcDate, AppLocalizations appLocalizations) {
    if (!showDaysAgo || utcDate == null) return '';

    final from = utcDate.value;
    final to = DateTime.now();
    if (from.isAfter(to)) return '';

    final days = to.difference(from).inDays;
    if (days >=7) return '';
    
    return appLocalizations.daysAgo(days);
  }
}