import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/minimize_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/title_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnChangeDisplayModeAction = Function(ScreenDisplayMode mode);

class MinimizeComposerWidget extends StatelessWidget {

  final OnChangeDisplayModeAction onChangeDisplayModeAction;
  final VoidCallback onCloseViewAction;
  final String emailSubject;

  final _imagePaths = Get.find<ImagePaths>();

  MinimizeComposerWidget({
    super.key,
    required this.emailSubject,
    required this.onChangeDisplayModeAction,
    required this.onCloseViewAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: MinimizeComposerWidgetStyle.elevation,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(MinimizeComposerWidgetStyle.radius))
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: MinimizeComposerWidgetStyle.backgroundColor,
        width: MinimizeComposerWidgetStyle.width,
        height: MinimizeComposerWidgetStyle.height,
        padding: MinimizeComposerWidgetStyle.padding,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: MinimizeComposerWidgetStyle.width / 2),
                child: TitleComposerWidget(emailSubject: emailSubject),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icCancel,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).saveAndClose,
                    iconSize: MinimizeComposerWidgetStyle.iconSize,
                    iconColor: MinimizeComposerWidgetStyle.iconColor,
                    padding: MinimizeComposerWidgetStyle.iconPadding,
                    onTapActionCallback: onCloseViewAction
                  ),
                  const SizedBox(width: MinimizeComposerWidgetStyle.space),
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icFullScreen,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).fullscreen,
                    iconSize: MinimizeComposerWidgetStyle.iconSize,
                    iconColor: MinimizeComposerWidgetStyle.iconColor,
                    padding: MinimizeComposerWidgetStyle.iconPadding,
                    onTapActionCallback: () => onChangeDisplayModeAction(ScreenDisplayMode.fullScreen)
                  ),
                  const SizedBox(width: MinimizeComposerWidgetStyle.space),
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icChevronUp,
                    backgroundColor: Colors.transparent,
                    tooltipMessage: AppLocalizations.of(context).show,
                    iconSize: MinimizeComposerWidgetStyle.iconSize,
                    iconColor: MinimizeComposerWidgetStyle.iconColor,
                    padding: MinimizeComposerWidgetStyle.iconPadding,
                    onTapActionCallback: () => onChangeDisplayModeAction(ScreenDisplayMode.normal)
                  ),
                ]
              ),
            )
          ],
        )
      ),
    );
  }
}