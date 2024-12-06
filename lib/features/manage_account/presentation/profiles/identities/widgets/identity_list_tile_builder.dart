import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/signature_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/widgets/signature_loading_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectIdentityAction = Function(Identity? identitySelected);
typedef OnEditIdentityAction = Function(Identity identitySelected);
typedef OnDeleteIdentityAction = Function(Identity identitySelected);

class IdentityListTileBuilder extends StatelessWidget {

  const IdentityListTileBuilder({
    Key? key, 
    required this.identity,
    required this.identitySelected,
    required this.mapIdentitySignatures,
    required this.signatureViewState,
    required this.imagePaths,
    required this.responsiveUtils,
    this.onSelectIdentityAction,
    this.onEditIdentityAction,
    this.onDeleteIdentityAction
  }) : super(key: key);

  final Identity identity;
  final Identity? identitySelected;
  final Map<IdentityId, String> mapIdentitySignatures;
  final Either<Failure, Success> signatureViewState;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final OnSelectIdentityAction? onSelectIdentityAction;
  final OnEditIdentityAction? onEditIdentityAction;
  final OnDeleteIdentityAction? onDeleteIdentityAction;

  @override
  Widget build(BuildContext context) {
    final listIdentitiesWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            (identity.name ?? ''),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        if (identity.email?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              identity.email ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.colorEmailAddressFull,
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        if (identity.replyTo?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              '${AppLocalizations.of(context).reply_to.capitalizeFirstEach}: ${identity.replyTo?.listEmailAddressToString(isFullEmailAddress: true)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.colorEmailAddressFull,
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        if (identity.bcc?.isNotEmpty == true)
          Text(
            '${AppLocalizations.of(context).bcc_email_address_prefix}: ${identity.bcc?.listEmailAddressToString(isFullEmailAddress: true)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColor.colorEmailAddressFull,
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
          ),
        if (identity.signatureAsString.isNotEmpty)
          ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '--',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
            SignatureLoadingWidget(signatureViewState: signatureViewState),
            SignatureBuilder(
              value: mapIdentitySignatures[identity.id!] ?? identity.signatureAsString,
              width: responsiveUtils.isWebDesktop(context) ? 280 : double.infinity,
            )
          ],
      ],
    );

    return Padding(
      padding: responsiveUtils.isWebDesktop(context)
        ? const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 24)
        : const EdgeInsetsDirectional.symmetric(vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio<Identity>(
            value: identity,
            splashRadius: PlatformInfo.isWeb ? 18 : 24,
            groupValue: identitySelected,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColor.primaryColor;
              }
              return AppColor.colorDisableRadioButton;
            }),
            onChanged: onSelectIdentityAction,
          ),
          const SizedBox(width: 5),
          if (responsiveUtils.isWebDesktop(context))
            SizedBox(
              width: 280,
              child: listIdentitiesWidget,
            )
          else
            Expanded(child: listIdentitiesWidget),
          TMailButtonWidget(
            icon: imagePaths.icCompose,
            iconSize: 20,
            text: responsiveUtils.isWebDesktop(context)
              ? AppLocalizations.of(context).edit
              : '',
            backgroundColor: Colors.transparent,
            iconColor: AppColor.primaryColor,
            textStyle: responsiveUtils.isWebDesktop(context)
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColor.primaryColor,
                )
              : null,
            flexibleText: responsiveUtils.isWebDesktop(context),
            minWidth: responsiveUtils.isWebDesktop(context) ? 100 : 0,
            mainAxisSize: MainAxisSize.min,
            maxLines: 1,
            iconSpace: 4,
            padding: responsiveUtils.isWebDesktop(context)
              ? const EdgeInsetsDirectional.symmetric(
                  vertical: 5,
                  horizontal: 8,
                )
              : null,
            onTapActionCallback: () => onEditIdentityAction?.call(identity),
          ),
          TMailButtonWidget(
            icon: imagePaths.icDeleteRule,
            iconSize: 20,
            text: responsiveUtils.isWebDesktop(context)
              ? AppLocalizations.of(context).delete
              : '',
            backgroundColor: Colors.transparent,
            iconColor: AppColor.primaryColor,
            textStyle: responsiveUtils.isWebDesktop(context)
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColor.primaryColor,
                )
              : null,
            flexibleText: responsiveUtils.isWebDesktop(context),
            minWidth: responsiveUtils.isWebDesktop(context) ? 100 : 0,
            mainAxisSize: MainAxisSize.min,
            maxLines: 1,
            iconSpace: 4,
            padding: responsiveUtils.isWebDesktop(context)
              ? const EdgeInsetsDirectional.symmetric(
                  vertical: 5,
                  horizontal: 8,
                )
              : null,
            onTapActionCallback: () => onDeleteIdentityAction?.call(identity),
          ),
          if (responsiveUtils.isWebDesktop(context))
            const Spacer(),
        ],
      ),
    );
  }


}