import 'package:core/core.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/load_more_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class ThreadController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final ResponsiveUtils responsiveUtils;

  final _properties = Properties({
    'id', 'subject', 'from', 'to', 'cc', 'bcc', 'keywords', 'receivedAt',
    'sentAt', 'preview', 'hasAttachment'
  });

  final emailList = <PresentationEmail>[].obs;
  final loadMoreState = LoadMoreState.IDLE.obs;

  int positionCurrent = 0;
  int lastGetTotal = 0;

  ThreadController(
    this.responsiveUtils,
    this._getEmailsInMailboxInteractor
  );

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.selectedMailbox.listen((selectedMailbox) {
      mailboxDashBoardController.setSelectedEmail(null);
      refreshGetAllEmailAction();
    });
  }

  @override
  void dispose() {
    super.dispose();
    mailboxDashBoardController.selectedMailbox.close();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) => _resetPositionCurrentAndLoadMoreState(),
      (success) => _updateEmailList(success is GetAllEmailSuccess ? success.emailList : [])
    );
  }

  @override
  void onError(error) {
    _resetPositionCurrentAndLoadMoreState();
  }

  void _updateEmailList(List<PresentationEmail> newListEmail) {
    emailList.value += newListEmail;

    lastGetTotal = emailList.length;

    loadMoreState.value = newListEmail.isEmpty ? LoadMoreState.COMPLETED : LoadMoreState.IDLE;
  }

  EmailFilterCondition? _getFilterConditionCurrent() {
    return EmailFilterCondition(inMailbox: mailboxDashBoardController.selectedMailbox.value?.id);
  }

  Set<Comparator>? _getSortCurrent() {
    return Set()
      ..add(EmailComparator(EmailComparatorProperty.sentAt)
        ..setIsAscending(false));
  }

  void _resetPositionCurrentAndLoadMoreState() {
    if (loadMoreState.value == LoadMoreState.LOADING) {
      positionCurrent -= lastGetTotal;
    }
    loadMoreState.value = LoadMoreState.IDLE;
  }

  void getAllEmailAction(AccountId accountId,
    {
      UnsignedInt? limit,
      int position = 0,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) async {
    consumeState(_getEmailsInMailboxInteractor.execute(
      accountId,
      limit: limit,
      position: position,
      sort: sort,
      filter: filter,
      properties: properties
    ));
  }

  void refreshGetAllEmailAction() {
    loadMoreState.value = LoadMoreState.IDLE;
    positionCurrent = 0;
    emailList.clear();

    final accountId = mailboxDashBoardController.accountId.value;

    if (accountId != null) {
      getAllEmailAction(
        accountId,
        limit: ThreadConstants.defaultLimit,
        position: positionCurrent,
        sort: _getSortCurrent(),
        properties: _properties,
        filter: _getFilterConditionCurrent());
    }
  }

  void loadMoreEmailAction() {
    loadMoreState.value = LoadMoreState.LOADING;
    positionCurrent += lastGetTotal;

    final accountId = mailboxDashBoardController.accountId.value;

    if (accountId != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        getAllEmailAction(
          accountId,
          limit: ThreadConstants.defaultLimit,
          position: positionCurrent,
          sort: _getSortCurrent(),
          properties: _properties,
          filter: _getFilterConditionCurrent());
      });
    }
  }

  SelectMode getSelectMode(PresentationEmail presentationEmail, PresentationEmail? selectedEmail) {
    return presentationEmail.id == selectedEmail?.id
      ? SelectMode.ACTIVE
      : SelectMode.INACTIVE;
  }

  void selectEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    mailboxDashBoardController.setSelectedEmail(presentationEmailSelected);
    if (!responsiveUtils.isDesktop(context)) {
      goToEmail(context);
    }
  }

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openDrawer();
  }

  void goToEmail(BuildContext context) {
    Get.toNamed(AppRoutes.EMAIL);
  }
}