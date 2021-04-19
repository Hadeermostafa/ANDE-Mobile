import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';

import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';


class ApplicationDataAPIs {
  static Future<ResponseViewModel<List<CountryModel>>> getSystemSupportedCountries() async {
    String getSupportedSystemURL = URL.getURL(functionName: URL.GET_SYSTEM_SUPPORTED_COUNTRIES);
    Map<String, String> requestHeaders = await NetworkUtilities.getHttpHeaders();
    ResponseViewModel getSupportedLanguages =
        await NetworkUtilities.handleGetRequest(
      methodURL: getSupportedSystemURL,
      parserFunction: (jsonResponse) {
        return CountryModel.fromListJson(jsonResponse['data']);
      },
      requestHeaders: requestHeaders,
    );

    return ResponseViewModel<List<CountryModel>>(
      isSuccess: getSupportedLanguages.isSuccess,
      serverError: getSupportedLanguages.serverError,
      serverData: getSupportedLanguages.responseData,
    );
  }
}
