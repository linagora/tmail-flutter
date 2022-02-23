import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/app_bar_mailbox_creator_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/create_mailbox_name_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxCreatorView extends GetWidget<MailboxCreatorController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        borderOnForeground: false,
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => controller.closeMailboxCreator(context),
          child: ResponsiveWidget(
              responsiveUtils: _responsiveUtils,
              mobile: Container(
                  child: _buildBody(context),
                  width: _responsiveUtils.getSizeWidthScreen(context)),
              tablet: Container(
                  child: Row(
                      children: [
                        Expanded(flex: 1, child: _buildBody(context)),
                        Expanded(flex: 1, child: Container(color: Colors.transparent)),
                      ]
                  )
              ),
              tabletLarge: Container(
                  child: Row(
                      children: [
                        Expanded(flex: 7, child: _buildBody(context)),
                        Expanded(flex: 13, child: Container(color: Colors.transparent)),
                      ]
                  )
              ),
              desktop: Container(
                  child: Row(
                      children: [
                        Expanded(flex: 1, child: _buildBody(context)),
                        Expanded(flex: 3, child: Container(color: Colors.transparent)),
                      ]
                  )
              )
          ),
        )
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
        top: _responsiveUtils.isMobile(context) ? true : false,
        bottom: false,
        left: false,
        right: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(_responsiveUtils.isMobile(context) ? 14 : 0),
                  topLeft: Radius.circular(_responsiveUtils.isMobile(context) ? 14 : 0)),
              child: Drawer(
                  child: Container(
                      color: AppColor.colorBgMailbox,
                      width: double.infinity,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        left: _responsiveUtils.isMobileDevice(context) ? true : false,
                        right: _responsiveUtils.isMobileDevice(context) ? true : false,
                        child: Column(
                            children: [
                              _buildAppBar(context),
                              _buildCreateMailboxNameInput(context),
                              _buildMailboxLocation(context),
                            ]
                        ),
                      )
                  )
              )
          ),
        )
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Obx(() => (AppBarMailboxCreatorBuilder(
              context,
              title: AppLocalizations.of(context).new_mailbox,
              isValidated: controller.isCreateMailboxValidated(context))
          ..addOnCancelActionClick(() => controller.closeMailboxCreator(context))
          ..addOnDoneActionClick(() => controller.createNewMailbox(context)))
        .build())
    );
  }

  Widget _buildCreateMailboxNameInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Obx(() => (TextFieldBuilder()
          ..key(Key('create_mailbox_name_input'))
          ..onChange((value) => controller.setNewNameMailbox(value))
          ..keyboardType(TextInputType.visiblePassword)
          ..cursorColor(AppColor.colorTextButton)
          ..autoFocus(true)
          ..textStyle(TextStyle(color: AppColor.colorNameEmail, fontSize: 16))
          ..textDecoration((CreateMailboxNameInputDecorationBuilder()
                ..setErrorText(controller.getErrorInputNameString(context)))
              .build()))
        .build())
    );
  }

  Widget _buildMailboxLocation(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 4),
        child: Text(
          AppLocalizations.of(context).mailbox_location.toUpperCase(),
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 13, color: AppColor.colorHintSearchBar)),
      ),
      Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white
          ),
          child: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.zero),
            child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => controller.selectMailboxLocation(context),
                leading: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: SvgPicture.asset(
                        _imagePaths.icFolderMailbox,
                        width: 28,
                        height: 28,
                        fit: BoxFit.fill)),
                title: Transform(
                    transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
                    child: Row(children: [
                      Expanded(child: Obx(() => Text(
                        '${controller.selectedMailbox.value?.name?.name ?? AppLocalizations.of(context).default_mailbox}',
                        maxLines: 1,
                        overflow:TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            color: controller.selectedMailbox.value == null
                                ? AppColor.colorHintSearchBar
                                : AppColor.colorNameEmail),
                      ))),
                    ])),
                trailing: Transform(
                    transform: Matrix4.translationValues(4.0, 0.0, 0.0),
                    child: IconButton(
                        color: AppColor.primaryColor,
                        icon: SvgPicture.asset(_imagePaths.icFolderArrow, color: AppColor.colorArrowUserMailbox, fit: BoxFit.fill),
                        onPressed: () => controller.selectMailboxLocation(context)
                    ))
            ),
          )
      )
    ]);
  }
}