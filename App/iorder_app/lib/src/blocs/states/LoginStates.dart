import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';

import '../events/LoginEvents.dart';

abstract class LoginStates {}

class LoginInitialized extends LoginStates {}

class LoginLoading extends LoginStates {}

class LoginSuccess extends LoginStates {
  final LoginMethods loginMethod;
  LoginSuccess({this.loginMethod});
}

class LoginError extends LoginStates {
  final ErrorViewModel error;
  final LoginEvents event ;
  LoginError({this.error , this.event});
}


class WaitingAuthCode extends LoginStates {}
