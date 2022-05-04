// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
//
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses
// for the GNU Affero General Public License version
//
// 3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
// for
//
// the Additional Terms applicable to LinShare software.

import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login_input_decoration_builder.dart';

typedef SetErrorString = String? Function(String);
typedef OnSubmitted = void Function(String);

class LoginTextInputBuilder {
  Key? _key;
  String? _title;
  String? _hintText;
  String? _labelText;
  String? _prefixText;
  SetErrorString? _setErrorString;
  String? _errorText;
  Timer? _debounce;
  bool? _obscureText;
  ValueChanged<String>? _onTextChange;
  TextInputAction? _textInputAction;
  TextEditingController? _textEditingController;
  bool? _passwordInput;
  OnSubmitted? _onSubmitted;

  final BuildContext context;
  final ImagePaths imagePaths;

  LoginTextInputBuilder(this.context, this.imagePaths);

  void key(Key key) {
    _key = key;
  }

  void title(String? title) {
    _title = title;
  }

  void hintText(String? hintText) {
    _hintText = hintText;
  }

  void labelText(String? labelText) {
    _labelText = labelText;
  }

  void prefixText(String? prefixText) {
    _prefixText = prefixText;
  }

  void textInputAction(TextInputAction inputAction) {
    _textInputAction = inputAction;
  }

  void obscureText(bool obscureText) {
    _obscureText = obscureText;
  }

  void onChange(ValueChanged<String> onChange) {
    _onTextChange = onChange;
  }

  void setErrorString(SetErrorString setErrorString) {
    _setErrorString = setErrorString;
  }

  void passwordInput(bool? passwordInput) {
    _passwordInput = passwordInput;
  }

  void setTextEditingController(TextEditingController textEditingController) {
    _textEditingController = textEditingController;
  }

  void _onTextChanged(String name, StateSetter setState) {
    if (_onTextChange != null) {
      _onTextChange!(name);
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _errorText = (_setErrorString != null) ? _setErrorString!(name) : '';
      });
    });
  }

  void errorText(String? errorText) {
    _errorText = errorText;
  }

  void _onObscureTextChanged(bool? value, StateSetter setState) {
    setState(() {
      _obscureText = value == true ? false : true;
    });
  }

  void setOnSubmitted(OnSubmitted onSubmitted) {
    _onSubmitted = onSubmitted;
  }

  Widget build() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Wrap(
        key: _key,
        children: <Widget>[
          Text(_title ?? '', style: const TextStyle(color: AppColor.loginTextFieldHintColor, fontSize: 14, fontWeight: FontWeight.normal)),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                TextFormField(
                  onFieldSubmitted: _onSubmitted,
                  onChanged: (value) => _onTextChanged(value, setState),
                  obscureText: _obscureText ?? false,
                  textInputAction: _textInputAction,
                  controller: _textEditingController,
                  cursorColor: AppColor.primaryColor,
                  style: const TextStyle(color: AppColor.loginTextFieldHintColor, fontSize: 16, fontWeight: FontWeight.normal),
                  decoration: (LoginInputDecorationBuilder()
                      ..setHintText(_hintText)
                      ..setPrefixText(_prefixText)
                      ..setErrorText(_errorText)
                      ..setHintStyle(const TextStyle(color: AppColor.loginTextFieldHintColor, fontSize: 16, fontWeight: FontWeight.normal))
                      ..setPrefixStyle(const TextStyle(color: AppColor.loginTextFieldHintColor, fontSize: 16, fontWeight: FontWeight.normal))
                      ..setErrorTextStyle(const TextStyle(color: AppColor.loginTextFieldErrorBorder, fontSize: 13, fontWeight: FontWeight.normal))
                      ..setFocusBorder(const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: AppColor.loginTextFieldFocusedBorder)))
                      ..setEnabledBorder(const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: AppColor.loginTextFieldBorderColor)))
                      ..setErrorBorder(const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: AppColor.loginTextFieldErrorBorder))))
                    .build(),
                ),
                if (_passwordInput == true)
                  Transform(
                    transform: Matrix4.translationValues(
                      0.0,
                      (_errorText != null && _errorText!.isNotEmpty) ? -10.0 : 0.0,
                      0.0),
                    child: IconButton(
                      onPressed: () => _onObscureTextChanged(_obscureText, setState),
                      icon: SvgPicture.asset(
                        _obscureText == true ? imagePaths.icEye : imagePaths.icEyeOff,
                        width: 18,
                        height: 18,
                        fit: BoxFit.fill)))
              ]
            )
          ),
        ],
      );
    });
  }
}
