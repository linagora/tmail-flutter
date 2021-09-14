
import 'package:equatable/equatable.dart';

abstract class AppAction with EquatableMixin {}

abstract class ActionOnline extends AppAction {}

abstract class ActionOffline extends AppAction {}