import 'package:ande_app/src/blocs/events/AuthenticationEvents.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/UserViewModel.dart';

abstract class AuthenticationStates {}

class UserUnInitialized extends AuthenticationStates {}

class UserAuthenticated extends AuthenticationStates {
  final String userToken;
  final UserViewModel user;
  UserAuthenticated({this.user, this.userToken});
}

class UserAuthenticating extends AuthenticationStates {}

class UserAuthenticationFailed extends AuthenticationStates {
  final ErrorViewModel error;
  final AuthenticationEvents event ;
  UserAuthenticationFailed({this.error , this.event});
}
