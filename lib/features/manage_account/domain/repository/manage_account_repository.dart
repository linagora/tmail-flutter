import 'dart:ui';

import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_email_rule_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';

abstract class ManageAccountRepository {
  Future<void> persistLanguage(Locale localeCurrent);

  Future<List<TMailRule>> getAllTMailRule(AccountId accountId);

  Future<List<TMailRule>> deleteTMailRule(AccountId accountId, DeleteEmailRuleRequest deleteEmailRuleRequest);

  Future<List<TMailRule>> createNewEmailRuleFilter(AccountId accountId, CreateNewEmailRuleFilterRequest ruleFilterRequest);

  Future<List<TMailRule>> editEmailRuleFilter(AccountId accountId, EditEmailRuleFilterRequest ruleFilterRequest);

  Future<TMailForward> getForward(AccountId accountId);

  Future<TMailForward> deleteRecipientInForwarding(AccountId accountId, DeleteRecipientInForwardingRequest deleteRequest);

  Future<TMailForward> addRecipientsInForwarding(AccountId accountId, AddRecipientInForwardingRequest addRequest);

  Future<TMailForward> editLocalCopyInForwarding(AccountId accountId, EditLocalCopyInForwardingRequest editRequest);
}