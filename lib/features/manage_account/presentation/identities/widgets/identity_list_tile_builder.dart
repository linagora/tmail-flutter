import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/list_identity_item_actions_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/signature_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/signature_loading_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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
    this.scrollController,
  }) : super(key: key);

  final Identity identity;
  final Map<IdentityId, String> mapIdentitySignatures;
  final Either<Failure, Success> signatureViewState;
  final ImagePaths imagePaths;
  final bool isSelected;
  final bool isDesktop;
  final OnEditIdentityAction onEditIdentityAction;
  final OnDeleteIdentityAction onDeleteIdentityAction;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final selectedIcon = SvgPicture.asset(
      isSelected ? imagePaths.icRadioSelected : imagePaths.icRadio,
      width: 18,
      height: 18,
      fit: BoxFit.fill,
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
          selectedIcon,
          Container(
            width: 280,
            padding: const EdgeInsetsDirectional.only(start: 18, end: 12),
            child: identityContent,
          ),
          ListIdentityItemActionsWidget(
            identity: identity,
            imagePaths: imagePaths,
            onEditIdentityAction: onEditIdentityAction,
            onDeleteIdentityAction: onDeleteIdentityAction,
            isDesktop: isDesktop,
          ),
          const Spacer(),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selectedIcon,
              const SizedBox(width: 18),
              Expanded(child: identityContent),
            ],
          ),
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