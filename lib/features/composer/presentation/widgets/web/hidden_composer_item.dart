import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/hidden_composer_item_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/title_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class HiddenComposerItem extends StatelessWidget {

  final ImagePaths imagePaths;
  final String composerSubject;
  final VoidCallback onCloseViewAction;
  final VoidCallback onShowComposer;

  const HiddenComposerItem({
    super.key,
    required this.imagePaths,
    required this.composerSubject,
    required this.onCloseViewAction,
    required this.onShowComposer,
  });

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Card(
        elevation: HiddenComposerItemStyle.elevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(HiddenComposerItemStyle.radius))
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: HiddenComposerItemStyle.backgroundColor,
          width: HiddenComposerItemStyle.width,
          height: HiddenComposerItemStyle.height,
          padding: HiddenComposerItemStyle.padding,
          child: InkWell(
            onTap: onShowComposer,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TMailButtonWidget.fromIcon(
                  icon: imagePaths.icCancel,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).saveAndClose,
                  iconSize: HiddenComposerItemStyle.iconSize,
                  iconColor: HiddenComposerItemStyle.iconColor,
                  onTapActionCallback: onCloseViewAction
                ),
                const SizedBox(width: HiddenComposerItemStyle.space),
                Expanded(child: TitleComposerWidget(emailSubject: composerSubject)),
              ]
            ),
          )
        ),
      ),
    );
  }
}