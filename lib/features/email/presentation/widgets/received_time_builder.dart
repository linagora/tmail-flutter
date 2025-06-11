
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';

class ReceivedTimeBuilder extends StatelessWidget {

  final PresentationEmail emailSelected;
  final EdgeInsetsGeometry? padding;

  const ReceivedTimeBuilder({
    Key? key,
    required this.emailSelected,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsetsDirectional.only(start: 16),
      child: Text(
        emailSelected.getReceivedAt(
          Localizations.localeOf(context).toLanguageTag(),
          pattern: emailSelected.receivedAt?.value.toLocal().toPatternForEmailView()
        ),
        maxLines: 1,
        overflow: CommonTextStyle.defaultTextOverFlow,
        softWrap: CommonTextStyle.defaultSoftWrap,
        style: ThemeUtils.textStyleBodyBody3(color: AppColor.steelGray400).copyWith(
          height: 1,
          letterSpacing: -0.14
        ),
      ),
    );
  }
}