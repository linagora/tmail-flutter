import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/list/sliver_grid_delegate_fixed_height.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_item_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile/mobile_attachment_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_item_composer_widget.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

class MobileAttachmentComposerWidget extends StatelessWidget {

  final List<UploadFileState> listFileUploaded;
  final OnDeleteAttachmentAction onDeleteAttachmentAction;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  MobileAttachmentComposerWidget({
    super.key,
    required this.listFileUploaded,
    required this.onDeleteAttachmentAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MobileAttachmentComposerWidgetStyle.padding,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_responsiveUtils.isLandscapeMobile(context))
            SizedBox(
              width: _responsiveUtils.getSizeScreenWidth(context) * 0.7,
              child: GridView.builder(
                reverse: true,
                primary: false,
                shrinkWrap: true,
                itemCount: listFileUploaded.length,
                gridDelegate: const SliverGridDelegateFixedHeight(
                  height: MobileAttachmentComposerWidgetStyle.listItemHeight,
                  crossAxisCount: MobileAttachmentComposerWidgetStyle.maxItemRow,
                  crossAxisSpacing: MobileAttachmentComposerWidgetStyle.listItemSpace,
                ),
                itemBuilder: (context, index) {
                  return AttachmentItemComposerWidget(
                    fileState: listFileUploaded[index],
                    itemMargin: MobileAttachmentComposerWidgetStyle.itemMargin,
                    onDeleteAttachmentAction: onDeleteAttachmentAction
                  );
                }
              ),
            )
          else
            SizedBox(
              width: AttachmentItemComposerWidgetStyle.width,
              child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                primary: false,
                itemCount: listFileUploaded.length,
                itemBuilder: (context, index) {
                  return AttachmentItemComposerWidget(
                    fileState: listFileUploaded[index],
                    itemMargin: MobileAttachmentComposerWidgetStyle.itemMargin,
                    onDeleteAttachmentAction: onDeleteAttachmentAction
                  );
                }
              ),
            )
        ]
      ),
    );
  }
}
