import 'package:model/account/account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

extension AccountExtensions on Account {
  AccountCache toCache() {
    return AccountCache(id, authenticationType.asString(), isSelected: isSelected);
  }
}