
import 'dart:async';

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';
import 'package:tmail_ui_user/features/email/data/datasource/mdn_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/send_receipt_to_sender_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/mdn_repository.dart';

class MdnRepositoryImpl extends MdnRepository {

  final MdnDataSource _dataSource;

  MdnRepositoryImpl(this._dataSource);

  @override
  Future<MDN?> sendReceiptToSender(AccountId accountId, SendReceiptToSenderRequest request) {
    return _dataSource.sendReceiptToSender(accountId, request);
  }
}