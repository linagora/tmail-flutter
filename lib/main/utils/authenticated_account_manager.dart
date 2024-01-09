import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linagora_design_flutter/colors/linagora_ref_colors.dart';
import 'package:linagora_design_flutter/colors/linagora_sys_colors.dart';
import 'package:linagora_design_flutter/multiple_account/models/twake_presentation_account.dart';
import 'package:linagora_design_flutter/multiple_account/multiple_account_picker.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/model/twake_mail_presentation_account.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnAddAnotherAccountAction = Function(PersonalAccount? currentAccount);
typedef OnSwitchActiveAccountAction = Function(
  PersonalAccount currentActiveAccount,
  PersonalAccount nextActiveAccount);
typedef OnSelectActiveAccountAction = Function(PersonalAccount activeAccount);

class AuthenticatedAccountManager {

  final GetAllAuthenticatedAccountInteractor _getAllAuthenticatedAccountInteractor;
  final ImagePaths _imagePaths;

  AuthenticatedAccountManager(
    this._getAllAuthenticatedAccountInteractor,
    this._imagePaths,
  );

  Future<List<PersonalAccount>> getAllPersonalAccount() {
    return _getAllAuthenticatedAccountInteractor
      .execute()
      .then((result) => result.fold(
        (failure) => <PersonalAccount>[],
        (success) => success is GetAllAuthenticatedAccountSuccess
          ? success.listAccount
          : <PersonalAccount>[]
      )
    );
  }

  Future<List<TwakeMailPresentationAccount>> _getAllTwakeMailPresentationAccount() {
    return _getAllAuthenticatedAccountInteractor
      .execute()
      .then((result) => result.fold(
        (failure) => <TwakeMailPresentationAccount>[],
        (success) => success is GetAllAuthenticatedAccountSuccess
          ? _generateTwakePresentationAccount(success.listAccount)
          : <TwakeMailPresentationAccount>[]
      )
    );
  }

  List<TwakeMailPresentationAccount> _generateTwakePresentationAccount(List<PersonalAccount> listAccount) {
    final listPresentationAccount = listAccount
      .map((account) => TwakeMailPresentationAccount(
        personalAccount: account,
        accountId: account.userName?.value ?? '',
        accountName: account.userName?.value ?? '',
        accountActiveStatus: account.isSelected
          ? AccountActiveStatus.active
          : AccountActiveStatus.inactive,
        avatar: AvatarBuilder(
          text: account.userName?.value.isNotEmpty == true
            ? account.userName!.value.firstLetterToUpperCase
            : '',
          size: 56,
          textColor: Colors.black,
          bgColor: Colors.white,
          boxShadows: const [
            BoxShadow(
              color: AppColor.colorShadowBgContentEmail,
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 0.5)
            )
          ]
        )
      ))
      .toList();

    listPresentationAccount.sort((pre, next) => pre.accountActiveStatus.index.compareTo(next.accountActiveStatus.index));

    return listPresentationAccount;
  }

  Future showAccountsBottomSheetModal({
    required BuildContext context,
    VoidCallback? onGoToManageAccount,
    OnAddAnotherAccountAction? onAddAnotherAccountAction,
    OnSwitchActiveAccountAction? onSwitchActiveAccountAction,
    OnSelectActiveAccountAction? onSelectActiveAccountAction,
  }) async {
    final listPresentationAccount = await _getAllTwakeMailPresentationAccount();
    final currentActiveAccount = listPresentationAccount
      .firstWhereOrNull((presentationAccount) => presentationAccount.isActive);

    if (context.mounted) {
      await MultipleAccountPicker.showMultipleAccountPicker(
        accounts: listPresentationAccount,
        context: context,
        titleAddAnotherAccount: AppLocalizations.of(context).addAnotherAccount,
        titleAccountSettings: AppLocalizations.of(context).manage_account,
        logoApp: Stack(
          children: [
            Center(child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
              child: SvgPicture.asset(_imagePaths.icLogoTwakeHorizontal),
            )),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TMailButtonWidget.fromIcon(
                icon: _imagePaths.icComposerClose,
                iconColor: Colors.black,
                margin: const EdgeInsetsDirectional.only(top: 8, end: 8),
                backgroundColor: Colors.transparent,
                onTapActionCallback: popBack,
              ),
            )
          ]
        ),
        accountNameStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: LinagoraSysColors.material().onSurface,
        ),
        accountIdStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: LinagoraRefColors.material().tertiary[20],
        ),
        addAnotherAccountStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: LinagoraSysColors.material().onPrimary,
        ),
        titleAccountSettingsStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: LinagoraSysColors.material().primary,
        ),
        onAddAnotherAccount: () => onAddAnotherAccountAction?.call(currentActiveAccount?.personalAccount),
        onGoToAccountSettings: () => onGoToManageAccount?.call(),
        onSetAccountAsActive: (presentationAccount) {
          if (presentationAccount is TwakeMailPresentationAccount) {
            if (currentActiveAccount != null) {
              onSwitchActiveAccountAction?.call(
                currentActiveAccount.personalAccount,
                presentationAccount.personalAccount);
            } else {
              onSelectActiveAccountAction?.call(presentationAccount.personalAccount);
            }
          }
        },
      );
    }
  }
}