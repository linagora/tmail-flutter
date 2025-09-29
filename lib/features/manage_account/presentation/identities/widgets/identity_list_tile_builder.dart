import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/list_identity_item_actions_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/signature_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/signature_loading_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnChangeIdentityAsDefaultAction = Function(Identity identity);

class IdentityListTileBuilder extends StatelessWidget {

  const IdentityListTileBuilder({
    Key? key, 
    required this.identity,
    required this.mapIdentitySignatures,
    required this.signatureViewState,
    required this.imagePaths,
    required this.onEditIdentityAction,
    required this.onDeleteIdentityAction,
    this.isDesktop = false,
    this.isSelected = false,
    this.isDefaultIdentitySupported = false,
    this.isItemLoading = false,
    this.scrollController,
    this.onChangeIdentityAsDefaultAction,
  }) : super(key: key);

  final Identity identity;
  final Map<IdentityId, String> mapIdentitySignatures;
  final Either<Failure, Success> signatureViewState;
  final ImagePaths imagePaths;
  final bool isSelected;
  final bool isDesktop;
  final bool isDefaultIdentitySupported;
  final bool isItemLoading;
  final OnEditIdentityAction onEditIdentityAction;
  final OnDeleteIdentityAction onDeleteIdentityAction;
  final OnChangeIdentityAsDefaultAction? onChangeIdentityAsDefaultAction;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final selectedIcon = AbsorbPointer(
      absorbing: isItemLoading,
      child: TMailButtonWidget.fromIcon(
        icon: isSelected ? imagePaths.icRadioSelected : imagePaths.icRadio,
        iconSize: 18,
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent,
        borderRadius: 100,
        onTapActionCallback: () =>
            onChangeIdentityAsDefaultAction?.call(identity),
      ),
    );

    final signatureContent = mapIdentitySignatures[identity.id!] ??
        identity.signatureAsString;

    final identityContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            (identity.name ?? ''),
            style: ThemeUtils.textStyleBodyBody1(color: Colors.black),
          ),
        ),
        if (identity.email?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              identity.email ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.steelGray400,
              ),
            ),
          ),
        if (identity.replyTo?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${AppLocalizations.of(context).reply_to.toUpperCase()}: ${identity.replyTo?.listEmailAddressToString(isFullEmailAddress: true)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.steelGray400,
              ),
            ),
          ),
        if (identity.bcc?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${AppLocalizations.of(context).bcc_email_address_prefix.toUpperCase()}: ${identity.bcc?.listEmailAddressToString(isFullEmailAddress: true)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.steelGray400,
              ),
            ),
          ),
        if (signatureContent.trim().isNotEmpty)
          ...[
            Text(
              '--',
              style: ThemeUtils.textStyleBodyBody2(
                color: Colors.black,
              ),
            ),
            SignatureLoadingWidget(signatureViewState: signatureViewState),
            SignatureBuilder(
              value: signatureContent,
              width: isDesktop ? 280 : double.infinity,
              scrollController: scrollController,
            ),
          ],
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDefaultIdentitySupported)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: selectedIcon,
            ),
          Container(
            width: 280,
            padding: EdgeInsetsDirectional.only(
              end: 12,
              top: isDefaultIdentitySupported ? 10 : 0,
            ),
            child: identityContent,
          ),
          Padding(
            padding: isDefaultIdentitySupported
                ? const EdgeInsetsDirectional.only(top: 10)
                : EdgeInsetsDirectional.zero,
            child: ListIdentityItemActionsWidget(
              identity: identity,
              imagePaths: imagePaths,
              onEditIdentityAction: onEditIdentityAction,
              onDeleteIdentityAction: onDeleteIdentityAction,
              isDesktop: isDesktop,
            ),
          ),
          const Spacer(),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDefaultIdentitySupported)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: selectedIcon,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 10),
                    child: identityContent,
                  ),
                ),
              ],
            )
          else
            identityContent,
          const SizedBox(height: 24),
          ListIdentityItemActionsWidget(
            identity: identity,
            imagePaths: imagePaths,
            onEditIdentityAction: onEditIdentityAction,
            onDeleteIdentityAction: onDeleteIdentityAction,
            isDesktop: isDesktop,
          ),
        ],
      );
    }
  }
}