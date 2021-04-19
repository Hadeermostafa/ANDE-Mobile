import 'package:ande_app/main.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AndeRatingsDialog extends StatefulWidget {
  @override
  _AndeRatingsDialogState createState() => _AndeRatingsDialogState();
}

class _AndeRatingsDialogState extends State<AndeRatingsDialog> {
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: loadingFlare,
      inAsyncCall: false,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(child: dialogContent(context)),
      ),
    );
  }

  Widget dialogContent(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: size.height * 0.1,
            width: size.width,
            child: Center(child: Text(tr(LocalKeys.RATING_LABEL))),
          ),
          SizedBox(
            height: size.height * 0.005,
          ),
          Divider(
            height: 10,
            color: Colors.black,
          ),
          SizedBox(
            height: size.height * 0.005,
          ),
          Center(child: Text(tr(LocalKeys.RATING_LABEL))),
          Padding(
            padding:
            const EdgeInsets.only(right: 10, left: 10 , top: 10 , bottom: 20),
            child: TextField(
              maxLines: 2,
              cursorColor: Colors.grey[900],
              onChanged: (text) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
                hintText: tr(LocalKeys.ADD_NOTE_TO_RESTAURANT),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[100],
                      width: 1,
                      style: BorderStyle.solid,
                    )),
                focusColor: Colors.grey[300],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              height: 60,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)
              ),
              child: FlatButton(
                child: Text(
                  tr(LocalKeys.SEND_LABEL),
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.grey[900],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          FlatButton(
            child: Text(
              tr(LocalKeys.ASK_ME_LATER),
              textScaleFactor: 1,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
