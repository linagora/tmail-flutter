import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

class AdvancedFilterController extends BaseController {

  final dateFilterSelectedFormAdvancedSearch = EmailReceiveTimeType.allTime.obs;
  final mailboxFilterSelectedFormAdvancedSearch = Rxn<PresentationMailbox>();
  final hasAttachment = false.obs;

  TextEditingController fromFilterInputController = TextEditingController();
  TextEditingController toFilterInputController = TextEditingController();
  TextEditingController subjectFilterInputController = TextEditingController();
  TextEditingController hasKeyWordFilterInputController = TextEditingController();
  TextEditingController notKeyWordFilterInputController = TextEditingController();
  TextEditingController dateFilterInputController = TextEditingController();
  TextEditingController mailBoxFilterInputController = TextEditingController();

  final SearchController _searchController = Get.find<SearchController>();
  final MailboxDashBoardController _mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  SearchEmailFilter get _searchEmailFilter => _searchController.searchEmailFilter.value;

  selectOpenAdvanceSearch() {
    _searchController.isAdvancedSearchViewOpen.toggle();
  }

  cleanSearchFilter() {
    _searchController.cleanSearchFilter();
  }

  applyAdvancedSearchFilter(BuildContext context){
    _mailboxDashBoardController.searchEmail(context, StringConvert.writeNullToEmpty(_searchEmailFilter.text?.value));
  }

  initSearchFilterField(BuildContext context) {
    fromFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.from.firstOrNull);
    toFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.to.firstOrNull);
    subjectFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.subject);
    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.hasKeyword);
    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.notKeyword);
    dateFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.emailReceiveTimeType.getTitle(context));
    mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.mailbox?.name?.name);
    dateFilterSelectedFormAdvancedSearch.value = _searchEmailFilter.emailReceiveTimeType;
    mailboxFilterSelectedFormAdvancedSearch.value = _searchEmailFilter.mailbox;
    hasAttachment.value = _searchEmailFilter.hasAttachment;
  }

  @override
  void onInit() {
    super.onInit();
    // TODO: implement onDone
  }
  @override
  void onDone() {
    // TODO: implement onDone
  }

  @override
  void onError(error) {
    // TODO: implement onError
  }

  @override
  void onClose() {
    fromFilterInputController.dispose();
    subjectFilterInputController.dispose();
    toFilterInputController.dispose();
    hasKeyWordFilterInputController.dispose();
    notKeyWordFilterInputController.dispose();
    mailBoxFilterInputController.dispose();
    dateFilterInputController.dispose();
    super.onClose();
  }
}
