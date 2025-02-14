import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/minimize_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/title_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DesktopAppBarComposerWidget extends StatelessWidget {

  final String emailSubject;
  final VoidCallback onCloseViewAction;
  final ScreenDisplayMode? displayMode;
  final OnChangeDisplayModeAction? onChangeDisplayModeAction;
  final BoxConstraints? constraints;

  final _imagePaths = Get.find<ImagePaths>();

  DesktopAppBarComposerWidget({
    super.key,
    required this.emailSubject,
    required this.onCloseViewAction,
    this.displayMode,
    this.onChangeDisplayModeAction,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppBarComposerWidgetStyle.height,
      padding: AppBarComposerWidgetStyle.padding,
      color: AppBarComposerWidgetStyle.backgroundColor,
      child: Stack(
        children: [
          Center(
            child: Container(
              constraints: constraints != null
                ? BoxConstraints(maxWidth: constraints!.maxWidth / 2)
                : null,
              child: TitleComposerWidget(emailSubject: emailSubject),
            ),
          ),
          if (onChangeDisplayModeAction != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icMinimize,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).minimize,
                    iconSize: AppBarComposerWidgetStyle.iconSize,
                    iconColor: AppBarComposerWidgetStyle.iconColor,
                    padding: AppBarComposerWidgetStyle.iconPadding,
                    onTapActionCallback: () => onChangeDisplayModeAction!(ScreenDisplayMode.minimize)
                  ),
                  const SizedBox(width: AppBarComposerWidgetStyle.space),
                  TMailButtonWidget.fromIcon(
                    icon: displayMode == ScreenDisplayMode.fullScreen
                      ? _imagePaths.icFullScreenExit
                      : _imagePaths.icFullScreen,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: displayMode == ScreenDisplayMode.fullScreen
                      ? AppLocalizations.of(context).exitFullscreen
                      : AppLocalizations.of(context).fullscreen,
                    iconSize: AppBarComposerWidgetStyle.iconSize,
                    iconColor: AppBarComposerWidgetStyle.iconColor,
                    padding: AppBarComposerWidgetStyle.iconPadding,
                    onTapActionCallback: () => onChangeDisplayModeAction!(
                      displayMode == ScreenDisplayMode.fullScreen
                        ? ScreenDisplayMode.normal
                        : ScreenDisplayMode.fullScreen
                    )
                  ),
                  const SizedBox(width: AppBarComposerWidgetStyle.space),
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icCancel,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).saveAndClose,
                    iconSize: AppBarComposerWidgetStyle.iconSize,
                    iconColor: AppBarComposerWidgetStyle.iconColor,
                    padding: AppBarComposerWidgetStyle.iconPadding,
                    onTapActionCallback: onCloseViewAction
                  ),
                ]
              ),
            )
          else
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TMailButtonWidget.fromIcon(
                icon: _imagePaths.icCancel,
                backgroundColor: Colors.transparent,
                tooltipMessage: AppLocalizations.of(context).saveAndClose,
                iconSize: AppBarComposerWidgetStyle.iconSize,
                iconColor: AppBarComposerWidgetStyle.iconColor,
                padding: AppBarComposerWidgetStyle.iconPadding,
                onTapActionCallback: onCloseViewAction
              ),
            )
        ],
      ),
    );
  }
}