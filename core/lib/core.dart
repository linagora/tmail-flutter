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

library core;

// Extensions
export 'presentation/extensions/color_extension.dart';
export 'presentation/extensions/url_extension.dart';

// Utils
export 'presentation/utils/theme_utils.dart';
export 'presentation/utils/responsive_utils.dart';
export 'presentation/utils/keyboard_utils.dart';
export 'presentation/utils/style_utils.dart';

// Views
export 'presentation/views/text/slogan_builder.dart';
export 'presentation/views/text/text_field_builder.dart';
export 'presentation/views/text/input_decoration_builder.dart';
export 'presentation/views/text/text_builder.dart';
export 'presentation/views/responsive/responsive_widget.dart';
export 'presentation/views/list/tree_list.dart';

// Resources
export 'presentation/resources/assets_paths.dart';
export 'presentation/resources/image_paths.dart';

// Constants
export 'presentation/constants/constants_ui.dart';
export 'data/constants/constant.dart';

// Network
export 'data/network/config/authorization_interceptors.dart';
export 'data/network/config/dynamic_url_interceptors.dart';
export 'data/network/config/accept_data_interceptors.dart';
export 'data/network/config/endpoint.dart';
export 'data/network/config/service_path.dart';
export 'data/network/dio_client.dart';
export 'data/network/exception/remote_exception_thrower.dart';
export 'data/network/exception/remote_exception.dart';

// State
export 'presentation/state/success.dart';
export 'presentation/state/failure.dart';