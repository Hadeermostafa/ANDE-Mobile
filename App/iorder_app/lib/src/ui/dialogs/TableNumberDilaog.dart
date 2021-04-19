import 'dart:convert';

import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../resources/UserCart.dart';

class TableNumberDialog extends StatefulWidget {
  @override
  _TableNumberDialogState createState() => _TableNumberDialogState();
}

class _TableNumberDialogState extends State<TableNumberDialog> {
  //bool isQREnabled = true;
  TextEditingController _tableNumberController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _canPop = true;



  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text(
            (LocalKeys.SCAN_QR_BUTTON_LABEL).tr(),
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              // fontFamily: Constants.FONT_ARIAL,
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 200,
                height: 180,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                            AssetImage('assets/images/scan_camera_border.png'),
                        fit: BoxFit.fill),
                  ),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated:
                    _onQRViewCreated,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[100],
                ),
              ),
              Text(
                (LocalKeys.OR).tr(),
                textScaleFactor: 1,
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[100],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Container(
                height: 40,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              (LocalKeys.ORDER_TABLE_NUMBER_LABEL).tr(),
                              textScaleFactor: 1,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                //fontFamily: Constants.FONT_ARIAL,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[100],
                                  ),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[100],
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              controller: _tableNumberController,
                              onChanged: (String userInput) {
                                UserCart().orderTableNumber = userInput;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.black.withOpacity(0.7),
                        child: Text(
                          (LocalKeys.SEND_LABEL).tr(),
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      _qrCallback(scanData.code);
    });
  }



  void _qrCallback(String code) async {
    final split = code.split('str=');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++)
        i: split[i]
    };
    var decoded = utf8.decode(base64.decode(values[1]));
    var codeMap = json.decode(decoded);
    String tableNum = codeMap['table_Number'] ?? '';
    UserCart().orderTableNumber = tableNum;
    if (_canPop) {
      _canPop = false;
      Navigator.of(context).pop();
    }
  }
}
