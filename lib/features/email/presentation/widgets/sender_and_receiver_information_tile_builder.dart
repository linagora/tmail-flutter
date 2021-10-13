
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenExpandAddressReceiverActionClick = void Function();

class SenderAndReceiverInformationTileBuilder {

  static const int LIMIT_ADDRESS_DISPLAY = 1;

  final ImagePaths _imagePaths;
  final BuildContext _context;
  final PresentationEmail? _presentationEmail;
  final ExpandMode _expandMode;

  OnOpenExpandAddressReceiverActionClick? _onOpenExpandAddressReceiverActionClick;

  SenderAndReceiverInformationTileBuilder(
    this._context,
    this._imagePaths,
    this._presentationEmail,
    this._expandMode,
  );

  SenderAndReceiverInformationTileBuilder onOpenExpandAddressReceiverActionClick(OnOpenExpandAddressReceiverActionClick onOpenExpandAddressReceiverActionClick) {
    _onOpenExpandAddressReceiverActionClick = onOpenExpandAddressReceiverActionClick;
    return this;
  }

  Widget build() {
    if (_presentationEmail == null) {
      return SizedBox.shrink();
    }
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: ListTile(
          leading: Transform(
            transform: Matrix4.translationValues(-15.0, -8.0, 0.0),
            child: AvatarBuilder()
              .text('${_presentationEmail!.getAvatarText()}')
              .size(40)
              // .iconStatus(_imagePaths.icOffline)
              .build()),
          title: Transform(
            transform: Matrix4.translationValues(-15.0, 0.0, 0.0),
            child: Text(
              '${AppLocalizations.of(_context).from_email_address_prefix}: ${_presentationEmail!.getSenderName()}',
              style: TextStyle(fontSize: 16, color: AppColor.nameUserColor, fontWeight: FontWeight.w500),
            )),
          subtitle: Transform(
            transform: Matrix4.translationValues(-15.0, 0.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_presentationEmail!.to.numberEmailAddress() > 0) _buildAddressToReceiverWidget(),
                if (_presentationEmail!.cc.numberEmailAddress() > 0) _buildAddressCcReceiverWidget(),
                if (_presentationEmail!.bcc.numberEmailAddress() > 0) _buildAddressBccReceiverWidget(),
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '${_presentationEmail!.getEmailDateTime(Localizations.localeOf(_context).toLanguageTag(), pattern: 'dd/MM/yyyy h:mm a')}',
                    style: TextStyle(fontSize: 12, color: AppColor.baseTextColor),
                  ))
              ],
            ))
        )
      )
    );
  }

  Widget _buildExpandAddressWidget(String typeReceiver, String nameAddress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$typeReceiver: ',
          style: TextStyle(fontSize: 12, color: AppColor.baseTextColor, fontWeight: FontWeight.w500)),
        Expanded(child: Text(
          '$nameAddress',
          style: TextStyle(fontSize: 12, color: AppColor.baseTextColor, fontWeight: FontWeight.w500),
        ))
      ]);
  }

  Widget _buildCollapseAddressWidget(String typeReceiver, String nameAddress) {
    return Row(
      children: [
        Text(
          '$typeReceiver: $nameAddress',
          style: TextStyle(fontSize: 12, color: AppColor.baseTextColor, fontWeight: FontWeight.w500)),
        if (_expandMode == ExpandMode.COLLAPSE
            && _presentationEmail != null
            && _presentationEmail!.numberOfAllEmailAddress() > LIMIT_ADDRESS_DISPLAY)
          _buildButtonExpandAddress()
      ]);
  }

  Widget _buildAddressWidget(String typeReceiver, String nameAddress) {
    if (_expandMode == ExpandMode.EXPAND
        || (_presentationEmail != null && _presentationEmail!.numberOfAllEmailAddress() <= LIMIT_ADDRESS_DISPLAY)) {
      return Padding(
        padding: EdgeInsets.only(top: 6),
        child: _buildExpandAddressWidget(typeReceiver, nameAddress));
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 6),
        child: _buildCollapseAddressWidget(typeReceiver, nameAddress));
    }
  }

  Widget _buildAddressToReceiverWidget() {
    return _buildAddressWidget(
      AppLocalizations.of(_context).to_email_address_prefix,
      _presentationEmail!.to.listEmailAddressToString(expandMode: _expandMode, limitAddress: LIMIT_ADDRESS_DISPLAY));
  }

  Widget _buildAddressCcReceiverWidget() {
    if (_presentationEmail!.to.numberEmailAddress() > 0) {
      if (_expandMode == ExpandMode.EXPAND) {
        return Padding(
          padding: EdgeInsets.only(top: 6),
          child: _buildExpandAddressWidget(AppLocalizations.of(_context).cc_email_address_prefix, _presentationEmail!.cc.listEmailAddressToString(expandMode: _expandMode, limitAddress: LIMIT_ADDRESS_DISPLAY)));
      } else {
        return SizedBox.shrink();
      }
    } else {
      return _buildAddressWidget(
        AppLocalizations.of(_context).cc_email_address_prefix,
        _presentationEmail!.cc.listEmailAddressToString(expandMode: _expandMode, limitAddress: LIMIT_ADDRESS_DISPLAY));
    }
  }

  Widget _buildAddressBccReceiverWidget() {
    if (_presentationEmail!.to.numberEmailAddress() > 0) {
      if (_expandMode == ExpandMode.EXPAND) {
        return Padding(
          padding: EdgeInsets.only(top: 6),
          child: _buildExpandAddressWidget(AppLocalizations.of(_context).bcc_email_address_prefix, _presentationEmail!.bcc.listEmailAddressToString(expandMode: _expandMode, limitAddress: LIMIT_ADDRESS_DISPLAY)));
      } else {
        return SizedBox.shrink();
      }
    } else {
      if (_presentationEmail!.cc.numberEmailAddress() > 0) {
        if (_expandMode == ExpandMode.EXPAND) {
          return Padding(
            padding: EdgeInsets.only(top: 6),
            child: _buildExpandAddressWidget(AppLocalizations.of(_context).bcc_email_address_prefix, _presentationEmail!.bcc.listEmailAddressToString(expandMode: _expandMode, limitAddress: LIMIT_ADDRESS_DISPLAY)));
        } else {
          return SizedBox.shrink();
        }
      } else {
        return _buildAddressWidget(
          AppLocalizations.of(_context).bcc_email_address_prefix,
          _presentationEmail!.bcc.listEmailAddressToString(expandMode: _expandMode, limitAddress: LIMIT_ADDRESS_DISPLAY));
      }
    }
  }

  String getRemainCountAddressReceiver() {
    if (_presentationEmail!.numberOfAllEmailAddress() - LIMIT_ADDRESS_DISPLAY >= 999) {
      return '999';
    }
    return '${_presentationEmail!.numberOfAllEmailAddress() - LIMIT_ADDRESS_DISPLAY}';
  }

  Widget _buildButtonExpandAddress() {
    return GestureDetector(
      onTap: () {
        if (_onOpenExpandAddressReceiverActionClick != null) {
          _onOpenExpandAddressReceiverActionClick!();
        }},
      child: Row(
        children: [
          SizedBox(width: 8),
          Text(
            '+${getRemainCountAddressReceiver()}',
            style: TextStyle(fontSize: 12, color: AppColor.baseTextColor, fontWeight: FontWeight.w500),
          ),
          SvgPicture.asset(_imagePaths.icMoreReceiver, width: 14, height: 14, fit: BoxFit.fill),
        ],
      ),
    );
  }
}