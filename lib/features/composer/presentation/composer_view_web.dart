import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/base_composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/email_editor_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class ComposerView extends BaseComposerView {

  ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: LayoutBuilder(builder: (context, constraints) {
            return PointerInterceptor(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAppBar(context),
                buildDivider(),
                buildFromEmailAddress(context),
                buildDivider(),
                _buildEmailAddressWeb(context, constraints),
                buildDivider(),
                buildSubjectEmail(context),
                buildDivider(),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  child: _buildListButton(context, constraints)
                ),
                buildDivider(),
                buildAttachmentsWidget(context),
                ToolbarRichTextWebBuilder(
                  richTextWebController: controller.richTextWebController,
                  padding: ComposerStyle.getRichTextButtonPadding(context, responsiveUtils),
                ),
                buildInlineLoadingView(controller),
                Expanded(child: _buildEditorForm(context))
              ]
            ));
          })
        )
      ),
      desktop: Obx(() {
        return Stack(children: [
          if (controller.screenDisplayMode.value == ScreenDisplayMode.normal)
            PositionedDirectional(end: 5, bottom: 5, child: Card(
              elevation: 20,
              color: Colors.transparent,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
                width: responsiveUtils.getSizeScreenWidth(context) * 0.5,
                height: responsiveUtils.getSizeScreenHeight(context) * 0.75,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(ComposerStyle.radius)),
                  child: LayoutBuilder(builder: (context, constraints) =>
                    PointerInterceptor(child: _buildBodyForDesktop(context, constraints))
                  )
                )
              )
            )),
          if (controller.screenDisplayMode.value == ScreenDisplayMode.minimize)
            PositionedDirectional(end: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
                  width: 500,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: PointerInterceptor(child: Row(children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 10),
                        child: buildIconWeb(
                          icon: SvgPicture.asset(imagePaths.icCloseMailbox, fit: BoxFit.fill),
                          tooltip: AppLocalizations.of(context).saveAndClose,
                          onTap: () => controller.saveEmailAsDrafts(context)
                        )),
                      buildIconWeb(
                        icon: SvgPicture.asset(imagePaths.icFullScreenComposer, fit: BoxFit.fill),
                        tooltip: AppLocalizations.of(context).fullscreen,
                        onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.fullScreen)),
                      buildIconWeb(
                        icon: SvgPicture.asset(imagePaths.icChevronUp, fit: BoxFit.fill),
                        tooltip: AppLocalizations.of(context).show,
                        onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.normal)),
                      Expanded(child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16, end: 80),
                        child: buildTitleComposer(context),
                      )),
                    ]))
                  )
                )
              )),
          if (controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen)
            Scaffold(
                backgroundColor: Colors.black38,
                body: Align(alignment: Alignment.center, child: Card(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
                    child: Container(
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
                        width: responsiveUtils.getSizeScreenWidth(context) * 0.85,
                        height: responsiveUtils.getSizeScreenHeight(context) * 0.9,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(ComposerStyle.radius)),
                            child: LayoutBuilder(builder: (context, constraints) =>
                                PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                        )
                    )
                )
                )
            )
        ]);
      }),
      tablet: Scaffold(
        backgroundColor: Colors.black38,
        body: Center(
          child: Card(
            elevation: 20,
            margin: ComposerStyle.getMarginForTabletWeb(context, responsiveUtils),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(ComposerStyle.radius))),
              width: ComposerStyle.getWidthForTabletWeb(context, responsiveUtils),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(ComposerStyle.radius)),
                child: LayoutBuilder(builder: (context, constraints) => PointerInterceptor(
                  child: _buildBodyForDesktop(
                    context,
                    constraints
                  )
                ))
              )
            )
          )
        )
      )
    );
  }

  Widget _buildAppBarDesktop(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 32),
      child: Row(
        children: [
          buildIconWeb(
            minSize: 40,
            iconPadding: EdgeInsets.zero,
            icon: SvgPicture.asset(imagePaths.icCloseMailbox, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).saveAndClose,
            onTap: () => controller.saveEmailAsDrafts(context)
          ),
          if (responsiveUtils.isDesktop(context))
            ...[
              Obx(() => buildIconWeb(
                minSize: 40,
                iconPadding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen
                    ? imagePaths.icFullScreenExit
                    : imagePaths.icFullScreenComposer,
                  fit: BoxFit.fill
                ),
                tooltip: AppLocalizations.of(context).fullscreen,
                onTap: () => controller.displayScreenTypeComposerAction(
                  controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen
                    ? ScreenDisplayMode.normal
                    : ScreenDisplayMode.fullScreen
                )
              )),
              buildIconWeb(
                minSize: 40,
                iconPadding: EdgeInsets.zero,
                icon: SvgPicture.asset(imagePaths.icMinimize, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).minimize,
                onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.minimize)
              ),
            ],
          Expanded(child: buildTitleComposer(context)),
          const SizedBox(width: 120),
        ]
      ),
    );
  }

  @override
  List<PopupMenuEntry> popUpMoreActionMenu(BuildContext context) {
    return [
      PopupMenuItem(
        padding: const EdgeInsets.symmetric(horizontal: 8), 
        child: PointerInterceptor(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Obx(() => buildIconWeb(
                  icon: Icon(controller.hasRequestReadReceipt.value ? Icons.done : null, color: Colors.black))), 
                Expanded(
                  child: InkResponse(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).requestReadReceipt,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                          )
                      ),
                    ),
                  ),
                ),
              ]),
          ),
        ),
        onTap: () {
          controller.toggleRequestReadReceipt();
        },
      )
    ];
  }

  Widget _buildBottomBarDesktop(BuildContext context, BoxConstraints constraints) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: constraints.widthConstraints(),
            child: buildBottomBar(context),
          ),
        ),
      );
  }

  Widget _buildBodyForDesktop(BuildContext context, BoxConstraints constraints) {
    return Column(children: [
        _buildAppBarDesktop(context),
        buildDivider(),
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
              _buildEmailAddressWeb(context, constraints),
              buildDivider(),
              buildSubjectEmail(context),
              buildDivider(),
              _buildListButton(context, constraints),
            ]))
          ]
        ),
        buildDivider(),
        buildAttachmentsWidget(context),
        ToolbarRichTextWebBuilder(
          richTextWebController: controller.richTextWebController,
          padding: ComposerStyle.getRichTextButtonPadding(context, responsiveUtils),
        ),
        buildInlineLoadingView(controller),
        Expanded(child: _buildEditorForm(context)),
        buildDivider(),
        _buildBottomBarDesktop(context, constraints),
    ]);
  }

  Widget _buildEmailAddressWeb(BuildContext context, BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ComposerStyle.getMaxHeightEmailAddressWidget(context, constraints, responsiveUtils)),
      child: SingleChildScrollView(
        controller: controller.scrollControllerEmailAddress,
        child: buildEmailAddress(context),
      )
    );
  }

  Widget _buildListButton(BuildContext context, BoxConstraints constraints) {
    return  Transform(
      transform: Matrix4.translationValues(
        DirectionUtils.isDirectionRTLByLanguage(context) ? 0.0 : -5.0,
        0.0,
        0.0
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          buildIconWeb(
            minSize: 40,
            iconPadding: EdgeInsets.zero,
            icon: SvgPicture.asset(imagePaths.icAttachmentsComposer,
              width: 24,
              height: 24,
              colorFilter: AppColor.colorTextButton.asFilter(),
              fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).attach_file,
            onTap: () => controller.openFilePickerByType(context, FileType.any)
          ),
          const SizedBox(width: 4),
          Obx(() {
            final opacity = controller.richTextWebController.codeViewEnabled ? 0.5 : 1.0;
            return AbsorbPointer(
              absorbing: controller.richTextWebController.codeViewEnabled,
              child: buildIconWeb(
                minSize: 40,
                iconPadding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  imagePaths.icInsertImage,
                  colorFilter: AppColor.colorTextButton.withOpacity(opacity).asFilter(),
                  fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).insertImage,
                onTap: () => controller.insertImage(context, constraints.maxWidth)
              ),
            );
          }),
          const SizedBox(width: 4),
          Obx(() {
            return buildIconWeb(
              minSize: 40,
              colorSelected: controller.richTextWebController.codeViewEnabled
                ? AppColor.colorSelectedRichTextButton
                : Colors.transparent,
              iconPadding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                imagePaths.icStyleCodeView,
                colorFilter: AppColor.colorTextButton.asFilter(),
                fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).codeView,
              onTap: controller.richTextWebController.toggleCodeView);
          }),
        ])
      )
    );
  }

  Widget _buildEditorForm(BuildContext context) {
    return Obx(() {
      final argsComposer = controller.composerArguments.value;

      if (argsComposer == null) {
        return const SizedBox.shrink();
      }

      final currentTextEditor = controller.textEditorWeb;

      switch(argsComposer.emailActionType) {
        case EmailActionType.compose:
        case EmailActionType.composeFromEmailAddress:
          return _buildHtmlEditor(
              context,
              currentTextEditor ?? HtmlExtension.editorStartTags);
        case EmailActionType.edit:
          return controller.emailContentsViewState.value.fold(
            (failure) => _buildHtmlEditor(
                context,
                currentTextEditor ?? HtmlExtension.editorStartTags),
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
                return _buildHtmlEditor(context, currentTextEditor ?? contentHtml);
              } else {
                return _buildHtmlEditor(
                  context,
                  currentTextEditor ?? HtmlExtension.editorStartTags);
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
          return _buildHtmlEditor(context, currentTextEditor ?? contentHtml);
        default:
          return _buildHtmlEditor(
              context,
              currentTextEditor ?? HtmlExtension.editorStartTags);
      }
    });
  }

  Widget _buildHtmlEditor(BuildContext context, String initContent) {
    return Padding(
      padding: ComposerStyle.getEditorPadding(context, responsiveUtils),
      child: EmailEditorWidget(
        controller: controller,
        content: initContent,
        direction: AppUtils.getCurrentDirection(context),
      ),
    );
  }
}