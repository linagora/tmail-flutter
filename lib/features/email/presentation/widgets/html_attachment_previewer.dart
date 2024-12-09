import 'dart:convert';
import 'dart:math';

import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/shims/dart_ui.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/top_bar_attachment_viewer.dart';
import 'package:universal_html/html.dart';

class HtmlAttachmentPreviewer extends StatefulWidget {
  const HtmlAttachmentPreviewer({
    super.key,
    required this.htmlContent,
    required this.title,
  });

  final String title;
  final String htmlContent;

  @override
  State<HtmlAttachmentPreviewer> createState() => _HtmlAttachmentPreviewerState();
}

class _HtmlAttachmentPreviewerState extends State<HtmlAttachmentPreviewer> {
  late final IFrameElement _iframeElement;
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _iframeElement = IFrameElement()
      ..srcdoc = widget.htmlContent
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..style.width = '100%'
      ..style.height = '100%';
    _viewId = _getRandString(10);

    platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _iframeElement);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBarAttachmentViewer(
          title: widget.title,
          closeAction: () {
            if (!mounted) return;
            Get.back();
          },
        ),
        Expanded(
          child: Center(
            child: ResponsiveWidget(
              responsiveUtils: ResponsiveUtils(),
              desktop: Container(
                width: MediaQuery.sizeOf(context).width * 0.4,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: HtmlElementView(viewType: _viewId),
              ),
              tablet: Container(
                width: MediaQuery.sizeOf(context).width * 0.8,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: HtmlElementView(viewType: _viewId),
              ),
              mobile: Container(
                width: MediaQuery.sizeOf(context).width,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: HtmlElementView(viewType: _viewId),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}