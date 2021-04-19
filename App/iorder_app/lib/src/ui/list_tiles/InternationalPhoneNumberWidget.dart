import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';

class InternationalNumberWidget extends StatefulWidget {
  @override
  _InternationalNumberWidgetState createState() =>
      _InternationalNumberWidgetState();
}

class _InternationalNumberWidgetState extends State<InternationalNumberWidget> {
  Country selectedItem;
  List<Country> itemList = [];
  bool hasError = false;
  TextEditingController phoneController;
  int cardIndex;
  Function onRemoveClicked;
  String initialPhoneNumber;

  @override
  void initState() {
    phoneController = new TextEditingController();

    phoneController.removeListener(_validatePhoneNumber);
    phoneController.addListener(_validatePhoneNumber);

    _fetchCountryData().then((list) {
      Country preSelectedItem;
      preSelectedItem = list[0];
      itemList = list;
      selectedItem = preSelectedItem;
      phoneController.text = phoneController.text.length == 0
          ? preSelectedItem.dialCode
          : phoneController.text;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    phoneController.removeListener(_validatePhoneNumber);
    phoneController.addListener(_validatePhoneNumber);
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DropdownButtonHideUnderline(
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: DropdownButton<Country>(
                value: selectedItem,
                onChanged: (Country newValue) {
                  selectedItem = newValue;
                  phoneController.text = selectedItem.dialCode;
                  _validatePhoneNumber();
                  setState(() {});
                },
                items: itemList.map<DropdownMenuItem<Country>>(
                  (Country value) {
                    return DropdownMenuItem<Country>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Image.asset(
                              value.flagUri,
                              width: 32.0,
                              package: 'international_phone_input',
                            ),
                            SizedBox(width: 4),
                            Text(value.dialCode)
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          Flexible(
            child: TextFormField(
              autovalidate: false,
              validator: (text) {
                return (hasError || text.length == 0)
                    ? 'Invalid Phone Format'
                    : null;
              },
              keyboardType: TextInputType.phone,
              controller: phoneController,
              decoration: InputDecoration(
                errorText: hasError ? 'Invalid Phone number' : null,
                labelText: 'Enter phone number',
              ),
            ),
          )
        ],
      ),
    );
  }

  // ------------------------------------- Validation Utilities ---------------------------------

  _validatePhoneNumber() {
    String phoneText = phoneController.text;
    try {
      if (phoneText != null && phoneText.isNotEmpty) {
        parsePhoneNumber(phoneText, selectedItem.code).then((isValid) {
          hasError = !isValid;
          setState(() {});
        });
      }
    } catch (ex) {
      hasError = true;
      setState(() {});
    }
  }

  Future<List<Country>> _fetchCountryData() async {
    var list = await DefaultAssetBundle.of(context)
        .loadString('assets/countries.json');
    var jsonList = json.decode(list);
    List<Country> elements = [];
    jsonList.forEach((s) {
      Map elem = Map.from(s);
      elements.add(Country(
          name: elem['en_short_name'],
          code: elem['alpha_2_code'],
          dialCode: elem['dial_code'],
          flagUri: 'flags/${elem['alpha_2_code'].toLowerCase()}.png'));
    });
    return elements;
  }

  static Future<bool> parsePhoneNumber(String number, String iso) async {
    try {
      bool isValid = await PhoneNumberUtil.isValidPhoneNumber(
          phoneNumber: number, isoCode: iso);
      return isValid;
    } on PlatformException {
      return false;
    }
  }

  static Future<String> getNormalizedPhoneNumber(
      String number, String iso) async {
    bool isValidPhoneNumber = await parsePhoneNumber(number, iso);

    if (isValidPhoneNumber) {
      String normalizedNumber = await PhoneNumberUtil.normalizePhoneNumber(
          phoneNumber: number, isoCode: iso);
      return normalizedNumber;
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Country {
  final String name;
  final String flagUri;
  final String code;
  final String dialCode;

  Country({this.name, this.code, this.flagUri, this.dialCode});
}
