import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/recent_item_tile_widget.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/presentation/base_login_view.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/privacy_link_widget.dart';
import 'package:tmail_ui_user/features/login/presentation/state/login_state.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends BaseLoginView {

  final keyboardUtils = Get.find<KeyboardUtils>();

  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryLightColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: _supportScrollForm(context)
                ? Stack(children: [
                    Center(child: SingleChildScrollView(
                        child: _buildCenterForm(context),
                        scrollDirection: Axis.vertical)),
                    Obx(() {
                      if (loginController.loginFormType.value == LoginFormType.credentialForm
                          || loginController.loginFormType.value == LoginFormType.ssoForm) {
                        return _buildBackButton(context);
                      }
                      return const SizedBox.shrink();
                    })
                  ])
                : Stack(children: [
                    _buildCenterForm(context),
                    Obx(() {
                      if (loginController.loginFormType.value == LoginFormType.credentialForm
                          || loginController.loginFormType.value == LoginFormType.ssoForm) {
                        return _buildBackButton(context);
                      }
                      return const SizedBox.shrink();
                    })
                  ]),
          ),
        ),
      ));
  }

  Widget _buildCenterForm(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: _supportScrollForm(context)
          ? const BoxConstraints(minWidth: 240, maxWidth: 400)
          : const BoxConstraints(minWidth: double.infinity),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: responsiveUtils.isHeightShortest(context) ? 64 : 0),
              child: Text(
                AppLocalizations.of(context).login,
                style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
              )
            ),
            Obx(() => buildLoginMessage(context, loginController.loginState.value)),
            Obx(() {
              switch (controller.loginFormType.value) {
                case LoginFormType.baseUrlForm:
                  return _buildUrlInput(context);
                case LoginFormType.credentialForm:
                  return buildInputCredentialForm(context);
                default:
                  return const SizedBox.shrink();
              }
            }),
            Obx(() {
              switch (controller.loginFormType.value) {
                case LoginFormType.baseUrlForm:
                  return Obx(() => loginController.loginState.value.viewState.fold(
                    (failure) => _buildNextButtonInContext(context),
                    (success) => success is LoginLoadingAction
                      ? buildLoadingCircularProgress()
                      : _buildNextButtonInContext(context)));
                case LoginFormType.credentialForm:
                  return Obx(() => loginController.loginState.value.viewState.fold(
                    (failure) => _buildLoginButtonInContext(context),
                    (success) => success is LoginLoadingAction
                      ? buildLoadingCircularProgress()
                      : _buildLoginButtonInContext(context)));
                case LoginFormType.ssoForm:
                  return Obx(() => loginController.loginState.value.viewState.fold(
                    (failure) => _buildLoginButtonInContext(context),
                    (success) => success is LoginLoadingAction
                      ? buildLoadingCircularProgress()
                      : _buildLoginButtonInContext(context)));
                default:
                  return const SizedBox.shrink();
              }
            }),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: PrivacyLinkWidget(),
            ),
          ]
        ),
      )
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
        left: 12,
        top: 12,
        child: IconButton(
          key: const Key('login_arrow_back_button'),
          onPressed: () => controller.handleBackInCredentialForm(),
          icon: SvgPicture.asset(
            imagePaths.icBack,
            alignment: Alignment.center,
            color: AppColor.primaryColor
          )
        ),
    );
  }

  Widget _buildUrlInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      child: TypeAheadFormField<RecentLoginUrl>(
        textFieldConfiguration: TextFieldConfiguration(
            controller: loginController.urlInputController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.url,
            onSubmitted: (value) => controller.handleNextInUrlInputFormPress(),
            decoration: (LoginInputDecorationBuilder()
                ..setLabelText(AppLocalizations.of(context).prefix_https)
                ..setPrefixText(AppLocalizations.of(context).prefix_https))
               .build()
        ),
        debounceDuration: const Duration(milliseconds: 300),
        suggestionsCallback: (pattern) async {
          loginController.formatUrl(pattern);
          return loginController.getAllRecentLoginUrlAction(pattern);
        },
        itemBuilder: (context, loginUrl) =>
            RecentItemTileWidget(loginUrl, imagePath: imagePaths),
        onSuggestionSelected: (loginUrl) => controller.formatUrl(loginUrl.url),
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(14))),
        noItemsFoundBuilder: (context) => const SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      ));
  }

  Widget _buildExpandedButton(BuildContext context, Widget child) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: child
      )
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      width: responsiveUtils.getDeviceWidth(context),height: 48,
      child: AbsorbPointer(
        absorbing: !controller.networkConnectionController.isNetworkConnectionAvailable(),
        child: ElevatedButton(
          key: const Key('nextToCredentialForm'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) => AppColor.primaryColor.withOpacity(
                  controller.networkConnectionController.isNetworkConnectionAvailable() ? 1 : 0.5)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(width: 0, color: AppColor.primaryColor)
            ))
          ),
          child: Text(AppLocalizations.of(context).next,
            style: const TextStyle(fontSize: 16, color: Colors.white)
          ),
          onPressed: () {
            loginController.handleNextInUrlInputFormPress();
          }
        ),
      )
    );
  }

  Widget _buildNextButtonInContext(BuildContext context) {
    return _supportScrollForm(context)
      ? _buildNextButton(context)
      : _buildExpandedButton(context, _buildNextButton(context));
  }

  Widget _buildLoginButtonInContext(BuildContext context) {
    return _supportScrollForm(context)
      ? buildLoginButton(context)
      : _buildExpandedButton(context, buildLoginButton(context));
  }
  
  bool _supportScrollForm(BuildContext context) {
    return !(responsiveUtils.isMobile(context) && responsiveUtils.isPortrait(context));
  }
}