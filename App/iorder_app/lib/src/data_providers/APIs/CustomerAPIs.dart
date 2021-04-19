import 'package:ande_app/src/data_providers/models/ActiveOrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/AddressToServerModel.dart';
import 'package:ande_app/src/data_providers/models/CustomerAddressViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:flutter/foundation.dart';

class CustomerAPIs {
  static Future<ResponseViewModel<bool>> addCustomerAddress({@required AddressToServerModel addressToServerModel}) async {
    String userId = await Repository.getUserId();
    String url = URL.getURL(functionName: URL.POST_CUSTOMER_ADDRESS(customerId: userId));
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel response = await NetworkUtilities.handlePostRequest(
      acceptJson: true,
      methodURL: url,
      requestHeaders: requestHeaders,
      requestBody: addressToServerModel.toJson(),
      parserFunction: (Map<String, dynamic> passedJson) {}
    );
    return ResponseViewModel<bool>(
      isSuccess: response.isSuccess,
      serverData: response.isSuccess,
      serverError: response.serverError
    );
  }

  static Future<ResponseViewModel<List<CustomerAddressViewModel>>> getCustomerAddresses() async {
    String userId = await Repository.getUserId();
    String url = URL.getURL(functionName: URL.GET_CUSTOMER_ADDRESS(customerId: userId));
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel response = await NetworkUtilities.handleGetRequest(
      methodURL: url,
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> passedJson) {
        var addressList = passedJson['data'];
        List<CustomerAddressViewModel> customerAddressList = List();
        for (int i = 0; i < addressList.length; i++) {
          customerAddressList.add(CustomerAddressViewModel.fromJson(addressList[i]));
        }
        return customerAddressList;
      }
    );
    return ResponseViewModel<List<CustomerAddressViewModel>>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError
    );
  }

  static Future<ResponseViewModel<ActiveOrderViewModel>> getCustomerActiveOrders() async {
    String userId = await Repository.getUserId();
    String url = URL.getURL(functionName: URL.GET_ACTIVE_ORDERS(userId: userId, language: Constants.currentAppLocale));
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel response = await NetworkUtilities.handleGetRequest(
      methodURL: url,
      requestHeaders: requestHeaders,
      parserFunction: (Map<String, dynamic> json){
        return ActiveOrderViewModel.fromJson(json);
      }
    );
    return ResponseViewModel<ActiveOrderViewModel>(
      isSuccess: response.isSuccess,
      serverData: response.responseData,
      serverError: response.serverError
    );
  }
}