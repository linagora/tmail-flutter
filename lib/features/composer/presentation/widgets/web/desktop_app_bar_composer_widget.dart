import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/minimize_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/title_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DesktopAppBarComposerWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final String emailSubject;
  final VoidCallback onCloseViewAction;
  final ScreenDisplayMode? displayMode;
  final OnChangeDisplayModeAction? onChangeDisplayModeAction;

  const DesktopAppBarComposerWidget({
    super.key,
    required this.imagePaths,
    required this.emailSubject,
    required this.onCloseViewAction,
    this.displayMode,
    this.onChangeDisplayModeAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppBarComposerWidgetStyle.height,
      padding: AppBarComposerWidgetStyle.padding,
      color: AppBarComposerWidgetStyle.backgroundColor,
      child: Row(
        children: [
          Expanded(child: TitleComposerWidget(emailSubject: emailSubject)),
          if (onChangeDisplayModeAction != null)
            ... [
                  TMailButtonWidget.fromIcon(
                    icon: imagePaths.icMinimize,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).minimize,
                    iconSize: AppBarComposerWidgetStyle.iconSize,
                    iconColor: AppBarComposerWidgetStyle.iconColor,
                    padding: AppBarComposerWidgetStyle.iconPadding,
                    onTapActionCallback: () => onChangeDisplayModeAction!(ScreenDisplayMode.minimize),
                  ),
                  const SizedBox(width: AppBarComposerWidgetStyle.space),
                  TMailButtonWidget.fromIcon(
                    icon: displayMode == ScreenDisplayMode.fullScreen
                      ? imagePaths.icFullScreenExit
                      : imagePaths.icFullScreen,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).fullscreen,
                    iconSize: AppBarComposerWidgetStyle.iconSize,
                    iconColor: AppBarComposerWidgetStyle.iconColor,
                    padding: AppBarComposerWidgetStyle.iconPadding,
                    onTapActionCallback: () => onChangeDisplayModeAction!(
                      displayMode == ScreenDisplayMode.fullScreen
                        ? ScreenDisplayMode.normal
                        : ScreenDisplayMode.fullScreen
                    ),
                  ),
                  const SizedBox(width: AppBarComposerWidgetStyle.space),
                  TMailButtonWidget.fromIcon(
                    icon: imagePaths.icCancel,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).saveAndClose,
                    iconSize: AppBarComposerWidgetStyle.iconSize,
                    iconColor: AppBarComposerWidgetStyle.iconColor,
                    padding: AppBarComposerWidgetStyle.iconPadding,
                    onTapActionCallback: onCloseViewAction,
                  ),
                ]
          else
            TMailButtonWidget.fromIcon(
              icon: imagePaths.icCancel,
              backgroundColor: Colors.transparent,
              tooltipMessage: AppLocalizations.of(context).saveAndClose,
              iconSize: AppBarComposerWidgetStyle.iconSize,
              iconColor: AppBarComposerWidgetStyle.iconColor,
              padding: AppBarComposerWidgetStyle.iconPadding,
              onTapActionCallback: onCloseViewAction,
            )
        ],
      ),
    );
  }
}