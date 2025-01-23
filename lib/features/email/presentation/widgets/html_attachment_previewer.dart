import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger_mobile.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/top_bar_attachment_viewer.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class HtmlAttachmentPreviewer extends StatefulWidget {
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

  @override
  State<HtmlAttachmentPreviewer> createState() => _HtmlAttachmentPreviewerState();
}

class _HtmlAttachmentPreviewerState extends State<HtmlAttachmentPreviewer> {
  final focusNode = FocusNode();

  static const double _verticalMargin = 16;

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        TopBarAttachmentViewer(
          title: widget.title,
          closeAction: popBack,
          downloadAction: widget.downloadAttachmentClicked,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
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
                              responsiveUtils: widget.responsiveUtils,
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
                ),
              );
            }
          ),
        ),
      ],
    );

    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (event) {
        if (!mounted) return;
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          popBack();
        }
      },
      child: child,
    );
  }

  Widget _buildHtmlViewerWith(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return PlatformInfo.isWeb
      ? HtmlContentViewerOnWeb(
          contentHtml: widget.htmlContent,
          widthContent: width,
          heightContent: height,
          direction: AppUtils.getCurrentDirection(context),
          mailtoDelegate: (uri) {
            popBack();
            widget.mailToClicked(uri);
          },
          keepWidthWhileLoading: true,
      )
      : HtmlContentViewer(
          contentHtml: widget.htmlContent,
          initialWidth: width,
          direction: AppUtils.getCurrentDirection(context),
          onMailtoDelegateAction: (uri) async {
            widget.mailToClicked(uri);
          },
          keepWidthWhileLoading: true,
      );
  }
}