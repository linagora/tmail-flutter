import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/list/sliver_grid_delegate_fixed_height.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/custom_scroll_behavior.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/composer_loading_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_file_composer_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/email_address_input_builder.dart';
import 'package:tmail_ui_user/features/upload/presentation/extensions/list_upload_file_state_extension.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class BaseComposerView extends GetWidget<ComposerController>
    with
        AppLoaderMixin,
        RichTextButtonMixin,
        ComposerLoadingMixin {

  BaseComposerView({Key? key}) : super(key: key);

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final appToast = Get.find<AppToast>();

  Widget buildFromEmailAddress(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: ComposerStyle.getFromAddressPadding(context, responsiveUtils),
        child: Row(children: [
          Text(
            '${AppLocalizations.of(context).from_email_address_prefix}:',
            style: const TextStyle(
              fontSize: 15,
              color: AppColor.colorHintEmailAddressInput
            )
          ),
          SizedBox(width: ComposerStyle.getSpace(context, responsiveUtils)),
          if (controller.listIdentities.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(end: ComposerStyle.getSpace(context, responsiveUtils)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<Identity>(
                  isExpanded: true,
                  customButton: SvgPicture.asset(imagePaths.icEditIdentity),
                  items: controller.listIdentities.map(_buildItemIdentity).toList(),
                  onChanged: controller.selectIdentity,
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 240,
                    width: PlatformInfo.isWeb ? 370 : 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                    elevation: 4,
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all<double>(6),
                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 55,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  )
                )
              ),
            ),
          Expanded(child: TextOverflowBuilder(
            controller.identitySelected.value != null
              ? (controller.identitySelected.value?.email ?? '')
              : (controller.userProfile?.email ?? ''),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              color: AppColor.colorEmailAddressPrefix
            )
          )),
        ]),
      );
    });
  }

  DropdownMenuItem<Identity> _buildItemIdentity(Identity identity) {
    return DropdownMenuItem<Identity>(
      value: identity,
      child: PointerInterceptor(
        child: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: identity == controller.identitySelected.value
              ? AppColor.colorBgMenuItemDropDownSelected
              : Colors.transparent
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                identity.name ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black
                ),
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
              ),
              Text(
                identity.email ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColor.colorHintSearchBar
                ),
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                softWrap: CommonTextStyle.defaultSoftWrap,
              )
            ]
          ),
        ),
      ),
    );
  }

  Widget buildEmailAddress(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return (EmailAddressInputBuilder(
            context,
            imagePaths,
            responsiveUtils,
            PrefixEmailAddress.to,
            controller.listToEmailAddress,
            controller.listEmailAddressType,
            expandMode: controller.toAddressExpandMode.value,
            controller: controller.toEmailAddressController,
            focusNode: controller.toAddressFocusNode,
            autoDisposeFocusNode: false,
            keyTagEditor: controller.keyToEmailTagEditor,
            isInitial: controller.isInitialRecipient.value,
            nextFocusNode: controller.getNextFocusOfToEmailAddress()
          )
            ..addOnFocusEmailAddressChangeAction(controller.onEmailAddressFocusChange)
            ..addOnShowFullListEmailAddressAction(controller.showFullEmailAddress)
            ..addOnAddEmailAddressTypeAction(controller.addEmailAddressType)
            ..addOnUpdateListEmailAddressAction(controller.updateListEmailAddress)
            ..addOnSuggestionEmailAddress(controller.getAutoCompleteSuggestion)
            ..addOnFocusNextAddressAction(controller.handleFocusNextAddressAction)
          ).build();
        }),
        Obx(() {
          if (controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true) {
            return const Divider(color: AppColor.colorDividerComposer, height: 1);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true) {
            return (EmailAddressInputBuilder(
              context,
              imagePaths,
              responsiveUtils,
              PrefixEmailAddress.cc,
              controller.listCcEmailAddress,
              controller.listEmailAddressType,
              focusNode: controller.ccAddressFocusNode,
              expandMode: controller.ccAddressExpandMode.value,
              controller: controller.ccEmailAddressController,
              keyTagEditor: controller.keyCcEmailTagEditor,
              autoDisposeFocusNode: false,
              isInitial: controller.isInitialRecipient.value,
              nextFocusNode: controller.getNextFocusOfCcEmailAddress()
            )
              ..addOnFocusEmailAddressChangeAction(controller.onEmailAddressFocusChange)
              ..addOnShowFullListEmailAddressAction(controller.showFullEmailAddress)
              ..addOnDeleteEmailAddressTypeAction(controller.deleteEmailAddressType)
              ..addOnUpdateListEmailAddressAction(controller.updateListEmailAddress)
              ..addOnSuggestionEmailAddress(controller.getAutoCompleteSuggestion)
              ..addOnFocusNextAddressAction(controller.handleFocusNextAddressAction)
            ).build();
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true) {
            return const Divider(color: AppColor.colorDividerComposer, height: 1);
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          if (controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true) {
            return (EmailAddressInputBuilder(
              context,
              imagePaths,
              responsiveUtils,
              PrefixEmailAddress.bcc,
              controller.listBccEmailAddress,
              controller.listEmailAddressType,
              focusNode: controller.bccAddressFocusNode,
              expandMode: controller.bccAddressExpandMode.value,
              controller: controller.bccEmailAddressController,
              autoDisposeFocusNode: false,
              keyTagEditor: controller.keyBccEmailTagEditor,
              isInitial: controller.isInitialRecipient.value,
              nextFocusNode: controller.subjectEmailInputFocusNode
            )
              ..addOnFocusEmailAddressChangeAction(controller.onEmailAddressFocusChange)
              ..addOnShowFullListEmailAddressAction(controller.showFullEmailAddress)
              ..addOnDeleteEmailAddressTypeAction(controller.deleteEmailAddressType)
              ..addOnUpdateListEmailAddressAction(controller.updateListEmailAddress)
              ..addOnSuggestionEmailAddress(controller.getAutoCompleteSuggestion)
              ..addOnFocusNextAddressAction(controller.handleFocusNextAddressAction)
            ).build();
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget buildSubjectEmail(BuildContext context) {
    return Padding(
      padding: PlatformInfo.isWeb
        ? ComposerStyle.getSubjectWebPadding(context, responsiveUtils)
        : ComposerStyle.getSubjectPadding(context, responsiveUtils),
      child: Row(
        children: [
          Text(
            '${AppLocalizations.of(context).subject_email}:',
            style: const TextStyle(
              fontSize: 15,
              color: AppColor.colorHintEmailAddressInput
            )
          ),
          const SizedBox(width: 8),
          Expanded(child: TextFieldBuilder(
            key: const Key('subject_email_input'),
            cursorColor: AppColor.colorTextButton,
            focusNode: controller.subjectEmailInputFocusNode,
            onTextChange: controller.setSubjectEmail,
            maxLines: PlatformInfo.isWeb ? 1 : null,
            textDirection: DirectionUtils.getDirectionByLanguage(context),
            textStyle: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal),
            decoration: const InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none),
            controller: controller.subjectEmailInputController,
          ))
        ]
      ),
    );
  }

  Widget buildDivider() => const Divider(color: AppColor.colorDividerComposer, height: 1);

  Widget buildAttachmentsWidget(BuildContext context) {
    return Obx(() {
      final uploadAttachments = controller.uploadController.listUploadAttachments;
      if (uploadAttachments.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return Padding(
          padding: ComposerStyle.getAttachmentPadding(context, responsiveUtils),
          child: Column(
            children: [
              _buildAttachmentsTitle(context,
                uploadAttachments,
                controller.expandModeAttachments.value
              ),
              _buildAttachmentsList(context,
                uploadAttachments,
                controller.expandModeAttachments.value
              )
            ]
          ),
        );
      }
    });
  }

  Widget _buildAttachmentsTitle(
    BuildContext context,
    List<UploadFileState> uploadFilesState,
    ExpandMode expandModeAttachment
  ) {
    return Row(
      children: [
        Text(
          '${AppLocalizations.of(context).attachments} (${filesize(uploadFilesState.totalSize, 0)}):',
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.colorHintEmailAddressInput,
            fontWeight: FontWeight.normal
          )
        ),
        const Spacer(),
        TMailButtonWidget.fromText(
          text: expandModeAttachment == ExpandMode.EXPAND
            ? AppLocalizations.of(context).hide
            : '${AppLocalizations.of(context).showAll} (${uploadFilesState.length})',
          onTapActionCallback: controller.toggleDisplayAttachments,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColor.colorTextButton
          ),
          backgroundColor: Colors.transparent,
        )
      ],
    );
  }

  Widget _buildAttachmentsList(
    BuildContext context,
    List<UploadFileState> uploadFilesState,
    ExpandMode expandMode
  ) {
    const double maxHeightItem = 60;
    if (expandMode == ExpandMode.EXPAND) {
      if (PlatformInfo.isWeb) {
        return LayoutBuilder(builder: (context, constraints) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              height: maxHeightItem,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: ListView.builder(
                  key: const Key('list_attachment_minimize'),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  controller: controller.scrollControllerAttachment,
                  itemCount: uploadFilesState.length,
                  itemBuilder: (context, index) => AttachmentFileComposerBuilder(
                    uploadFilesState[index],
                    itemMargin: const EdgeInsetsDirectional.only(end: 8),
                    maxWidth: ComposerStyle.getMaxWidthItemListAttachment(context, constraints),
                    onDeleteAttachmentAction: (attachment) => controller.deleteAttachmentUploaded(attachment.uploadTaskId)
                  )
                ),
              )
            )
          );
        });
      } else {
        return LayoutBuilder(builder: (context, constraints) {
          return GridView.builder(
            key: const Key('list_attachment_full'),
            primary: false,
            shrinkWrap: true,
            itemCount: uploadFilesState.length,
            gridDelegate: SliverGridDelegateFixedHeight(
              height: maxHeightItem,
              crossAxisCount: ComposerStyle.getMaxItemRowListAttachment(context, constraints),
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0),
            itemBuilder: (context, index) => AttachmentFileComposerBuilder(
              uploadFilesState[index],
              onDeleteAttachmentAction: (attachment) => controller.deleteAttachmentUploaded(attachment.uploadTaskId)
            )
          );
        });
      }
    } else {
      if (PlatformInfo.isWeb) {
        return const SizedBox.shrink();
      } else {
        return LayoutBuilder(builder: (context, constraints) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              height: maxHeightItem,
              child: ListView.builder(
                key: const Key('list_attachment_minimize'),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: uploadFilesState.length,
                itemBuilder: (context, index) => AttachmentFileComposerBuilder(
                  uploadFilesState[index],
                  itemMargin: const EdgeInsetsDirectional.only(end: 8),
                  maxWidth: ComposerStyle.getMaxWidthItemListAttachment(context, constraints),
                  onDeleteAttachmentAction: (attachment) => controller.deleteAttachmentUploaded(attachment.uploadTaskId)
                )
              )
            )
          );
        });
      }
    }
  }

  Widget buildAppBar(BuildContext context) {
    return Container(
      height: ComposerStyle.getAppBarHeight(context, responsiveUtils),
      padding: ComposerStyle.getAppBarPadding(context, responsiveUtils),
      child: Row(
        children: [
          buildIconWeb(
            icon: SvgPicture.asset(
              imagePaths.icClose,
              width: 30,
              height: 30,
              fit: BoxFit.fill
            ),
            iconPadding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context).saveAndClose,
            onTap: () => controller.saveEmailAsDrafts(context)
          ),
          Expanded(child: buildTitleComposer(context)),
          if (responsiveUtils.isScreenWithShortestSide(context))
            Obx(() => buildIconWeb(
              icon: SvgPicture.asset(
                controller.isEnableEmailSendButton.value
                  ? imagePaths.icSendMobile
                  : imagePaths.icSendDisable,
                fit: BoxFit.fill
              ),
              tooltip: AppLocalizations.of(context).send,
              onTap: () => controller.sendEmailAction(context)
            )),
          if (responsiveUtils.isScreenWithShortestSide(context))
            buildIconWithLowerMenu(
              SvgPicture.asset(imagePaths.icRequestReadReceipt),
              context,
              popUpMoreActionMenu(context),
              controller.openPopupMenuAction
            ),
        ],
      ),
    );
  }

  List<PopupMenuEntry> popUpMoreActionMenu(BuildContext context) {
    return [];
  }

  Widget buildTitleComposer(BuildContext context) {
    return Obx(() => Text(
      controller.subjectEmail.isNotEmpty == true
        ? controller.subjectEmail.value ?? ''
        : AppLocalizations.of(context).new_message.capitalizeFirstEach,
      maxLines: 1,
      textAlign: TextAlign.center,
      overflow: CommonTextStyle.defaultTextOverFlow,
      softWrap: CommonTextStyle.defaultSoftWrap,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black
      ),
    ));
  }

  Widget buildBottomBar(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 24),
            buildTextButton(
              AppLocalizations.of(context).cancel,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: AppColor.colorLabelCancelButton
              ),
              backgroundColor: AppColor.emailAddressChipColor,
              width: 150,
              height: 44,
              radius: 10,
              onTap: () => controller.closeComposer(context)
            ),
            const SizedBox(width: 12),
            buildTextButton(
              AppLocalizations.of(context).save_to_drafts,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: AppColor.colorTextButton
              ),
              backgroundColor: AppColor.emailAddressChipColor,
              width: 150,
              height: 44,
              radius: 10,
              onTap: () => controller.saveEmailAsDrafts(context)
            ),
            const SizedBox(width: 12),
            buildTextButton(
              AppLocalizations.of(context).send,
              width: 150,
              height: 44,
              radius: 10,
              onTap: () => controller.sendEmailAction(context)
            ),
            const SizedBox(width: 24),
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buildIconWithUpperMenu(
              SvgPicture.asset(imagePaths.icRequestReadReceipt),
              context,
              popUpMoreActionMenu(context),
              controller.openPopupMenuAction
            )
          ]
        ),
      ],
    );
  }
}