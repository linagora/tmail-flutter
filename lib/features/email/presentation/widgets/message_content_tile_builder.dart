
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tmail_ui_user/features/email/presentation/model/attachment_file.dart';
import 'package:tmail_ui_user/features/email/presentation/model/message_content.dart';
import 'package:tmail_ui_user/features/email/presentation/model/text_format.dart';
import 'package:sanitize_html/sanitize_html.dart' show sanitizeHtml;

class MessageContentTileBuilder {

  final MessageContent _messageContent;
  final ImagePaths _imagePaths;
  final List<AttachmentFile> _attachmentInlines;
  final Session? _session;
  final AccountId? _accountId;

  MessageContentTileBuilder(
    this._messageContent,
    this._imagePaths,
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
                cleanHtmlMessage(_messageContent.content),
                textStyle: TextStyle(fontSize: 12, color: AppColor.mailboxTextColor),
                buildAsync: true,
                factoryBuilder: () => _PopupPhotoViewWidgetFactory(_imagePaths),
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
    return message;
  }

  String cleanHtmlMessage(String message) => hasTagTable(getHtmlMessageText()) ? sanitizeHtml(getHtmlMessageText()) : message;

  bool hasTagTable(String html) => html.toLowerCase().contains('</table>');
}

class _PopupPhotoViewWidgetFactory extends WidgetFactory {

  final ImagePaths _imagePaths;

  _PopupPhotoViewWidgetFactory(this._imagePaths);

  @override
  Widget? buildImageWidget(BuildMetadata meta, {String? semanticLabel, required String url}) {
    final built = super.buildImageWidget(meta, semanticLabel: semanticLabel, url: url);

    if (built is Image) {
      return Builder(
        builder: (context) => GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Stack(
                  children: [
                    PhotoView(
                      heroAttributes: PhotoViewHeroAttributes(tag: url),
                      imageProvider: built.image),
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 35),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: SvgPicture.asset(_imagePaths.icCloseMailbox, width: 30, height: 30, fit: BoxFit.fill)))
                  ],
                ),
              ))),
          child: Hero(tag: url, child: built),
        ),
      );
    }

    return built;
  }
}