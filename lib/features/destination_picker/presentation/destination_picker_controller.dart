
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_screen_type.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/special_character_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class DestinationPickerController extends BaseMailboxController {

  final SearchMailboxInteractor _searchMailboxInteractor;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;

  final mailboxAction = Rxn<MailboxActions>();
  final listMailboxSearched = <PresentationMailbox>[].obs;
  final searchState = SearchState.initial().obs;
  final searchQuery = SearchQuery.initial().obs;
  final destinationScreenType = DestinationScreenType.destinationPicker.obs;
  final mailboxDestination = Rxn<PresentationMailbox>();
  final newNameMailbox = Rxn<String>();

  DestinationPickerArguments? arguments;
  Session? _session;
  AccountId? accountId;
  MailboxId? mailboxIdSelected;

  List<String> listMailboxNameAsStringExist = <String>[];
  final FocusNode nameInputFocusNode = FocusNode();
  final FocusNode searchFocus = FocusNode();
  final TextEditingController nameInputController = TextEditingController();
  final TextEditingController searchInputController = TextEditingController();
  final destinationListScrollController = ScrollController();

  DestinationPickerController(
    this._searchMailboxInteractor,
    this._createNewMailboxInteractor,
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
    GetAllMailboxInteractor getAllMailboxInteractor,
    RefreshAllMailboxInteractor refreshAllMailboxInteractor
  ) : super(
    treeBuilder,
    verifyNameInteractor,
    getAllMailboxInteractor : getAllMailboxInteractor,
    refreshAllMailboxInteractor : refreshAllMailboxInteractor
  );

  @override
  void onInit() {
    super.onInit();
    log('DestinationPickerController::onInit():arguments: ${Get.arguments}');
    arguments = Get.arguments;
  }

  @override
  void onReady() {
    super.onReady();
    log('DestinationPickerController::onReady():');
    if (arguments != null) {
      mailboxAction.value = arguments!.mailboxAction;
      mailboxIdSelected = arguments!.mailboxIdSelected;
      accountId = arguments!.accountId;
      _session = arguments!.session;
      getAllMailboxAction();
    }
  }

  @override
  void handleSuccessViewState(Success success) async {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess)  {
      if (mailboxAction.value == MailboxActions.move && mailboxIdSelected != null) {
        await buildTree(
          success.mailboxList.listSubscribedMailboxesAndDefaultMailboxes,
          mailboxIdSelected: mailboxIdSelected);
      } else {
        await buildTree(success.mailboxList.listSubscribedMailboxesAndDefaultMailboxes);
      }
      if (currentContext != null) {
        syncAllMailboxWithDisplayName(currentContext!);
      }
    } else if (success is RefreshChangesAllMailboxSuccess) {
      await refreshTree(success.mailboxList.listSubscribedMailboxesAndDefaultMailboxes);
      if (currentContext != null) {
        syncAllMailboxWithDisplayName(currentContext!);
      }
    } else if (success is SearchMailboxSuccess) {
      _searchMailboxSuccess(success);
    } else if (success is CreateNewMailboxSuccess) {
      _createNewMailboxSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is SearchMailboxFailure) {
      _searchMailboxFailure(failure);
    } else if (failure is CreateNewMailboxFailure) {
      _createNewMailboxFailure(failure);
    }
  }

  @override
  void onClose() {
    log('DestinationPickerController::onClose():');
    nameInputFocusNode.dispose();
    nameInputController.dispose();
    searchFocus.dispose();
    searchInputController.dispose();
    destinationListScrollController.dispose();
    super.onClose();
  }

  void getAllMailboxAction() {
    if (accountId != null && _session != null) {
      getAllMailbox(_session!, accountId!);
    }
  }

  void _refreshMailboxChanges(jmap.State currentMailboxState) {
    if (accountId != null && _session != null) {
      refreshMailboxChanges(_session!, accountId!, currentMailboxState);
    }
  }

  void toggleMailboxCategories(MailboxCategories categories) {
    switch(categories) {
      case MailboxCategories.exchange:
        final newExpandMode = mailboxCategoriesExpandMode.value.defaultMailbox == ExpandMode.EXPAND
          ? ExpandMode.COLLAPSE
          : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.defaultMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.personalFolders:
        final newExpandMode = mailboxCategoriesExpandMode.value.personalFolders == ExpandMode.EXPAND
          ? ExpandMode.COLLAPSE
          : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.personalFolders = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.teamMailboxes:
        final newExpandMode = mailboxCategoriesExpandMode.value.teamMailboxes == ExpandMode.EXPAND
          ? ExpandMode.COLLAPSE
          : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.teamMailboxes = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      default:
        return;
    }
  }

  bool isSearchActive() => searchState.value.searchStatus == SearchStatus.ACTIVE;

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
  }

  void setNewNameMailbox(String newName) => newNameMailbox.value = newName;

  String? getErrorInputNameString(BuildContext context) {
    final nameMailbox = newNameMailbox.value;

    if (nameInputFocusNode.hasFocus == false && nameMailbox == null) {
      return null;
    }

    return verifyNameInteractor.execute(
      nameMailbox,
      [
        EmptyNameValidator(),
        NameWithSpaceOnlyValidator(),
        DuplicateNameValidator(listMailboxNameAsStringExist),
        SpecialCharacterValidator()
      ]
    ).fold(
      (failure) {
        if (failure is VerifyNameFailure) {
          return failure.getMessage(context);
        } else {
          return null;
        }
      },
      (success) => null
    );
  }

  bool isCreateMailboxValidated(BuildContext context) {
    final nameValidated = getErrorInputNameString(context);

    if (nameInputFocusNode.hasFocus == false && newNameMailbox.value == null) {
      return false;
    }

    if (nameValidated?.isNotEmpty == true) {
      return false;
    }
    return true;
  }

  void _createListMailboxNameAsStringInMailboxLocation() {
    if (mailboxDestination.value == null ||
        mailboxDestination.value == PresentationMailbox.unifiedMailbox) {
      final allChildrenAtMailboxLocation = (defaultMailboxTree.value.root.childrenItems ?? <MailboxNode>[]) +
          (personalMailboxTree.value.root.childrenItems ?? <MailboxNode>[]);
      if (allChildrenAtMailboxLocation.isNotEmpty) {
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.nameNotEmpty)
            .map((mailboxNode) => mailboxNode.mailboxNameAsString)
            .toList();
      }  else {
        listMailboxNameAsStringExist = [];
      }
    } else {
      final mailboxNodeLocation = findMailboxNodeById(mailboxDestination.value!.id);
      if (mailboxNodeLocation != null && mailboxNodeLocation.childrenItems?.isNotEmpty == true) {
        final allChildrenAtMailboxLocation =  mailboxNodeLocation.childrenItems!;
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.nameNotEmpty)
            .map((mailboxNode) => mailboxNode.mailboxNameAsString)
            .toList();
      } else {
        listMailboxNameAsStringExist = [];
      }
    }
  }

  void disableSearch(BuildContext context) {
    listMailboxSearched.clear();
    searchState.value = searchState.value.disableSearchState();
    searchQuery.value = SearchQuery.initial();
    searchInputController.clear();
    KeyboardUtils.hideKeyboard(context);
  }

  void clearSearchText() {
    searchQuery.value = SearchQuery.initial();
    searchFocus.requestFocus();
    listMailboxSearched.clear();
  }

  void searchMailbox(BuildContext context, String value) {
    searchQuery.value = SearchQuery(value);
    final searchableMailboxList = mailboxAction.value == MailboxActions.moveEmail
      ? allMailboxes
      : allMailboxes.listPersonalMailboxes;

    final mailboxListWithDisplayName = searchableMailboxList
      .map((mailbox) => mailbox.withDisplayName(mailbox.getDisplayName(context)))
      .toList();

    _searchMailboxAction(mailboxListWithDisplayName, searchQuery.value);
  }

  void _searchMailboxAction(List<PresentationMailbox> allMailboxes, SearchQuery searchQuery) {
    if (searchQuery.value.isNotEmpty) {
      consumeState(_searchMailboxInteractor.execute(allMailboxes, searchQuery));
    } else {
      listMailboxSearched.clear();
    }
  }

  void _searchMailboxSuccess(SearchMailboxSuccess success) {
    final mailboxesSearchedWithPath = findMailboxPath(success.mailboxesSearched);
    listMailboxSearched.value = mailboxesSearchedWithPath;
  }

  void _searchMailboxFailure(SearchMailboxFailure failure) {
    listMailboxSearched.clear();
  }

  void openCreateNewMailboxView(BuildContext context) async {
    if (mailboxDestination.value == null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageErrorNotSelectedFolderWhenCreateNewMailbox);
    } else {
      destinationScreenType.value = DestinationScreenType.createNewMailbox;
      _createListMailboxNameAsStringInMailboxLocation();
    }
  }

  void _dispatchCreateNewMailboxFolder(
    Session session,
    AccountId accountId,
    CreateNewMailboxRequest request
  ) async {
    consumeState(_createNewMailboxInteractor.execute(session, accountId, request));
  }

  void _createNewMailboxSuccess(CreateNewMailboxSuccess success) {
    if (currentContext != null) {
      disableSearch(currentContext!);
    }

    if (success.currentMailboxState != null) {
      _refreshMailboxChanges(success.currentMailboxState!);
    } else {
      getAllMailboxAction();
    }
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!).createNewFolderFailure;
      if (exception is ErrorMethodResponse) {
        messageError = exception.description ?? AppLocalizations.of(currentContext!).createNewFolderFailure;
      }
      appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void selectMailboxAction(
      PresentationMailbox? presentationMailbox,
      {MailboxNode? mailboxNode}
  ) {
    if (mailboxDestination.value == presentationMailbox) {
      return;
    }
    mailboxDestination.value = presentationMailbox;
    if (presentationMailbox == null ||
        presentationMailbox.id == PresentationMailbox.unifiedMailbox.id) {
      unAllSelectedMailboxNode();
    } else {
      if (mailboxNode != null) {
        unAllSelectedMailboxNode();
        selectMailboxNode(mailboxNode);
      } else {
        final matchedMailboxNode = findMailboxNodeById(presentationMailbox.id);
        if (matchedMailboxNode != null) {
          unAllSelectedMailboxNode();
          selectMailboxNode(matchedMailboxNode);
        }
      }
    }
  }

  void dispatchSelectMailboxDestination(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);

    if (mailboxDestination.value == null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageErrorNotSelectedFolderWhenCreateNewMailbox);
      return;
    }
    popBack(result: mailboxDestination.value);
  }

  void createNewMailboxAction(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);

    final nameMailbox = newNameMailbox.value;
    if (nameMailbox != null && nameMailbox.isNotEmpty) {
      final parentId = mailboxDestination.value == PresentationMailbox.unifiedMailbox
        ? null
        : mailboxDestination.value?.id;

      _dispatchCreateNewMailboxFolder(
        _session!,
        accountId!,
        CreateNewMailboxRequest(
          MailboxName(nameMailbox),
          parentId: parentId));
    }

    backToDestinationScreen(context);
  }

  void backToDestinationScreen(BuildContext context) {
    nameInputController.clear();
    KeyboardUtils.hideKeyboard(context);
    destinationScreenType.value = DestinationScreenType.destinationPicker;
  }

  void closeDestinationPicker(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    popBack();
  }
}