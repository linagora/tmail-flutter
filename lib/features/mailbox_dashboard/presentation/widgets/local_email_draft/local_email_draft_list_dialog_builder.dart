import 'dart:ui';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_local_email_draft_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/local_email_draft/local_email_draft_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LocalEmailDraftListDialogBuilder extends StatefulWidget {
  final AccountId? accountId;
  final UserName? userName;
  final List<PresentationLocalEmailDraft> presentationLocalEmailDrafts;
  final OnEditLocalEmailDraftAction? onEditLocalEmailDraftAction;
  final OnSaveAsDraftLocalEmailDraftAction? onSaveAsDraftLocalEmailDraftAction;

  const LocalEmailDraftListDialogBuilder({
    super.key,
    required this.accountId,
    required this.userName,
    required this.presentationLocalEmailDrafts,
    this.onEditLocalEmailDraftAction,
    this.onSaveAsDraftLocalEmailDraftAction,
  });

  @override
  State<LocalEmailDraftListDialogBuilder> createState() =>
      _LocalEmailDraftListDialogBuilderState();
}

class _LocalEmailDraftListDialogBuilderState
    extends State<LocalEmailDraftListDialogBuilder> {
  static const double _maxHeight = 656.0;
  static const double _maxWidth = 556.0;

  late final ResponsiveUtils _responsiveUtils;
  late final ImagePaths _imagePaths;
  late final ScrollController _scrollController;
  late final RemoveLocalEmailDraftInteractor? _removeLocalEmailDraftInteractor;

  final ValueNotifier<List<PresentationLocalEmailDraft>> _listLocalEmailDraftsNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _responsiveUtils = Get.find<ResponsiveUtils>();
    _imagePaths = Get.find<ImagePaths>();
    _removeLocalEmailDraftInteractor = getBinding<RemoveLocalEmailDraftInteractor>();
    _scrollController = ScrollController();
    _listLocalEmailDraftsNotifier.value = widget.presentationLocalEmailDrafts;
  }

  @override
  void dispose() {
    _listLocalEmailDraftsNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(context),
      ),
      insetPadding: _getMargin(context),
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _getBorderRadius(context),
        ),
        width: _getWidth(context),
        height: _getHeight(context),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).localDraftList,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.black),
                    ),
                  ),
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icComposerClose,
                    backgroundColor: Colors.transparent,
                    margin: const EdgeInsetsDirectional.only(end: 12),
                    onTapActionCallback: popBack,
                  )
                ],
              ),
            ),
            const Divider(color: AppColor.colorDivider, height: 1),
            Expanded(
              child: ScrollbarListView(
                scrollBehavior: ScrollConfiguration.of(context).copyWith(
                  physics: const BouncingScrollPhysics(),
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad
                  },
                  scrollbars: false,
                ),
                scrollController: _scrollController,
                child: ValueListenableBuilder(
                  valueListenable: _listLocalEmailDraftsNotifier,
                  builder: (context, localDrafts, _) {
                    log('_LocalEmailDraftListDialogBuilderState::build:_listLocalEmailDraftsNotifier:localDrafts = ${localDrafts.length}');
                    return ListView.builder(
                      itemCount: localDrafts.length,
                      shrinkWrap: true,
                      controller: _scrollController,
                      primary: false,
                      itemBuilder: (_, index) {
                        final draftLocal = localDrafts[index];
                        return LocalEmailDraftItemWidget(
                            draftLocal: draftLocal,
                            isOldest: index == localDrafts.length - 1,
                            imagePaths: _imagePaths,
                            onSelectLocalEmailDraftAction: widget.onEditLocalEmailDraftAction,
                            onEditLocalEmailDraftAction: widget.onEditLocalEmailDraftAction,
                            onSaveAsDraftLocalEmailDraftAction: widget.onSaveAsDraftLocalEmailDraftAction,
                            onDiscardLocalEmailDraftAction: (draftLocal) =>
                                _handleDiscardLocalEmailDraftAction(
                                  draftLocal,
                                  AppLocalizations.of(context),
                                )
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const Divider(color: AppColor.colorDivider, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Spacer(),
                  TMailButtonWidget(
                    text: AppLocalizations.of(context).discardAll,
                    backgroundColor: AppColor.grayBackgroundColor,
                    maxLines: 1,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColor.steelGray600),
                    borderRadius: 10,
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTapActionCallback: () {},
                  ),
                  TMailButtonWidget(
                    text: AppLocalizations.of(context).openAll,
                    backgroundColor: AppColor.blue700,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                    maxLines: 1,
                    borderRadius: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTapActionCallback: () {},
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  EdgeInsets _getMargin(BuildContext context) {
    if (_responsiveUtils.isMobile(context)) {
      return EdgeInsets.zero;
    } else {
      if (_responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
        return const EdgeInsets.symmetric(vertical: 12);
      } else {
        return const EdgeInsets.symmetric(vertical: 50);
      }
    }
  }

  BorderRadius _getBorderRadius(BuildContext context) {
    if (_responsiveUtils.isMobile(context)) {
      return const BorderRadius.only(
        topRight: Radius.circular(16),
        topLeft: Radius.circular(16),
      );
    } else {
      return const BorderRadius.all(Radius.circular(16));
    }
  }

  double _getWidth(BuildContext context) {
    if (_responsiveUtils.isMobile(context)) {
      return double.infinity;
    } else {
      return _maxWidth;
    }
  }

  double _getHeight(BuildContext context) {
    if (!_responsiveUtils.isMobile(context) &&
        _responsiveUtils.getSizeScreenHeight(context) > _maxHeight) {
      return _maxHeight;
    } else {
      return double.infinity;
    }
  }

  void _handleDiscardLocalEmailDraftAction(
    PresentationLocalEmailDraft emailDraft,
    AppLocalizations appLocalizations,
  ) {
    Get.dialog(
      PointerInterceptor(child: ConfirmationDialogBuilder(
        imagePath: _imagePaths,
        useIconAsBasicLogo: true,
        textContent: appLocalizations.messageWarningDialogDiscardLocalDraft,
        confirmText: appLocalizations.yes,
        cancelText: appLocalizations.no,
        cancelBackgroundButtonColor: AppColor.blue700,
        cancelLabelButtonColor: Colors.white,
        confirmBackgroundButtonColor: AppColor.grayBackgroundColor,
        confirmLabelButtonColor: AppColor.steelGray600,
        onConfirmButtonAction: () => removeLocalEmailDraft(emailDraft.id),
        onCancelButtonAction: popBack,
        onCloseButtonAction: popBack,
      )),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  void removeLocalEmailDraft(String draftLocalId) {
    log('_LocalEmailDraftListDialogBuilderState::removeLocalEmailDraft:draftLocalId = $draftLocalId');
    popBack();

    _listLocalEmailDraftsNotifier.value = List.from(_listLocalEmailDraftsNotifier.value)
      ..removeWhere((draftLocal) => draftLocal.id == draftLocalId);

    _removeLocalEmailDraftInteractor?.execute(draftLocalId);
  }
}
