import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/recent_item_tile_widget.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_text_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class BaseLoginView extends GetWidget<LoginController> {
  const BaseLoginView({Key? key}) : super(key: key);

  Widget buildLoginButton(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 16, start: 24, end: 24),
      width: controller.responsiveUtils.getDeviceWidth(context),
      height: 48,
      child: ElevatedButton(
        key: const Key('loginSubmitForm'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0, color: AppColor.primaryColor)
          )
        ),
        onPressed: () => controller.handleLoginPressed(context),
        child: Text(
          AppLocalizations.of(context).signIn,
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      )
    );
  }

  Widget buildInputCredentialForm(BuildContext context) {
    return AutofillGroup(
      key: const Key('credential_input_form'),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Column(
            children: [
              buildUserNameInput(context),
              const SizedBox(height: 24),
              buildPasswordInput(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserNameInput(BuildContext context) {
    return TypeAheadFormFieldBuilder<RecentLoginUsername>(
      key: const Key('login_username_input'),
      controller: controller.usernameInputController,
      onTextChange: controller.onUsernameChange,
      focusNode: controller.userNameFocusNode,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
      keyboardType: TextInputType.emailAddress,
      decoration: (LoginInputDecorationBuilder()
        ..setLabelText(AppLocalizations.of(context).email)
        ..setHintText(AppLocalizations.of(context).email))
        .build(),
      debounceDuration: const Duration(milliseconds: 300),
      suggestionsCallback: controller.getAllRecentLoginUsernameAction,
      itemBuilder: (_, loginUsername) => RecentItemTileWidget(loginUsername),
      onSuggestionSelected: controller.selectUsernameFromSuggestion,
      noItemsFoundBuilder: (context) => const SizedBox(),
      hideOnEmpty: true,
      hideOnError: true,
      hideOnLoading: true,
    );
  }

  Widget buildPasswordInput(BuildContext context) {
    return LoginTextInputBuilder(
      key: const Key('login_password_input'),
      controller: controller.passwordInputController,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      hintText: AppLocalizations.of(context).password,
      focusNode: controller.passFocusNode,
      onTextChange: controller.onPasswordChange,
      onSubmitted: (_) => controller.handleLoginPressed(context),
    );
  }

  Widget buildLoadingCircularProgress() {
    return const SizedBox(
        key: Key('login_loading_icon'),
        width: 40,
        height: 40,
        child: CircularProgressIndicator(color: AppColor.primaryColor));
  }
}