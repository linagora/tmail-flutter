import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityInfoTileBuilder extends StatelessWidget {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final Identity? _identity;
  final double? maxWidth;

  const IdentityInfoTileBuilder(
    this._context,
    this._imagePaths,
    this._identity,
    {Key? key, this.maxWidth}
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_identity == null) {
      return const SizedBox.shrink();
    }

    return Container(
        key: const Key('identity_info_tile'),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.colorBorderIdentityInfo, width: 1),
            color: Colors.white),
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        margin: const EdgeInsets.only(top: 12),
        width: maxWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Expanded(child: Text(_identity?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: Colors.black))),
                buildIconWeb(
                    icon: SvgPicture.asset(_imagePaths.icMoreVertical, fit: BoxFit.fill),
                    onTap: () => {})
              ])),
            const SizedBox(height: 10),
            const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(_identity?.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.black))),
            if (_identity?.email != null) const SizedBox(height: 10),
            if (_identity?.email != null)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    SizedBox(
                      width: 40,
                      child: SvgPicture.asset(_imagePaths.icEmail, width: 15, height: 15)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(_identity?.email ?? '',
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.colorHintSearchBar)))
                  ])),
            if (_identity?.replyTo != null) const SizedBox(height: 10),
            if (_identity?.replyTo != null)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    SizedBox(
                        width: 40,
                        child: SvgPicture.asset(_imagePaths.icReplyTo, width: 15, height: 15)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(_identity?.replyTo?.listEmailAddressToString(isFullEmailAddress: true) ?? '',
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.colorHintSearchBar)))
                  ])),
            if (_identity?.cc != null) const SizedBox(height: 6),
            if (_identity?.cc != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  Container(
                      width: 40,
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(AppLocalizations.of(_context).cc_email_address_prefix,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                              color: AppColor.colorTextButton))),
                  const SizedBox(width: 4),
                  Expanded(child: Text(_identity?.cc?.listEmailAddressToString(isFullEmailAddress: true) ?? '',
                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.colorHintSearchBar)))
                ])),
            if (_identity?.bcc != null) const SizedBox(height: 6),
            if (_identity?.bcc != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    Container(
                        padding: const EdgeInsets.only(left: 6),
                        width: 40,
                        child: Text(AppLocalizations.of(_context).bcc_email_address_prefix,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                              color: AppColor.colorTextButton))),
                    const SizedBox(width: 4),
                    Expanded(child: Text(_identity?.bcc?.listEmailAddressToString(isFullEmailAddress: true) ?? '',
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.colorHintSearchBar)))
                  ])),
        ])
    );
  }
}