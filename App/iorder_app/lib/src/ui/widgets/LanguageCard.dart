import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/LanguageModel.dart';
import 'package:flutter/material.dart';

class LanguageCard extends StatelessWidget {

  final LanguageModel languageModel;
  final Function onLanguageTapped ;
  LanguageCard({this.languageModel , this.onLanguageTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(onLanguageTapped != null) onLanguageTapped(languageModel);
        return;
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            Text(
              languageModel.localeName,
            ),
          ],
        ),
      ),
    );
  }

}
