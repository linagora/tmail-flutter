import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/preferences_setting.dart';

part 'preferences_root.g.dart';

@JsonSerializable(explicitToJson: true)
class PreferencesRoot with EquatableMixin {
  final PreferencesSetting setting;

  PreferencesRoot({required this.setting});

  factory PreferencesRoot.initial() {
    return PreferencesRoot(
      setting: PreferencesSetting.initial(),
    );
  }

  factory PreferencesRoot.fromJson(Map<String, dynamic> json) =>
      _$PreferencesRootFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesRootToJson(this);

  @override
  List<Object?> get props => [setting];
}

extension PreferencesRootExtension on PreferencesRoot {
  PreferencesRoot copyWith({PreferencesSetting? setting}) {
    return PreferencesRoot(
      setting: setting ?? this.setting,
    );
  }

  PreferencesRoot updateThreadDetail(bool enabled) {
    return copyWith(setting: setting.updateThreadDetail(enabled));
  }

  PreferencesRoot updateSpamReport({
    bool? isEnabled,
    int? lastTimeDismissedMilliseconds,
  }) {
    return copyWith(
      setting: setting.updateSpamReport(
        isEnabled: isEnabled,
        lastTimeDismissedMilliseconds: lastTimeDismissedMilliseconds,
      ),
    );
  }
}
