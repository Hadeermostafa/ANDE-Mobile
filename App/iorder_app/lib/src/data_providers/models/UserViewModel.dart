
import 'package:ande_app/src/data_providers/models/CustomerAddressViewModel.dart';

import 'delivery/LocationViewModel.dart';

class UserViewModel {
  String userId, userToken;

  LocationViewModel userLastKnownLocation;
  // List<LocationViewModel> userLocations;
  List<CustomerAddressViewModel> userLocations;

  UserViewModel(
      {this.userId,
      this.userToken,
      this.userLastKnownLocation,
      this.userLocations});

  static UserViewModel fromAnonymous() {
    return UserViewModel(
      userLocations: [],
      userId: 0.toString(),
      userLastKnownLocation: LocationViewModel(),
    );
  }

  static UserViewModel fromJson(Map<String, dynamic> json) {
    var userInformation = json['user_data'];

    return UserViewModel(
      userToken: json['access_token'].toString(),
      userId: userInformation['id'].toString(),
      userLastKnownLocation: userInformation['user_last_known_location'] == null
          ? LocationViewModel.fromAnonymous()
          : LocationViewModel.fromJson(json['user_last_known_location']),
      userLocations: userInformation['user_addresses'] == null
          ? []
          : LocationViewModel.fromListJson(json['user_addresses']),
    );
  }

  static UserViewModel fromClosedJson(Map<String, dynamic> json) {
    var userInformation = json['data'];
    return UserViewModel(
      userToken: userInformation['bearer_token'].toString(),
      userId: userInformation['id'].toString(),
    );
  }


  @override
  String toString() => 'User{id: $userId, token: $userToken}';

  // Map<String, dynamic> toJson() {
  //   List<dynamic> locationsJson = List();
  //   for (int i = 0; i < userLocations.length; i++)
  //     locationsJson.add(userLocations[i].toJson());
  //   return {
  //     "userId": userId,
  //     "user_last_known_location": userLastKnownLocation.toJson(),
  //     "user_addresses": locationsJson
  //   };
  // }
}
