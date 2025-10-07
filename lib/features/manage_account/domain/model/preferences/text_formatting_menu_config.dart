import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'text_formatting_menu_config.g.dart';

@JsonSerializable()
class TextFormattingMenuConfig extends PreferencesConfig {
  final bool isDisplayed;

  TextFormattingMenuConfig({this.isDisplayed = false});

  factory TextFormattingMenuConfig.initial() => TextFormattingMenuConfig();

  factory TextFormattingMenuConfig.fromJson(Map<String, dynamic> json) =>
      _$TextFormattingMenuConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextFormattingMenuConfigToJson(this);

  @override
  List<Object> get props => [isDisplayed];
}

extension TextFormattingMenuConfigExtension on TextFormattingMenuConfig {
  TextFormattingMenuConfig copyWith({bool? isDisplayed}) {
    return TextFormattingMenuConfig(
      isDisplayed: isDisplayed ?? this.isDisplayed,
    );
  }
}
