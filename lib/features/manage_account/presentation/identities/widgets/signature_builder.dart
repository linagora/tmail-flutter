import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/tooltip/iframe_tooltip_overlay.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class SignatureBuilder extends StatelessWidget {

  const SignatureBuilder({
    Key? key,
    required this.value,
    this.height = 150,
    this.width = 280,
    this.scrollController,
  }) : super(key: key);

  final String value;
  final double width;
  final double height;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      final iframeOverlay = Obx(() {
        if (MessageDialogActionManager().isDialogOpened ||
            DialogRouter.isDialogOpened ||
            DialogRouter.isRuleFilterDialogOpened.isTrue) {
          return Positioned.fill(
            child: PointerInterceptor(
              child: const SizedBox.expand(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      });

      final htmlView = HtmlContentViewerOnWeb(
        contentHtml: value,
        widthContent: width,
        heightContent: height,
        contentPadding: 0,
        viewMaxHeight: height,
        htmlContentMinWidth: width,
        htmlContentMinHeight: 0.0,
        offsetHtmlContentHeight: 0.0,
        allowResizeToDocumentSize: false,
        direction: AppUtils.getCurrentDirection(context),
        scrollController: scrollController,
        keepAlive: true,
        disableScrolling: true,
        autoAdjustHeight: true,
        iframeTooltipOptions: IframeTooltipOptions(
          tooltipTextStyle: ThemeUtils.textStyleInter400.copyWith(
            color: Colors.white,
          ),
        ),
      );

      return Stack(
        children: [
          htmlView,
          iframeOverlay,
        ],
      );
    } else {
      return HtmlContentViewer(
        contentHtml: value,
        initialWidth: width,
        maxViewHeight: height,
        contentPadding: 0,
        htmlContentMinHeight: 0.0,
        offsetHtmlContentHeight: 0.0,
        direction: AppUtils.getCurrentDirection(context),
        keepAlive: true,
        disableScrolling: true,
      );
    }
  }
}