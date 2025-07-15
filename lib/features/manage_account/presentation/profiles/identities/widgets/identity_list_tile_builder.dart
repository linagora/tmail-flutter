import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectIdentityAction = Function(Identity? identitySelected);
typedef OnEditIdentityAction = Function(Identity identitySelected);
typedef OnDeleteIdentityAction = Function(Identity identitySelected);

class IdentityListTileBuilder extends StatelessWidget {

  const IdentityListTileBuilder({
    Key? key, 
    required this.identity,
    required this.identitySelected,
    required this.imagePaths,
    this.onSelectIdentityAction,
    this.onEditIdentityAction,
    this.onDeleteIdentityAction
  }) : super(key: key);

  final Identity identity;
  final Identity? identitySelected;
  final ImagePaths imagePaths;
  final OnSelectIdentityAction? onSelectIdentityAction;
  final OnEditIdentityAction? onEditIdentityAction;
  final OnDeleteIdentityAction? onDeleteIdentityAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => onSelectIdentityAction?.call(identity),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: _isIdentitySelected
                ? AppColor.colorItemSelected
                : Colors.transparent,
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Radio<Identity>(
                  value: identity,
                  splashRadius: 15,
                  groupValue: identitySelected,
                  activeColor: AppColor.primaryColor,
                  onChanged: onSelectIdentityAction,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: TextOverflowBuilder(
                          (identity.name ?? ''),
                          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black)),
                      ),
                      if (identity.email?.isNotEmpty == true)
                        _buildIconSVGWithTextLine(imagePaths.icEmail, identity.email),
                      if (identity.replyTo?.isNotEmpty == true)
                        _buildIconSVGWithTextLine(
                          imagePaths.icReplyTo,
                          identity.replyTo?.listEmailAddressToString(isFullEmailAddress: true)
                        ),
                      if (identity.bcc?.isNotEmpty == true)
                        _buildIconCharacterWithTextLine(
                          AppLocalizations.of(context).bcc_email_address_prefix,
                          identity.bcc?.listEmailAddressToString(isFullEmailAddress: true)
                        ),
                    ],
                  )
                ),
                if(_isIdentitySelected)
                  ...[
                    buildSVGIconButton(
                      icon: imagePaths.icEditRule,
                      iconSize: 24,
                      iconColor: AppColor.primaryColor,
                      onTap: () => onEditIdentityAction?.call(identity),
                    ),
                    buildSVGIconButton(
                      icon: imagePaths.icDeleteRule,
                      iconSize: 24,
                      iconColor: AppColor.colorDeletePermanentlyButton,
                      onTap: () => onDeleteIdentityAction?.call(identity),
                    ),
                  ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSVGWithTextLine(String imagePath, String? text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(
          width: 30,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(imagePath, width: 15, height: 15))),
        const SizedBox(width: 4),
        Expanded(child: TextOverflowBuilder(
          (text ?? ''),
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            color: AppColor.colorEmailAddressFull,
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
        ))
      ]),
    );
  }

  Widget _buildIconCharacterWithTextLine(String character, String? text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Container(
          width: 30,
          alignment: Alignment.centerLeft,
          child: Text(
            character,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.underline,
              color: AppColor.colorTextButton))),
        const SizedBox(width: 4),
        Expanded(child: TextOverflowBuilder(
          (text ?? ''),
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            color: AppColor.colorEmailAddressFull,
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
        ))
      ]),
    );
  }

  bool get _isIdentitySelected => identity.id == identitySelected?.id;
}