import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/app_bar/mobile_app_bar_thread_widget_style.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar/mobile_app_bar_thread_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SelectionMobileAppBarThreadWidget extends StatelessWidget {
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final List<PresentationEmail> selectedEmails;
  final List<EmailSelectionActionType> emailSelectionActionTypes;
  final OnPressEmailSelectionActionClick onPressEmailSelectionActionClick;
  final OnCancelSelectionAction onCancelSelectionAction;
  final EdgeInsetsGeometry? padding;

  const SelectionMobileAppBarThreadWidget({
    super.key,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.selectedEmails,
    required this.emailSelectionActionTypes,
    required this.onPressEmailSelectionActionClick,
    required this.onCancelSelectionAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MobileAppBarThreadWidgetStyle.backgroundColor,
      padding: padding ?? MobileAppBarThreadWidgetStyle.getPadding(
        context,
        responsiveUtils,
      ),
      height: MobileAppBarThreadWidgetStyle.height,
      child: Row(children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TMailButtonWidget(
                  text: AppLocalizations.of(context).count_email_selected(
                    selectedEmails.length,
                  ),
                  icon: imagePaths.icCancel,
                  iconColor: MobileAppBarThreadWidgetStyle.actionIconColor,
                  iconSize: MobileAppBarThreadWidgetStyle.actionIconSize,
                  textStyle:
                      MobileAppBarThreadWidgetStyle.emailCounterTitleStyle,
                  backgroundColor: Colors.transparent,
                  flexibleText: true,
                  mainAxisSize: MainAxisSize.min,
                  maxLines: 1,
                  onTapActionCallback: onCancelSelectionAction,
                ),
              )
            ],
          ),
        ),
        ...emailSelectionActionTypes.map(
          (type) => TMailButtonWidget.fromIcon(
            key: Key('${type.name}_selected_email_button'),
            icon: type.getIcon(imagePaths),
            iconColor: type.getIconColor(),
            iconSize: type.getIconSize(),
            tooltipMessage: type.getTitle(AppLocalizations.of(context)),
            backgroundColor: Colors.transparent,
            onTapActionCallback: () => onPressEmailSelectionActionClick(
              type,
              selectedEmails,
            ),
          ),
        ),
      ]),
    );
  }
}
