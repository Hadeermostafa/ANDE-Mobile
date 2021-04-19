import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/data_providers/models/AddressToServerModel.dart';

abstract class UserEvents {}

class LoadUserInformation extends UserEvents {}

class MoveToState extends UserEvents {
  final UserStates wantedState;
  MoveToState({this.wantedState});
}

class SaveUserAddress extends UserEvents {
  final AddressToServerModel addressToServerModel;
  SaveUserAddress({this.addressToServerModel});
}

class LoadUserAddresses extends UserEvents {}

