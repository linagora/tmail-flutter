import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/context_menu/simple_context_menu_action_builder.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/base_composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class ComposerView extends BaseComposerView {

  ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: _buildComposerViewForMobile(context),
      tablet: _buildComposerViewForTablet(context),
    );
  }

  Widget _buildComposerViewForMobile(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.saveEmailAsDrafts(context, canPop: false);
        return true;
      },
      child: GestureDetector(
        onTap: () => controller.clearFocusEditor(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(builder: (context, constraints) {
            return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
              return KeyboardRichText(
                richTextController: controller.keyboardRichTextController,
                keyBroadToolbar: RichTextKeyboardToolBar(
                  backgroundKeyboardToolBarColor: AppColor.colorBackgroundKeyboard,
                  isLandScapeMode: responsiveUtils.isLandscapeMobile(context),
                  insertAttachment: controller.isNetworkConnectionAvailable
                    ? () => controller.openPickAttachmentMenu(context, _pickAttachmentsActionTiles(context))
                    : null,
                  insertImage: controller.isNetworkConnectionAvailable
                    ? () => controller.insertImage(context, constraints.maxWidth)
                    : null,
                  richTextController: controller.keyboardRichTextController,
                  titleQuickStyleBottomSheet: AppLocalizations.of(context).titleQuickStyles,
                  titleBackgroundBottomSheet: AppLocalizations.of(context).titleBackground,
                  titleForegroundBottomSheet: AppLocalizations.of(context).titleForeground,
                  titleFormatBottomSheet: AppLocalizations.of(context).titleFormat,
                  titleBack: AppLocalizations.of(context).format,
                ),
                paddingChild: isKeyboardVisible ? const EdgeInsets.only(bottom: 64) : EdgeInsets.zero,
                child: SafeArea(
                  child: Container(
                    color: Colors.white,
                    child: Column(children: [
                      buildAppBar(context),
                      buildDivider(),
                      Expanded(child: _buildBodyMobile(context))
                    ])
                  ),
                ),
              );
            });
          })
        ),
      )
    );
  }

  Widget _buildComposerViewForTablet(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.saveEmailAsDrafts(context, canPop: false);
        return true;
      },
      child: GestureDetector(
        onTap: () => controller.clearFocusEditor(context),
        child: Scaffold(
          backgroundColor: Colors.black38,
          body: LayoutBuilder(builder: (context, constraints) {
            return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
              return KeyboardRichText(
                richTextController: controller.keyboardRichTextController,
                keyBroadToolbar: RichTextKeyboardToolBar(
                  backgroundKeyboardToolBarColor: AppColor.colorBackgroundKeyboard,
                  insertAttachment: () => controller.openPickAttachmentMenu(context, _pickAttachmentsActionTiles(context)),
                  insertImage: () => controller.insertImage(context, constraints.maxWidth),
                  richTextController: controller.keyboardRichTextController,
                  titleQuickStyleBottomSheet: AppLocalizations.of(context).titleQuickStyles,
                  titleBackgroundBottomSheet: AppLocalizations.of(context).titleBackground,
                  titleForegroundBottomSheet: AppLocalizations.of(context).titleForeground,
                  titleFormatBottomSheet: AppLocalizations.of(context).titleFormat,
                  titleBack: AppLocalizations.of(context).format,
                ),
                paddingChild: isKeyboardVisible ? const EdgeInsets.only(bottom: 64) : EdgeInsets.zero,
                child: Center(
                  child: SafeArea(
                    child: Card(
                      elevation: 20,
                      margin: ComposerStyle.getMarginForTablet(context, responsiveUtils),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
                        width: ComposerStyle.getWidthForTablet(context, responsiveUtils),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(ComposerStyle.radius)),
                          child: Column(children: [
                            buildAppBar(context),
                            buildDivider(),
                            Expanded(child: _buildBodyTablet(context)),
                            buildDivider(),
                            Padding(
                              padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                              child: buildBottomBar(context)),
                          ])
                        )
                      )
                    ),
                  )),
              );
            });
          })
        )
      )
    );
  }

  @override
  List<PopupMenuEntry> popUpMoreActionMenu(BuildContext context) {
    return [
      PopupMenuItem(
        padding: const EdgeInsets.symmetric(horizontal: 8), 
        child: Row(
          children: [
            Obx(() => buildIconWeb(
              icon: Icon(controller.hasRequestReadReceipt.value ? Icons.done : null, color: Colors.black))), 
            IgnorePointer(
              child: buildTextIcon(
                AppLocalizations.of(context).requestReadReceipt, 
                textStyle: const TextStyle(color: Colors.black, fontSize: 15)),
            ),
          ]),
        onTap: () {
          controller.toggleRequestReadReceipt();
        },
      )
    ];
  }

  List<Widget> _pickAttachmentsActionTiles(BuildContext context) {
    return [
      _pickPhotoAndVideoAction(context),
      _browseFileAction(context),
      const SizedBox(height: kIsWeb ? 16 : 30),
    ];
  }

  Widget _pickPhotoAndVideoAction(BuildContext context) {
    return (SimpleContextMenuActionBuilder(
            const Key('pick_photo_and_video_context_menu_action'),
            SvgPicture.asset(imagePaths.icPhotoLibrary, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).photos_and_videos)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.media)))
      .build();
  }

  Widget _browseFileAction(BuildContext context) {
    return (SimpleContextMenuActionBuilder(
            const Key('browse_file_context_menu_action'),
            SvgPicture.asset(imagePaths.icMore, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).browse)
        ..onActionClick((_) => controller.openFilePickerByType(context, FileType.any)))
      .build();
  }

  Widget _buildBodyMobile(BuildContext context) {
    return SingleChildScrollView(
      controller: controller.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          _buildHeaderEditorMobile(context),
          _buildComposerEditor(context),
          SizedBox(height: controller.maxKeyBoardHeight),
        ],
      ),
    );
  }

  Widget _buildHeaderEditorMobile(BuildContext context) {
    return Column(
      key: controller.headerEditorMobileWidgetKey,
      children: [
        buildFromEmailAddress(context),
        buildDivider(),
        buildEmailAddress(context),
        buildDivider(),
        buildSubjectEmail(context),
        buildDivider(),
        buildAttachmentsWidget(context),
        buildInlineLoadingView(controller),
      ],
    );
  }

  Widget _buildBodyTablet(BuildContext context) {
    return SingleChildScrollView(
        controller: controller.scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: (AvatarBuilder()
                  ..text(controller.mailboxDashBoardController.userProfile.value?.getAvatarText() ?? '')
                  ..size(56)
                  ..addTextStyle(const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: Colors.white
                  ))
                  ..backgroundColor(AppColor.colorAvatar)
                ).build()
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(children: [
                buildFromEmailAddress(context),
                buildDivider(),
                buildEmailAddress(context),
                buildDivider(),
                buildSubjectEmail(context),
              ]))
          ]),
          buildDivider(),
          buildAttachmentsWidget(context),
          buildInlineLoadingView(controller),
          _buildComposerEditor(context),
        ])
    );
  }

  Widget _buildComposerEditor(BuildContext context) {
    return Obx(() {
      final argsComposer = controller.composerArguments.value;

      if (argsComposer == null) {
        return const SizedBox.shrink();
      }

      switch(argsComposer.emailActionType) {
        case EmailActionType.compose:
        case EmailActionType.composeFromEmailAddress:
          return _buildHtmlEditor(context, initialContent: HtmlExtension.editorStartTags);
        case EmailActionType.edit:
          return controller.emailContentsViewState.value.fold(
            (failure) => _buildHtmlEditor(context, initialContent: HtmlExtension.editorStartTags),
            (success) {
                if (success is GetEmailContentLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: loadingWidget,
                  );
                } else if (success is GetEmailContentSuccess) {
                  var contentHtml = success.emailContent;
                  if (contentHtml.isEmpty == true) {
                    contentHtml = HtmlExtension.editorStartTags;
                  }
                  return _buildHtmlEditor(context, initialContent: contentHtml);
                } else {
                  return _buildHtmlEditor(context, initialContent: HtmlExtension.editorStartTags);
                }
              });
        case EmailActionType.reply:
        case EmailActionType.replyAll:
        case EmailActionType.forward:
          var contentHtml = controller.getEmailContentQuotedAsHtml(
              context,
              argsComposer);
          if (contentHtml.isEmpty == true) {
            contentHtml = HtmlExtension.editorStartTags;
          }
          return _buildHtmlEditor(context, initialContent: contentHtml);
        default:
          return _buildHtmlEditor(context, initialContent: HtmlExtension.editorStartTags);
      }
    });
  }

  Widget _buildHtmlEditor(BuildContext context, {String? initialContent}) {
    return GestureDetector(
      onTapDown: (_) {
        controller.removeFocusAllInputEditorHeader();
      },
      child: Padding(
        padding: ComposerStyle.getEditorPadding(context, responsiveUtils),
        child: HtmlEditor(
          key: const Key('composer_editor'),
          minHeight: 550,
          addDefaultSelectionMenuItems: false,
          initialContent: initialContent ?? '',
          customStyleCss: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils.getCurrentDirection(context)),
          onCreated: (editorApi) => controller.initRichTextForMobile(context, editorApi, initialContent)
        ),
      ),
    );
  }
}