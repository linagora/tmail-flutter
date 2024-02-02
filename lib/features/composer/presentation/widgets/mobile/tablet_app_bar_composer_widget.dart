import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/app_bar_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/title_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TabletAppBarComposerWidget extends StatelessWidget {

  final String emailSubject;
  final VoidCallback onCloseViewAction;
  final ScreenDisplayMode? displayMode;
  final BoxConstraints? constraints;
  final VoidCallback attachFileAction;
  final VoidCallback insertImageAction;
  final bool isNetworkConnectionAvailable;

  final _imagePaths = Get.find<ImagePaths>();

  TabletAppBarComposerWidget({
    super.key,
    required this.emailSubject,
    required this.onCloseViewAction,
    required this.attachFileAction,
    required this.insertImageAction,
    this.displayMode,
    this.constraints,
    this.isNetworkConnectionAvailable = false,
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
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNetworkConnectionAvailable)
                  ...[
                    TMailButtonWidget.fromIcon(
                      icon: _imagePaths.icAttachFile,
                      iconColor: AppBarComposerWidgetStyle.iconColor,
                      backgroundColor: Colors.transparent,
                      iconSize: AppBarComposerWidgetStyle.iconSize,
                      tooltipMessage: AppLocalizations.of(context).attach_file,
                      onTapActionCallback: attachFileAction,
                    ),
                    const SizedBox(width: AppBarComposerWidgetStyle.space),
                    TMailButtonWidget.fromIcon(
                      icon: _imagePaths.icInsertImage,
                      iconColor: AppBarComposerWidgetStyle.iconColor,
                      backgroundColor: Colors.transparent,
                      iconSize: AppBarComposerWidgetStyle.iconSize,
                      tooltipMessage: AppLocalizations.of(context).insertImage,
                      onTapActionCallback: insertImageAction,
                    ),
                    const SizedBox(width: AppBarComposerWidgetStyle.space),
                  ],
                TMailButtonWidget.fromIcon(
                  icon: _imagePaths.icCancel,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).saveAndClose,
                  iconSize: AppBarComposerWidgetStyle.iconSize,
                  iconColor: AppBarComposerWidgetStyle.iconColor,
                  onTapActionCallback: onCloseViewAction
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}