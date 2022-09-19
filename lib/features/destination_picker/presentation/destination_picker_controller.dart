
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class DestinationPickerController extends BaseMailboxController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final SearchMailboxInteractor _searchMailboxInteractor;

  final mailboxAction = Rxn<MailboxActions>();
  final listMailboxSearched = <PresentationMailbox>[].obs;
  final mailboxIdSelected = Rxn<MailboxId>();
  final searchState = SearchState.initial().obs;
  final searchQuery = SearchQuery.initial().obs;
  final mailboxCategoriesExpandMode = MailboxCategoriesExpandMode.initial().obs;

  AccountId? accountId;
  final searchInputController = TextEditingController();
  final searchFocus = FocusNode();

  DestinationPickerController(
    this._getAllMailboxInteractor,
    this._searchMailboxInteractor,
    treeBuilder,
  ) : super(treeBuilder);

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments != null && arguments is DestinationPickerArguments) {
      mailboxAction.value = arguments.mailboxAction;
      mailboxIdSelected.value = arguments.mailboxIdSelected;
      accountId = arguments.accountId;
      getAllMailboxAction();
    }
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.map((success) {
      if (success is GetAllMailboxSuccess) {
        if (mailboxAction.value == MailboxActions.move && mailboxIdSelected.value != null) {
          final newMailboxList = success.mailboxList
              .where((mailbox) => mailbox.id != mailboxIdSelected.value)
              .toList();
          buildTree(newMailboxList);
        } else {
          buildTree(success.mailboxList);
        }
      }
    });
  }

  @override
  void onDone() {
    viewState.value.fold(
        (failure) {
          if (failure is SearchMailboxFailure) {
            _searchMailboxFailure(failure);
          }
        },
        (success) {
          if (success is SearchMailboxSuccess) {
            _searchMailboxSuccess(success);
          }
        }
    );
  }

  @override
  void onError(error) {}

  @override
  void onClose() {
    searchInputController.dispose();
    searchFocus.dispose();
    super.onClose();
  }

  void getAllMailboxAction() {
    if (accountId != null) {
      consumeState(_getAllMailboxInteractor.execute(accountId!));
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
    }
  }

  bool isSearchActive() => searchState.value.searchStatus == SearchStatus.ACTIVE;

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSearch(BuildContext context) {
    listMailboxSearched.clear();
    searchState.value = searchState.value.disableSearchState();
    searchQuery.value = SearchQuery.initial();
    searchInputController.clear();
    FocusScope.of(context).unfocus();
  }

  void clearSearchText() {
    searchQuery.value = SearchQuery.initial();
    searchFocus.requestFocus();
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

  void selectMailboxAction(PresentationMailbox? destinationMailbox) {
    popBack(result: destinationMailbox);
  }

  void closeDestinationPicker() {
    popBack();
  }
}