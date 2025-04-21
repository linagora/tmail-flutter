
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/html_viewer/ios_html_content_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EditorFullscreenDialogView extends StatelessWidget {
  final String content;
  final ImagePaths imagePaths;
  final String? subject;

  const EditorFullscreenDialogView({
    super.key,
    required this.imagePaths,
    required this.content,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      insetPadding: EdgeInsets.zero,
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(child: Text(
                    subject ?? AppLocalizations.of(context).compose_email,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                  TMailButtonWidget.fromIcon(
                    icon: imagePaths.icComposerClose,
                    backgroundColor: Colors.transparent,
                    margin: const EdgeInsetsDirectional.only(end: 12),
                    onTapActionCallback: popBack,
                  )
                ],
              ),
            ),
            const Divider(color: AppColor.colorDivider, height: 1),
            Expanded(
              child: IosHtmlContentViewerWidget(
                contentHtml: content,
                useDefaultFont: true,
                direction: AppUtils().getCurrentDirection(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
