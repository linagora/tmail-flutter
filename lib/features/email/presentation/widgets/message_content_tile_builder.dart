
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/model/message_content.dart';
import 'package:tmail_ui_user/features/email/presentation/model/text_format.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MessageContentTileBuilder {

  final MessageContent messageContent;
  final List<Attachment> attachmentInlines;
  final Session? session;
  final AccountId? accountId;
  final HtmlMessagePurifier htmlMessagePurifier;

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
        child: Center(
           
          child: messageContent.textFormat == TextFormat.PLAIN
            ? Text('${messageContent.content}', style: TextStyle(fontSize: 12, color: AppColor.mailboxTextColor))
            // : HtmlWidget(
            //     getHtmlMessageText(),
            //     textStyle: TextStyle(fontSize: 12, color: AppColor.mailboxTextColor),
            //     buildAsync: true,
            //     buildAsyncBuilder: (_, snapshot) => snapshot.data ?? SizedBox(
            //       height: 30,
            //       width: 30,
            //       child: CircularProgressIndicator(color: AppColor.primaryColor)),
            //     webViewJs: false),
            : SizedBox(
              child:InAppWebView(
                    initialData: InAppWebViewInitialData(data: getHtmlMessageText()),
                    
                ),
            width: double.infinity,
            height: 500,
            )
        )
      )
    );
  }

  String getHtmlMessageText() {
    final message = (attachmentInlines.isNotEmpty && session != null && accountId != null && messageContent.hasImageInlineWithCid())
      ? '${messageContent.getContentHasInlineAttachment(session!.getDownloadUrl(), accountId!, attachmentInlines)}'
      : '${messageContent.content}';

    final trustAsHtml = htmlMessagePurifier.purifyHtmlMessage(
        message,
        allowAttributes: {'style', 'input', 'form'});

    return trustAsHtml;
  }
}