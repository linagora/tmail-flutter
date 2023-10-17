import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnDownloadAttachmentFileAction = void Function(Attachment attachment);
typedef OnDownloadAllButtonAction = void Function();
typedef OnCancelButtonAction = void Function();
typedef OnCloseButtonAction = void Function();

class AttachmentListDialogBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final List<Attachment> _attachments;
  final ResponsiveUtils _responsiveUtils;

  Key? _key;
  Color? _backgroundColor;
  double? _widthDialog;
  double? _heightDialog;

  OnDownloadAllButtonAction? _onDownloadAllButtonAction;
  OnDownloadAttachmentFileAction? _onDownloadAttachmentFileAction;
  OnCancelButtonAction? _onCancelButtonAction;
  OnCloseButtonAction? _onCloseButtonAction;

  AttachmentListDialogBuilder(
    this._context,
    this._imagePaths,
    this._attachments,
    this._responsiveUtils,
  );

  void key(Key key) {
    _key = key;
  }

  void backgroundColor(Color color) {
    _backgroundColor = color;
  }

  void widthDialog(double width) {
    _widthDialog = width;
  }

  void heightDialog(double height) {
    _heightDialog = height;
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

  Widget build() {
    return Dialog(
      key: _key,
      shape: AttachmentListStyles.shapeBorder,
      insetPadding: _responsiveUtils.isDesktop(_context)
        ? AttachmentListStyles.dialogPaddingWeb
        : AttachmentListStyles.dialogPaddingTablet,
      alignment: Alignment.center,
      backgroundColor: _backgroundColor,
      child: _bodyContent(),
    );
  }

  Widget _bodyContent() {
    ScrollController scrollController = ScrollController();
    return Container(
      width: _widthDialog,
      height: _heightDialog,
      decoration: AttachmentListStyles.dialogBodyDecoration,
      child: Column(
        children: [
          Container(
            padding: AttachmentListStyles.headerPadding,
            decoration: AttachmentListStyles.headerDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  AppLocalizations.of(_context).attachmentList,
                  style: AttachmentListStyles.titleTextStyle
                ),
                const SizedBox(width: AttachmentListStyles.titleSpace),
                Text(
                  '${_attachments.length} ${AppLocalizations.of(_context).files}',
                  style: AttachmentListStyles.subTitleTextStyle
                ),
                if (_onCloseButtonAction != null)
                  const Spacer(),
                  buildIconWeb(
                    icon: SvgPicture.asset(_imagePaths.icCircleClose),
                    onTap: () => _onCloseButtonAction?.call(),
                  ),
              ],
            )
          ),
          Expanded(
            child: Padding(
              padding: AttachmentListStyles.listAreaPadding,
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
          Row(
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
          const SizedBox(height: AttachmentListStyles.dialogBottomSpace)
        ],
      ),
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
            color: borderColor ?? Colors.transparent
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