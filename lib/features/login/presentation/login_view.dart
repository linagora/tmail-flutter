import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/recent_item_tile_widget.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/presentation/base_login_view.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/privacy_link_widget.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends BaseLoginView {

  const LoginView({Key? key}) : super(key: key);

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
                        scrollDirection: Axis.vertical,
                        child: _buildCenterForm(context))),
                    Obx(() {
                      if (controller.loginFormType.value == LoginFormType.credentialForm
                          || controller.loginFormType.value == LoginFormType.ssoForm) {
                        return _buildBackButton(context);
                      }
                      return const SizedBox.shrink();
                    })
                  ])
                : Stack(children: [
                    _buildCenterForm(context),
                    Obx(() {
                      if (controller.loginFormType.value == LoginFormType.credentialForm
                          || controller.loginFormType.value == LoginFormType.ssoForm) {
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
                top: controller.responsiveUtils.isHeightShortest(context) ? 64 : 0),
              child: Text(
                AppLocalizations.of(context).login,
                style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
              )
            ),
            Obx(() => buildLoginMessage(context, controller.viewState.value)),
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
            _buildLoadingProgress(context),
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
            controller.imagePaths.icBack,
            alignment: Alignment.center,
            colorFilter: AppColor.primaryColor.asFilter()
          )
        ),
    );
  }

  Widget _buildUrlInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      child: TypeAheadFormFieldBuilder<RecentLoginUrl>(
        controller: controller.urlInputController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.url,
        onTextSubmitted: (value) => controller.handleNextInUrlInputFormPress(),
        decoration: (LoginInputDecorationBuilder()
            ..setLabelText(AppLocalizations.of(context).prefix_https)
            ..setPrefixText(AppLocalizations.of(context).prefix_https))
         .build(),
        debounceDuration: const Duration(milliseconds: 300),
        suggestionsCallback: (pattern) async {
          controller.formatUrl(pattern);
          return controller.getAllRecentLoginUrlAction(pattern);
        },
        itemBuilder: (context, loginUrl) => RecentItemTileWidget(loginUrl, imagePath: controller.imagePaths),
        onSuggestionSelected: (loginUrl) => controller.formatUrl(loginUrl.url),
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(borderRadius: BorderRadius.all(Radius.circular(14))),
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
      width: controller.responsiveUtils.getDeviceWidth(context),height: 48,
      child: ElevatedButton(
        key: const Key('nextToCredentialForm'),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => AppColor.primaryColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0, color: AppColor.primaryColor)
          ))
        ),
        child: Text(AppLocalizations.of(context).next,
          style: const TextStyle(fontSize: 16, color: Colors.white)
        ),
        onPressed: () {
          controller.handleNextInUrlInputFormPress();
        }
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
    return !(controller.responsiveUtils.isMobile(context) && controller.responsiveUtils.isPortrait(context));
  }

  Widget _buildLoadingProgress(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) {
        switch (controller.loginFormType.value) {
          case LoginFormType.baseUrlForm:
            return _buildNextButtonInContext(context);
          case LoginFormType.credentialForm:
            return _buildLoginButtonInContext(context);
          case LoginFormType.ssoForm:
            return _buildLoginButtonInContext(context);
          default:
            return const SizedBox.shrink();
        }
      },
      (success) {
        if (success is LoadingState) {
          return buildLoadingCircularProgress();
        } else {
          switch (controller.loginFormType.value) {
            case LoginFormType.baseUrlForm:
              return _buildNextButtonInContext(context);
            case LoginFormType.credentialForm:
              return _buildLoginButtonInContext(context);
            case LoginFormType.ssoForm:
              return _buildLoginButtonInContext(context);
            default:
              return const SizedBox.shrink();
          }
        }
      }
    ));
  }
}