import 'package:contact/contact/model/capability_contact.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/fps_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_capability.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/view_as_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/mdn_interactor_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/contact_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/tmail_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/log_out_oidc_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/bindings/email_rules_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/bindings/forwarding_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/bindings/mailbox_visibility_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_subscription_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_fcm_subscription_local.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/destroy_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_fcm_subscription_local_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/fcm_configuration.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

abstract class BaseController extends GetxController
    with MessageDialogActionMixin,
        PopupContextMenuActionMixin,
        ViewAsDialogActionMixin {

  final CachingManager cachingManager = Get.find<CachingManager>();
  final languageCacheManager = Get.find<LanguageCacheManager>();
  final authorizationInterceptors = Get.find<AuthorizationInterceptors>();
  final authorizationIsolateInterceptors = Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag);
  final DeleteCredentialInteractor deleteCredentialInteractor = Get.find<DeleteCredentialInteractor>();
  final LogoutOidcInteractor logoutOidcInteractor = Get.find<LogoutOidcInteractor>();
  final DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor = Get.find<DeleteAuthorityOidcInteractor>();
  final _fcmReceiver = FcmReceiver.instance;

  GetFCMSubscriptionLocalInteractor? _getSubscriptionLocalInteractor;
  DestroySubscriptionInteractor? _destroySubscriptionInteractor;

  final AppToast _appToast = Get.find<AppToast>();


  final viewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  FpsCallback? fpsCallback;

  void consumeState(Stream<Either<Failure, Success>> newStateStream) async {
    newStateStream.listen(
      (state) => onData(state),
      onError: (error, stackTrace) {
        logError('BaseController::consumeState():onError:error: $error');
        logError('BaseController::consumeState():onError:stackTrace: $stackTrace');
        onError(error);
      },
      onDone: () => onDone()
    );
  }

  void dispatchState(Either<Failure, Success> newState) {
    viewState.value = newState;
  }

  void clearState() {
    viewState.value = Right(UIState.idle);
  }

  void onData(Either<Failure, Success> newState) {
    viewState.value = newState;
    viewState.value.fold(
      (failure) {
        if (_handleCommonException(failure)) {
          return;
        }
        if (failure is LogoutOidcFailure) {
          log('BaseController::onData(): $failure');
          _getSubscriptionLocalAction();
        } else if (failure is GetFCMSubscriptionLocalFailure) {
          checkAuthenticationTypeWhenLogout();
        } else if (failure is DestroySubscriptionFailure) {
          checkAuthenticationTypeWhenLogout();
        }
      },
      (success) {
        if (success is LogoutOidcSuccess) {
          log('BaseController::onData(): $success');
          _getSubscriptionLocalAction();
        } else if (success is GetFCMSubscriptionLocalSuccess) {
          final _subscriptionId = success.fcmSubscription.subscriptionId;
          _destroySubscriptionAction(_subscriptionId);
        } else if (success is DestroySubscriptionSuccess) {
          checkAuthenticationTypeWhenLogout();
        }
      }
    );
  }

  bool _handleCommonException(Failure failure) {
    if (failure is FeatureFailure) {
      log('BaseController::_handleCommonException(): ${failure.exception}');
      if (failure.exception is NoNetworkError) {
        return true;
      } else if (failure.exception is BadCredentialsException) {
        _appToast.showErrorToast(AppLocalizations.of(currentContext!).badCredentials);
        cleanAppAtTheEnd();
        checkAuthenticationTypeWhenLogout();
        return true;
      }
    }
    return false;
  }

  void onError(dynamic error) {
    if (error is NoNetworkError) {
      logError('BaseController::onError(): $error');
      return;
    }

    final appToast = Get.find<AppToast>();
    final imagePaths = Get.find<ImagePaths>();
    final responsiveUtils = Get.find<ResponsiveUtils>();

    String messageError = '';
    if (error is MethodLevelErrors) {
      messageError = error.message ?? error.type.value;
    } else {
      if (currentContext != null) {
        messageError = AppLocalizations.of(currentContext!).unknownError;
      }
    }

    if (messageError.isNotEmpty && currentContext != null && currentOverlayContext != null) {
      appToast.showBottomToast(
        currentOverlayContext!,
        messageError,
        leadingIcon: SvgPicture.asset(
          imagePaths.icNotConnection,
          width: 24,
          height: 24,
          colorFilter: Colors.white.asFilter(),
          fit: BoxFit.fill),
        backgroundColor: AppColor.toastErrorBackgroundColor,
        textColor: Colors.white,
        textActionColor: Colors.white,
        maxWidth: responsiveUtils.getMaxWidthToast(currentContext!));
    }
  }

  void onDone();

  void startFpsMeter() {
    FpsManager().start();
    fpsCallback = (fpsInfo) {
      log('BaseController::startFpsMeter(): $fpsInfo');
    };
    if (fpsCallback != null) {
      FpsManager().addFpsCallback(fpsCallback!);
    }
  }

  void stopFpsMeter() {
    FpsManager().stop();
    if (fpsCallback != null) {
      FpsManager().removeFpsCallback(fpsCallback!);
    }
  }

  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      ContactAutoCompleteBindings().dependencies();
      requireCapability(session!, accountId!, [tmailContactCapabilityIdentifier]);
      TMailAutoCompleteBindings().dependencies();
    } catch (e) {
      logError('BaseController::injectAutoCompleteBindings(): exception: $e');
    }
  }

  void injectMdnBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapMdn]);
      MdnInteractorBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectMdnBindings(): exception: $e');
    }
  }

  void injectForwardBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityForward]);
      ForwardingInteractorsBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectForwardBindings(): exception: $e');
    }
  }

  void injectRuleFilterBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityRuleFilter]);
      EmailRulesInteractorBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectRuleFilterBindings(): exception: $e');
    }
  }

  void injectMailboxVisibilityBindings() {
    MailboxVisibilityInteractorBindings().dependencies();
  }

  void injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      requireCapability(session!, accountId!, [FirebaseCapability.fcmIdentifier]);
      if (AppConfig.fcmAvailable) {
        final mapEnvData = Map<String, String>.from(dotenv.env);
        await AppUtils.loadFcmConfigFileToEnv(currentMapEnvData: mapEnvData);
        FcmConfiguration.initialize();
        if (!BuildUtils.isWeb) {
          await LocalNotificationManager.instance.setUp();
        }
        FcmInteractorBindings().dependencies();
        FcmController.instance.initialize(accountId: accountId);
      } else {
        throw NotSupportFCMException();
      }
    } catch(e) {
      logError('BaseController::injectFCMBindings(): exception: $e');
    }
  }
}