import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/reveal_experimental_preferences_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/bindings/preferences_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option_registry.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_options.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_options/drive_attachment_preference_option.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';

class PreferencesBindings extends Bindings {

  @override
  void dependencies() {
    PreferencesInteractorsBindings().dependencies();

    Get.lazyPut(() => GetLocalSettingsInteractor(
      Get.find<ManageAccountRepository>(),
    ));
    Get.lazyPut(() => UpdateLocalSettingsInteractor(
      Get.find<ManageAccountRepository>(),
    ));
    Get.lazyPut(() => RevealExperimentalPreferencesInteractor(
      Get.find<ManageAccountRepository>(),
    ));

    // The registry — registration order is the display order. Adding a
    // preference means adding one PreferenceOption here, nothing else.
    Get.lazyPut(() {
      final updateLocal = Get.find<UpdateLocalSettingsInteractor>();
      final updateServer = Get.find<UpdateServerSettingInteractor>();
      return PreferenceOptionRegistry([
        ReadReceiptPreferenceOption(updateServer),
        SenderPriorityPreferenceOption(updateServer),
        ThreadPreferenceOption(updateLocal),
        SpamReportPreferenceOption(updateLocal),
        AIScribePreferenceOption(updateLocal),
        AILabelCategorizationPreferenceOption(updateServer),
        LabelPreferenceOption(updateLocal),
        DriveAttachmentPreferenceOption(updateLocal),
      ]);
    });

    Get.lazyPut(() => PreferencesController(
      Get.find<GetServerSettingInteractor>(),
      Get.find<GetLocalSettingsInteractor>(),
      Get.find<PreferenceOptionRegistry>(),
      Get.find<RevealExperimentalPreferencesInteractor>(),
    ));
  }
}