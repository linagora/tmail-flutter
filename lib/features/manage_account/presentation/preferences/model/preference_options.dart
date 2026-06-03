import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

// --- Server-backed options ---

class ReadReceiptPreferenceOption extends ServerPreferenceOption {
  ReadReceiptPreferenceOption(super.updateServerSettingInteractor);

  @override
  String get id => 'read-receipt';

  @override
  String title(AppLocalizations l) => l.emailReadReceipts;

  @override
  String explanation(AppLocalizations l) => l.emailReadReceiptsSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.emailReadReceiptsToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.serverOptions?.isAlwaysReadReceipts ?? false;

  @override
  TMailServerSettingOptions applyTo(
    TMailServerSettingOptions current, {
    required bool enabled,
  }) =>
      current.copyWith(alwaysReadReceipts: enabled);
}

class SenderPriorityPreferenceOption extends ServerPreferenceOption {
  SenderPriorityPreferenceOption(super.updateServerSettingInteractor);

  @override
  String get id => 'sender-priority';

  @override
  String title(AppLocalizations l) => l.senderSetImportantFlag;

  @override
  String explanation(AppLocalizations l) => l.senderImportantSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.senderImportantSettingToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.serverOptions?.isDisplaySenderPriority ?? false;

  @override
  TMailServerSettingOptions applyTo(
    TMailServerSettingOptions current, {
    required bool enabled,
  }) =>
      current.copyWith(displaySenderPriority: enabled);
}

class AILabelCategorizationPreferenceOption extends ServerPreferenceOption {
  AILabelCategorizationPreferenceOption(super.updateServerSettingInteractor);

  @override
  String get id => 'ai-label-categorization';

  @override
  String title(AppLocalizations l) => l.aiLabelCategorization;

  @override
  String explanation(AppLocalizations l) => l.aiLabelCategorizationSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.aiLabelCategorizationToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.serverOptions?.isAILabelCategorizationEnabled ?? false;

  @override
  bool isAvailable(PreferencesContext context) =>
      context.serverOptions != null && context.isAICapabilitySupported;

  @override
  TMailServerSettingOptions applyTo(
    TMailServerSettingOptions current, {
    required bool enabled,
  }) =>
      current.copyWith(aiLabelCategorizationEnabled: enabled);
}

// --- Local-backed options ---

class ThreadPreferenceOption extends LocalPreferenceOption {
  ThreadPreferenceOption(super.updateLocalSettingsInteractor);

  @override
  String get id => 'thread';

  @override
  String title(AppLocalizations l) => l.thread;

  @override
  String explanation(AppLocalizations l) => l.threadSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.threadToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.localSettings.threadConfig.isEnabled;

  @override
  PreferencesConfig buildConfig({required bool enabled}) =>
      ThreadDetailConfig(isEnabled: enabled);
}

class SpamReportPreferenceOption extends LocalPreferenceOption {
  SpamReportPreferenceOption(super.updateLocalSettingsInteractor);

  @override
  String get id => 'spam-report';

  @override
  String title(AppLocalizations l) => l.spamReports;

  @override
  String explanation(AppLocalizations l) => l.spamReportsSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.spamReportToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.localSettings.spamReportConfig.isEnabled;

  @override
  PreferencesConfig buildConfig({required bool enabled}) =>
      SpamReportConfig(isEnabled: enabled);
}

class AIScribePreferenceOption extends LocalPreferenceOption {
  AIScribePreferenceOption(super.updateLocalSettingsInteractor);

  @override
  String get id => 'ai-scribe';

  @override
  String title(AppLocalizations l) => l.aiScribe;

  @override
  String explanation(AppLocalizations l) => l.aiScribeSettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.aiScribeToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.localSettings.aiScribeConfig.isEnabled;

  @override
  bool isAvailable(PreferencesContext context) =>
      context.localSettings.configs.isNotEmpty && context.isAIScribeAvailable;

  @override
  PreferencesConfig buildConfig({required bool enabled}) =>
      AIScribeConfig(isEnabled: enabled);
}

class LabelPreferenceOption extends LocalPreferenceOption {
  LabelPreferenceOption(super.updateLocalSettingsInteractor);

  @override
  String get id => 'label';

  @override
  String title(AppLocalizations l) => l.labelVisibility;

  @override
  String explanation(AppLocalizations l) => l.labelVisibilitySettingExplanation;

  @override
  String toggleDescription(AppLocalizations l) => l.labelVisibilityToggleDescription;

  @override
  bool isEnabled(PreferencesContext context) =>
      context.localSettings.labelConfig.isEnabled;

  @override
  bool isAvailable(PreferencesContext context) => context.isLabelVisibilityEnabled;

  @override
  PreferencesConfig buildConfig({required bool enabled}) =>
      LabelConfig(isEnabled: enabled);
}
