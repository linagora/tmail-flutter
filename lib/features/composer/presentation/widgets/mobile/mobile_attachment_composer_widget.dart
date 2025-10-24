import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/list/sliver_grid_delegate_fixed_height.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_item_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/mobile_attachment_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_item_composer_widget.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MobileAttachmentComposerWidget extends StatefulWidget {

  final List<UploadFileState> listFileUploaded;
  final OnDeleteAttachmentAction onDeleteAttachmentAction;

  const MobileAttachmentComposerWidget({
    super.key,
    required this.listFileUploaded,
    required this.onDeleteAttachmentAction,
  });

  @override
  State<MobileAttachmentComposerWidget> createState() => _MobileAttachmentComposerWidgetState();
}

class _MobileAttachmentComposerWidgetState extends State<MobileAttachmentComposerWidget> {
  static const int _maxCountDisplayedAttachments = 2;

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  List<UploadFileState> _listFileDisplayed = [];
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _updateListFileDisplayed();
  }

  @override
  void didUpdateWidget(covariant MobileAttachmentComposerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listFileUploaded != widget.listFileUploaded) {
      _updateListFileDisplayed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _responsiveUtils.isPortraitMobile(context)
        ? MobileAttachmentComposerWidgetStyle.padding
        : MobileAttachmentComposerWidgetStyle.tabletPadding,
      width: double.infinity,
      child: _responsiveUtils.isPortraitMobile(context)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(child: SizedBox(
                    width: AttachmentItemComposerWidgetStyle.width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _listFileDisplayed.length,
                      itemBuilder: (context, index) {
                        final file =  _listFileDisplayed[index];
                        return AttachmentItemComposerWidget(
                          imagePaths: _imagePaths,
                          fileIcon: file.getIcon(_imagePaths),
                          fileName: file.fileName,
                          fileSize: filesize(file.fileSize),
                          uploadStatus: file.uploadStatus,
                          percentUploading: file.percentUploading,
                          uploadTaskId: file.uploadTaskId,
                          itemMargin: MobileAttachmentComposerWidgetStyle.itemMargin,
                          onDeleteAttachmentAction: widget.onDeleteAttachmentAction
                        );
                      }
                    ),
                  )),
                  if (!_isCollapsed && _isExceededDisplayedAttachments)
                    TMailButtonWidget(
                      text: AppLocalizations.of(context).showLess,
                      icon: _imagePaths.icChevronUp,
                      iconAlignment: TextDirection.rtl,
                      iconSpace: 2,
                      iconSize: 24,
                      iconColor: AppColor.primaryColor,
                      backgroundColor: Colors.transparent,
                      textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 15,
                        color: AppColor.primaryColor
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      margin: const EdgeInsetsDirectional.only(start: 8),
                      onTapActionCallback: _toggleListAttachments
                    )
                ],
              ),
              if (_isCollapsed && _isExceededDisplayedAttachments)
                TMailButtonWidget.fromText(
                  text: AppLocalizations.of(context).showMoreAttachment(_countRemainingAttachments),
                  backgroundColor: Colors.transparent,
                  textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 15,
                    color: AppColor.primaryColor
                  ),
                  margin: const EdgeInsetsDirectional.only(top: 5),
                  onTapActionCallback: _toggleListAttachments
                )
            ]
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 7,
                child: GridView.builder(
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _listFileDisplayed.length,
                  gridDelegate: const SliverGridDelegateFixedHeight(
                    height: MobileAttachmentComposerWidgetStyle.listItemHeight,
                    crossAxisCount: MobileAttachmentComposerWidgetStyle.maxItemRow,
                    crossAxisSpacing: MobileAttachmentComposerWidgetStyle.listItemSpace,
                  ),
                  itemBuilder: (context, index) {
                    final file = _listFileDisplayed[index];
                    return AttachmentItemComposerWidget(
                      imagePaths: _imagePaths,
                      fileIcon: file.getIcon(_imagePaths),
                      fileName: file.fileName,
                      fileSize: filesize(file.fileSize),
                      uploadStatus: file.uploadStatus,
                      percentUploading: file.percentUploading,
                      uploadTaskId: file.uploadTaskId,
                      itemMargin: MobileAttachmentComposerWidgetStyle.itemMargin,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 8),
                      onDeleteAttachmentAction: widget.onDeleteAttachmentAction
                    );
                  }
                )
              ),
              Flexible(
                flex: 3,
                child: _isExceededDisplayedAttachments
                  ? Row(
                      children: [
                        if (!_isCollapsed)
                          TMailButtonWidget(
                            text: AppLocalizations.of(context).showLess,
                            icon: _imagePaths.icChevronUp,
                            iconAlignment: TextDirection.rtl,
                            iconSpace: 2,
                            iconSize: 24,
                            iconColor: AppColor.primaryColor,
                            backgroundColor: Colors.transparent,
                            textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 15,
                              color: AppColor.primaryColor
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            margin: const EdgeInsetsDirectional.only(start: 8, top: 10),
                            onTapActionCallback: _toggleListAttachments
                          )
                        else
                          TMailButtonWidget.fromText(
                            text: AppLocalizations.of(context).showMoreAttachment(_countRemainingAttachments),
                            backgroundColor: Colors.transparent,
                            textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 15,
                              color: AppColor.primaryColor
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            margin: const EdgeInsetsDirectional.only(start: 8, top: 10),
                            onTapActionCallback: _toggleListAttachments
                          ),
                        const Spacer(),
                      ],
                    )
                    : const SizedBox.shrink()
              )
            ],
      )
    );
  }

  bool get _listFileUploadedSuccess =>
    widget.listFileUploaded.every((uploadFile) => uploadFile.uploadStatus.completed);

  bool get _isExceededDisplayedAttachments =>
    _listFileUploadedSuccess &&
    widget.listFileUploaded.length > _maxCountDisplayedAttachments;

  int get _countRemainingAttachments =>
    widget.listFileUploaded.length - _maxCountDisplayedAttachments;

  void _updateListFileDisplayed() {
    final reversedList = widget.listFileUploaded.reversed.toList();
    if (_isCollapsed && reversedList.length > _maxCountDisplayedAttachments) {
      _listFileDisplayed = reversedList.sublist(0, _maxCountDisplayedAttachments);
    } else {
      _listFileDisplayed = reversedList;
    }
  }

  void _toggleListAttachments() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      _updateListFileDisplayed();
    });
  }
}
