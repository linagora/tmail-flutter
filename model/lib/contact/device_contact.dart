
import 'package:equatable/equatable.dart';
import 'package:model/contact/contact.dart';

class DeviceContact extends Contact implements EquatableMixin {
  DeviceContact(String displayName, String email) : super(displayName, email);

  @override
  List<Object> get props => super.props;
}
