import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/app_bar_mailbox_creator_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/create_mailbox_name_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxCreatorView extends GetWidget<MailboxCreatorController> {

  final _maxHeight = 656.0;
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  final controller = Get.find<MailboxCreatorController>();

  MailboxCreatorView({Key? key}) : super(key: key) {
    controller.arguments = Get.arguments;
  }

  MailboxCreatorView.fromArguments(
      MailboxCreatorArguments arguments, {
      Key? key,
      OnCreatedMailboxCallback? onCreatedMailboxCallback,
      VoidCallback? onDismissCallback
  }) : super(key: key) {
    controller.arguments = arguments;
    controller.onCreatedMailboxCallback = onCreatedMailboxCallback;
    controller.onDismissMailboxCreator = onDismissCallback;
  }

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: GestureDetector(
        onTap: () => controller.closeMailboxCreator(context),
        child: Card(
          margin: EdgeInsets.zero,
          borderOnForeground: false,
          color: Colors.transparent,
          child: SafeArea(
            top: !BuildUtils.isWeb && _responsiveUtils.isPortraitMobile(context),
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
                            left: !BuildUtils.isWeb && _responsiveUtils.isLandscapeMobile(context),
                            right: !BuildUtils.isWeb && _responsiveUtils.isLandscapeMobile(context),
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
    return Obx(() => (AppBarMailboxCreatorBuilder(
            context,
            title: AppLocalizations.of(context).new_mailbox,
            isValidated: controller.isCreateMailboxValidated(context))
        ..addOnCancelActionClick(() => controller.closeMailboxCreator(context))
        ..addOnDoneActionClick(() => controller.createNewMailbox(context)))
      .build());
  }

  Widget _buildCreateMailboxNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Obx(() => (TextFieldBuilder()
          ..key(const Key('create_mailbox_name_input'))
          ..onChange((value) => controller.setNewNameMailbox(value))
          ..keyboardType(TextInputType.visiblePassword)
          ..cursorColor(AppColor.colorTextButton)
          ..addController(controller.nameInputController)
          ..maxLines(1)
          ..textStyle(const TextStyle(
              color: AppColor.colorNameEmail,
              fontSize: 16,
              overflow: CommonTextStyle.defaultTextOverFlow))
          ..addFocusNode(controller.nameInputFocusNode)
          ..textDecoration((CreateMailboxNameInputDecorationBuilder()
                ..setHintText(AppLocalizations.of(context).hint_input_create_new_mailbox)
                ..setErrorText(controller.getErrorInputNameString(context)))
              .build()))
        .build())
    );
  }

  Widget _buildMailboxLocation(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          AppLocalizations.of(context).selectParentFolder,
          textAlign: TextAlign.left,
          style: const TextStyle(
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
                    controller.selectedMailbox.value?.getMailboxIcon(_imagePaths) ?? _imagePaths.icFolderMailbox,
                    width: BuildUtils.isWeb ? 20 : 24,
                    height: BuildUtils.isWeb ? 20 : 24,
                    fit: BoxFit.fill)),
                const SizedBox(width: 12),
                Expanded(child: Obx(() => Text(
                  controller.selectedMailbox.value?.name?.name ?? AppLocalizations.of(context).allMailboxes,
                  maxLines: 1,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  style: TextStyle(
                      fontSize: 15,
                      color: controller.selectedMailbox.value == null
                          ? AppColor.colorHintSearchBar
                          : AppColor.colorNameEmail),
                ))),
                const SizedBox(width: 12),
                IconButton(
                    color: AppColor.primaryColor,
                    icon: SvgPicture.asset(
                        _imagePaths.icCollapseFolder,
                        color: AppColor.colorCollapseMailbox,
                        fit: BoxFit.fill),
                    onPressed: () => controller.selectMailboxLocation(context))
                ])),
          )
      )
    ]);
  }

  double _getWidthView(BuildContext context) {
    if (BuildUtils.isWeb) {
      if (_responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        return 556;
      }
    } else {
      if (_responsiveUtils.isLandscapeMobile(context) ||
          _responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        return 556;
      }
    }
  }

  double _getHeightView(BuildContext context) {
    if (BuildUtils.isWeb) {
      if (_responsiveUtils.isMobile(context)) {
        return double.infinity;
      } else {
        if (_responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    } else {
      if (_responsiveUtils.isLandscapeMobile(context) ||
          _responsiveUtils.isPortraitMobile(context)) {
        return double.infinity;
      } else {
        if (_responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return _maxHeight;
        } else {
          return double.infinity;
        }
      }
    }

  }

  EdgeInsets _getMarginView(BuildContext context) {
    if (BuildUtils.isWeb) {
      if (_responsiveUtils.isMobile(context)) {
        return EdgeInsets.zero;
      } else {
        if (_responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return const EdgeInsets.symmetric(vertical: 12);
        } else {
          return const EdgeInsets.symmetric(vertical: 50);
        }
      }
    } else {
      if (_responsiveUtils.isLandscapeMobile(context) ||
          _responsiveUtils.isPortraitMobile(context)) {
        return EdgeInsets.zero;
      } else {
        if (_responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
          return const EdgeInsets.symmetric(vertical: 12);
        } else {
          return const EdgeInsets.symmetric(vertical: 50);
        }
      }
    }
  }

  BorderRadius _getRadiusView(BuildContext context) {
    if (!BuildUtils.isWeb && _responsiveUtils.isLandscapeMobile(context)) {
      return BorderRadius.zero;
    } else if (_responsiveUtils.isMobile(context)) {
      return const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16));
    } else {
      return const BorderRadius.all(Radius.circular(16));
    }
  }
}