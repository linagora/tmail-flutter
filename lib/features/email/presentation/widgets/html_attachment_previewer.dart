import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/top_bar_attachment_viewer.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class HtmlAttachmentPreviewer extends StatelessWidget {
  const HtmlAttachmentPreviewer({
    super.key,
    required this.htmlContent,
    required this.title,
    required this.mailToClicked,
    required this.downloadAttachmentClicked,
    required this.responsiveUtils,
  });

  final String title;
  final String htmlContent;
  final OnMailtoClicked mailToClicked;
  final VoidCallback downloadAttachmentClicked;
  final ResponsiveUtils responsiveUtils;

  static const double _verticalMargin = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBarAttachmentViewer(
          title: title,
          closeAction: popBack,
          downloadAction: downloadAttachmentClicked,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: GestureDetector(
                  onTap: popBack,
                  child: PointerInterceptor(
                    child: ColoredBox(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: _verticalMargin),
                          color: Colors.white,
                          child: ResponsiveWidget(
                            responsiveUtils: responsiveUtils,
                            desktop: _buildHtmlViewerWith(
                              context,
                              width: constraints.maxWidth * 0.8,
                              height: constraints.maxHeight - _verticalMargin * 2
                            ),
                            tablet: _buildHtmlViewerWith(
                              context,
                              width: constraints.maxWidth * 0.8,
                              height: constraints.maxHeight - _verticalMargin * 2
                            ),
                            mobile: _buildHtmlViewerWith(
                              context,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight - _verticalMargin * 2
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildHtmlViewerWith(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return PlatformInfo.isWeb
      ? HtmlContentViewerOnWeb(
          contentHtml: htmlContent,
          widthContent: width,
          heightContent: height,
          direction: AppUtils.getCurrentDirection(context),
          mailtoDelegate: (uri) {
            popBack();
            mailToClicked(uri);
          },
          keepWidthWhileLoading: true,
      )
      : HtmlContentViewer(
          contentHtml: htmlContent,
          initialWidth: width,
          direction: AppUtils.getCurrentDirection(context),
          onMailtoDelegateAction: (uri) async {
            mailToClicked(uri);
          },
      );
  }
}