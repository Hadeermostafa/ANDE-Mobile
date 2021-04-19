import 'dart:convert';
import 'dart:io';

import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkUtilities {
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup(
          URL.SERVER_URL)
          .timeout(Duration(seconds: 5), onTimeout: () {
        throw SocketException('');
      });
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
  static Future<Map<String,String>> getHttpHeaders({Map<String,dynamic> customHeaders}) async {
    String userToken = await Repository.getAccessToken();
    if (userToken == null) {
      ResponseViewModel<User> firebaseLoginResult = await Repository.loginAnonymously();
      if(firebaseLoginResult.isSuccess) {
        userToken = await (firebaseLoginResult.responseData).getIdToken(true);
      }
    }

    Map<String,String> requestHeaders =  {
      'content-language': Constants.currentAppLocale,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'ANDE-Token' : '$userToken',
      HttpHeaders.authorizationHeader : 'Bearer $userToken',

    };
    if(customHeaders != null){
      customHeaders.forEach((key, value) {
          requestHeaders.putIfAbsent(key, () => value);
      });
    }
    return requestHeaders;

  }



  static Future<ResponseViewModel<dynamic>> handleGetRequest(
      {String methodURL,
        Map<String, String> requestHeaders,
        Function parserFunction}) async {
    ResponseViewModel getResponse;

    try {
      var serverResponse = await http.get(methodURL, headers: requestHeaders).timeout(Duration(seconds: 20),onTimeout: (){
        throw SocketException;
      });
      if (serverResponse.statusCode == 200) {
        getResponse = ResponseViewModel(
          isSuccess: true,
          serverError: null,
          serverData: parserFunction(json.decode(serverResponse.body)),
        );
      }
      else {
        getResponse = handleError(serverResponse);
      }
    } on SocketException {
      getResponse = ResponseViewModel(
        isSuccess: false,
        serverError: Constants.connectionTimeoutException,
        serverData: null,
      );
    } catch (exception) {

      debugPrint("Exception in get => $exception");

      if(exception == SocketException){
        getResponse = ResponseViewModel(
          isSuccess: false,
          serverError: Constants.connectionTimeoutException,
          serverData: null,
        );
      } else {
        getResponse = ResponseViewModel(
          isSuccess: false,
          serverError: ErrorViewModel(
            errorMessage: '',
            errorCode: HttpStatus.serviceUnavailable,
          ),
          serverData: null,
        );
      }
    }
    networkLogger(
        url: methodURL,
        body: '',
        headers: requestHeaders,
        response: getResponse);
    return getResponse;
  }

  static Future<ResponseViewModel> handlePostRequest(
      {bool acceptJson = false,
        String methodURL,
        Map<String, String> requestHeaders,
        Map<String, dynamic> requestBody,
        Function parserFunction}) async {
    ResponseViewModel postResponse;



    try {
      http.Response serverResponse = await http.post(methodURL,
          headers: requestHeaders,
          body: acceptJson ? json.encode(requestBody) : requestBody);
      if (serverResponse.statusCode == 200) {
        postResponse = ResponseViewModel(
          isSuccess: true,
          serverError: null,
          serverData: parserFunction(json.decode(serverResponse.body)),
        );
      } else if (serverResponse.statusCode == 201) {
        postResponse = ResponseViewModel(
          isSuccess: true,
          serverError: null,
          serverData: parserFunction(json.decode(serverResponse.body)),
        );
      }

      else {
        postResponse = handleError(serverResponse);
      }
    } on SocketException {
      postResponse = ResponseViewModel(
        isSuccess: false,
        serverError: Constants.connectionTimeoutException,
        serverData: null,
      );
    } catch (exception) {
      debugPrint("Exception in post => $exception");
      if(exception == SocketException){
        postResponse = ResponseViewModel(
          isSuccess: false,
          serverError: Constants.connectionTimeoutException,
          serverData: null,
        );
      } else {
        postResponse = ResponseViewModel(
          isSuccess: false,
          serverError: ErrorViewModel(
            errorMessage: '',
            errorCode: HttpStatus.serviceUnavailable,
          ),
          serverData: null,
        );
      }
    }
    networkLogger(
        url: methodURL,
        body: requestBody,
        headers: requestHeaders,
        response: postResponse);
    return postResponse;
  }

  static Future<ResponseViewModel> handlePutRequest(
      {bool acceptJson = false,
        String methodURL,
        Map<String, String> requestHeaders,
        Map<String, dynamic> requestBody,
        Function parserFunction}) async {
    ResponseViewModel postResponse;



    try {
      http.Response serverResponse = await http.put(methodURL,
          headers: requestHeaders,
          body: acceptJson ? json.encode(requestBody) : requestBody).timeout(Duration(seconds: 5), onTimeout: (){
        throw SocketException;
      });
      if (serverResponse.statusCode == 200) {
        postResponse = ResponseViewModel(
          isSuccess: true,
          serverError: null,
          serverData: parserFunction(json.decode(serverResponse.body)),
        );
      } else if (serverResponse.statusCode == 201) {
        postResponse = ResponseViewModel(
          isSuccess: true,
          serverError: null,
          serverData: parserFunction(json.decode(serverResponse.body)),
        );
      }
      else {
        postResponse = handleError(serverResponse);
      }
    } on SocketException {
      postResponse = ResponseViewModel(
        isSuccess: false,
        serverError: Constants.connectionTimeoutException,
        serverData: null,
      );
    } catch (exception) {
      debugPrint("Exception in post => $exception");
      if(exception == SocketException){
        postResponse = ResponseViewModel(
          isSuccess: false,
          serverError: Constants.connectionTimeoutException,
          serverData: null,
        );
      } else {
        postResponse = ResponseViewModel(
          isSuccess: false,
          serverError: ErrorViewModel(
            errorMessage: '',
            errorCode: HttpStatus.serviceUnavailable,
          ),
          serverData: null,
        );
      }
    }
    networkLogger(
        url: methodURL,
        body: requestBody,
        headers: requestHeaders,
        response: postResponse);
    return postResponse;
  }


  static void networkLogger({url, headers, body, ResponseViewModel response}) {
    debugPrint('---------------------------------------------------');
    debugPrint('AT => ${DateTime.now().toString()}');
    debugPrint('URL => $url');
    debugPrint('headers => $headers');
    debugPrint('Body => $body');
    debugPrint('Response => ${response.toString()}');
    debugPrint('---------------------------------------------------');
  }

  static ResponseViewModel handleError(http.Response serverResponse) {
    debugPrint("Server Response not ok => ");
    debugPrint(serverResponse.body);
    debugPrint("----------------------------------");


    FirebaseCrashlytics.instance.recordError(Exception(serverResponse.body), StackTrace.fromString(serverResponse.request.toString()));


    ResponseViewModel responseViewModel;
    if (serverResponse.statusCode == HttpStatus.unprocessableEntity) {
      List<String> errors = List();
      try {
        (json.decode(serverResponse.body)['errors'] as Map<String, dynamic>)
            .forEach((key, value) {
          if (value is List<String>)
            errors.addAll(value);
          else if (value is List<dynamic>) {
            for (int i = 0; i < value.length; i++)
              errors.add(value[i].toString());
          } else if (value is String) errors.add(value);
        });
      } catch (exception) {
        debugPrint("Exception => $exception");
      }
      responseViewModel = ResponseViewModel(
        isSuccess: false,
        serverError: ErrorViewModel(
          errorMessage: errors.length > 0
              ? errors.join(',')
              : (LocalKeys.SERVER_UNREACHABLE).tr(),
          errorCode: serverResponse.statusCode,
        ),
        serverData: null,
      );
    }
    else if(serverResponse.statusCode == HttpStatus.internalServerError){
      responseViewModel = ResponseViewModel(
        isSuccess: false,
        serverError: ErrorViewModel(
          errorMessage: (LocalKeys.SERVER_UNREACHABLE).tr(),
          errorCode: serverResponse.statusCode,
        ),
        serverData: null,
      );
    }
    else {
      String serverError = (LocalKeys.SERVER_UNREACHABLE).tr();
      try {
        serverError = json.decode(serverResponse.body)['error'] ??
            json.decode(serverResponse.body)['message'];
        if (serverError.isEmpty) {
          serverError = tr(LocalKeys.SERVER_UNREACHABLE);
        }
      } catch (exception) {
        serverError = serverResponse.body;
      }
      responseViewModel = ResponseViewModel(
        isSuccess: false,
        serverError: ErrorViewModel(
          errorMessage: serverError,
          errorCode: serverResponse.statusCode,
        ),
        serverData: null,
      );
    }
    return responseViewModel;
  }
}
