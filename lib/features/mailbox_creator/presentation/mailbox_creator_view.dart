import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/app_bar_mailbox_creator_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/create_mailbox_name_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxCreatorView extends GetWidget<MailboxCreatorController> {

  final _maxHeight = 656.0;

  @override
  final controller = Get.find<MailboxCreatorController>();

  MailboxCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    log('MailboxCreatorView::build():');
    return PointerInterceptor(
      child: GestureDetector(
        onTap: () => controller.closeMailboxCreator(context),
        child: Card(
          margin: EdgeInsets.zero,
          borderOnForeground: false,
          color: Colors.transparent,
          child: SafeArea(
            top: PlatformInfo.isMobile && controller.responsiveUtils.isPortraitMobile(context),
            bottom: false,
            left: false,
            right: false,
            child: Center(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Container(
                      margin: _getMarginView(context),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: _getRadiusView(context),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColor.colorShadowLayerBottom,
                                blurRadius: 96,
                                spreadRadius: 96,
                                offset: Offset.zero),
                            BoxShadow(
                                color: AppColor.colorShadowLayerTop,
                                blurRadius: 2,
                                spreadRadius: 2,
                                offset: Offset.zero),
                          ]),
                      width: _getWidthView(context),
                      height: _getHeightView(context),
                      child: ClipRRect(
                          borderRadius: _getRadiusView(context),
                          child: SafeArea(
                            top: false,
                            bottom: false,
                            left: PlatformInfo.isMobile && controller.responsiveUtils.isLandscapeMobile(context),
                            right: PlatformInfo.isMobile && controller.responsiveUtils.isLandscapeMobile(context),
                            child: Column(children: [
                              _buildAppBar(context),
                              const Divider(color: AppColor.colorDividerDestinationPicker, height: 1),
                              _buildCreateMailboxNameInput(context),
                              _buildMailboxLocation(context),
                            ]),
                          )
                      )
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return (AppBarMailboxCreatorBuilder(
      context,
      title: AppLocalizations.of(context).newFolder,
      isValidated: true)
    ..addOnCancelActionClick(() => controller.closeMailboxCreator(context))
    ..addOnDoneActionClick(() => controller.createNewMailbox(context)))
    .build();
  }

  Widget _buildCreateMailboxNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Obx(() => TextFieldBuilder(
        onTextChange: controller.setNewNameMailbox,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: AppColor.colorTextButton,
        controller: controller.nameInputController,
        textDirection: DirectionUtils.getDirectionByLanguage(context),
        maxLines: 1,
        textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
          color: AppColor.colorNameEmail,
          fontSize: 16,
          overflow: CommonTextStyle.defaultTextOverFlow),
        focusNode: controller.nameInputFocusNode,
        decoration: (CreateMailboxNameInputDecorationBuilder()
          ..setHintText(AppLocalizations.of(context).hintInputCreateNewFolder)
          ..setErrorText(controller.getErrorInputNameString(context)))
        .build(),
      ))
    );
  }

  Widget _buildMailboxLocation(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          AppLocalizations.of(context).selectParentFolder,
          textAlign: TextAlign.left,
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: 13,
              color: AppColor.colorHintSearchBar,
              fontWeight: FontWeight.normal)),
      ),
      Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColor.colorBgMailbox
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.selectMailboxLocation(context),
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const SizedBox(width: 12),
                Obx(() => SvgPicture.asset(
                    controller.selectedMailbox.value?.getMailboxIcon(controller.imagePaths) ?? controller.imagePaths.icFolderMailbox,
                    width: PlatformInfo.isWeb ? 20 : 24,
                    height: PlatformInfo.isWeb ? 20 : 24,
                    fit: BoxFit.fill)),
                const SizedBox(width: 12),
                Expanded(child: Obx(() => Text(
                  controller.selectedMailbox.value?.getDisplayName(context) ?? AppLocalizations.of(context).allFolders,
                  maxLines: 1,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontSize: 15,
                      color: controller.selectedMailbox.value == null
                          ? AppColor.colorHintSearchBar
                          : AppColor.colorNameEmail),
                ))),
                const SizedBox(width: 12),
                IconButton(
                    color: AppColor.primaryColor,
                    icon: SvgPicture.asset(
                        DirectionUtils.isDirectionRTLByLanguage(context)
                          ? controller.imagePaths.icBack
                          : controller.imagePaths.icCollapseFolder,
                        colorFilter: AppColor.colorCollapseMailbox.asFilter(),
                        fit: BoxFit.fill),
                    onPressed: () => controller.selectMailboxLocation(context))
                ])),
          )
      )
    ]);
  }

  double _getWidthView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        return 556;
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
          controller.responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        return 556;
      }
    }
  }

  double _getHeightView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
          controller.responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    }

  }

  EdgeInsets _getMarginView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (controller.responsiveUtils.isMobile(context)) {
        return EdgeInsets.zero;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return const EdgeInsets.symmetric(vertical: 12);
        } else {
          return const EdgeInsets.symmetric(vertical: 50);
        }
      }
    } else {
      if (controller.responsiveUtils.isLandscapeMobile(context) ||
          controller.responsiveUtils.isPortraitMobile(context)) {
        return EdgeInsets.zero;
      } else {
        if (controller.responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return const EdgeInsets.symmetric(vertical: 12);
        } else {
          return const EdgeInsets.symmetric(vertical: 50);
        }
      }
    }
  }

  BorderRadius _getRadiusView(BuildContext context) {
    if (PlatformInfo.isMobile && controller.responsiveUtils.isLandscapeMobile(context)) {
      return BorderRadius.zero;
    } else if (controller.responsiveUtils.isMobile(context)) {
      return const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16));
    } else {
      return const BorderRadius.all(Radius.circular(16));
    }
  }
}