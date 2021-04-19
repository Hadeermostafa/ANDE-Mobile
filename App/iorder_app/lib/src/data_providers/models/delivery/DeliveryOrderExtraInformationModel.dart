
import 'package:ande_app/src/data_providers/models/CustomerAddressViewModel.dart';

class DeliveryOrderExtraInformationModel {
  String userName, userPhoneNumber, deliveryNotes;
  // LocationViewModel deliveryLocation;
  CustomerAddressViewModel deliveryLocation;
  double deliveryCost;
  DeliveryOrderExtraInformationModel(
      {this.userPhoneNumber,
      this.userName,
      this.deliveryLocation,
      this.deliveryCost,
      this.deliveryNotes});
}
