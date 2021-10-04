
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/model/message_content.dart';
import 'package:tmail_ui_user/features/email/presentation/model/text_format.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/html_content_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sanitize_html/sanitize_html.dart' show sanitizeHtml; 

class MessageContentTileBuilder {

  final MessageContent messageContent;
  final List<Attachment> attachmentInlines;
  final Session? session;
  final AccountId? accountId;
  final HtmlMessagePurifier htmlMessagePurifier;
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        enableViewportScale: true,
      ));

  MessageContentTileBuilder({
    required this.htmlMessagePurifier,
    required this.messageContent,
    required this.attachmentInlines,
    required this.session,
    required this.accountId,
  });

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: messageContent.textFormat == TextFormat.PLAIN
            ? Text('${messageContent.content}', style: TextStyle(fontSize: 12, color: AppColor.mailboxTextColor))
            : HtmlContentView(getHtmlMessageText())
      )
    );
  }

  String getHtmlMessageText() {
    final htmlString = (attachmentInlines.isNotEmpty && session != null && accountId != null && messageContent.hasImageInlineWithCid())
      ? '${messageContent.getContentHasInlineAttachment(session!.getDownloadUrl(), accountId!, attachmentInlines)}'
      : '${messageContent.content}';
    
    return htmlString.changeStyleBackground()
      .removeFontSizeZeroPixel()
      .addBorderLefForBlockQuote();
  }
}