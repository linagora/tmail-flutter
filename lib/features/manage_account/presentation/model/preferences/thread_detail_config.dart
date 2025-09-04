import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_detail_config.g.dart';

@JsonSerializable()
class ThreadDetailConfig with EquatableMixin {
  final bool isEnabled;

  ThreadDetailConfig({this.isEnabled = false});

  factory ThreadDetailConfig.initial() {
    return ThreadDetailConfig(
      isEnabled: false,
    );
  }

  factory ThreadDetailConfig.fromJson(Map<String, dynamic> json) =>
      _$ThreadDetailConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadDetailConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}

extension ThreadDetailConfigExtension on ThreadDetailConfig {
  ThreadDetailConfig copyWith({bool? isEnabled}) {
    return ThreadDetailConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
