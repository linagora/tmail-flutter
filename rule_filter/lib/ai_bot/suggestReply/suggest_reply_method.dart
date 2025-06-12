import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:rule_filter/rule_filter/converter/rule_id_converter.dart';

part 'suggest_reply_method.g.dart';

@IdConverter()
@RuleIdConverter()
@AccountIdConverter()
@PropertiesConverter()
@JsonSerializable(explicitToJson: true)
class SuggestReplyMethod extends MethodRequiringAccountId {
  static final capabilityIdentifier =
      CapabilityIdentifier(Uri.parse('com.linagora.tmail:params:jmap:aibot'));

  final String emailId;
  final String userInput;

  SuggestReplyMethod({
    required AccountId accountId,
    required this.emailId,
    required this.userInput,
  }) : super(accountId);

  @override
  MethodName get methodName => MethodName('AIBot/suggestReply');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        capabilityIdentifier,
        CapabilityIdentifier.jmapCore,
      };

  @override
  List<Object?> get props => [accountId, emailId, userInput];

  @override
  Map<String, dynamic> toJson() => _$SuggestReplyMethodToJson(this);

  factory SuggestReplyMethod.fromJson(Map<String, dynamic> json) =>
      _$SuggestReplyMethodFromJson(json);
}
