
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/presentation/model/attachment_file.dart';
import 'package:tmail_ui_user/features/email/presentation/model/message_content.dart';
import 'package:tmail_ui_user/features/email/presentation/model/text_format.dart';

class MessageContentTileBuilder {

  final MessageContent _messageContent;
  final List<AttachmentFile> _attachmentInlines;
  final Session? _session;
  final AccountId? _accountId;
  final HtmlMessagePurifier _htmlMessagePurifier;

  MessageContentTileBuilder(
    this._htmlMessagePurifier,
    this._messageContent,
    this._attachmentInlines,
    this._session,
    this._accountId,
  );

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Center(
          child: _messageContent.textFormat == TextFormat.PLAIN
            ? Text('${_messageContent.content}', style: TextStyle(fontSize: 12, color: AppColor.mailboxTextColor))
            : HtmlWidget(
                getHtmlMessageText(),
                textStyle: TextStyle(fontSize: 12, color: AppColor.mailboxTextColor),
                buildAsync: true,
                buildAsyncBuilder: (_, snapshot) => snapshot.data ?? SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(color: AppColor.primaryColor)),
                webViewJs: false),
        )
      )
    );
  }

  String getHtmlMessageText() {
    final message = (_attachmentInlines.isNotEmpty && _session != null && _accountId != null && _messageContent.hasImageInlineWithCid())
      ? '${_messageContent.getContentHasInlineAttachment(_session!, _accountId!, _attachmentInlines)}'
      : '${_messageContent.content}';

    final trustAsHtml = _htmlMessagePurifier.purifyHtmlMessage(
        message,
        allowAttributes: {'style', 'input', 'form'});

    return trustAsHtml;
  }
}