import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/date_range_picker_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_all_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/controller/input_field_focus_manager.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_arguments.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_time_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class EmailRecoveryController extends BaseController with DateRangePickerMixin {
  GetAllAutoCompleteInteractor? _getAllAutoCompleteInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  GetDeviceContactSuggestionsInteractor? _getDeviceContactSuggestionsInteractor;

  final deletionDateFieldSelected = EmailRecoveryTimeType.last1Year.obs;
  final receptionDateFieldSelected = EmailRecoveryTimeType.allTime.obs;
  final startDeletionDate = Rxn<DateTime>();
  final endDeletionDate = Rxn<DateTime>();
  final startReceptionDate = Rxn<DateTime>();
  final endReceptionDate = Rxn<DateTime>();
  final hasAttachment = false.obs;
  final recipientsExpandMode = ExpandMode.EXPAND.obs;
  final senderExpandMode = ExpandMode.EXPAND.obs;

  final focusManager = InputFieldFocusManager.initial();

  List<EmailAddress> listRecipients = <EmailAddress>[];
  List<EmailAddress> listSenders = <EmailAddress>[];

  TextEditingController subjectFieldInputController = TextEditingController();
  TextEditingController recipientsFieldInputController = TextEditingController();
  TextEditingController senderFieldInputController = TextEditingController();
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final GlobalKey<TagsEditorState> recipientsFieldKey = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> senderFieldKey = GlobalKey<TagsEditorState>();

  EmailRecoveryArguments? arguments;
  AccountId? _accountId;
  Session? _session;

  EmailRecoveryController();

  @override
  void onInit() {
    _registerFocusListener();
    log('EmailRecoveryController::onInit():arguments: ${Get.arguments}');
    arguments = Get.arguments;
    super.onInit();
  }

  @override
  void onReady() {
    log('EmailRecoveryController::onReady():');
    if (arguments != null) {
      _accountId = arguments!.accountId;
      _session = arguments!.session;
    }
    if (PlatformInfo.isMobile) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _checkContactPermission(),
      );
    }
    injectAutoCompleteBindings(_session, _accountId);
    super.onReady();
  }

  int get minInputLengthAutocomplete {
    if (_session == null || _accountId == null) {
      return AppConfig.defaultMinInputLengthAutocomplete;
    }
    return getMinInputLengthAutocomplete(
      session: _session!,
      accountId: _accountId!);
  }

  void _checkContactPermission() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      _contactSuggestionSource = ContactSuggestionSource.all;
    } else if (!permissionStatus.isPermanentlyDenied) {
      final requestedPermission = await Permission.contacts.request();
      _contactSuggestionSource = 
        requestedPermission == PermissionStatus.granted
          ? ContactSuggestionSource.all
          : _contactSuggestionSource;
    }
  }

  void _registerFocusListener() {
    focusManager.subjectFieldFocusNode.addListener(_onSubjectFieldFocusChanged);
    focusManager.recipientsFieldFocusNode.addListener(_onRecipientsFieldFocusChanged);
    focusManager.senderFieldFocusNode.addListener(_onSenderFieldFocusChanged);
  }

  void _onSubjectFieldFocusChanged() {
    if (focusManager.subjectFieldFocusNode.hasFocus) {
      senderExpandMode.value = ExpandMode.COLLAPSE;
      recipientsExpandMode.value = ExpandMode.COLLAPSE;
      _closeSuggestionBox();
    }
  }

  void _onRecipientsFieldFocusChanged() {
    if (focusManager.recipientsFieldFocusNode.hasFocus) {
      recipientsExpandMode.value = ExpandMode.EXPAND;
      senderExpandMode.value = ExpandMode.COLLAPSE;
      _closeSuggestionBox();
    }
  }

  void _onSenderFieldFocusChanged() {
    if (focusManager.senderFieldFocusNode.hasFocus) {
      senderExpandMode.value = ExpandMode.EXPAND;
      recipientsExpandMode.value = ExpandMode.COLLAPSE;
      _closeSuggestionBox();
    }
  }

  void _closeSuggestionBox() {
    if (recipientsFieldInputController.text.isNotEmpty) {
      recipientsFieldKey.currentState?.closeSuggestionBox();
    }

    if (senderFieldInputController.text.isNotEmpty) {
      senderFieldKey.currentState?.closeSuggestionBox();
    }
  }

  void onSelectDeletionDateRange(BuildContext context) {
    showMultipleViewDateRangePicker(
      context,
      startDeletionDate.value,
      endDeletionDate.value,
      onCallbackAction: (startDate, endDate) {
        _updateDateRangeTime(
          EmailRecoveryField.deletionDate,
          EmailRecoveryTimeType.customRange,
          startDate: startDate,
          endDate: endDate,
        );
      }
    );
  }

  void onSelectReceptionDateRange(BuildContext context) {
    showMultipleViewDateRangePicker(
      context,
      startReceptionDate.value,
      endReceptionDate.value,
      onCallbackAction: (startDate, endDate) {
        _updateDateRangeTime(
          EmailRecoveryField.receptionDate,
          EmailRecoveryTimeType.customRange,
          startDate: startDate,
          endDate: endDate,
        );
      }
    );
  }

  void _updateDateRangeTime(
    EmailRecoveryField field,
    EmailRecoveryTimeType recoveryTimeType,
    {
      DateTime? startDate,
      DateTime? endDate,
    }
  ) {
    if (field == EmailRecoveryField.deletionDate) {
      deletionDateFieldSelected.value = recoveryTimeType;
      startDeletionDate.value = startDate;
      endDeletionDate.value = endDate;
    } else {
      receptionDateFieldSelected.value = recoveryTimeType;
      startReceptionDate.value = startDate;
      endReceptionDate.value = endDate;
    }
  }

  void onDeletionDateTypeSelected(BuildContext context, EmailRecoveryTimeType type) {
    if (type == EmailRecoveryTimeType.customRange) {
      onSelectDeletionDateRange(context);
    } else {
      _updateDateRangeTime(
        EmailRecoveryField.deletionDate,
        type,
        startDate: type.toLatestUTCDate()?.value,
        endDate: DateTime.now(),
      );
    }
  }

  void onReceptionDateTypeSelected(BuildContext context, EmailRecoveryTimeType type) {
    if (type == EmailRecoveryTimeType.customRange) {
      onSelectReceptionDateRange(context);
    } else {
      _updateDateRangeTime(
        EmailRecoveryField.receptionDate,
        type,
      );
    }
  }

  void onChangeHasAttachment(bool? value) {
    hasAttachment.value = value ?? false;
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word, {int? limit}) async {
    log('EmailRecoveryController::getAutoCompleteSuggestion():  $word | $_contactSuggestionSource');
    _getAllAutoCompleteInteractor = getBinding<GetAllAutoCompleteInteractor>();
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();
    _getDeviceContactSuggestionsInteractor = getBinding<GetDeviceContactSuggestionsInteractor>();

    final autoCompletePattern = AutoCompletePattern(
      word: word,
      limit: limit,
      accountId: _accountId
    );

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAllAutoCompleteInteractor != null) {
        return await _getAllAutoCompleteInteractor!
          .execute(autoCompletePattern)
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      } else if (_getDeviceContactSuggestionsInteractor != null) {
        return await _getDeviceContactSuggestionsInteractor!
          .execute(autoCompletePattern)
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetDeviceContactSuggestionsSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      } else {
        return <EmailAddress>[];
      }
    } else {
      if (_getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      } else {
        return await _getAutoCompleteInteractor!
          .execute(autoCompletePattern)
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]
          ));
      }
    }
  }

  void showFullEmailAddress(EmailRecoveryField field) {
    switch (field) {
      case EmailRecoveryField.recipients:
        recipientsExpandMode.value = ExpandMode.EXPAND;
        break;
      case EmailRecoveryField.sender:
        senderExpandMode.value = ExpandMode.EXPAND;
        break;
      default:
        break;
    }
  }

  void updateListEmailAddress(
    EmailRecoveryField field,
    List<EmailAddress> listEmailAddress,
  ) {
    switch (field) {
      case EmailRecoveryField.recipients:
        listRecipients = List.from(listEmailAddress);
        log('EmailRecoveryController::updateListEmailAddress(): listRecipients: ${listRecipients.first}');
        break;
      case EmailRecoveryField.sender:
        listSenders = List.from(listEmailAddress);
        log('EmailRecoveryController::updateListEmailAddress(): listSenders: ${listSenders.first}');
        break;
      default:
        break;
    }
  }

  void onRestore(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    
    UTCDate? deletedBefore;
    UTCDate? deletedAfter;
    UTCDate? receivedBefore;
    UTCDate? receivedAfter;
    if (deletionDateFieldSelected.value == EmailRecoveryTimeType.customRange) {
      deletedBefore = endDeletionDate.value?.toUTCDate();
      deletedAfter = startDeletionDate.value?.toUTCDate();
      receivedBefore = endReceptionDate.value?.toUTCDate();
      receivedAfter = startReceptionDate.value?.toUTCDate();
    } else {
      deletedBefore = DateTime.now().toUTCDate();
      deletedAfter = deletionDateFieldSelected.value.toOldestUTCDate();
      receivedBefore = DateTime.now().toUTCDate();
      receivedAfter = receptionDateFieldSelected.value.toOldestUTCDate();
    }
    
    final emailRecoveryAction = EmailRecoveryAction(
      deletedBefore: deletedBefore,
      deletedAfter: deletedAfter,
      receivedBefore: receivedBefore,
      receivedAfter: receivedAfter,
      hasAttachment: hasAttachment.value,
      subject: subjectFieldInputController.text,
      recipients: listRecipients.isNotEmpty ?
        listRecipients.map((emailAddress) => emailAddress.emailAddress).toList()
        : null,
      sender: listSenders.isNotEmpty ?
        listSenders.first.emailAddress
        : null
    );

    log('EmailRecoveryController::onRestore(): emailRecoveryAction: $emailRecoveryAction');

    popBack(result: emailRecoveryAction);
  }

  void closeView(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    popBack();
  }

  @override
  void dispose() {
    focusManager.subjectFieldFocusNode.removeListener(_onSubjectFieldFocusChanged);
    focusManager.recipientsFieldFocusNode.removeListener(_onRecipientsFieldFocusChanged);
    focusManager.senderFieldFocusNode.removeListener(_onSenderFieldFocusChanged);
    subjectFieldInputController.dispose();
    recipientsFieldInputController.dispose();
    senderFieldInputController.dispose();
    focusManager.dispose();
    super.dispose();
  }
}