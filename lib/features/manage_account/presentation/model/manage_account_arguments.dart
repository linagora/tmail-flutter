import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

class ManageAccountArguments with EquatableMixin {

  final Session? session;
  final AccountMenuItem? menuSettingCurrent;
  final Uri? previousUri;
  final Quota? quota;

  ManageAccountArguments(
    this.session,
    {
      this.menuSettingCurrent,
      this.previousUri,
      this.quota,
    }
  );

  @override
  List<Object?> get props => [
    session,
    menuSettingCurrent,
    previousUri,
    quota,
  ];
}