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
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnNewSearchQuery = Function(String);

class SearchFormWidgetBuilder {
  final imagePath = Get.find<ImagePaths>();
  final TextEditingController _typeAheadController = TextEditingController();

  final BuildContext _context;

  OnNewSearchQuery? _onNewSearchQuery;

  SearchFormWidgetBuilder(this._context);

  SearchFormWidgetBuilder onNewSearchQuery(OnNewSearchQuery onNewSearchQuery) {
    _onNewSearchQuery = onNewSearchQuery;
    return this;
  }

  Widget build() {
    return Container(
      key: Key('search_folder_form'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.searchBorderColor),
        color: AppColor.primaryLightColor),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _typeAheadController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 0, top: 15, bottom: 15, right: 15),
            hintText: AppLocalizations.of(_context).search_folder,
            hintStyle: TextStyle(color: AppColor.searchHintTextColor, fontSize: 15.0, fontWeight: FontWeight.w500),
            icon: Padding(
              padding: EdgeInsets.only(left: 20),
              child: SvgPicture.asset(imagePath.icSearch, width: 24, height: 24, fit: BoxFit.fill),
            ))),
        debounceDuration: Duration(milliseconds: 300),
        suggestionsCallback: (pattern) async {
          if (_onNewSearchQuery != null) {
            _onNewSearchQuery!(pattern);
          }
          return [];
        },
        itemBuilder: (BuildContext context, itemData) => SizedBox.shrink(),
        onSuggestionSelected: (suggestion) {},
        noItemsFoundBuilder: (context) => SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
        hideSuggestionsOnKeyboardHide: true,
      ));
  }
}