import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/drive_attachment_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

class DriveAttachmentPreferenceOption extends LocalPreferenceOption {
  DriveAttachmentPreferenceOption(super.updateLocalSettingsInteractor);

  @override
  String get id => 'drive-attachment';

  @override
  bool get isExperimental => true;

  @override
  String title(AppLocalizations l) => l.driveAttachment;

  @override
  String explanation(AppLocalizations l) => l.driveAttachmentSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.driveAttachmentToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.localSettings.driveAttachmentConfig.isEnabled;

  @override
  bool isAvailable(PreferencesContext context) {
    final enabled = appProviderContainer.read(driveAttachmentEnabledProvider);
    final fqdn = appProviderContainer.read(workplaceFqdnProvider);
    return enabled && fqdn != null && fqdn.isNotEmpty;
  }

  @override
  PreferencesConfig buildConfig({required bool enabled}) =>
      DriveAttachmentConfig(isEnabled: enabled);
}
