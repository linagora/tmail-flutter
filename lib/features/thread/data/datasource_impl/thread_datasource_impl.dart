import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';

class ThreadDataSourceImpl extends ThreadDataSource {

  final ThreadAPI threadAPI;

  ThreadDataSourceImpl(this.threadAPI);

  @override
  Future<List<Email>> getAllEmail(
    AccountId accountId,
    {
      int? position,
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) {
    return Future.sync(() async {
      return await threadAPI.getAllEmail(
        accountId,
        position: position,
        limit: limit,
        sort: sort,
        filter: filter,
        properties: properties);
    }).catchError((error) {
      throw error;
    });
  }
}