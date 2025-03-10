import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/title_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TitleComposerWidget extends StatelessWidget {

  final String emailSubject;

  const TitleComposerWidget({
    super.key,
    required this.emailSubject,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      emailSubject.isNotEmpty == true
        ? emailSubject
        : AppLocalizations.of(context).new_message.capitalizeFirstEach,
      maxLines: 1,
      overflow: CommonTextStyle.defaultTextOverFlow,
      softWrap: CommonTextStyle.defaultSoftWrap,
      style: TitleComposerWidgetStyle.textStyle,
    );
  }
}