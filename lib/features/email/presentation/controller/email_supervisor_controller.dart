import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/model/page_view_navigator_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class EmailSupervisorController extends GetxController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final Queue<EmailLoaded> presentationEmailsLoaded = Queue();
  PageController? pageController;

  int _currentEmailIndex = -1;
  final List<PresentationEmail> _currentListEmail = <PresentationEmail>[];

  final pageViewNavigatorState = PageViewNavigatorState.none.obs;
  final supportedPageView = RxBool(false);
  final scrollPhysicsPageView = Rxn<ScrollPhysics>();

  List<PresentationEmail> get currentListEmail => _currentListEmail;

  int get currentEmailIndex => _currentEmailIndex;

  void setCurrentEmailIndex(int index) => _currentEmailIndex = index;

  @override
  void onInit() {
    super.onInit();
    updateScrollPhysicPageView();
  }

  @override
  void onClose() {
    pageController?.dispose();
    pageController = null;
    super.onClose();
  }

  void updateNewCurrentListEmail() {
    _currentListEmail.clear();
    if (isSearchActivatedOnMobile) {
      _currentListEmail.addAll(mailboxDashBoardController.listResultSearch);
    } else {
      _currentListEmail.addAll(mailboxDashBoardController.emailsInCurrentMailbox);
    }
  }

  bool get isSearchActivatedOnMobile {
    return mailboxDashBoardController.searchController.isSearchEmailRunning
      && !BuildUtils.isWeb;
  }

  void createPageControllerAndJumpToEmailById(EmailId currentEmailId) {
    _currentEmailIndex = _currentListEmail.matchedIndex(currentEmailId);
    if (pageController != null && pageController?.hasClients == true) {
      pageController?.jumpToPage(_currentEmailIndex);
    } else {
      pageController = PageController(initialPage: _currentEmailIndex);
    }
    _updateStatePageViewNavigator();
  }

  void onPageChanged(int index) {
    updateScrollPhysicPageView();
    mailboxDashBoardController.openEmailDetailedView(currentListEmail[index]);
  }

  void _updateStatePageViewNavigator() {
    if (_currentListEmail.length <= 1) {
      pageViewNavigatorState.value = PageViewNavigatorState.none;
    } else {
      if (_currentEmailIndex > 0 && _currentEmailIndex < _currentListEmail.length - 1) {
        pageViewNavigatorState.value = PageViewNavigatorState.all;
      } else if (_currentEmailIndex <= 0) {
        pageViewNavigatorState.value = PageViewNavigatorState.previous;
      } else if (_currentEmailIndex >= _currentListEmail.length - 1) {
        pageViewNavigatorState.value = PageViewNavigatorState.next;
      }
    }
  }

  bool get nextEmailActivated {
    return pageViewNavigatorState.value == PageViewNavigatorState.next ||
      pageViewNavigatorState.value == PageViewNavigatorState.all;
  }

  bool get previousEmailActivated {
    return pageViewNavigatorState.value == PageViewNavigatorState.previous ||
      pageViewNavigatorState.value == PageViewNavigatorState.all;
  }

  void moveToNextEmail() {
    if (nextEmailActivated) {
      _currentEmailIndex--;
      _jumpToPage(_currentEmailIndex);
    }
  }

  void backToPreviousEmail() {
    if (previousEmailActivated) {
      _currentEmailIndex++;
      _jumpToPage(_currentEmailIndex);
    }
  }

  void _jumpToPage(int page) {
    if (BuildUtils.isWeb) {
      pageController?.jumpToPage(page);
    } else {
      pageController?.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear);
    }
  }

  void updateScrollPhysicPageView({bool isScrollPageViewActivated = false}) {
    if (BuildUtils.isWeb || !isScrollPageViewActivated) {
      scrollPhysicsPageView.value = const NeverScrollableScrollPhysics();
    } else {
      scrollPhysicsPageView.value = null;
    }
  }

  EmailLoaded? getEmailInQueueByEmailId(EmailId emailId) {
    return presentationEmailsLoaded.firstWhereOrNull((e) => e.emailCurrent!.id == emailId);
  }

  void popFirstEmailQueue() {
    presentationEmailsLoaded.removeFirst();
  }

  void popEmailQueue(EmailId? emailId) {
    presentationEmailsLoaded.removeWhere((e) => e.emailCurrent!.id == emailId);
  }

  void pushEmailQueue(EmailLoaded emailLoaded) {
    presentationEmailsLoaded.add(emailLoaded);
  }

  void disposePageViewController() {
    pageController?.dispose();
    pageController = null;
  }
}