import 'dart:async';
import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:model/model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/transformers.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/mixin/ai_scribe_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/base/mixin/own_email_address_mixin.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/extensions/email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/compose_action_mode.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_sending_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_sending_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_restored_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/restore_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/unsubscribe_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_arguments.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/store_session_interactor.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/state/get_identity_cache_on_web_state.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/get_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/logout_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/clear_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_stored_email_sort_order_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_text_formatting_menu_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_stored_email_sort_order_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_text_formatting_menu_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_by_id_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_text_formatting_menu_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_email_sort_order_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/ai_scribe/setup_cached_ai_scribe_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/cleanup_recent_search_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/delete_emails_in_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_action_type_for_email_selection.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_clear_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_create_new_rule_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_preferences_setting_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_preview_attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_reactive_obx_variable_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_save_email_as_draft_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_store_email_sort_order_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/initialize_app_language.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/check_label_available_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/notify_thread_detail_setting_updated.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/reopen_composer_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/select_search_filter_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/set_error_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_text_formatting_menu_state_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/web_auth_redirect_processor_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/refresh_action_view_event.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailto/presentation/model/mailto_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_ai_scribe_config_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_ai_scribe_config_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_controller.dart';
import 'package:tmail_ui_user/features/paywall/presentation/saas_premium_mixin.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/web_socket_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/features/search/email/presentation/mixin/search_label_filter_modal_mixin.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/get_all_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/update_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_spam_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/ios_notification_manager.dart';
import 'package:uuid/uuid.dart';

class MailboxDashBoardController extends ReloadableController
    with ContactSupportMixin,
        OwnEmailAddressMixin,
        SaaSPremiumMixin,
        AiScribeMixin,
        SearchLabelFilterModalMixin {

  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final EmailReceiveManager _emailReceiveManager = Get.find<EmailReceiveManager>();
  final search.SearchController searchController = Get.find<search.SearchController>();
  final DownloadController downloadController = Get.find<DownloadController>();
  final AppGridDashboardController appGridDashboardController = Get.find<AppGridDashboardController>();
  final SpamReportController spamReportController = Get.find<SpamReportController>();
  final NetworkConnectionController networkConnectionController = Get.find<NetworkConnectionController>();
  final LabelController labelController = Get.find<LabelController>();
  final ComposerManager composerManager = Get.find<ComposerManager>();
  final getAuthenticationInfoInteractor =
      Get.find<GetAuthenticationInfoInteractor>();
  final getStoredOidcConfigurationInteractor =
      Get.find<GetStoredOidcConfigurationInteractor>();
  final getTokenOIDCInteractor = Get.find<GetTokenOIDCInteractor>();

  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final DeleteEmailPermanentlyInteractor _deleteEmailPermanentlyInteractor;
  final MarkAsMailboxReadInteractor _markAsMailboxReadInteractor;
  final GetComposerCacheOnWebInteractor _getEmailCacheOnWebInteractor;
  final GetIdentityCacheOnWebInteractor _getIdentityCacheOnWebInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final MarkAsMultipleEmailReadInteractor _markAsMultipleEmailReadInteractor;
  final MarkAsStarMultipleEmailInteractor _markAsStarMultipleEmailInteractor;
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final EmptyTrashFolderInteractor _emptyTrashFolderInteractor;
  final DeleteMultipleEmailsPermanentlyInteractor _deleteMultipleEmailsPermanentlyInteractor;
  final GetEmailByIdInteractor _getEmailByIdInteractor;
  final SendEmailInteractor _sendEmailInteractor;
  final StoreSendingEmailInteractor _storeSendingEmailInteractor;
  final UpdateSendingEmailInteractor _updateSendingEmailInteractor;
  final GetAllSendingEmailInteractor _getAllSendingEmailInteractor;
  final StoreSessionInteractor _storeSessionInteractor;
  final EmptySpamFolderInteractor _emptySpamFolderInteractor;
  final DeleteSendingEmailInteractor _deleteSendingEmailInteractor;
  final UnsubscribeEmailInteractor _unsubscribeEmailInteractor;
  final RestoredDeletedMessageInteractor _restoreDeletedMessageInteractor;
  final GetRestoredDeletedMessageInterator _getRestoredDeletedMessageInteractor;
  final RemoveComposerCacheByIdOnWebInteractor _removeComposerCacheByIdOnWebInteractor;
  final RemoveAllComposerCacheOnWebInteractor _removeAllComposerCacheOnWebInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final ClearMailboxInteractor clearMailboxInteractor;
  final StoreEmailSortOrderInteractor storeEmailSortOrderInteractor;
  final GetStoredEmailSortOrderInteractor getStoredEmailSortOrderInteractor;

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  IOSNotificationManager? _iosNotificationManager;
  GetServerSettingInteractor? getServerSettingInteractor;
  CreateNewEmailRuleFilterInteractor? createNewEmailRuleFilterInteractor;
  SaveLanguageInteractor? saveLanguageInteractor;
  GetTextFormattingMenuStateInteractor? getTextFormattingMenuStateInteractor;
  SaveTextFormattingMenuStateInteractor? saveTextFormattingMenuStateInteractor;
  GetAIScribeConfigInteractor? getAIScribeConfigInteractor;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final dashBoardAction = Rxn<UIAction>();
  final mailboxUIAction = Rxn<MailboxUIAction>();
  final emailUIAction = Rxn<EmailUIAction>();
  final threadDetailUIAction = Rxn<ThreadDetailUIAction>();
  final dashboardRoute = DashboardRoutes.waiting.obs;
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final filterMessageOption = FilterMessageOption.all.obs;
  final listEmailSelected = <PresentationEmail>[].obs;
  final viewStateMailboxActionProgress = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final vacationResponse = Rxn<VacationResponse>();
  final routerParameters = Rxn<Map<String, dynamic>>();
  final _isDraggingMailbox = RxBool(false);
  final searchMailboxActivated = RxBool(false);
  final listSendingEmails = RxList<SendingEmail>();
  final refreshingAllMailboxState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final refreshingAllEmailState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final attachmentDraggableAppState = Rxn<DraggableAppState>();
  final isRecoveringDeletedMessage = RxBool(false);
  final localFileDraggableAppState = Rxn<DraggableAppState>();
  final isSenderImportantFlagEnabled = RxBool(true);
  final isAppGridDialogDisplayed = RxBool(false);
  final isDrawerOpened = RxBool(false);
  final isContextMenuOpened = RxBool(false);
  final isPopupMenuOpened = RxBool(false);
  final octetsQuota = Rxn<Quota>();
  final isTextFormattingMenuOpened = RxBool(false);
  final cachedAIScribeConfig = AIScribeConfig.initial().obs;

  Map<Role, MailboxId> mapDefaultMailboxIdByRole = {};
  Map<MailboxId, PresentationMailbox> mapMailboxById = {};
  final emailsInCurrentMailbox = <PresentationEmail>[].obs;
  final listResultSearch = RxList<PresentationEmail>();
  PresentationMailbox? outboxMailbox;
  List<Identity>? _identities;
  jmap.State? _currentEmailState;
  ScrollController? listSearchFilterScrollController;
  StreamSubscription? _pendingSharedFileInfoSubscription;
  StreamSubscription? _receivingFileSharingStreamSubscription;
  StreamSubscription? _currentEmailIdInNotificationIOSStreamSubscription;
  bool _isFirstSessionLoad = false;
  DeepLinksManager? _deepLinksManager;
  StreamSubscription<DeepLinkData?>? _deepLinkDataStreamSubscription;
  int minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete;
  EmailSortOrderType currentSortOrder = SearchEmailFilter.defaultSortOrder;
  PaywallController? paywallController;
  Worker? advancedSearchVisibleWorker;
  Worker? searchInputFocusWorker;
  Worker? _downloadUIActionWorker;

  final StreamController<Either<Failure, Success>> progressStateController =
    StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get progressState => progressStateController.stream;

  final StreamController<RefreshActionViewEvent> _refreshActionEventController =
    StreamController<RefreshActionViewEvent>.broadcast();

  final _notificationManager = LocalNotificationManager.instance;
  final _fcmService = FcmService.instance;

  bool get isFirstSessionLoad => _isFirstSessionLoad;

  bool setIsFirstSessionLoad(bool value) => _isFirstSessionLoad = value;

  MailboxDashBoardController(
    this._moveToMailboxInteractor,
    this._deleteEmailPermanentlyInteractor,
    this._markAsMailboxReadInteractor,
    this._getEmailCacheOnWebInteractor,
    this._getIdentityCacheOnWebInteractor,
    this._markAsEmailReadInteractor,
    this._markAsStarEmailInteractor,
    this._markAsMultipleEmailReadInteractor,
    this._markAsStarMultipleEmailInteractor,
    this._moveMultipleEmailToMailboxInteractor,
    this._emptyTrashFolderInteractor,
    this._deleteMultipleEmailsPermanentlyInteractor,
    this._getEmailByIdInteractor,
    this._sendEmailInteractor,
    this._storeSendingEmailInteractor,
    this._updateSendingEmailInteractor,
    this._getAllSendingEmailInteractor,
    this._storeSessionInteractor,
    this._emptySpamFolderInteractor,
    this._deleteSendingEmailInteractor,
    this._unsubscribeEmailInteractor,
    this._restoreDeletedMessageInteractor,
    this._getRestoredDeletedMessageInteractor,
    this._removeAllComposerCacheOnWebInteractor,
    this._removeComposerCacheByIdOnWebInteractor,
    this._getAllIdentitiesInteractor,
    this.clearMailboxInteractor,
    this.storeEmailSortOrderInteractor,
    this.getStoredEmailSortOrderInteractor,
  );

  @override
  void onInit() {
    if (PlatformInfo.isMobile) {
      _registerReceivingFileSharingStream();
      _registerDeepLinks();
    }
    _registerStreamListener();
    BackButtonInterceptor.add(onBackButtonInterceptor, name: AppRoutes.dashboard);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await applicationManager.initUserAgent();
    });
    super.onInit();
  }

  @override
  void onReady() {
    if (PlatformInfo.isWeb) {
      listSearchFilterScrollController = ScrollController();
      twakeAppManager.setExecutingBeforeReconnect(false);
      registerReactiveObxVariableListener();
      initialTextFormattingMenuState();
    }
    if (PlatformInfo.isIOS) {
      _registerPendingCurrentEmailIdInNotification();
    }
    _handleArguments();
    _loadAppGrid();
    loadAIScribeConfig();
    super.onReady();
  }

  void _handleComposerCache() async {
    if (accountId.value == null || sessionCurrent == null) return;

    consumeState(
      _getEmailCacheOnWebInteractor.execute(
        accountId.value!,
        sessionCurrent!.username));
  }

  void _handleIdentityCache() async {
    if (accountId.value == null || sessionCurrent == null) return;

    consumeState(
      _getIdentityCacheOnWebInteractor.execute(
        accountId.value!,
        sessionCurrent!.username));
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is SendEmailLoading) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).your_email_being_sent,
          leadingSVGIcon: imagePaths.icSendToast);
      }
    } else if (success is SendEmailSuccess) {
      _handleSendEmailSuccess(success);
    } else if (success is SaveEmailAsDraftsSuccess) {
      _saveEmailAsDraftsSuccess(success);
    } else if (success is UpdateEmailDraftsSuccess) {
      handleUpdateEmailAsDraftsSuccess();
    } else if (success is MoveToMailboxSuccess) {
      _moveToMailboxSuccess(success);
    } else if (success is DeleteEmailPermanentlySuccess) {
      _deleteEmailPermanentlySuccess(success);
    } else if (success is MarkAsMailboxReadAllSuccess ||
        success is MarkAsMailboxReadHasSomeEmailFailure) {
      _markAsReadMailboxSuccess(success);
    } else if (success is GetAllVacationSuccess) {
      if (success.listVacationResponse.isNotEmpty) {
        vacationResponse.value = success.listVacationResponse.first;
      }
    } else if (success is UpdateVacationSuccess) {
      _handleUpdateVacationSuccess(success);
    } else if (success is MarkAsMultipleEmailReadAllSuccess) {
      _markAsReadSelectedMultipleEmailSuccess(success.readActions, success.emailIds);
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      _markAsReadSelectedMultipleEmailSuccess(success.readActions, success.successEmailIds);
    } else if (success is MarkAsStarMultipleEmailAllSuccess) {
      _markAsStarMultipleEmailSuccess(
        success.markStarAction,
        success.countMarkStarSuccess,
        success.emailIds,
      );
    } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      _markAsStarMultipleEmailSuccess(
        success.markStarAction,
        success.countMarkStarSuccess,
        success.successEmailIds,
      );
    } else if (success is MoveMultipleEmailToMailboxAllSuccess ||
        success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      _moveSelectedMultipleEmailToMailboxSuccess(success);
    } else if (success is EmptyTrashFolderSuccess) {
      _emptyTrashFolderSuccess(success);
    } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess ||
        success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
      _deleteMultipleEmailsPermanentlySuccess(success);
    } else if(success is GetEmailByIdSuccess) {
      openEmailDetailedView(success.email);
    } else if (success is StoreSendingEmailSuccess) {
      _handleStoreSendingEmailSuccess(success);
    } else if (success is GetAllSendingEmailSuccess) {
      _handleGetAllSendingEmailsSuccess(success);
    } else if (success is UpdateSendingEmailSuccess) {
      _handleUpdateSendingEmailSuccess(success);
    } else if (success is EmptySpamFolderSuccess) {
      _emptySpamFolderSuccess(success);
    } else if (success is MarkAsEmailReadSuccess) {
      _markAsReadEmailSuccess(success);
    } else if (success is DeleteSendingEmailSuccess) {
      getAllSendingEmails();
    } else if (success is UnsubscribeEmailSuccess) {
      _handleUnsubscribeMailSuccess(success.emailId);
    } else if (success is RestoreDeletedMessageSuccess) {
      _handleRestoreDeletedMessageSuccess(success.emailRecoveryAction.id!);
    } else if (success is GetRestoredDeletedMessageSuccess) {
      _handleGetRestoredDeletedMessageSuccess(success);
    } else if (success is GetAllIdentitiesSuccess) {
      _handleGetAllIdentitiesSuccess(success);
    } else if (success is GetComposerCacheSuccess) {
      handleGetComposerCacheSuccess(success);
    } else if (success is GetIdentityCacheOnWebSuccess) {
      goToSettings();
    } else if (success is MarkAsStarEmailSuccess) {
      updateEmailFlagByEmailIds(
        [success.emailId],
        markStarAction: success.markStarAction,
      );
    } else if (success is GetServerSettingSuccess) {
      isSenderImportantFlagEnabled.value = success.settingOption.isDisplaySenderPriority;
      initializeAppLanguage(success);
    } else if (success is ClearMailboxSuccess) {
      clearMailboxSuccess(success);
    } else if (success is CreateNewRuleFilterSuccess) {
      handleCreateNewRuleFilterSuccess(success);
    } else if (success is GetAuthenticationInfoSuccess) {
      getStoredOidcConfiguration();
    } else if (success is GetStoredOidcConfigurationSuccess) {
      getTokenOIDCAction(success.oidcConfiguration);
    } else if (success is GetTokenOIDCSuccess) {
      synchronizeTokenAndGetSession(
        baseUri: success.baseUri,
        tokenOIDC: success.tokenOIDC,
        oidcConfiguration: success.configuration,
      );
    } else if (success is GetStoredEmailSortOrderSuccess) {
      setUpDefaultEmailSortOrder(success.emailSortOrderType);
    } else if (success is GetTextFormattingMenuStateSuccess) {
      updateTextFormattingMenuState(success.isDisplayed);
    } else if (success is GetAIScribeConfigSuccess) {
      handleLoadAIScribeConfigSuccess(success.aiScribeConfig);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is SendEmailFailure) {
      _handleSendEmailFailure(failure);
    } else if (failure is SaveEmailAsDraftsFailure) {
      _handleSaveEmailAsDraftsFailure(failure);
    } else if (failure is UpdateEmailDraftsFailure) {
      _handleUpdateEmailAsDraftsFailure(failure);
    } else if (failure is RemoveEmailDraftsFailure) {
      clearState();
    } else if (failure is MarkAsMailboxReadAllFailure) {
      _markAsReadMailboxAllFailure(failure);
    }  else if (failure is MarkAsMailboxReadFailure) {
      _markAsReadMailboxFailure(failure);
    } else if (failure is GetEmailByIdFailure) {
      _handleGetEmailByIdFailure(failure);
    } else if (failure is RestoreDeletedMessageFailure) {
      _handleRestoreDeletedMessageFailed();
    } else if (failure is GetRestoredDeletedMessageFailure) {
      _handleRestoreDeletedMessageFailed();
    } else if (failure is EmptySpamFolderFailure) {
      _handleEmptySpamFolderFailure(failure);
    } else if (failure is EmptyTrashFolderFailure) {
      _handleEmptyTrashFolderFailure(failure);
    } else if (failure is MoveMultipleEmailToMailboxFailure) {
      toastManager.showMessageFailure(failure);
    } else if (failure is GetComposerCacheFailure) {
      _handleIdentityCache();
    } else if (failure is GetServerSettingFailure) {
      isSenderImportantFlagEnabled.value = true;
    } else if (failure is GetAllIdentitiesFailure) {
      _handleGetAllIdentitiesFailure();
    } else if (failure is ClearMailboxFailure) {
      clearMailboxFailure(failure);
    } else if (failure is CreateNewRuleFilterFailure) {
      handleCreateNewRuleFilterFailure(failure);
    } else if (failure is GetAuthenticationInfoFailure) {
      tryGetAuthenticatedAccountToUseApp();
    } else if (isGetTokenOIDCFailure(failure)) {
      backToHomeScreen();
    } else if (failure is GetTextFormattingMenuStateFailure) {
      updateTextFormattingMenuState(false);
    } else if (failure is GetAIScribeConfigFailure) {
      handleLoadAIScribeConfigFailure();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleUrgentExceptionOnMobile({Failure? failure, Exception? exception}) {
    SmartDialog.dismiss();

    if (failure is SendEmailFailure && exception is NoNetworkError) {
      storeSendingEmailInCaseOfSendingFailureInMobile(failure);
    } else {
      super.handleUrgentExceptionOnMobile(failure: failure, exception: exception);
    }
  }

  @override
  Future<void> onBeforeUnloadBrowserListener(html.Event event) async {
    log('MailboxDashBoardController::onBeforeUnloadBrowserListener:event = ${event.runtimeType} | hasComposer = ${twakeAppManager.hasComposer} | isExecutingBeforeReconnect = ${twakeAppManager.isExecutingBeforeReconnect}');
    if (event is html.BeforeUnloadEvent &&
        twakeAppManager.hasComposer &&
        !twakeAppManager.isExecutingBeforeReconnect) {
      event.preventDefault();
    }
  }

  void _registerReceivingFileSharingStream() {
    _receivingFileSharingStreamSubscription = _emailReceiveManager
      .receivingFileSharingStream
      .listen(
        _emailReceiveManager.setPendingFileInfo,
        onError: (err) {
          logError('MailboxDashBoardController::_registerReceivingFileSharingStream::receivingFileSharingStream:Exception = $err');
        },
      );

    _pendingSharedFileInfoSubscription = _emailReceiveManager
      .pendingSharedFileInfo
      .listen(
        _handleReceivingFileSharing,
        onError: (err) {
          logError('MailboxDashBoardController::_registerReceivingFileSharingStream::pendingSharedFileInfo:Exception = $err');
        },
      );
  }

  void _handleReceivingFileSharing(List<SharedMediaFile> listSharedMediaFile) {
    log('MailboxDashBoardController::_handleReceivingFileSharing: LIST_LENGTH = ${listSharedMediaFile.length}');
    if (listSharedMediaFile.isEmpty) return;

    for (var file in listSharedMediaFile) {
      log('MailboxDashBoardController::_handleReceivingFileSharing:SharedMediaFile = ${file.toMap()}');
    }

    if (listSharedMediaFile.length == 1) {
      final sharedMediaFile = listSharedMediaFile.first;
      if (sharedMediaFile.path.trim().isEmpty) return;

      switch (sharedMediaFile.type) {
        case SharedMediaType.image:
        case SharedMediaType.video:
        case SharedMediaType.file:
          openComposer(
            ComposerArguments.fromFileShared([sharedMediaFile]),
          );
          break;
        case SharedMediaType.text:
          if (sharedMediaFile.mimeType == Constant.textVCardMimeType) {
            openComposer(
              ComposerArguments.fromFileShared([sharedMediaFile]),
            );
          } else if (sharedMediaFile.mimeType == Constant.textPlainMimeType) {
            openComposer(
              ComposerArguments.fromContentShared(sharedMediaFile.path.trim()),
            );
          }
          break;
        case SharedMediaType.url:
          if (sharedMediaFile.path.startsWith(RouteUtils.mailtoPrefix)) {
            final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(sharedMediaFile.path);
            openComposer(
              ComposerArguments.fromMailtoUri(
                listEmailAddress: navigationRouter.listEmailAddress,
                subject: navigationRouter.subject,
                body: navigationRouter.body,
              ),
            );
          }
          break;
        case SharedMediaType.mailto:
          if (EmailUtils.isEmailAddressValid(sharedMediaFile.path)) {
            openComposer(
              ComposerArguments.fromEmailAddress(
                EmailAddress(null, sharedMediaFile.path),
              ),
            );
          }
          break;
      }
      return;
    }

    openComposer(
      ComposerArguments.fromFileShared(listSharedMediaFile),
    );
  }

  void _registerDeepLinks() {
    _deepLinksManager = getBinding<DeepLinksManager>();
    _deepLinksManager?.clearPendingDeepLinkData();
    _deepLinkDataStreamSubscription = _deepLinksManager
        ?.pendingDeepLinkData.stream
        .listen(_handlePendingDeepLinkDataStream);
  }

  void _handlePendingDeepLinkDataStream(DeepLinkData? deepLinkData) {
    log('MailboxDashBoardController::_handlePendingDeepLinkDataStream:DeepLinkData = $deepLinkData');
    _deepLinksManager?.handleDeepLinksWhenAppRunning(
      deepLinkData: deepLinkData,
      onSuccessCallback: (deepLinkData) {
        if (deepLinkData is! OpenAppDeepLinkData) return;

        _deepLinksManager?.handleOpenAppDeepLinks(
          openAppDeepLinkData: deepLinkData,
          isSignedIn: true,
          username: sessionCurrent?.username,
          onConfirmLogoutCallback: _handleLogOutAndSignInNewAccount,
        );
      },
    );
  }

  void _handleLogOutAndSignInNewAccount(OpenAppDeepLinkData openAppDeepLinkData) {
    if (sessionCurrent == null || accountId.value == null) return;

    if (currentContext != null) {
      SmartDialog.showLoading(msg: AppLocalizations.of(currentContext!).loadingPleaseWait);
    }

    logoutToSignInNewAccount(
      session: sessionCurrent!,
      accountId: accountId.value!,
      onFailureCallback: ({exception}) {
        if (exception is UserCancelledLogoutOIDCFlowException) {
          _deepLinksManager?.autoSignInViaDeepLink(
            openAppDeepLinkData: openAppDeepLinkData,
            onFailureCallback: SmartDialog.dismiss,
            onAutoSignInSuccessCallback: _handleAutoSignInViaDeepLinkSuccess,
          );
        } else {
          SmartDialog.dismiss();
        }
      },
      onSuccessCallback: () => _deepLinksManager?.autoSignInViaDeepLink(
        openAppDeepLinkData: openAppDeepLinkData,
        onFailureCallback: SmartDialog.dismiss,
        onAutoSignInSuccessCallback: _handleAutoSignInViaDeepLinkSuccess,
      ),
    );
  }

  void _handleAutoSignInViaDeepLinkSuccess(AutoSignInViaDeepLinkSuccess success) {
    SmartDialog.dismiss();

    pushAndPopAll(
      AppRoutes.home,
      arguments: LoginNavigateArguments.autoSignIn(
        autoSignInViaDeepLinkSuccess: success,
      ),
    );
  }

  void _registerPendingCurrentEmailIdInNotification() {
    _iosNotificationManager = getBinding<IOSNotificationManager>();
    _currentEmailIdInNotificationIOSStreamSubscription = _iosNotificationManager
        ?.pendingCurrentEmailIdInNotification.stream
        .listen((emailId) {
          if (emailId != null) {
            _iosNotificationManager?.clearPendingCurrentEmailId();
            _handleNotificationMessageFromEmailId(emailId);
          }
        });
  }

  void _registerStreamListener() {
    progressState.listen((state) {
      log('$runtimeType::_registerStreamListener: ViewStateMailboxActionProgress = ${state.runtimeType}');
      syncViewStateMailboxActionProgress(newState: state);
    });

    _refreshActionEventController.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationMessageComing))
      .listen(_handleRefreshActionWhenBackToApp);

    _registerLocalNotificationStreamListener();

    _registerDownloadUIActionListener();
  }

  void _registerLocalNotificationStreamListener() {
    _notificationManager.localNotificationStream.listen(_handleClickLocalNotificationOnForeground);
  }

  void _registerDownloadUIActionListener() {
    _downloadUIActionWorker = ever(
      downloadController.downloadUIAction,
      (action) {
        if (action is OpenComposerFromMailtoLinkAction) {
          openComposerFromMailToLink(action.uri);
          downloadController.clearDownloadUIAction();
        }
      },
    );
  }

  Future<void> _handleClickNotificationOnAndroidInTerminated() async {
    _notificationManager.activatedNotificationClickedOnTerminate = true;
    final notificationResponse = await _notificationManager.getCurrentNotificationResponse();
    log('MailboxDashBoardController::_handleClickLocalNotificationOnTerminated():payload: ${notificationResponse?.payload}');
    _handleMessageFromNotification(notificationResponse?.payload, onForeground: false);
  }

  void _handleArguments() {
    final arguments = Get.arguments;
    log('MailboxDashBoardController::_handleArguments():Arguments = ${arguments.runtimeType}');
    if (arguments is Session) {
      _handleSessionFromArguments(arguments);
    } else if (arguments is MailtoArguments) {
      _handleMailtoURL(arguments);
    } else if (PlatformInfo.isWeb) {
      dispatchRoute(DashboardRoutes.thread);
      getAuthenticationInfoRedirect();
    } else {
      dispatchRoute(DashboardRoutes.thread);
      reload();
    }
  }

  @override
  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      super.injectVacationBindings(session, accountId);
      _getAllVacationInteractor = Get.find<GetAllVacationInteractor>();
      _updateVacationInteractor = Get.find<UpdateVacationInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::injectVacationBindings(): $e');
    }
  }

  @override
  Future<void> injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      await super.injectFCMBindings(session, accountId);
      await LocalNotificationManager.instance.recreateStreamController();
      _registerLocalNotificationStreamListener();
    } catch (e) {
      logError('MailboxDashBoardController::injectFCMBindings(): $e');
    }
  }

  void _handleSessionFromArguments(Session session) {
    log('MailboxDashBoardController::_handleSession:');
    _setUpComponentsFromSession(session);

    if (PlatformInfo.isWeb) {
      _handleComposerCache();
    }

    if (PlatformInfo.isAndroid && !_notificationManager.isNotificationClickedOnTerminate) {
      _handleClickNotificationOnAndroidInTerminated();
    } else {
      dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _setUpComponentsFromSession(Session session) {
    final currentAccountId = session.accountId;
    _isFirstSessionLoad = true;
    sessionCurrent = session;
    accountId.value = currentAccountId;
    synchronizeOwnEmailAddress(session.getOwnEmailAddressOrEmpty());

    _setUpMinInputLengthAutocomplete();
    injectAutoCompleteBindings(session, currentAccountId);
    injectRuleFilterBindings(session, currentAccountId);
    injectVacationBindings(session, currentAccountId);
    injectWebSocket(session, currentAccountId);
    injectPreferencesBindings();
    injectAIScribeBindings(session, currentAccountId);
    if (PlatformInfo.isMobile) {
      injectFCMBindings(session, currentAccountId);
    }

    _getVacationResponse();
    spamReportController.getSpamReportStateAction();
    _getAllIdentities();
    notifyThreadDetailSettingUpdated();
    getServerSetting();
    cleanupRecentSearch();
    loadStoredEmailSortOrder();

    if (PlatformInfo.isMobile) {
      getAllSendingEmails();
      _storeSessionAction(session);
    }

    paywallController = PaywallController(
      ownEmailAddress: ownEmailAddress.value,
    );

    if (isLabelCapabilitySupported) {
      labelController.checkLabelSettingState(currentAccountId);
    }
  }

  void _handleMailtoURL(MailtoArguments arguments) {
    log('MailboxDashBoardController::_handleMailtoURL:');
    routerParameters.value = arguments.toMapRouter();
    _handleSessionFromArguments(arguments.session);
  }

  void _getVacationResponse() {
    if (accountId.value != null && _getAllVacationInteractor != null) {
      consumeState(_getAllVacationInteractor!.execute(accountId.value!));
    }
  }

  MailboxId? getMailboxIdByRole(Role role) {
    return mapDefaultMailboxIdByRole[role];
  }

  MailboxId? get spamMailboxId {
    return mapDefaultMailboxIdByRole[PresentationMailbox.roleJunk]
      ?? mapDefaultMailboxIdByRole[PresentationMailbox.roleSpam];
  }

  void setMapDefaultMailboxIdByRole(Map<Role, MailboxId> newMapMailboxId) {
    mapDefaultMailboxIdByRole = newMapMailboxId;
  }

  void setMapMailboxById(Map<MailboxId, PresentationMailbox> newMapMailboxById) {
    mapMailboxById = newMapMailboxById;
  }

  void setOutboxMailbox(PresentationMailbox? newOutbox) {
    outboxMailbox = newOutbox;
    log('MailboxDashBoardController::setOutboxMailbox(): $newOutbox');
  }

  void setSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    log('MailboxDashBoardController::setSelectedMailbox: SELECTED_MAILBOX_ID = ${newPresentationMailbox?.id.asString} |  SELECTED_MAILBOX_NAME = ${newPresentationMailbox?.name?.name} | ');
    selectedMailbox.value = newPresentationMailbox;
  }

  void setSelectedEmail(PresentationEmail? newPresentationEmail) {
    log('MailboxDashBoardController::setSelectedEmail(): $newPresentationEmail');
    selectedEmail.value = newPresentationEmail;
  }

  void clearSelectedEmail() {
    selectedEmail.value = null;
  }

  void openEmailDetailedView(PresentationEmail presentationEmail) {
    setSelectedEmail(presentationEmail);
    dispatchRoute(DashboardRoutes.threadDetailed);
    if (PlatformInfo.isWeb && presentationEmail.routeWeb != null) {
      RouteUtils.replaceBrowserHistory(
        title: 'Email-${presentationEmail.id?.id.value ?? ''}',
        url: presentationEmail.routeWeb!
      );
    }
  }

  void openMailboxMenuDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeMailboxMenuDrawer() {
    if (isDrawerOpen) {
      scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void hideMailboxMenuWhenScreenSizeChange() {
    if (isDrawerOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        closeMailboxMenuDrawer();
      });
    }
  }

  bool get isDrawerOpen => scaffoldKey.currentState?.isDrawerOpen == true;

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  void handleAdvancedSearchEmail() {
    log('MailboxDashBoardController::handleAdvancedSearchEmail:');
    if (_searchInsideThreadDetailViewIsActive()) {
      _closeEmailDetailedView();
    }
    _unSelectedMailbox();
    searchController.clearFilterSuggestion();
    FocusManager.instance.primaryFocus?.unfocus();
    storeEmailSortOrder(searchController.searchEmailFilter.value.sortOrderType);
    dispatchAction(StartSearchEmailAction());
  }

  void handleClearAdvancedSearchFilterEmail() {
    log('MailboxDashBoardController::handleClearAdvancedSearchFilterEmail:');
    clearFilterMessageOption();
    if (_searchInsideThreadDetailViewIsActive()) {
      _closeEmailDetailedView();
    }
    _unSelectedMailbox();
    searchController.clearAllFilterSearch();
    FocusManager.instance.primaryFocus?.unfocus();
    dispatchAction(ClearAdvancedSearchFilterEmailAction());
  }

  void searchEmailByQueryString(String queryString) {
    final isMailAddress = EmailUtils.isEmailAddressValid(queryString);
    log('MailboxDashBoardController::searchEmailByQueryString():QueryString = $queryString | isMailAddress = $isMailAddress');
    if (_searchInsideThreadDetailViewIsActive()) {
      _closeEmailDetailedView();
    }
    _unSelectedMailbox();
    searchController.clearFilterSuggestion();

    searchController.updateFilterEmail(
      textOption: !isMailAddress
        ? Some(SearchQuery(queryString))
        : null,
      fromOption: isMailAddress
        ? Some({queryString})
        : null);

    if (searchController.searchEmailFilter.value.isContainFlagged) {
      filterMessageOption.value = FilterMessageOption.starred;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    dispatchAction(StartSearchEmailAction());
  }

  bool _searchInsideThreadDetailViewIsActive() {
    return PlatformInfo.isWeb
      && currentContext != null
      && responsiveUtils.isDesktop(currentContext!)
      && dashboardRoute.value == DashboardRoutes.threadDetailed;
  }

  void _unSelectedMailbox() {
    selectedMailbox.value = null;
  }

  void _closeEmailDetailedView() {
    log('MailboxDashBoardController::_closeEmailDetailedView(): ');
    dispatchRoute(DashboardRoutes.thread);
    clearSelectedEmail();
  }

  void _saveEmailAsDraftsSuccess(SaveEmailAsDraftsSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).drafts_saved,
        actionName: AppLocalizations.of(currentContext!).discard,
        onActionClick: () => _discardEmail(success.emailId, success.draftMailboxId),
        leadingSVGIcon: imagePaths.icMailboxDrafts,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo));
    }
  }

  void moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    final currentMailboxes = moveRequest.currentMailboxes;
    if (currentMailboxes.length == 1 && currentMailboxes.values.first.length == 1) {
      consumeState(_moveToMailboxInteractor.execute(
        session,
        accountId,
        moveRequest,
        emailIdsWithReadStatus,
      ));
    } else {
      consumeState(_moveMultipleEmailToMailboxInteractor.execute(
        session,
        accountId,
        moveRequest,
        emailIdsWithReadStatus,
      ));
    }
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    dispatchThreadDetailUIAction(EmailMovedAction(
      emailId: success.emailId,
      originalMailboxId: success.currentMailboxId,
      targetMailboxId: success.destinationMailboxId,
    ));
    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        success.emailActionType.getToastMessageMoveToMailboxSuccess(currentContext!, destinationPath: success.destinationPath),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          _revertedToOriginalMailbox(MoveToMailboxRequest(
            {success.destinationMailboxId: [success.emailId]},
            success.currentMailboxId,
            MoveAction.undo,
            success.emailActionType
          ), success.emailIdsWithReadStatus);
        },
        leadingSVGIcon: imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo));
    }
  }

  void _revertedToOriginalMailbox(
    MoveToMailboxRequest newMoveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null) {
      moveToMailbox(
        session,
        currentAccountId,
        newMoveRequest,
        emailIdsWithReadStatus,
      );
    }
  }

  void _discardEmail(EmailId emailId, MailboxId? draftMailboxId) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null) {
      consumeState(_removeEmailDraftsInteractor.execute(
        session,
        currentAccountId,
        emailId,
        draftMailboxId,
      ));
    }
  }

  void deleteEmailPermanently(PresentationEmail email) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null && email.id != null) {
      consumeState(_deleteEmailPermanentlyInteractor.execute(
        session,
        currentAccountId,
        email.id!,
        email.mailboxContain?.mailboxId,
      ));
    }
  }

  void _deleteEmailPermanentlySuccess(DeleteEmailPermanentlySuccess success) {
    handleDeleteEmailsInMailbox(
      emailIds: [success.emailId],
      affectedMailboxId: success.mailboxId,
    );
    if (currentOverlayContext != null &&  currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_delete_a_email_permanently_success,
        leadingSVGIcon: imagePaths.icDeleteToast
      );
    }
  }

  void markAsEmailRead(
    EmailId emailId,
    ReadActions readActions,
    MarkReadAction markReadAction,
    MailboxId? mailboxId,
  ) {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsEmailReadInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        emailId,
        readActions,
        markReadAction,
        mailboxId,
      ));
    }
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction action) {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsStarEmailInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        presentationEmail.id!,
        action));
    }
  }

  void markAsReadSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, ReadActions readActions) {
    final listEmailNeedMarkAsRead = listPresentationEmail
      .where((email) {
        if (readActions == ReadActions.markAsUnread) {
          return email.hasRead;
        } else {
          return !email.hasRead;
        }
      })
      .toList();

    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsMultipleEmailReadInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        listEmailNeedMarkAsRead.listEmailIds,
        readActions,
        listEmailNeedMarkAsRead.emailIdsByMailboxId,
      ));
    }
  }

  void _markAsReadSelectedMultipleEmailSuccess(ReadActions readActions, List<EmailId> emailIds) {
    updateEmailFlagByEmailIds(emailIds, readAction: readActions);
    if (currentContext != null && currentOverlayContext != null) {
      final message = readActions == ReadActions.markAsUnread
        ? AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).unread)
        : AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).read);

      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        message,
        leadingSVGIcon: readActions == ReadActions.markAsUnread
          ? imagePaths.icUnreadToast
          : imagePaths.icReadToast
      );
    }
  }

  void _markAsReadEmailSuccess(MarkAsEmailReadSuccess success) {
    updateEmailFlagByEmailIds(
      [success.emailId],
      readAction: success.readActions,
    );
    if (currentContext != null &&
        currentOverlayContext != null &&
        success.markReadAction == MarkReadAction.swipeOnThread) {
      final message = success.readActions == ReadActions.markAsUnread
        ? AppLocalizations.of(currentContext!).markedSingleMessageToast(AppLocalizations.of(currentContext!).unread.toLowerCase())
        : AppLocalizations.of(currentContext!).markedSingleMessageToast(AppLocalizations.of(currentContext!).read.toLowerCase());

      final undoAction = success.readActions == ReadActions.markAsUnread
          ? ReadActions.markAsRead
          : ReadActions.markAsUnread;

      appToast.showToastMessage(
        currentOverlayContext!,
        message,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          markAsEmailRead(success.emailId, undoAction, MarkReadAction.undo, success.mailboxId);
        },
        leadingSVGIcon: imagePaths.icToastSuccessMessage,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, MarkStarAction markStarAction) {
    if (accountId.value != null && sessionCurrent != null) {
      final listEmailIds = listPresentationEmail
          .where((email) {
            if (markStarAction == MarkStarAction.unMarkStar) {
              return email.hasStarred;
            } else {
              return !email.hasStarred;
            }
          })
          .toList()
          .listEmailIds;

      consumeState(_markAsStarMultipleEmailInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        listEmailIds,
        markStarAction));
    }
  }

  void _markAsStarMultipleEmailSuccess(
    MarkStarAction markStarAction,
    int countMarkStarSuccess,
    List<EmailId> emailIds,
  ) {
    updateEmailFlagByEmailIds(emailIds, markStarAction: markStarAction);
    if (currentOverlayContext != null && currentContext != null) {
      final message = markStarAction == MarkStarAction.unMarkStar
        ? AppLocalizations.of(currentContext!).marked_unstar_multiple_item(countMarkStarSuccess)
        : AppLocalizations.of(currentContext!).marked_star_multiple_item(countMarkStarSuccess);

      appToast.showToastMessage(
        currentOverlayContext!,
        message,
        leadingSVGIcon: markStarAction == MarkStarAction.unMarkStar
          ? imagePaths.icUnStar
          : imagePaths.icStar,
      );
    }
  }

  Future<void> moveEmailsToMailbox(
    List<PresentationEmail> listEmails, {
    VoidCallback? onCallbackAction,
  }) async {
    if (accountId.value != null) {
      final arguments = DestinationPickerArguments(
        accountId.value!,
        MailboxActions.moveEmail,
        sessionCurrent,
      );

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter().pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox != null &&
          destinationMailbox is PresentationMailbox &&
          sessionCurrent != null &&
          accountId.value != null
      ) {
        onCallbackAction?.call();

        if (destinationMailbox.isTrash) {
          moveEmailsToFolder(
            listEmails,
            EmailActionType.moveToTrash,
            selectedMailboxId: destinationMailbox.id,
          );
        } else if (destinationMailbox.isSpam) {
          moveEmailsToFolder(
            listEmails,
            EmailActionType.moveToSpam,
            selectedMailboxId: destinationMailbox.id,
          );
        } else if (destinationMailbox.isArchive) {
          moveEmailsToFolder(
            listEmails,
            EmailActionType.archiveMessage,
            selectedMailboxId: destinationMailbox.id,
          );
        } else {
          moveEmailsToFolder(
            listEmails,
            EmailActionType.moveToMailbox,
            selectedMailboxId: destinationMailbox.id,
            destinationFolderPath: destinationMailbox.mailboxPath,
          );
        }
      }
    } else {
      onCallbackAction?.call();
      consumeState(
        Stream.value(Left(MoveMultipleEmailToMailboxFailure(
          EmailActionType.moveToMailbox,
          MoveAction.moving,
          ParametersIsNullException(),
        ))),
      );
    }
  }

  void dragSelectedMultipleEmailToMailboxAction(
    List<PresentationEmail> listEmails,
    PresentationMailbox destinationMailbox,
  ) {
    final emailIdsWithReadStatus = Map.fromEntries(listEmails
      .where((email) => email.id != null)
      .map((e) => MapEntry(e.id!, e.hasRead))
    );

    if (destinationMailbox.isFavorite) {
      _handleDragSelectedMultipleEmailToFavoriteFolder(listEmails);
    } else {
      if (searchController.isSearchEmailRunning ||
          selectedMailbox.value?.isFavorite == true) {
        final Map<MailboxId,List<EmailId>> mapListEmailSelectedByMailBoxId = {};
        for (var element in listEmails) {
          final mailbox = element.findMailboxContain(mapMailboxById);
          if (mailbox != null && element.id != null) {
            if (mapListEmailSelectedByMailBoxId.containsKey(mailbox.id)) {
              mapListEmailSelectedByMailBoxId[mailbox.id]?.add(element.id!);
            } else {
              mapListEmailSelectedByMailBoxId.addAll({mailbox.id: [element.id!]});
            }
          }
        }
        _handleDragSelectedMultipleEmailToMailboxAction(
          mapListEmailSelectedByMailBoxId,
          destinationMailbox,
          emailIdsWithReadStatus,
        );
      } else if (selectedMailbox.value != null) {
        _handleDragSelectedMultipleEmailToMailboxAction(
          {selectedMailbox.value!.id: listEmails.listEmailIds},
          destinationMailbox,
          emailIdsWithReadStatus,
        );
      }
    }
  }

  void _handleDragSelectedMultipleEmailToFavoriteFolder(
    List<PresentationEmail> listPresentationEmail,
  ) async {
    if (accountId.value != null && sessionCurrent != null) {
      final listEmailIds = listPresentationEmail
        .where((email) => !email.hasStarred)
        .toList()
        .listEmailIds;

      consumeState(
        _markAsStarMultipleEmailInteractor.execute(
          sessionCurrent!,
          accountId.value!,
          listEmailIds,
          MarkStarAction.markStar,
        ),
      );
    } else {
      consumeState(
        Stream.value(Left(
          MarkAsStarMultipleEmailFailure(
            MarkStarAction.markStar,
            NotFoundSessionException(),
          ),
        )),
      );
    }

    dispatchAction(CancelSelectionAllEmailAction());
  }

  void _handleDragSelectedMultipleEmailToMailboxAction(
    Map<MailboxId, List<EmailId>> mapListEmails,
    PresentationMailbox destinationMailbox,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) async {
    if (accountId.value != null && sessionCurrent != null) {
      if (destinationMailbox.isTrash) {
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            EmailActionType.moveToTrash,
          ),
          emailIdsWithReadStatus,
        );
      } else if (destinationMailbox.isSpam) {
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            EmailActionType.moveToSpam,
          ),
          emailIdsWithReadStatus,
        );
      } else {
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            EmailActionType.moveToMailbox,
            destinationPath: destinationMailbox.mailboxPath,
          ),
          emailIdsWithReadStatus,
        );
      }
    }
    dispatchAction(CancelSelectionAllEmailAction());
  }

  void moveSelectedEmailMultipleToMailboxAction(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(
      session,
      accountId,
      moveRequest,
      emailIdsWithReadStatus,
    ));
  }

  void _moveSelectedMultipleEmailToMailboxSuccess(Success success) {
    String? destinationPath;
    List<EmailId> movedEmailIds = [];
    MailboxId? currentMailboxId;
    MailboxId? destinationMailboxId;
    MoveAction? moveAction;
    EmailActionType? emailActionType;
    Map<EmailId, bool>? emailIdsWithReadStatus;
    bool isUndoActionEnabled = false;

    if (success is MoveMultipleEmailToMailboxAllSuccess) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.originalMailboxIdsWithEmailIds.keys.firstOrNull;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
      emailIdsWithReadStatus = success.emailIdsWithReadStatus;
      isUndoActionEnabled = success.originalMailboxIdsWithEmailIds.length == 1;
    } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.originalMailboxIdsWithMoveSucceededEmailIds.keys.firstOrNull;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
      emailIdsWithReadStatus = success.moveSucceededEmailIdsWithReadStatus;
      isUndoActionEnabled = success.originalMailboxIdsWithMoveSucceededEmailIds.length == 1;
    }

    if (currentMailboxId == null ||
        currentOverlayContext == null ||
        emailActionType == null ||
        moveAction != MoveAction.moving) {
      return;
    }

    if (!isUndoActionEnabled) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        emailActionType.getToastMessageMoveToMailboxSuccess(
          currentContext!,
          destinationPath: destinationPath,
        ),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,
      );
    } else {
      appToast.showToastMessage(
        currentOverlayContext!,
        emailActionType.getToastMessageMoveToMailboxSuccess(
          currentContext!,
          destinationPath: destinationPath,
        ),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          final newCurrentMailboxId = destinationMailboxId;
          final newDestinationMailboxId = currentMailboxId;
          if (newCurrentMailboxId != null && newDestinationMailboxId != null) {
            _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest(
              {newCurrentMailboxId: movedEmailIds},
              newDestinationMailboxId,
              MoveAction.undo,
              emailActionType!,
              destinationPath: destinationPath,
            ), emailIdsWithReadStatus ?? {});
          }
        },
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }

  void _revertedSelectionEmailToOriginalMailbox(
    MoveToMailboxRequest newMoveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_moveMultipleEmailToMailboxInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        newMoveRequest,
        emailIdsWithReadStatus));
    }
  }

  void unSpamSelectedMultipleEmail(List<PresentationEmail> listEmail) {
    if (accountId.value == null || sessionCurrent == null) {
      consumeState(Stream.value(
        Left(MoveMultipleEmailToMailboxFailure(
          EmailActionType.unSpam,
          MoveAction.moving,
          NotFoundSessionException()
        ))
      ));
      return;
    }

    if (spamMailboxId == null) {
      consumeState(Stream.value(
        Left(MoveMultipleEmailToMailboxFailure(
          EmailActionType.unSpam,
          MoveAction.moving,
          NotFoundSpamMailboxException()
        ))
      ));
      return;
    }

    final inboxMailboxId = getMailboxIdByRole(PresentationMailbox.roleInbox);
    if (inboxMailboxId == null) {
      consumeState(Stream.value(
        Left(MoveMultipleEmailToMailboxFailure(
          EmailActionType.unSpam,
          MoveAction.moving,
          NotFoundInboxMailboxException()
        ))
      ));
      return;
    }

    moveSelectedEmailMultipleToMailboxAction(
      sessionCurrent!,
      accountId.value!,
      MoveToMailboxRequest(
        {spamMailboxId!: listEmail.listEmailIds},
        inboxMailboxId,
        MoveAction.moving,
        EmailActionType.unSpam),
      Map.fromEntries(
        listEmail
          .where((email) => email.id != null)
          .map((email) => MapEntry(email.id!, email.hasRead)),
      ),
    );
  }

  void moveMultipleEmailInThreadDetail(
    List<EmailInThreadDetailInfo> emailsInThreadDetailInfo, {
    required MailboxId destinationMailboxId,
    required EmailActionType emailActionType,
  }) {
    if (sessionCurrent == null || accountId.value == null) {
      consumeState(Stream.value(
        Left(MoveMultipleEmailToMailboxFailure(
          emailActionType,
          MoveAction.moving,
          NotFoundSessionException()
        ))
      ));
      return;
    }
    final currentMailboxes = <MailboxId, List<EmailId>>{};
    for (final email in emailsInThreadDetailInfo) {
      final mailboxIdContain = email.mailboxIdContain;
      if (mailboxIdContain == null) continue;

      currentMailboxes.putIfAbsent(mailboxIdContain, () => []).add(email.emailId);
    }
    final moveRequest = MoveToMailboxRequest(
      currentMailboxes,
      destinationMailboxId,
      MoveAction.moving,
      emailActionType,
      destinationPath: currentContext == null
          ? mapMailboxById[destinationMailboxId]?.name?.name
          : mapMailboxById[destinationMailboxId]?.getDisplayName(currentContext!),
    );
    final emailIdsWithReadStatus = Map.fromEntries(
      emailsInThreadDetailInfo.map(
        (email) => MapEntry(
          email.emailId,
          email.keywords?[KeyWordIdentifier.emailSeen] == true,
        ),
      ),
    );

    moveSelectedEmailMultipleToMailboxAction(
      sessionCurrent!,
      accountId.value!,
      moveRequest,
      emailIdsWithReadStatus,
    );
  }

  void permanentDeleteMultipleEmailInThreadDetail(
    List<EmailInThreadDetailInfo> emailsInThreadDetailInfo, {
    VoidCallback? onConfirm,
  }) {
    if (currentContext == null) return;

    final mailboxContainId = emailsInThreadDetailInfo.firstOrNull?.mailboxIdContain;
    final mailboxContain = mailboxContainId == null
        ? null
        : mapMailboxById[mailboxContainId];

    deleteSelectionEmailsPermanently(
      currentContext!,
      DeleteActionType.multiple,
      listEmails: emailsInThreadDetailInfo
          .map(
            (email) => PresentationEmail(
              id: email.emailId,
              mailboxContain: mailboxContain,
            ),
          )
          .toList(),
      mailboxCurrent: mailboxContain,
      onConfirm: onConfirm,
    );
  }

  void deleteSelectionEmailsPermanently(
      BuildContext context,
      DeleteActionType actionType,
      {
        List<PresentationEmail>? listEmails,
        PresentationMailbox? mailboxCurrent,
        Function? onCancelSelectionEmail,
        VoidCallback? onConfirm,
      }
  ) {
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(actionType.getContentDialog(
            context,
            count: listEmails?.length,
            mailboxName: mailboxCurrent?.getDisplayName(context)))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(
            actionType.getConfirmActionName(context),
            () {
              onConfirm?.call();
              _deleteSelectionEmailsPermanentlyAction(
                actionType,
                listEmails: listEmails,
                onCancelSelectionEmail: onCancelSelectionEmail,
              );
            }))
      .show();
    } else {
      MessageDialogActionManager().showConfirmDialogAction(
        key: const Key('confirm_dialog_delete_emails_permanently'),
        context,
        title: actionType.getTitleDialog(context),
        actionType.getContentDialog(
          context,
          count: listEmails?.length,
          mailboxName: mailboxCurrent?.getDisplayName(context),
        ),
        actionType.getConfirmActionName(context),
        cancelTitle: AppLocalizations.of(context).cancel,
        onConfirmAction: () {
          onConfirm?.call();
          _deleteSelectionEmailsPermanentlyAction(
            actionType,
            listEmails: listEmails,
            onCancelSelectionEmail: onCancelSelectionEmail,
          );
        },
        onCloseButtonAction: popBack,
      );
    }
  }

  void _deleteSelectionEmailsPermanentlyAction(
    DeleteActionType actionType, {
    List<PresentationEmail>? listEmails,
    Function? onCancelSelectionEmail,
  }) {
    popBack();

    switch(actionType) {
      case DeleteActionType.all:
        emptyTrashFolderAction(onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.multiple:
        _deleteMultipleEmailsPermanently(listEmails ?? [], onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.single:
        break;
    }
  }

  void emptyTrashFolderAction({
    Function? onCancelSelectionEmail,
    MailboxId? trashFolderId,
    int totalEmails = 0,
  }) {
    onCancelSelectionEmail?.call();

    final trashMailboxId = trashFolderId ?? mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];
    final accountId = this.accountId.value;

    if (accountId == null || sessionCurrent == null) {
      consumeState(Stream.value(Left(EmptyTrashFolderFailure(NotFoundSessionException()))));
      return;
    }

    if (trashMailboxId == null) {
      consumeState(Stream.value(Left(EmptyTrashFolderFailure(NotFoundMailboxException()))));
      return;
    }

    if (CapabilityIdentifier.jmapMailboxClear.isSupported(sessionCurrent!, accountId)) {
      clearMailbox(
        sessionCurrent!,
        accountId,
        trashMailboxId,
        PresentationMailbox.roleTrash,
      );
    } else {
      final totalEmailsInTrash = totalEmails == 0
          ? mapMailboxById[trashMailboxId]?.countTotalEmails ?? 0
          : totalEmails;

      consumeState(_emptyTrashFolderInteractor.execute(
        sessionCurrent!,
        accountId,
        trashMailboxId,
        totalEmailsInTrash,
        progressStateController,
      ));
    }
  }

  void syncViewStateMailboxActionProgress({
    required Either<Failure, Success> newState,
  }) {
    viewStateMailboxActionProgress.value = newState;
  }

  void _emptyTrashFolderSuccess(EmptyTrashFolderSuccess success) {
    syncViewStateMailboxActionProgress(newState: Right(UIState.idle));

    handleDeleteEmailsInMailbox(
      emailIds: success.emailIds,
      affectedMailboxId: success.mailboxId,
    );

    toastManager.showMessageSuccess(success);
  }

  void _deleteMultipleEmailsPermanently(List<PresentationEmail> listEmails, {Function? onCancelSelectionEmail}) {
    onCancelSelectionEmail?.call();

    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_deleteMultipleEmailsPermanentlyInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        listEmails.listEmailIds,
        listEmails.firstOrNull?.mailboxContain?.mailboxId));
    }
  }

  void _deleteMultipleEmailsPermanentlySuccess(Success success) {
    List<EmailId> listEmailIdResult = <EmailId>[];
    if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
      handleDeleteEmailsInMailbox(
        emailIds: success.emailIds,
        affectedMailboxId: success.mailboxId,
      );
      listEmailIdResult = success.emailIds;
    } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
      handleDeleteEmailsInMailbox(
        emailIds: success.emailIds,
        affectedMailboxId: success.mailboxId,
      );
      listEmailIdResult = success.emailIds;
    }

    if (currentOverlayContext != null && currentContext != null && listEmailIdResult.isNotEmpty) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_delete_multiple_email_permanently_success(listEmailIdResult.length));
    }
  }

  void dispatchAction(UIAction action) {
    log('MailboxDashBoardController::dispatchAction(): ${action.runtimeType}');
    dashBoardAction.value = action;
  }

  void dispatchMailboxUIAction(MailboxUIAction newAction) {
    log('MailboxDashBoardController::dispatchMailboxUIAction():newAction: ${newAction.runtimeType}');
    mailboxUIAction.value = newAction;
  }

  void dispatchEmailUIAction(EmailUIAction newAction) {
    log('MailboxDashBoardController::dispatchEmailUIAction():newAction: ${newAction.runtimeType}');
    emailUIAction.value = newAction;
  }

  void dispatchThreadDetailUIAction(ThreadDetailUIAction newAction) {
    log('MailboxDashBoardController::dispatchThreadDetailUIAction():newAction: ${newAction.runtimeType}');
    threadDetailUIAction.value = newAction;
  }

  void dispatchRoute(DashboardRoutes route) {
    log('MailboxDashBoardController::dispatchRoute(): $route');
    dashboardRoute.value = route;
  }

  @override
  void handleReloaded(Session session) {
    log('MailboxDashBoardController::handleReloaded():');
    SmartDialog.dismiss();

    _getRouteParameters();
    _setUpComponentsFromSession(session);
    if (PlatformInfo.isWeb) {
      _handleComposerCache();
    }
  }

  void _getRouteParameters() {
    final parameters = Get.parameters;
    log('MailboxDashBoardController::_getRouteParameters(): parameters: $parameters');
    routerParameters.value = parameters;
  }

  UnsignedInt? get maxSizeAttachmentsPerEmail {
    try {
      if (sessionCurrent != null && accountId.value != null) {
        final mailCapability = sessionCurrent!.getCapabilityProperties<MailCapability>(accountId.value!, CapabilityIdentifier.jmapMail);
        final maxSizeAttachmentsPerEmail = mailCapability?.maxSizeAttachmentsPerEmail;
        log('MailboxDashBoardController::maxSizeAttachmentsPerEmail(): $maxSizeAttachmentsPerEmail');
        return maxSizeAttachmentsPerEmail;
      }
      return null;
    } catch (e) {
      logError('MailboxDashBoardController::maxSizeAttachmentsPerEmail(): [Exception] $e');
      return null;
    }
  }

  void clearFilterMessageOption() {
    filterMessageOption.value = FilterMessageOption.all;
  }

  void markAsReadMailboxAction(BuildContext context) {
    final session = sessionCurrent;
    final currentAccountId = accountId.value;
    final mailboxId = selectedMailbox.value?.id;
    final countEmailsUnread = selectedMailbox.value?.unreadEmails?.value.value ?? 0;
    if (session != null && currentAccountId != null && mailboxId != null) {
      markAsReadMailbox(
        session,
        currentAccountId,
        mailboxId,
        selectedMailbox.value?.getDisplayName(context) ?? '',
        countEmailsUnread.toInt()
      );
    }
  }

  void markAsReadMailbox(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    String mailboxDisplayName,
    int totalEmailsUnread
  ) {
    consumeState(_markAsMailboxReadInteractor.execute(
      session,
      accountId,
      mailboxId,
      mailboxDisplayName,
      totalEmailsUnread,
      progressStateController));
  }

  void _markAsReadMailboxSuccess(Success success) {
    syncViewStateMailboxActionProgress(newState: Right(UIState.idle));

    if (success is MarkAsMailboxReadAllSuccess) {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMessageMarkAsMailboxReadSuccess(success.mailboxDisplayName),
          leadingSVGIcon: imagePaths.icReadToast);
      }
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxDisplayName, success.countEmailsRead),
          leadingSVGIcon: imagePaths.icReadToast);
      }
    }
  }

  void _markAsReadMailboxFailure(MarkAsMailboxReadFailure failure) {
    syncViewStateMailboxActionProgress(newState: Right(UIState.idle));
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageMarkAsReadFolderAllFailure(
          failure.mailboxDisplayName,
        )
      );
    }
  }

  void _markAsReadMailboxAllFailure(MarkAsMailboxReadAllFailure failure) {
    syncViewStateMailboxActionProgress(newState: Right(UIState.idle));
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageMarkAsReadFolderAllFailure(failure.mailboxDisplayName)
      );
    }
  }

  void clearDashBoardAction() {
    dashBoardAction.value = DashBoardAction.idle;
  }

  void clearMailboxUIAction() {
    mailboxUIAction.value = MailboxUIAction.idle;
  }

  void clearEmailUIAction() {
    emailUIAction.value = EmailUIAction.idle;
  }

  void goToSettings() async {
    closeMailboxMenuDrawer();
    BackButtonInterceptor.removeByName(AppRoutes.dashboard);
    final result = await push(
      AppRoutes.settings,
      arguments: ManageAccountArguments(
        sessionCurrent,
        previousUri: RouteUtils.baseUri,
        quota: octetsQuota.value,
      ),
    );

    BackButtonInterceptor.add(onBackButtonInterceptor, name: AppRoutes.dashboard);

    if (result is Tuple2) {
      if (result.value1 is VacationResponse) {
        vacationResponse.value = result.value1;
        dispatchMailboxUIAction(RefreshChangeMailboxAction(
          newState: jmap.State('vacation-updated-state-${DateTime.now().millisecondsSinceEpoch}'),
        ));
      }
      await Future.delayed(
        const Duration(milliseconds: 500),
        () => _replaceBrowserHistory(uri: result.value2)
      );
    }

    _getAllIdentities();
    notifyThreadDetailSettingUpdated();
    getServerSetting();
    spamReportController.getSpamReportStateAction();
    loadAIScribeConfig();
    if (isLabelCapabilitySupported && accountId.value != null) {
      labelController.checkLabelSettingState(accountId.value!);
    }
  }

  Future<List<PresentationEmail>> quickSearchEmails(String query) async {
    if (sessionCurrent != null && accountId.value != null) {
      return searchController.quickSearchEmails(
        session: sessionCurrent!,
        accountId: accountId.value!,
        ownEmailAddress: ownEmailAddress.value,
        query: query
      );
    } else {
      return [];
    }
  }

  void addDownloadTask(DownloadTaskState task) {
    downloadController.addDownloadTask(task);
  }

  void updateDownloadTask(
      DownloadTaskId taskId,
      UpdateDownloadTaskStateCallback updateDownloadTaskCallback
  ) {
    downloadController.updateDownloadTaskByTaskId(
        taskId,
        updateDownloadTaskCallback);
  }

  void deleteDownloadTask(DownloadTaskId taskId) {
    downloadController.deleteDownloadTask(taskId);
  }

  void disableVacationResponder(VacationResponse vacationResponse) {
    if (accountId.value != null && _updateVacationInteractor != null) {
      consumeState(_updateVacationInteractor!.execute(
        accountId.value!,
        vacationResponse.clearAllExceptHtmlBody(),
      ));
    } else {
      consumeState(
        Stream.value(Left(UpdateVacationFailure(ParametersIsNullException()))),
      );
    }
  }

  void goToVacationSetting() async {
    BackButtonInterceptor.removeByName(AppRoutes.dashboard);
    final result = await push(
      AppRoutes.settings,
      arguments: ManageAccountArguments(
        sessionCurrent,
        menuSettingCurrent: AccountMenuItem.vacation,
        previousUri: RouteUtils.baseUri,
        quota: octetsQuota.value,
      )
    );

    BackButtonInterceptor.add(onBackButtonInterceptor, name: AppRoutes.dashboard);

    if (result is Tuple2) {
      if (result.value1 is VacationResponse) {
        vacationResponse.value = result.value1;
        dispatchMailboxUIAction(RefreshChangeMailboxAction(
          newState: jmap.State('vacation-updated-state-${DateTime.now().millisecondsSinceEpoch}'),
        ));
      }
      await Future.delayed(
        const Duration(milliseconds: 500),
        () => _replaceBrowserHistory(uri: result.value2)
      );
    }

    _getAllIdentities();
    notifyThreadDetailSettingUpdated();
    getServerSetting();
    spamReportController.getSpamReportStateAction();
    loadAIScribeConfig();
    if (isLabelCapabilitySupported && accountId.value != null) {
      labelController.checkLabelSettingState(accountId.value!);
    }
  }

  void _handleUpdateVacationSuccess(UpdateVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty) {
      if (!success.isAuto &&
          currentContext != null &&
          currentOverlayContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully,
        );
      }
      vacationResponse.value = success.listVacationResponse.first;
      log('MailboxDashBoardController::_handleUpdateVacationSuccess(): $vacationResponse');
    }
  }

  void selectHasAttachmentSearchFilter() {
    searchController.updateFilterEmail(hasAttachmentOption: const Some(true));
    dispatchAction(StartSearchEmailAction());
  }

  Future<void> selectFromSearchFilter({required AppLocalizations appLocalizations}) async {
    if (accountId.value == null || sessionCurrent == null) return;

    final contactArgument = ContactArguments(
      accountId: accountId.value!,
      session: sessionCurrent!,
      selectedContactList: searchController.searchEmailFilter.value.from,
      contactViewTitle: '${appLocalizations.findEmails} ${appLocalizations.from_email_address_prefix.toLowerCase()}'
    );

    final newListContact = await DialogRouter().pushGeneralDialog(
      routeName: AppRoutes.contact,
      arguments: contactArgument);

    if (newListContact is List<EmailAddress>) {
      final listMailAddress = newListContact
        .map((emailAddress) => emailAddress.emailAddress)
        .toSet();
      searchController.updateFilterEmail(fromOption: Some(listMailAddress));
      dispatchAction(StartSearchEmailAction());
    }
  }

  Future<void> selectToSearchFilter({required AppLocalizations appLocalizations}) async {
    if (accountId.value == null || sessionCurrent == null) return;

    final contactArgument = ContactArguments(
      accountId: accountId.value!,
      session: sessionCurrent!,
      selectedContactList: searchController.searchEmailFilter.value.to,
      contactViewTitle: '${appLocalizations.findEmails} ${appLocalizations.to_email_address_prefix.toLowerCase()}'
    );

    final newListContact = await DialogRouter().pushGeneralDialog(
      routeName: AppRoutes.contact,
      arguments: contactArgument);

    if (newListContact is List<EmailAddress>) {
      final listMailAddress = newListContact
        .map((emailAddress) => emailAddress.emailAddress)
        .toSet();
      searchController.updateFilterEmail(toOption: Some(listMailAddress));
      dispatchAction(StartSearchEmailAction());
    }
  }

  Future<void> selectFolderSearchFilter() async {
    if (accountId.value == null || sessionCurrent == null) return;

    final mailboxIdSelected = searchController.mailboxFiltered?.id;

    final destinationArgument = DestinationPickerArguments(
      accountId.value!,
      MailboxActions.select,
      sessionCurrent!,
      mailboxIdSelected: mailboxIdSelected);

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter().pushGeneralDialog(
          routeName: AppRoutes.destinationPicker,
          arguments: destinationArgument)
      : await push(
          AppRoutes.destinationPicker,
          arguments: destinationArgument);

    if (destinationMailbox is! PresentationMailbox) return;

    searchController.updateFilterEmail(
      mailboxOption: destinationMailbox.id == PresentationMailbox.unifiedMailbox.id
        ? const None()
        : Some(destinationMailbox)
    );

    dispatchAction(StartSearchEmailAction());
  }

  void selectReceiveTimeQuickSearchFilter(BuildContext context, EmailReceiveTimeType receiveTime) {
    log('MailboxDashBoardController::selectReceiveTimeQuickSearchFilter():receiveTime: $receiveTime');
    if (receiveTime == EmailReceiveTimeType.customRange) {
      searchController.showMultipleViewDateRangePicker(
        context,
        searchController.startDateFiltered,
        searchController.endDateFiltered,
        onCallbackAction: (startDate, endDate) {
          dispatchAction(SelectDateRangeToAdvancedSearch(startDate, endDate));
          searchController.updateFilterEmail(
            emailReceiveTimeTypeOption: Some(receiveTime),
            startDateOption: optionOf(startDate?.toUTCDate()),
            endDateOption: optionOf(endDate?.toUTCDate())
          );
          dispatchAction(StartSearchEmailAction());
        }
      );
    } else {
      dispatchAction(ClearDateRangeToAdvancedSearch(receiveTime));
      searchController.updateFilterEmail(
        emailReceiveTimeTypeOption: Some(receiveTime),
        startDateOption: const None(),
        endDateOption: const None()
      );
      dispatchAction(StartSearchEmailAction());
    }
  }

  void selectSortOrderQuickSearchFilter(EmailSortOrderType sortOrder) {
    log('MailboxDashBoardController::selectSortOrderQuickSearchFilter():sortOrder: $sortOrder');
    searchController.updateFilterEmail(sortOrderTypeOption: Some(sortOrder));
    storeEmailSortOrder(sortOrder);
    dispatchAction(StartSearchEmailAction());
  }

  void _deleteDateTimeSearchFilter() {
    dispatchAction(ClearDateRangeToAdvancedSearch(EmailReceiveTimeType.allTime));
    searchController.updateFilterEmail(
      emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.allTime),
      startDateOption: const None(),
      endDateOption: const None()
    );
    dispatchAction(StartSearchEmailAction());
  }

  void _deleteSortOrderSearchFilter() {
    searchController.updateFilterEmail(
      sortOrderTypeOption: const Some(SearchEmailFilter.defaultSortOrder));
    storeEmailSortOrder(SearchEmailFilter.defaultSortOrder);
    dispatchAction(StartSearchEmailAction());
  }

  void _deleteFromSearchFilter() {
    searchController.updateFilterEmail(fromOption: const None());
    dispatchAction(StartSearchEmailAction());
  }

  void _deleteToSearchFilter() {
    searchController.updateFilterEmail(toOption: const None());
    dispatchAction(StartSearchEmailAction());
  }

  void _deleteHasAttachmentSearchFilter() {
    searchController.updateFilterEmail(hasAttachmentOption: const None());
    dispatchAction(StartSearchEmailAction());
  }

  void _deleteFolderSearchFilter() {
    searchController.updateFilterEmail(mailboxOption: const None());
    dispatchAction(StartSearchEmailAction());
  }

  void onDeleteSearchFilterAction(QuickSearchFilter searchFilter) {
    switch(searchFilter) {
      case QuickSearchFilter.dateTime:
        _deleteDateTimeSearchFilter();
        break;
      case QuickSearchFilter.sortBy:
        _deleteSortOrderSearchFilter();
        break;
      case QuickSearchFilter.from:
        _deleteFromSearchFilter();
        break;
      case QuickSearchFilter.hasAttachment:
        _deleteHasAttachmentSearchFilter();
        break;
      case QuickSearchFilter.to:
        _deleteToSearchFilter();
        break;
      case QuickSearchFilter.folder:
        _deleteFolderSearchFilter();
        break;
      case QuickSearchFilter.starred:
      case QuickSearchFilter.unread:
      case QuickSearchFilter.labels:
        deleteQuickSearchFilter(filter: searchFilter);
        break;
      default:
        break;
    }
  }

  bool isEmptyTrashBannerEnabledOnWeb(
    BuildContext context,
    PresentationMailbox? mailbox
  ) {
    return mailbox != null &&
      mailbox.isTrash &&
      mailbox.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      responsiveUtils.isWebDesktop(context);
  }

  bool isEmptyTrashBannerEnabledOnMobile(
    BuildContext context,
    PresentationMailbox? mailbox
  ) {
    return mailbox != null &&
      mailbox.isTrash &&
      mailbox.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      !responsiveUtils.isWebDesktop(context);
  }

  void emptyTrashAction() {
    dispatchAction(EmptyTrashAction());
  }

  void refreshActionWhenBackToApp() {
    log('MailboxDashBoardController::refreshActionWhenBackToApp():');
    _refreshActionEventController.add(RefreshActionViewEvent());
  }

  void _handleRefreshActionWhenBackToApp(RefreshActionViewEvent viewEvent) {
    log('MailboxDashBoardController::_handleRefreshActionWhenBackToApp():');
    dispatchEmailUIAction(RefreshChangeEmailAction(
      newState: jmap.State('refresh-action-when-back-to-app-state-${DateTime.now().millisecondsSinceEpoch}'),
    ));
    dispatchMailboxUIAction(RefreshChangeMailboxAction(
      newState: jmap.State('refresh-action-when-back-to-app-state-${DateTime.now().millisecondsSinceEpoch}'),
    ));
  }

  void _handleClickLocalNotificationOnForeground(NotificationResponse? response) {
    _notificationManager.activatedNotificationClickedOnTerminate = true;
    log('MailboxDashBoardController::_handleClickLocalNotificationOnForeground():payload: ${response?.payload}');
    _handleMessageFromNotification(response?.payload);
  }

  void _handleMessageFromNotification(String? payload, {bool onForeground = true}) async {
    log('MailboxDashBoardController::_handleMessageFromNotification():payload: $payload');
    if (payload == null || payload.isEmpty) {
      dispatchRoute(DashboardRoutes.thread);
      return;
    }

    final payloadDecoded = jsonDecode(payload);
    if (payloadDecoded is Map<String, dynamic>) {
      final notificationPayload = NotificationPayload.fromJson(payloadDecoded);
      log('MailboxDashBoardController::_handleMessageFromNotification():notificationPayload: $notificationPayload');

      if (notificationPayload.emailId != null) {
        _handleNotificationMessageFromEmailId(notificationPayload.emailId!, onForeground: onForeground);
      } else if (notificationPayload.newState != null) {
        _handleNotificationMessageFromNewState(notificationPayload.newState!, onForeground: onForeground);
      } else {
        dispatchRoute(DashboardRoutes.thread);
      }
    } else {
      dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _handleNotificationMessageFromNewState(jmap.State newState, {bool onForeground = true}) {
    if (onForeground) {
      _openInboxMailboxFromNotification();
    }
  }

  void _handleNotificationMessageFromEmailId(EmailId emailId, {bool onForeground = true}) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null) {
      if (onForeground) {
        _showWaitingView();
      }
      _getPresentationEmailFromEmailIdAction(emailId, currentAccountId, session);
    } else {
      dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _showWaitingView() {
    popAllRouteIfHave();
    dispatchRoute(DashboardRoutes.waiting);
  }

  void _openInboxMailboxFromNotification() {
    popAllRouteIfHave();
    dispatchMailboxUIAction(SelectMailboxDefaultAction());
    dispatchRoute(DashboardRoutes.thread);
  }

  void _getPresentationEmailFromEmailIdAction(EmailId emailId, AccountId accountId, Session session) {
    log('MailboxDashBoardController:_getPresentationEmailFromEmailIdAction:emailId: $emailId');
    consumeState(_getEmailByIdInteractor.execute(
      session,
      accountId,
      emailId,
      properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId)
    ));
  }

  void _handleGetEmailByIdFailure(GetEmailByIdFailure failure) {
    dispatchRoute(DashboardRoutes.thread);
  }

  void popAllRouteIfHave() {
    Get.until((route) => Get.currentRoute == AppRoutes.dashboard);
  }

  void handleOnForegroundGained() {
    log('MailboxDashBoardController::handleOnForegroundGained():');
    refreshActionWhenBackToApp();
  }

  void updateEmailList(List<PresentationEmail> newEmailList) {
    emailsInCurrentMailbox.value = newEmailList;
  }

  void openMailboxAction(PresentationMailbox presentationMailbox) {
    dispatchMailboxUIAction(OpenMailboxAction(presentationMailbox));
  }

  bool get enableSpamReport => spamReportController.enableSpamReport;

  void getSpamReportBanner() {
    if (enableSpamReport) {
      final spamId = spamMailboxId;
      if (spamId == null) {
        spamReportController.setSpamPresentationMailbox(null);
        return;
      }

      final spamMailbox = mapMailboxById[spamId];
      final unreadEmails = spamMailbox?.unreadEmails?.value.value ?? 0;
      if (unreadEmails > 0) {
        spamReportController.setSpamPresentationMailbox(spamMailbox);
      } else {
        spamReportController.setSpamPresentationMailbox(null);
      }
    }
  }

  void refreshSpamReportBanner() {
    if (enableSpamReport && sessionCurrent != null && accountId.value != null) {
      spamReportController.getSpamMailboxCached(accountId.value!, sessionCurrent!.username);
    }
  }

  void storeSpamReportStateAction() {
    final storeSpamReportState = enableSpamReport ? SpamReportState.disabled : SpamReportState.enabled;
    spamReportController.storeSpamReportStateAction(storeSpamReportState);
  }

  void onDragMailbox(bool isDragging) {
    _isDraggingMailbox.value = isDragging;
  }

  bool get isDraggingMailbox => _isDraggingMailbox.value;

  void _handleSendEmailFailure(SendEmailFailure failure) {
    logError('MailboxDashBoardController::_handleSendEmailFailure():failure: $failure');
    if (PlatformInfo.isMobile) {
      storeSendingEmailInCaseOfSendingFailureInMobile(failure);
    }
    if (currentContext == null) {
      clearState();
      return;
    }
    final exception = failure.exception;
    logError('MailboxDashBoardController::_handleSendEmailFailure():exception: $exception');
    if (exception is SetMethodException) {
      final listErrors = exception.mapErrors.values.toList();
      final toastSuccess = _handleSetErrors(listErrors);
      if (!toastSuccess) {
        _showToastSendMessageFailure(AppLocalizations.of(currentContext!).sendMessageFailure);
      }
    } else {
      _showToastSendMessageFailure(AppLocalizations.of(currentContext!).sendMessageFailure);
    }

    clearState();
  }

  bool _handleSetErrors(List<SetError> listErrors, {bool isDrafts = false}) {
    for (var error in listErrors) {
      if (error.type == SetError.tooLarge || error.type == SetError.overQuota) {
        if (isDrafts) {
          _showToastSendMessageFailure(error.toastMessageForSaveEmailAsDraftFailure(
            appLocalizations: AppLocalizations.of(currentContext!),
          ));
        } else {
          _showToastSendMessageFailure(error.toastMessageForSendEmailFailure(
            appLocalizations: AppLocalizations.of(currentContext!),
          ));
        }
        return true;
      }
    }
    return false;
  }

  void _showToastSendMessageFailure(String message) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        message,
        leadingSVGIcon: imagePaths.icSendSuccessToast);
    }
  }

  void _handleSaveEmailAsDraftsFailure(SaveEmailAsDraftsFailure failure) {
    logError('MailboxDashBoardController::_handleSaveEmailAsDraftsFailure():failure: $failure');
    if (currentContext == null) {
      clearState();
      return;
    }
    final exception = failure.exception;
    logError('MailboxDashBoardController::_handleSaveEmailAsDraftsFailure():exception: $exception');
    if (exception is SetMethodException) {
      final listErrors = exception.mapErrors.values.toList();
      final toastSuccess = _handleSetErrors(listErrors);
      if (!toastSuccess) {
        _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
      }
    } else {
      _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
    }

    clearState();
  }

  void _handleUpdateEmailAsDraftsFailure(UpdateEmailDraftsFailure failure) {
    logError('MailboxDashBoardController::_handleUpdateEmailAsDraftsFailure():failure: $failure');
    if (currentContext == null) {
      clearState();
      return;
    }
    final exception = failure.exception;
    logError('MailboxDashBoardController::_handleUpdateEmailAsDraftsFailure():exception: $exception');
    if (exception is SetMethodException) {
      final listErrors = exception.mapErrors.values.toList();
      final toastSuccess = _handleSetErrors(listErrors);
      if (!toastSuccess) {
        _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
      }
    } else {
      _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
    }

    clearState();
  }

  void handleSendEmailAction(SendingEmailArguments arguments) {
    switch(arguments.actionMode) {
      case ComposeActionMode.pushQueue:
        _handleStoreSendingEmail(
          arguments.session,
          arguments.accountId,
          arguments.emailRequest,
          arguments.mailboxRequest
        );
        break;
      case ComposeActionMode.editQueue:
        _tryToStoreSendingEmail(
          arguments.session,
          arguments.accountId,
          arguments.emailRequest,
          arguments.mailboxRequest
        );
        break;
      case ComposeActionMode.sent:
        consumeState(_sendEmailInteractor.execute(
          arguments.session,
          arguments.accountId,
          arguments.emailRequest,
          mailboxRequest: arguments.mailboxRequest
        ));
        break;
    }
  }

  void _handleStoreSendingEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
  ) {
    log('MailboxDashBoardController::_handleStoreSendingEmail:');
    final sendingEmail = emailRequest.toSendingEmail(uuid.v1(), mailboxRequest: mailboxRequest);
    consumeState(_storeSendingEmailInteractor.execute(
      accountId,
      session.username,
      sendingEmail
    ));
  }

  void storeSendingEmailInCaseOfSendingFailureInMobile(SendEmailFailure failure) {
    if (failure.session != null &&
        failure.accountId != null &&
        failure.emailRequest != null
    ) {
      _tryToStoreSendingEmail(
        failure.session!,
        failure.accountId!,
        failure.emailRequest!,
        failure.mailboxRequest
      );
    }
  }

  void _tryToStoreSendingEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
  ) {
    log('MailboxDashBoardController::_handleUpdateSendingEmail:');
    final storedSendingId = emailRequest.storedSendingId;
    if (storedSendingId != null) {
      final sendingEmail = emailRequest.toSendingEmail(storedSendingId, mailboxRequest: mailboxRequest);
      consumeState(_updateSendingEmailInteractor.execute(
        accountId,
        session.username,
        sendingEmail
      ));
    } else {
      logError('MailboxDashBoardController::_handleUpdateSendingEmail(): StoredSendingId is null');
      _handleStoreSendingEmail(
        session,
        accountId,
        emailRequest,
        mailboxRequest
      );
    }
  }

  void _handleStoreSendingEmailSuccess(StoreSendingEmailSuccess success) {
    getAllSendingEmails();
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastWarningMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).messageHasBeenSavedToTheSendingQueue,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icEmail);
    }
  }

  void _handleUpdateSendingEmailSuccess(UpdateSendingEmailSuccess success) async {
    getAllSendingEmails();
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastWarningMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).messageHasBeenSavedToTheSendingQueue,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icEmail);
    }
  }

  void getAllSendingEmails() {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_getAllSendingEmailInteractor.execute(
        accountId.value!,
        sessionCurrent!.username
      ));
    }
  }

  void _handleGetAllSendingEmailsSuccess(GetAllSendingEmailSuccess success) async {
    listSendingEmails.value = success.sendingEmails;

    if (listSendingEmails.isEmpty && dashboardRoute.value == DashboardRoutes.sendingQueue) {
      openDefaultMailbox();
    }
  }

  void openDefaultMailbox() {
    dispatchRoute(DashboardRoutes.thread);
    dispatchMailboxUIAction(SelectMailboxDefaultAction());
  }

  void _storeSessionAction(Session session) {
    consumeState(_storeSessionInteractor.execute(session));
  }

  void emptySpamFolderAction({
    Function? onCancelSelectionEmail,
    MailboxId? spamFolderId,
    int totalEmails = 0
  }) {
    onCancelSelectionEmail?.call();

    spamFolderId ??= spamMailboxId;
    final accountId = this.accountId.value;

    if (accountId == null || sessionCurrent == null) {
      consumeState(Stream.value(Left(EmptySpamFolderFailure(NotFoundSessionException()))));
      return;
    }

    if (spamFolderId == null) {
      consumeState(Stream.value(Left(EmptySpamFolderFailure(NotFoundSpamMailboxException()))));
      return;
    }

    if (CapabilityIdentifier.jmapMailboxClear.isSupported(sessionCurrent!, accountId)) {
      clearMailbox(
        sessionCurrent!,
        accountId,
        spamFolderId,
        PresentationMailbox.roleSpam,
      );
    } else {
      consumeState(_emptySpamFolderInteractor.execute(
        sessionCurrent!,
        accountId,
        spamFolderId,
        totalEmails,
        progressStateController,
      ));
    }
  }

  void _emptySpamFolderSuccess(EmptySpamFolderSuccess success) {
    syncViewStateMailboxActionProgress(newState: Right(UIState.idle));

    handleDeleteEmailsInMailbox(
      emailIds: success.emailIds,
      affectedMailboxId: success.mailboxId,
    );

    toastManager.showMessageSuccess(success);
  }

  bool isEmptySpamBannerEnabledOnWeb(
    BuildContext context,
    PresentationMailbox? mailbox
  ) {
    return mailbox != null &&
      mailbox.isSpam &&
      mailbox.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      responsiveUtils.isWebDesktop(context);
  }

  bool isEmptySpamBannerEnabledOnMobile(
    BuildContext context,
    PresentationMailbox? mailbox
  ) {
    return mailbox != null &&
      mailbox.isSpam &&
      mailbox.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      !responsiveUtils.isWebDesktop(context);
  }

  void openDialogEmptySpamFolder(BuildContext context) {
    final spamMailbox = selectedMailbox.value;
    if (spamMailbox == null || !spamMailbox.isSpam) {
      logError('MailboxDashBoardController::openDialogEmptySpamFolder: Selected mailbox is not spam');
      return;

    }
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).emptySpamMessageDialog)
        ..onCancelAction(AppLocalizations.of(context).cancel, popBack)
        ..onConfirmAction(AppLocalizations.of(context).delete_all, () {
          popBack();
          if (spamMailbox.countTotalEmails > 0) {
            emptySpamFolderAction(spamFolderId: spamMailbox.id, totalEmails: spamMailbox.countTotalEmails);
          } else {
            appToast.showToastWarningMessage(
              context,
              AppLocalizations.of(context).noEmailInYourCurrentFolder
            );
          }
        }))
          .show();
    } else {
      MessageDialogActionManager().showConfirmDialogAction(
        key: const Key('confirm_dialog_empty_spam'),
        context,
        title: AppLocalizations.of(context).emptySpamFolder,
        AppLocalizations.of(context).emptySpamMessageDialog,
        AppLocalizations.of(context).delete_all,
        cancelTitle: AppLocalizations.of(context).cancel,
        onConfirmAction: () {
          popBack();
          if (spamMailbox.countTotalEmails > 0) {
            emptySpamFolderAction(spamFolderId: spamMailbox.id, totalEmails: spamMailbox.countTotalEmails);
          } else {
            appToast.showToastWarningMessage(
              context,
              AppLocalizations.of(context).noEmailInYourCurrentFolder
            );
          }
        },
        onCloseButtonAction: popBack,
      );
    }
  }

  Future<void> refreshMailboxAction() async {
    updateRefreshAllMailboxState(Right(RefreshingAllMailbox()));
    updateRefreshAllEmailState(Right(RefreshingAllEmail()));

    await Future.delayed(const Duration(milliseconds: 500));

    dispatchMailboxUIAction(RefreshAllMailboxAction());
    dispatchEmailUIAction(RefreshAllEmailAction());
  }

  void updateRefreshAllMailboxState(Either<Failure, Success> newState) {
    refreshingAllMailboxState.value = newState;
  }

  void updateRefreshAllEmailState(Either<Failure, Success> newState) {
    refreshingAllEmailState.value = newState;
  }

  bool get isRefreshingAllMailboxAndEmail {
    final isRefreshingMailbox = refreshingAllMailboxState.value.fold(
      (failure) => false,
      (success) => success is RefreshingAllMailbox);
    final isRefreshingEmail = refreshingAllEmailState.value.fold(
      (failure) => false,
      (success) => success is RefreshingAllEmail);
    log('MailboxDashBoardController::isRefreshingAllMailboxAndEmail:isRefreshingMailbox = $isRefreshingMailbox | isRefreshingEmail = $isRefreshingEmail');
    return isRefreshingMailbox || isRefreshingEmail;
  }

  void selectAllEmailAction() {
    dispatchAction(SelectionAllEmailAction());
  }

  String get baseDownloadUrl {
    try {
      return sessionCurrent?.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl) ?? '';
    } catch (e) {
      logError('MailboxDashboardController::baseDownloadUrl(): $e');
      return '';
    }
  }

  void redirectToInboxAction() {
    log('MailboxDashBoardController::redirectToInboxAction:');
    final inboxId = getMailboxIdByRole(PresentationMailbox.roleInbox);
    if (inboxId == null) return;

    final inboxPresentation = mapMailboxById[inboxId];
    if (inboxPresentation == null) return;

    openMailboxAction(inboxPresentation);
  }

  bool get isAttachmentDraggableAppActive => attachmentDraggableAppState.value == DraggableAppState.active;

  bool get isLocalFileDraggableAppActive => localFileDraggableAppState.value == DraggableAppState.active;

  void enableAttachmentDraggableApp() {
    attachmentDraggableAppState.value = DraggableAppState.active;
  }

  void disableAttachmentDraggableApp() {
    attachmentDraggableAppState.value = DraggableAppState.inActive;
  }

  void _handleSendEmailSuccess(SendEmailSuccess success) {
    if (PlatformInfo.isMobile &&
        success.emailRequest.storedSendingId != null &&
        accountId.value != null &&
        sessionCurrent != null
    ) {
      consumeState(_deleteSendingEmailInteractor.execute(
        accountId.value!,
        sessionCurrent!.username,
        success.emailRequest.storedSendingId!
      ));
    }
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).message_has_been_sent_successfully,
        leadingSVGIcon: imagePaths.icSendSuccessToast
      );
    }

    if (success.emailRequest.emailActionType == EmailActionType.composeFromUnsubscribeMailtoLink &&
        success.emailRequest.previousEmailId != null) {
      unsubscribeMail(success.emailRequest.previousEmailId!);
    }

    if (success.emailRequest.isEmailAnswered) {
      updateEmailAnswered(success.emailRequest.emailIdAnsweredOrForwarded!);
    }

    if (success.emailRequest.isEmailForwarded) {
      updateEmailForwarded(success.emailRequest.emailIdAnsweredOrForwarded!);
    }
  }

  Future<List<EmailAddress>> getContactSuggestion(String query) async {
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();

    if (_getAutoCompleteInteractor == null || accountId.value == null) {
      return <EmailAddress>[];
    }

    if (query.length < minInputLengthAutocomplete) {
      return <EmailAddress>[];
    }

    final listEmailAddress = await _getAutoCompleteInteractor!
      .execute(AutoCompletePattern(word: query, accountId: accountId.value!, limit: 2))
      .then((value) => value.fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]
      ));
    log('MailboxDashBoardController::getAutoCompleteSuggestion:listEmailAddress: $listEmailAddress');
    return listEmailAddress;
  }

  void quickSearchEmailByFrom(EmailAddress emailAddress) {
    FocusManager.instance.primaryFocus?.unfocus();
    clearFilterMessageOption();
    searchController.clearFilterSuggestion();
    if (_searchInsideThreadDetailViewIsActive()) {
      _closeEmailDetailedView();
    }
    _unSelectedMailbox();
    dispatchAction(QuickSearchEmailByFromAction(emailAddress));
  }

  void unsubscribeMail(EmailId emailId) {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(
        _unsubscribeEmailInteractor.execute(
          sessionCurrent!,
          accountId.value!,
          emailId
        )
      );
    }
  }

  void _handleUnsubscribeMailSuccess(EmailId emailId) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).unsubscribedFromThisMailingList);
    }
    dispatchThreadDetailUIAction(UpdatedEmailKeywordsAction(
      emailId,
      KeyWordIdentifierExtension.unsubscribeMail,
      true,
    ));
    // Reset threadDetailUIAction
    dispatchThreadDetailUIAction(ThreadDetailUIAction());

    final listEmail = searchController.isSearchEmailRunning
      ? listResultSearch
      : emailsInCurrentMailbox;
    var newEmailIndex = listEmail.indexWhere((email) => email.id == emailId);
    if (newEmailIndex == -1) return;

    listEmail[newEmailIndex] = listEmail[newEmailIndex].updateKeywords({
      KeyWordIdentifierExtension.unsubscribeMail: true,
    });
  }

  void _replaceBrowserHistory({Uri? uri}) {
    log('MailboxDashBoardController::_replaceBrowserHistory:uri: $uri');
    if (PlatformInfo.isWeb) {
      final selectedMailboxId = selectedMailbox.value?.id;
      final selectedEmailId = selectedEmail.value?.id;
      final isSearchRunning = searchController.isSearchEmailRunning;
      String title = '';
      if (selectedEmail.value != null) {
        title = 'Email-${selectedEmailId?.asString ?? ''}';
      } else if (isSearchRunning) {
        title = 'SearchEmail';
      } else {
        title = 'Mailbox-${selectedMailboxId?.asString}';
      }
      RouteUtils.replaceBrowserHistory(
        title: title,
        url: uri ?? RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            emailId: selectedEmail.value?.id,
            mailboxId: isSearchRunning
              ? null
              : selectedMailboxId,
            dashboardType: isSearchRunning
              ? DashboardType.search
              : DashboardType.normal,
            searchQuery: isSearchRunning
              ? searchController.searchQuery
              : null
          )
        )
      );
    }
  }

  bool _navigateToScreen() {
    log('MailboxDashBoardController::_navigateToScreen: dashboardRoute: $dashboardRoute');
    switch(dashboardRoute.value) {
      case DashboardRoutes.thread:
        if (PlatformInfo.isMobile) {
          if (currentContext != null && canBack(currentContext!)) {
            return false;
          } else if (isSelectionEnabled()) {
            dispatchAction(CancelSelectionAllEmailAction());
            return true;
          } else if (selectedMailbox.value?.isInbox == true) {
            return false;
          } else {
            openDefaultMailbox();
            return true;
          }
        } else if (searchController.isSearchEmailRunning) {
          dispatchMailboxUIAction(SystemBackToInboxAction());
          return true;
        } else {
          if (PlatformInfo.isWeb &&
              currentContext != null &&
              !responsiveUtils.isDesktop(currentContext!) &&
              isDrawerOpen
          ) {
            closeMailboxMenuDrawer();
            return true;
          } else if (selectedMailbox.value?.isInbox == true) {
            pushAndPopAll(AppRoutes.home);
            return true;
          } else {
            openDefaultMailbox();
            return true;
          }
        }
      case DashboardRoutes.sendingQueue:
        if (PlatformInfo.isMobile) {
          openDefaultMailbox();
          return true;
        }
        return false;
      case DashboardRoutes.searchEmail:
        if (PlatformInfo.isMobile) {
          if (currentContext != null && canBack(currentContext!)) {
            return false;
          } else if (listResultSearch.any((email) => email.selectMode == SelectMode.ACTIVE)) {
            dispatchAction(CancelSelectionSearchEmailAction());
            return true;
          } else {
            dispatchAction(CloseSearchEmailViewAction());
            return true;
          }
        } else {
          dispatchAction(CloseSearchEmailViewAction());
          return true;
        }
      default:
        return false;
    }
  }

  bool get _isDialogViewOpen => Get.isOverlaysOpen == true;

  bool onBackButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    log('MailboxDashBoardController::onBackButtonInterceptor:currentRoute: ${Get.currentRoute} | _isDialogViewOpen: $_isDialogViewOpen');
    if (_isDialogViewOpen) {
      popBack();
      _replaceBrowserHistory();
      return true;
    }

    if (Get.currentRoute.startsWith(AppRoutes.dashboard)) {
      return _navigateToScreen();
    }

    return false;
  }

  void archiveMessage(PresentationEmail email) {
    final mailboxContain = email.findMailboxContain(mapMailboxById);
    if (mailboxContain != null) {
      final archiveMailboxId = getMailboxIdByRole(PresentationMailbox.roleArchive);
      if (archiveMailboxId != null) {
        final moveToArchiveMailboxRequest = MoveToMailboxRequest(
          {mailboxContain.id: [email.id!]},
          archiveMailboxId,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
          destinationPath: getMailboxNameById(archiveMailboxId),
        );
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          moveToArchiveMailboxRequest,
          {email.id!: email.hasRead}
        );
      }
    }
  }

  String getMailboxNameById(MailboxId mailboxId) {
    final mailbox = mapMailboxById[mailboxId];
    if (currentContext != null) {
      return mailbox?.getDisplayName(currentContext!) ?? '';
    } else {
      return mailbox?.name?.name ?? '';
    }
  }

  void _handleRestoreDeletedMessageSuccess(EmailRecoveryActionId emailRecoveryActionId) async {
    log('MailboxDashBoardController::_handleRestoreDeletedMessageSuccess():emailRecoveryActionId: $emailRecoveryActionId');
    _getRestoredDeletedMessage(emailRecoveryActionId);
  }

  void _getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId) {
    consumeState(_getRestoredDeletedMessageInteractor.execute(sessionCurrent!, accountId.value!, emailRecoveryActionId));
  }

  void _handleRestoreDeletedMessageFailed() {
    appToast.showToastErrorMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentOverlayContext!).restoreDeletedMessageFailed
    );
  }

  void _handleEmptySpamFolderFailure(EmptySpamFolderFailure failure) {
    syncViewStateMailboxActionProgress(newState: Right(UIState.idle));

    toastManager.showMessageFailure(failure);
  }

  void _handleEmptyTrashFolderFailure(EmptyTrashFolderFailure failure) {
    syncViewStateMailboxActionProgress(newState: Right(UIState.idle));

    toastManager.showMessageFailure(failure);
  }

  void _handleGetRestoredDeletedMessageSuccess(GetRestoredDeletedMessageSuccess success) async {
    if (selectedMailbox.value != null && selectedMailbox.value!.isRecovered) {
      dispatchEmailUIAction(RefreshChangeEmailAction(
        newState: jmap.State('restored-deleted-message-success-state-${DateTime.now().millisecondsSinceEpoch}'),
      ));
    }

    if (success is GetRestoredDeletedMessageCompleted) {
      isRecoveringDeletedMessage.value = false;
      if (success.recoveredMailbox != null) {
        appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).restoreDeletedMessageSuccess,
          actionName: AppLocalizations.of(currentContext!).open,
          onActionClick: () => openMailboxAction(success.recoveredMailbox!.toPresentationMailbox()),
          leadingSVGIcon: imagePaths.icRecoverDeletedMessages,
          leadingSVGIconColor: Colors.white,
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          actionIcon: SvgPicture.asset(
            imagePaths.icFolderMailbox,
            colorFilter: Colors.white.asFilter(),
          )
        );
      } else {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).restoreDeletedMessageSuccess
        );
      }
    } else if (success is GetRestoredDeletedMessageInProgress || success is GetRestoredDeletedMessageWaiting) {
      await Future.delayed(const Duration(seconds: 2));
      _getRestoredDeletedMessage(success.emailRecoveryAction.id!);
    } else if (success is GetRestoredDeletedMessageCanceled) {
      isRecoveringDeletedMessage.value = false;
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).restoreDeletedMessageCanceled,
        leadingSVGIcon: imagePaths.icRecoverDeletedMessages,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.primaryColor,
        textColor: Colors.white,
      );
    }
  }

  void gotoEmailRecovery() async {
    closeMailboxMenuDrawer();
    final currentAccountId = accountId.value;
    final currentSession = sessionCurrent;
    if (currentAccountId != null && currentSession != null) {
      final arguments = EmailRecoveryArguments(currentAccountId, currentSession);

      final result = PlatformInfo.isWeb 
      ? await DialogRouter().pushGeneralDialog(
          routeName: AppRoutes.emailRecovery,
          arguments: arguments,
        )
      : await push(AppRoutes.emailRecovery, arguments: arguments);

      if (result is EmailRecoveryAction) {
        log('MailboxDashBoardController::gotoEmailRecovery():result: $result');
        handleRestoreEmailAction(result);
      }
    }
  }

  void handleRestoreEmailAction(EmailRecoveryAction emailRecoveryAction) {
    log('MailboxController::_handleRestoreEmailAction');
    final generateId = Id(const Uuid().v4());
    final restoreDeletedMessageRequest = RestoredDeletedMessageRequest(generateId, emailRecoveryAction);

    consumeState(_restoreDeletedMessageInteractor.execute(sessionCurrent!, accountId.value!, restoreDeletedMessageRequest));
    isRecoveringDeletedMessage.value = true;
  }

  Future<void> removeComposerCacheByIdOnWeb(String composerId) async {
    if (accountId.value == null || sessionCurrent == null) return;

    await _removeComposerCacheByIdOnWebInteractor.execute(
      accountId.value!,
      sessionCurrent!.username,
      composerId,
    );
  }

  Future<void> removeAllComposerCacheOnWeb() async {
    if (accountId.value == null || sessionCurrent == null) return;

    await _removeAllComposerCacheOnWebInteractor.execute(
      accountId.value!,
      sessionCurrent!.username,
    );
  }

  bool validateSendingEmailFailedWhenNetworkIsLostOnMobile(dynamic failure) {
    return failure is SendEmailFailure &&
      failure.exception is NoNetworkError &&
      PlatformInfo.isMobile;
  }

  void _getAllIdentities() {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_getAllIdentitiesInteractor.execute(
        sessionCurrent!,
        accountId.value!
      ));
    } else {
      consumeState(Stream.value(Left(GetAllIdentitiesFailure(NotFoundAccountIdException()))));
    }
  }

  void _handleGetAllIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    log('MailboxDashBoardController::_handleGetAllIdentitiesSuccess: IDENTITIES_SIZE = ${_identities?.length}');
    final listIdentities = success.identities ?? [];

    final listIdentitiesMayDeleted = listIdentities.toListMayDeleted();
    _identities = listIdentitiesMayDeleted;

    updateOwnEmailAddressFromIdentities(listIdentities);
  }

  void _handleGetAllIdentitiesFailure() {
    _identities = null;
    updateOwnEmailAddressFromIdentities([]);
  }

  List<Identity> get listIdentities => _identities ?? [];

  bool validateNoEmailsInTrashAndSpamFolder() {
    return selectedMailbox.value != null
      && (selectedMailbox.value!.isTrash || selectedMailbox.value!.isSpam)
      && selectedMailbox.value!.countTotalEmails <= 0;
  }

  bool validateNoEmailsInTrashFolder() {
    return selectedMailbox.value != null
      && selectedMailbox.value!.isTrash
      && selectedMailbox.value!.countTotalEmails <= 0;
  }

  bool get isSearchFilterHasApplied {
    return searchController.searchEmailFilter.value.isApplied ||
      filterMessageOption.value != FilterMessageOption.all;
  }

  void openAdvancedSearchView() {
    dispatchAction(OpenAdvancedSearchViewAction());
    searchController.openAdvanceSearch();
  }

  void clearAllSearchFilterApplied() {
    dispatchAction(ClearSearchFilterAppliedAction());
  }

  void _setUpMinInputLengthAutocomplete() {
    if (sessionCurrent == null || accountId.value == null) {
      minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete;
    }
    minInputLengthAutocomplete = getMinInputLengthAutocomplete(
      session: sessionCurrent!,
      accountId: accountId.value!,
    );
  }

  void setCurrentEmailState(jmap.State? newState) {
    _currentEmailState = newState;
  }

  jmap.State? get currentEmailState => _currentEmailState;

  bool get isThreadDetailedViewVisible =>
      dashboardRoute.value == DashboardRoutes.threadDetailed;

  void _loadAppGrid() {
    if (PlatformInfo.isWeb && AppConfig.appGridDashboardAvailable) {
      appGridDashboardController.loadAppDashboardConfiguration();
    } else if (PlatformInfo.isMobile) {
      appGridDashboardController.loadAppGridLinagraEcosystem(
        dynamicUrlInterceptors.jmapUrl ?? '',
      );
    }
  }

  bool get isEmailOpened =>
      dashboardRoute.value == DashboardRoutes.threadDetailed;

  bool get isEmailListDisplayed =>
      dashboardRoute.value == DashboardRoutes.thread;

  @override
  void onClose() {
    if (PlatformInfo.isWeb) {
      listSearchFilterScrollController?.dispose();
      disposeReactiveObxVariableListener();
    }
    if (PlatformInfo.isIOS) {
      _iosNotificationManager?.dispose();
      _currentEmailIdInNotificationIOSStreamSubscription?.cancel();
    }
    if (PlatformInfo.isMobile) {
      _pendingSharedFileInfoSubscription?.cancel();
      _receivingFileSharingStreamSubscription?.cancel();
      _emailReceiveManager.closeEmailReceiveManagerStream();
      _deepLinkDataStreamSubscription?.cancel();
    }
    progressStateController.close();
    _refreshActionEventController.close();
    _notificationManager.closeStream();
    _fcmService.closeStream();
    applicationManager.releaseUserAgent();
    BackButtonInterceptor.removeByName(AppRoutes.dashboard);
    _identities = null;
    outboxMailbox = null;
    sessionCurrent = null;
    mapMailboxById = {};
    mapDefaultMailboxIdByRole = {};
    WebSocketController.instance.onClose();
    _currentEmailState = null;
    _isFirstSessionLoad = false;
    twakeAppManager.setHasComposer(false);
    paywallController?.onClose();
    paywallController = null;
    _downloadUIActionWorker?.dispose();
    _downloadUIActionWorker = null;
    super.onClose();
  }
}