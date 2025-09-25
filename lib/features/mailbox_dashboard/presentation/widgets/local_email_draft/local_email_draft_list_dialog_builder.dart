import 'dart:ui';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/handle_message_failure_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/saving_message_dialog_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_local_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_local_email_draft_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/local_email_draft/local_email_draft_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnRestoreAllLocalEmailDraftsAction = Function(List<PresentationLocalEmailDraft>);

class LocalEmailDraftListDialogBuilder extends StatefulWidget {
  final AccountId? accountId;
  final Session? session;
  final String ownEmailAddress;
  final List<PresentationLocalEmailDraft> presentationLocalEmailDrafts;
  final OnEditLocalEmailDraftAction? onEditLocalEmailDraftAction;
  final OnRestoreAllLocalEmailDraftsAction? onRestoreAllLocalEmailDraftsAction;

  const LocalEmailDraftListDialogBuilder({
    super.key,
    required this.accountId,
    required this.session,
    required this.ownEmailAddress,
    required this.presentationLocalEmailDrafts,
    this.onEditLocalEmailDraftAction,
    this.onRestoreAllLocalEmailDraftsAction,
  });

  @override
  State<LocalEmailDraftListDialogBuilder> createState() =>
      _LocalEmailDraftListDialogBuilderState();
}

class _LocalEmailDraftListDialogBuilderState
    extends State<LocalEmailDraftListDialogBuilder>
    with HandleMessageFailureMixin {
  static const double _maxHeight = 656.0;
  static const double _maxWidth = 556.0;

  late final ResponsiveUtils _responsiveUtils;
  late final ImagePaths _imagePaths;
  late final AppToast _appToast;
  late final ScrollController _scrollController;
  late final RemoveLocalEmailDraftInteractor? _removeLocalEmailDraftInteractor;
  late final CreateNewAndSaveEmailToDraftsInteractor? _createNewAndSaveEmailToDraftsInteractor;
  late final RemoveAllLocalEmailDraftsInteractor? _removeAllLocalEmailDraftsInteractor;

  final ValueNotifier<List<PresentationLocalEmailDraft>> _listLocalEmailDraftsNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _responsiveUtils = Get.find<ResponsiveUtils>();
    _imagePaths = Get.find<ImagePaths>();
    _appToast = Get.find<AppToast>();
    _removeLocalEmailDraftInteractor = getBinding<RemoveLocalEmailDraftInteractor>();
    _createNewAndSaveEmailToDraftsInteractor = getBinding<CreateNewAndSaveEmailToDraftsInteractor>();
    _removeAllLocalEmailDraftsInteractor = getBinding<RemoveAllLocalEmailDraftsInteractor>();
    _scrollController = ScrollController();
    _listLocalEmailDraftsNotifier.value = widget.presentationLocalEmailDrafts;
  }

  @override
  void dispose() {
    _listLocalEmailDraftsNotifier.dispose();
    _scrollController.dispose();
    if (SmartDialog.checkExist()) SmartDialog.dismiss();
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
                            onSaveAsDraftLocalEmailDraftAction: (draftLocal) =>
                                _saveAsDraftLocalEmailDraft(draftLocal, context),
                            onDiscardLocalEmailDraftAction: (draftLocal) =>
                                _handleDiscardLocalEmailDraftAction(draftLocal, context)
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
                    onTapActionCallback: () => _handleDiscardAllLocalEmailDraftAction(context),
                  ),
                  TMailButtonWidget(
                    text: AppLocalizations.of(context).restoreAll,
                    backgroundColor: AppColor.blue700,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                    maxLines: 1,
                    borderRadius: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTapActionCallback: () =>
                      widget.onRestoreAllLocalEmailDraftsAction?.call(
                        _listLocalEmailDraftsNotifier.value,
                      ),
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
    BuildContext context,
  ) {
    final appLocalizations = AppLocalizations.of(context);
    MessageDialogActionManager().showConfirmDialogAction(
      context,
      appLocalizations.messageWarningDialogDiscardLocalDraft,
      appLocalizations.yes,
      cancelTitle: appLocalizations.no,
      onConfirmAction: () => _removeLocalEmailDraft(context, emailDraft.id),
      onCloseButtonAction: popBack,
    );
  }

  Future<void> _removeLocalEmailDraft(
    BuildContext context,
    String draftLocalId,
    {bool showToast = true}
  ) async {
    _listLocalEmailDraftsNotifier.value = List.from(_listLocalEmailDraftsNotifier.value)
      ..removeWhere((draftLocal) => draftLocal.id == draftLocalId);

    await _removeLocalEmailDraftInteractor?.execute(draftLocalId);

    if (showToast && context.mounted) {
      _appToast.showToastSuccessMessage(
        context,
        AppLocalizations.of(context).deleteLocalDraftSuccessfully,
      );
    }

    if (_listLocalEmailDraftsNotifier.value.isEmpty) {
      popBack();
    }
  }

  Future<void> _saveAsDraftLocalEmailDraft(
    PresentationLocalEmailDraft draftLocal,
    BuildContext context,
  ) async {
    if (widget.accountId == null ||
        widget.session == null ||
        _createNewAndSaveEmailToDraftsInteractor == null) {
      return;
    }

    final resultState = await _showSavingMessageToDraftsDialog(
      session: widget.session!,
      accountId: widget.accountId!,
      ownEmailAddress: widget.ownEmailAddress,
      draftLocal: draftLocal,
      createNewAndSaveEmailToDraftsInteractor: _createNewAndSaveEmailToDraftsInteractor!,
      cancelToken: CancelToken(),
    );

    if (!context.mounted) return;

    if (resultState is SaveEmailAsDraftsSuccess) {
      _appToast.showToastSuccessMessage(
        context,
        AppLocalizations.of(context).drafts_saved,
        leadingSVGIcon: _imagePaths.icMailboxDrafts,
        leadingSVGIconColor: Colors.white,
      );

      _removeLocalEmailDraft(context, draftLocal.id, showToast: false);
    } else if (resultState is SaveEmailAsDraftsFailure) {
      final errorMessage = getMessageFailure(
        appLocalizations: AppLocalizations.of(context),
        exception: resultState.exception,
        isDraft: true,
      );

      _appToast.showToastErrorMessage(
        context,
        errorMessage.message,
        leadingSVGIcon: _imagePaths.icMailboxDrafts,
        leadingSVGIconColor: Colors.white,
      );
    }
  }

  Future<dynamic> _showSavingMessageToDraftsDialog({
    required Session session,
    required AccountId accountId,
    required String ownEmailAddress,
    required PresentationLocalEmailDraft draftLocal,
    required CreateNewAndSaveEmailToDraftsInteractor createNewAndSaveEmailToDraftsInteractor,
    CancelToken? cancelToken,
  }) {
    final childWidget = PointerInterceptor(
      child: SavingMessageDialogView(
        createEmailRequest: CreateEmailRequest.fromLocalEmailDraft(
          session: session,
          accountId: accountId,
          ownEmailAddress: ownEmailAddress,
          draftLocal: draftLocal,
        ),
        createNewAndSaveEmailToDraftsInteractor: createNewAndSaveEmailToDraftsInteractor,
        onCancelSavingEmailToDraftsAction: _handleCancelSavingMessageToDrafts,
        cancelToken: cancelToken,
      ),
    );

    return Get.dialog(
      childWidget,
      barrierDismissible: false,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  void _handleCancelSavingMessageToDrafts({CancelToken? cancelToken}) {
    cancelToken?.cancel([SavingEmailToDraftsCanceledException()]);
  }

  void _handleDiscardAllLocalEmailDraftAction(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    MessageDialogActionManager().showConfirmDialogAction(
      context,
      appLocalizations.messageWarningDialogDiscardAllLocalDrafts,
      appLocalizations.yes,
      cancelTitle: appLocalizations.no,
      onConfirmAction: () => _removeAllLocalEmailDrafts(context),
      onCloseButtonAction: popBack,
    );
  }

  Future<void> _removeAllLocalEmailDrafts(BuildContext context) async {
    if (widget.accountId == null ||
        widget.session == null ||
        _removeAllLocalEmailDraftsInteractor == null) {
      return;
    }

    SmartDialog.showLoading(
      msg: AppLocalizations.of(context).deletingLocalDraft,
    );
    _listLocalEmailDraftsNotifier.value = [];

    await _removeAllLocalEmailDraftsInteractor!.execute(
      widget.accountId!,
      widget.session!.username,
    );

    if (context.mounted) {
      _appToast.showToastSuccessMessage(
        context,
        AppLocalizations.of(context).deleteAllLocalDraftsSuccessfully,
      );
    }

    SmartDialog.dismiss();
    popBack();
  }
}
