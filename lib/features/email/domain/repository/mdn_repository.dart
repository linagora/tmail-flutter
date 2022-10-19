import 'dart:async';

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';
import 'package:tmail_ui_user/features/email/domain/model/send_receipt_to_sender_request.dart';

abstract class MdnRepository {
  Future<MDN?> sendReceiptToSender(AccountId accountId, SendReceiptToSenderRequest request);
}