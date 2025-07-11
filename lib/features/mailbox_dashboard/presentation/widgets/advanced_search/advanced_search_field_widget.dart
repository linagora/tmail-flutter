import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/label_advanced_search_field_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AdvancedSearchFieldWidget extends StatelessWidget {
  final FilterField filterField;
  final Widget child;
  final bool useHeight;

  const AdvancedSearchFieldWidget({
    super.key,
    required this.filterField,
    required this.child,
    this.useHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Row(
      children: [
        SizedBox(
          width: AdvancedSearchInputFormStyle.labelMaxWidth,
          child: LabelAdvancedSearchFieldWidget(
            name: filterField.getTitle(AppLocalizations.of(context)),
          ),
        ),
        const SizedBox(width: AdvancedSearchInputFormStyle.labelSpace),
        Expanded(child: child),
      ],
    );

    if (useHeight) {
      return SizedBox(
        height: AdvancedSearchInputFormStyle.inputFieldHeight,
        child: bodyWidget,
      );
    } else {
      return bodyWidget;
    }
  }
}
