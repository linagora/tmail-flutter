
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class EmailQuickSearchItemTileWidget extends StatelessWidget {

  final imagePath = Get.find<ImagePaths>();

  final PresentationEmail _presentationEmail;
  final PresentationMailbox? _presentationMailbox;
  final EdgeInsetsGeometry? contentPadding;
  final SearchQuery? searchQuery;

  EmailQuickSearchItemTileWidget(
      this._presentationEmail,
      this._presentationMailbox, {
      Key? key,
      this.contentPadding,
      this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidthItem = constraints.maxWidth;
        log('EmailQuickSearchItemTileWidget::build(): maxWidthItem: $maxWidthItem');
        return Padding(
          padding: contentPadding ?? const EdgeInsetsDirectional.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SvgPicture.asset(
                    _presentationEmail.hasStarred ? imagePath.icStar : imagePath.icUnStar,
                    width: 18, height: 18, fit: BoxFit.fill),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: maxWidthItem / 3),
                        child: RichTextBuilder(
                          textOrigin: _getInformationSender(),
                          wordToStyle: searchQuery?.value ?? '',
                          styleOrigin: ThemeUtils.defaultTextStyleInterFont.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          styleWord: ThemeUtils.defaultTextStyleInterFont.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            backgroundColor: Colors.amberAccent[200],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RichTextBuilder(
                          textOrigin: _presentationEmail.getEmailTitle(),
                          wordToStyle: searchQuery?.value ?? '',
                          preMarkedText: _presentationEmail.sanitizedSearchSnippetSubject,
                          ensureHighlightVisible: true,
                          styleOrigin: ThemeUtils.defaultTextStyleInterFont.copyWith(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.normal
                          ),
                          styleWord: ThemeUtils.defaultTextStyleInterFont.copyWith(
                            fontSize: 13,
                            backgroundColor: Colors.amberAccent[200],
                            color: Colors.black,
                            fontWeight: FontWeight.normal
                          )
                        ),
                      ),
                      if (_presentationEmail.hasAttachment == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SvgPicture.asset(imagePath.icAttachment, width: 14, height: 14, fit: BoxFit.fill),
                      ),
                      Text(_presentationEmail.getReceivedAt(Localizations.localeOf(context).toLanguageTag()),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: CommonTextStyle.defaultTextOverFlow,
                        softWrap: CommonTextStyle.defaultSoftWrap,
                        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.black))
                    ]),
                    const SizedBox(height: 3),
                    RichTextBuilder(
                      textOrigin: _presentationEmail.getPartialContent(),
                      wordToStyle: searchQuery?.value ?? '',
                      preMarkedText: _presentationEmail.sanitizedSearchSnippetPreview,
                      ensureHighlightVisible: true,
                      styleOrigin: ThemeUtils.defaultTextStyleInterFont.copyWith(
                        fontSize: 13,
                        color: AppColor.colorContentEmail,
                        fontWeight: FontWeight.normal
                      ),
                      styleWord: ThemeUtils.defaultTextStyleInterFont.copyWith(
                        fontSize: 13,
                        color: AppColor.colorContentEmail,
                        backgroundColor: Colors.amberAccent[200],
                      )
                    ),
                  ]
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  String _getInformationSender() {
    if (_presentationMailbox?.isSent == true
        || _presentationMailbox?.isDrafts == true
        || _presentationMailbox?.isOutbox == true) {
      return _presentationEmail.recipientsName();
    }
    return _presentationEmail.getSenderName();
  }
}