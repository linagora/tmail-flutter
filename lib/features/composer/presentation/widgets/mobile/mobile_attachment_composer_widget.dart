import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/mobile_attachment_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_item_composer_widget.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnShowMoreAttachmentAction = void Function(bool isShowMore);

class MobileAttachmentComposerWidget extends StatefulWidget {

  final List<UploadFileState> listFileUploaded;
  final bool isShowMore;
  final OnDeleteAttachmentAction onDeleteAttachmentAction;
  final OnShowMoreAttachmentAction onShowMoreAttachmentAction;

  const MobileAttachmentComposerWidget({
    super.key,
    required this.listFileUploaded,
    required this.isShowMore,
    required this.onDeleteAttachmentAction,
    required this.onShowMoreAttachmentAction,
  });

  @override
  State<MobileAttachmentComposerWidget> createState() => _MobileAttachmentComposerWidgetState();
}

class _MobileAttachmentComposerWidgetState extends State<MobileAttachmentComposerWidget> {

  static const int _maxDisplayedItem = 6;

  bool _isShowMore = false;
  int _currentCountDisplayed = _maxDisplayedItem;

  @override
  void initState() {
    super.initState();
    _isShowMore = widget.isShowMore;
    if (_isShowMore) {
      _currentCountDisplayed = widget.listFileUploaded.length;
    } else {
      _currentCountDisplayed = widget.listFileUploaded.length > 6
        ? 6
        : widget.listFileUploaded.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedFiles = widget.listFileUploaded.sublist(0, _currentCountDisplayed);

    return Container(
      color: MobileAttachmentComposerWidgetStyle.backgroundColor,
      width: double.infinity,
      padding: MobileAttachmentComposerWidgetStyle.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MobileAttachmentComposerWidgetStyle.listItemSpace,
            runSpacing: MobileAttachmentComposerWidgetStyle.listItemSpace,
            children: displayedFiles
              .map((file) => AttachmentItemComposerWidget(
                fileState: file,
                onDeleteAttachmentAction: widget.onDeleteAttachmentAction
              ))
              .toList(),
          ),
          if (!_isShowMore)
            TMailButtonWidget.fromText(
              text: AppLocalizations.of(context).showMoreAttachment(widget.listFileUploaded.length),
              textStyle: MobileAttachmentComposerWidgetStyle.showMoreButtonTextStyle,
              margin: MobileAttachmentComposerWidgetStyle.showMoreMargin,
              backgroundColor: Colors.transparent,
              onTapActionCallback: () {
                setState(() => _isShowMore = true);
                widget.onShowMoreAttachmentAction(_isShowMore);
              },
            )
        ]
      ),
    );
  }
}
