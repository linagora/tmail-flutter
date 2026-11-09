import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DelegationPreferenceOption extends LocalPreferenceOption {
  DelegationPreferenceOption(super.updateLocalSettingsInteractor);

  @override
  String get id => 'delegation';

  @override
  String title(AppLocalizations l) => l.delegation;

  @override
  String explanation(AppLocalizations l) => l.delegationSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.delegationToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.localSettings.delegationConfig.isEnabled;

  @override
  bool isAvailable(PreferencesContext context) =>
      super.isAvailable(context) && context.session?.supportsDelegation == true;

  @override
  bool get isExperimental => true;

  @override
  PreferencesConfig buildConfig({required bool enabled}) =>
      DelegationConfig(isEnabled: enabled);
}
