
import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ContactListActionWidget extends StatelessWidget {

  final VoidCallback onClearFilterAction;
  final VoidCallback onDoneAction;

  const ContactListActionWidget({
    super.key,
    required this.onClearFilterAction,
    required this.onDoneAction
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: TMailButtonWidget.fromText(
              text: AppLocalizations.of(context).clearFilter.capitalizeFirstEach,
              backgroundColor: AppColor.colorContactViewClearFilterButton.withOpacity(0.05),
              borderRadius: 10,
              maxHeight: 44,
              minWidth: 156,
              maxLines: 1,
              textAlign: TextAlign.center,
              textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: AppColor.primaryColor
              ),
              onTapActionCallback: onClearFilterAction,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: TMailButtonWidget.fromText(
              text: AppLocalizations.of(context).done,
              backgroundColor: AppColor.primaryColor,
              borderRadius: 10,
              maxHeight: 44,
              minWidth: 156,
              maxLines: 1,
              textAlign: TextAlign.center,
              textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.white
              ),
              onTapActionCallback: onDoneAction,
            ),
          ),
        ],
      ),
    );
  }
}
