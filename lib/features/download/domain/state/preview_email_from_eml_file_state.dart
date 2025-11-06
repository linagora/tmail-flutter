import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PreviewingEmailFromEmlFile extends LoadingState {}

class PreviewEmailFromEmlFileSuccess extends UIState {
  final EMLPreviewer emlPreviewer;
  final AccountId accountId;
  final Session session;
  final String ownEmailAddress;
  final AppLocalizations appLocalizations;

  PreviewEmailFromEmlFileSuccess(
    this.emlPreviewer,
    this.accountId,
    this.session,
    this.ownEmailAddress,
    this.appLocalizations,
  );

  @override
  List<Object?> get props => [
        emlPreviewer,
        accountId,
        session,
        ownEmailAddress,
        appLocalizations,
      ];
}

class PreviewEmailFromEmlFileFailure extends FeatureFailure {
  PreviewEmailFromEmlFileFailure(dynamic exception)
      : super(exception: exception);
}
