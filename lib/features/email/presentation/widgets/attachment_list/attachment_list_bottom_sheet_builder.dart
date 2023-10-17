import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnDownloadAttachmentFileAction = void Function(Attachment attachment);
typedef OnDownloadAllButtonAction = void Function();
typedef OnCancelButtonAction = void Function();
typedef OnCloseButtonAction = void Function();

class AttachmentListBottomSheetBuilder {
  final BuildContext _context;
  final List<Attachment> _attachments;
  final ImagePaths _imagePaths;

  late double _statusBarHeight;

  OnDownloadAllButtonAction? _onDownloadAllButtonAction;
  OnDownloadAttachmentFileAction? _onDownloadAttachmentFileAction;
  OnCancelButtonAction? _onCancelButtonAction;
  OnCloseButtonAction? _onCloseButtonAction;

  AttachmentListBottomSheetBuilder(
    this._context,
    this._attachments,
    this._imagePaths,
  ) {
    _statusBarHeight = Get.statusBarHeight / MediaQuery.of(_context).devicePixelRatio;
  }

  void onDownloadAllButtonAction(OnDownloadAllButtonAction onDownloadAllButtonAction) {
    _onDownloadAllButtonAction = onDownloadAllButtonAction;
  }

  void onDownloadAttachmentFileAction(OnDownloadAttachmentFileAction onDownloadAttachmentFileAction) {
    _onDownloadAttachmentFileAction = onDownloadAttachmentFileAction;
  }

  void onCancelButtonAction(OnCancelButtonAction onCancelButtonAction) {
    _onCancelButtonAction = onCancelButtonAction;
  }

  void onCloseButtonAction(OnCloseButtonAction onCloseButtonAction) {
    _onCloseButtonAction = onCloseButtonAction;
  }

  Future show() {
    return showModalBottomSheet(
      context: _context,
      isScrollControlled: true,
      barrierColor: AttachmentListStyles.barrierColor,
      backgroundColor: AttachmentListStyles.modalBackgroundColor,
      enableDrag: false,
      builder: (context) => PointerInterceptor(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: EdgeInsets.only(top: _statusBarHeight),
          child: ClipRRect(
            borderRadius: AttachmentListStyles.modalRadius,
            child: Scaffold(
              appBar: AppBar(
                leading: const SizedBox.shrink(),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(_context).attachmentList,
                      style: AttachmentListStyles.titleTextStyle
                    ),
                    const SizedBox(width: AttachmentListStyles.titleSpace),
                    Text(
                      '${_attachments.length} ${AppLocalizations.of(_context).files}',
                      style: AttachmentListStyles.subTitleTextStyle
                    ),
                  ],
                ),
                centerTitle: true,
                actions: [
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(_imagePaths.icCircleClose),
                    ),
                    onTapDown: (_) {
                      _onCloseButtonAction?.call();
                      Get.back();
                    },
                  )
                ],
              ),
              body: Container(
                decoration: AttachmentListStyles.dialogBodyDecorationMobile,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: AttachmentListStyles.listAreaPaddingMobile,
                        child: RawScrollbar(
                          trackColor: AttachmentListStyles.scrollbarTrackColor,
                          thumbColor: AttachmentListStyles.scrollbarThumbColor,
                          radius: AttachmentListStyles.scrollbarThumbRadius,
                          trackRadius: AttachmentListStyles.scrollbarTrackRadius,
                          thickness: AttachmentListStyles.scrollbarThickness,
                          thumbVisibility: true,
                          trackVisibility: true,
                          controller: scrollController,
                          trackBorderColor: AttachmentListStyles.scrollbarTrackBorderColor,
                          child: Padding(
                            padding: AttachmentListStyles.listItemPadding,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(_context).copyWith(scrollbars: false),
                              child: ListView.separated(
                                controller: scrollController,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: _attachments.length,
                                itemBuilder: (context, index) {
                                  return AttachmentListItemWidget(
                                    attachment: _attachments[index],
                                    downloadAttachmentAction: _onDownloadAttachmentFileAction,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const Padding(
                                    padding: AttachmentListStyles.separatorPadding,
                                    child: Divider(
                                      height: AttachmentListStyles.separatorHeight,
                                      color: AttachmentListStyles.separatorColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_onDownloadAllButtonAction != null)
                            _buildButton(
                              name: AppLocalizations.of(_context).downloadAll,
                              bgColor: AttachmentListStyles.downloadAllButtonColor,
                              textStyle: AttachmentListStyles.downloadAllButtonTextStyle
                            ),
                          if (_onDownloadAllButtonAction != null && _onCancelButtonAction != null)
                            const SizedBox(width: AttachmentListStyles.buttonsSpaceBetween),
                          if (_onCancelButtonAction != null)
                            _buildButton(
                              name: AppLocalizations.of(_context).close,
                              bgColor: AttachmentListStyles.cancelButtonColor,
                              borderColor: AttachmentListStyles.cancelButtonBorderColor,
                              textStyle: AttachmentListStyles.cancelButtonTextStyle
                            )
                        ],
                      ),
                    ),
                  const SizedBox(height: AttachmentListStyles.dialogBottomSpace)
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget _buildButton({
    String? name,
    TextStyle? textStyle,
    Color? bgColor,
    Color? borderColor,
    Function? action
  }) {
    return InkWell(
      onTap: () => action?.call(),
      child: Container(
        padding: AttachmentListStyles.buttonsPadding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AttachmentListStyles.buttonRadius,
          border: Border.all(
            width: borderColor != null ? AttachmentListStyles.buttonBorderWidth : 0,
            color: borderColor ?? AttachmentListStyles.buttonBorderDefaultColor
          )
        ),
        child: Center(
          child: Text(
            name ?? '',
            textAlign: TextAlign.center,
            style: textStyle
          ),
        ),
      ),
    );
  }
}