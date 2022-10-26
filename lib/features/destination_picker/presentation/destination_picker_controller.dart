
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
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
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

typedef OnSelectedMailboxCallback = Function(PresentationMailbox? destinationMailbox);

class DestinationPickerController extends BaseMailboxController {

  final _uuid = Get.find<Uuid>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final SearchMailboxInteractor _searchMailboxInteractor;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;
  final RefreshAllMailboxInteractor _refreshAllMailboxInteractor;
  final VerifyNameInteractor _verifyNameInteractor;

  final mailboxAction = Rxn<MailboxActions>();
  final listMailboxSearched = <PresentationMailbox>[].obs;
  final searchState = SearchState.initial().obs;
  final searchQuery = SearchQuery.initial().obs;
  final mailboxCategoriesExpandMode = MailboxCategoriesExpandMode.initial().obs;
  final destinationScreenType = DestinationScreenType.destinationPicker.obs;
  final mailboxDestination = Rxn<PresentationMailbox>();
  final newNameMailbox = Rxn<String>();

  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputController;
  TextEditingController? searchInputController;
  FocusNode? searchFocus;
  DestinationPickerArguments? arguments;
  AccountId? accountId;
  MailboxId? mailboxIdSelected;
  OnSelectedMailboxCallback? onSelectedMailboxCallback;
  VoidCallback? onDismissDestinationPicker;

  List<String> listMailboxNameAsStringExist = <String>[];

  DestinationPickerController(
    this._getAllMailboxInteractor,
    this._searchMailboxInteractor,
    this._createNewMailboxInteractor,
    this._refreshAllMailboxInteractor,
    this._verifyNameInteractor,
    treeBuilder,
  ) : super(treeBuilder);

  @override
  void onInit() {
    super.onInit();
    nameInputFocusNode = FocusNode();
    nameInputController = TextEditingController();
    searchInputController = TextEditingController();
    searchFocus = FocusNode();
    searchFocus?.unfocus();
    nameInputFocusNode?.unfocus();
  }

  @override
  void onReady() {
    super.onReady();
    if (arguments != null) {
      mailboxAction.value = arguments!.mailboxAction;
      mailboxIdSelected = arguments!.mailboxIdSelected;
      accountId = arguments!.accountId;
      getAllMailboxAction();
    }
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.map((success) {
      if (success is GetAllMailboxSuccess) {
        if (mailboxAction.value == MailboxActions.move && mailboxIdSelected != null) {
          buildTree(success.mailboxList, mailboxIdSelected: mailboxIdSelected);
        } else {
          buildTree(success.mailboxList);
        }
      } else if (success is RefreshChangesAllMailboxSuccess) {
        refreshTree(success.mailboxList);
      }
    });
  }

  @override
  void onDone() {
    viewState.value.fold(
        (failure) {
          if (failure is SearchMailboxFailure) {
            _searchMailboxFailure(failure);
          } else if (failure is CreateNewMailboxFailure) {
            _createNewMailboxFailure(failure);
          }
        },
        (success) {
          if (success is SearchMailboxSuccess) {
            _searchMailboxSuccess(success);
          } else if (success is CreateNewMailboxSuccess) {
            _createNewMailboxSuccess(success);
          }
        }
    );
  }

  @override
  void onError(error) {}

  @override
  void onClose() {
    _disposeWidget();
    super.onClose();
  }

  void getAllMailboxAction() {
    if (accountId != null) {
      consumeState(_getAllMailboxInteractor.execute(accountId!));
    }
  }

  void _refreshMailboxChanges(jmap.State currentMailboxState) {
    if (accountId != null) {
      consumeState(_refreshAllMailboxInteractor.execute(accountId!, currentMailboxState));
    }
  }

  void toggleMailboxCategories(MailboxCategories categories) {
    switch(categories) {
      case MailboxCategories.exchange:
        final newExpandMode = mailboxCategoriesExpandMode.value.defaultMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.defaultMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.folders:
        final newExpandMode = mailboxCategoriesExpandMode.value.folderMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.folderMailbox = newExpandMode;
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

    if (nameInputFocusNode?.hasFocus == false && nameMailbox == null) {
      return null;
    }

    return _verifyNameInteractor.execute(
      nameMailbox,
      [
        EmptyNameValidator(),
        DuplicateNameValidator(listMailboxNameAsStringExist),
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

    if (nameInputFocusNode?.hasFocus == false && newNameMailbox.value == null) {
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
          (folderMailboxTree.value.root.childrenItems ?? <MailboxNode>[]);
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
    searchInputController?.clear();
    FocusScope.of(context).unfocus();
  }

  void clearSearchText() {
    searchQuery.value = SearchQuery.initial();
    searchFocus?.requestFocus();
    listMailboxSearched.clear();
  }

  void searchMailbox(String value) {
    searchQuery.value = SearchQuery(value);
    _searchMailboxAction(allMailboxes, searchQuery.value);
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
      _appToast.showBottomToast(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageErrorNotSelectedFolderWhenCreateNewMailbox,
        leadingIcon: SvgPicture.asset(
          _imagePaths.icNotConnection,
          width: 24,
          height: 24,
          color: Colors.white,
          fit: BoxFit.fill),
        backgroundColor: AppColor.toastErrorBackgroundColor,
        textColor: Colors.white,
        textActionColor: Colors.white,
        maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!));
    } else {
      destinationScreenType.value = DestinationScreenType.createNewMailbox;
      _createListMailboxNameAsStringInMailboxLocation();
    }
  }

  void _dispatchCreateNewMailboxFolder(
      AccountId accountId,
      CreateNewMailboxRequest request
  ) async {
    consumeState(_createNewMailboxInteractor.execute(accountId, request));
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
      var messageError = AppLocalizations.of(currentContext!).create_new_mailbox_failure;
      if (exception is ErrorMethodResponse) {
        messageError = exception.description ?? AppLocalizations.of(currentContext!).create_new_mailbox_failure;
      }

      _appToast.showBottomToast(
          currentOverlayContext!,
          messageError,
          leadingIcon: SvgPicture.asset(
              _imagePaths.icNotConnection,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!));
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
    FocusScope.of(context).unfocus();

    if (mailboxDestination.value == null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(context).toastMessageErrorNotSelectedFolderWhenCreateNewMailbox,
          leadingIcon: SvgPicture.asset(
              _imagePaths.icNotConnection,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!));
      return;
    }

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onSelectedMailboxCallback?.call(mailboxDestination.value);
    } else {
      popBack(result: mailboxDestination.value);
    }
  }

  void createNewMailboxAction(BuildContext context) {
    FocusScope.of(context).unfocus();

    final nameMailbox = newNameMailbox.value;
    if (nameMailbox != null && nameMailbox.isNotEmpty) {
      final generateCreateId = Id(_uuid.v1());
      final parentId = mailboxDestination.value == PresentationMailbox.unifiedMailbox
        ? null
        : mailboxDestination.value?.id;

      _dispatchCreateNewMailboxFolder(
        accountId!,
        CreateNewMailboxRequest(
          generateCreateId,
          MailboxName(nameMailbox),
          parentId: parentId));
    }

    backToDestinationScreen(context);
  }

  void backToDestinationScreen(BuildContext context) {
    nameInputController?.clear();
    FocusScope.of(context).unfocus();
    destinationScreenType.value = DestinationScreenType.destinationPicker;
  }

  void _disposeWidget() {
    nameInputFocusNode?.dispose();
    nameInputFocusNode = null;
    nameInputController?.dispose();
    nameInputController = null;
    searchFocus?.dispose();
    searchFocus = null;
    searchInputController?.dispose();
    searchInputController = null;
  }

  void closeDestinationPicker(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onDismissDestinationPicker?.call();
    } else {
      popBack();
    }
  }
}