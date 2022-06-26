import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedFilterController extends BaseController {

  final dateFilterSelectedFormAdvancedSearch = EmailReceiveTimeType.allTime.obs;
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
    dateFilterSelectedFormAdvancedSearch.value = EmailReceiveTimeType.allTime;
    fromFilterInputController.text = '';
    toFilterInputController.text = '';
    subjectFilterInputController.text = '';
    hasKeyWordFilterInputController.text = '';
    notKeyWordFilterInputController.text = '';
    dateFilterInputController.text = '';
    hasAttachment.value = false;
    _searchController.isAdvancedSearchHasApply.isFalse;
    _searchController.isAdvancedSearchViewOpen.toggle();
  }

  void _updateFilterEmailFromAdvancedSearchView() {
    if (fromFilterInputController.text.isNotEmpty) {
      _searchController.updateFilterEmail(from: fromFilterInputController.text.split(',').toSet());
    }
    if (toFilterInputController.text.isNotEmpty) {
      _searchController.updateFilterEmail(to: toFilterInputController.text.split(',').toSet());
    }

    _searchController.updateFilterEmail(
      subject: StringConvert.writeEmptyToNull(subjectFilterInputController.text),
      hasKeyword: Wrapped.value(
          StringConvert.writeEmptyToNull(hasKeyWordFilterInputController.text)),
      notKeyword: Wrapped.value(
          StringConvert.writeEmptyToNull(notKeyWordFilterInputController.text)),
      emailReceiveTimeType: dateFilterSelectedFormAdvancedSearch.value,
      hasAttachment: hasAttachment.value,
    );
  }

  Future<void> selectedMailBox() async{
      final PresentationMailbox destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(_mailboxDashBoardController.accountId.value!, MailboxActions.moveEmail));
      _searchController.updateFilterEmail(mailbox: destinationMailbox);
      mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(destinationMailbox.name?.name);
    }

  applyAdvancedSearchFilter(BuildContext context){
    _updateFilterEmailFromAdvancedSearchView();
    _mailboxDashBoardController.searchEmail(context, StringConvert.writeNullToEmpty(_searchEmailFilter.text?.value));
    _searchController.isAdvancedSearchViewOpen.toggle();
    _searchController.isAdvancedSearchHasApply.value = _checkAdvancedSearchHasApply();
  }

 bool _checkAdvancedSearchHasApply() {
    return fromFilterInputController.text.isNotEmpty ||
        toFilterInputController.text.isNotEmpty ||
        subjectFilterInputController.text.isNotEmpty ||
        hasKeyWordFilterInputController.text.isNotEmpty ||
        notKeyWordFilterInputController.text.isNotEmpty ||
        dateFilterInputController.text.isNotEmpty ||
        mailBoxFilterInputController.text.isNotEmpty ||
        hasAttachment.isFalse;
  }

  initSearchFilterField(BuildContext context) {
    _searchController.updateFilterEmail(mailbox: _mailboxDashBoardController.selectedMailbox.value);
    fromFilterInputController.text = StringConvert.writeNullToEmpty(_searchController.searchEmailFilter.value.from.firstOrNull);
    toFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.to.firstOrNull);
    subjectFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.subject);
    hasKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.hasKeyword);
    notKeyWordFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.notKeyword);
    dateFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.emailReceiveTimeType.getTitle(context));
    mailBoxFilterInputController.text = StringConvert.writeNullToEmpty(_searchEmailFilter.mailbox?.name?.name);
    dateFilterSelectedFormAdvancedSearch.value = _searchEmailFilter.emailReceiveTimeType;
    hasAttachment.value = _searchEmailFilter.hasAttachment;
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {
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
