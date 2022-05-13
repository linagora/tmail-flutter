import 'package:contact/contact/model/capability_contact.dart';
import 'package:contact/contact/model/contact_filter.dart';
import 'package:contact/core/method/request/autocomplete_method.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/unsigned_int_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';

class AutoCompleteTMailContactMethod extends AutoCompleteMethod {

  AutoCompleteTMailContactMethod(
      AccountId accountId,
      ContactFilter filter
  ) : super(accountId, filter);

  @override
  MethodName get methodName => MethodName('TMailContact/autocomplete');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    CapabilityIdentifier.jmapCore,
    capabilityContact
  };

  factory AutoCompleteTMailContactMethod.fromJson(Map<String, dynamic> json) {
    return AutoCompleteTMailContactMethod(
      const AccountIdConverter().fromJson(json['accountId'] as String),
      ContactFilter.fromJson(json['filter'] as Map<String, dynamic>),
    )
      ..limit = const UnsignedIntNullableConverter().fromJson(json['limit'] as int?);
  }

  @override
  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{
      'accountId': const AccountIdConverter().toJson(accountId),
    };

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull(
        'limit', const UnsignedIntNullableConverter().toJson(limit));
    val['filter'] = filter.toJson();
    return val;
  }

  @override
  List<Object?> get props => [methodName, accountId, limit, filter];
}