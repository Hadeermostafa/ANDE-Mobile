
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:flutter/material.dart';

import '../../data_providers/models/LanguageModel.dart';
import '../../resources/external_resource/RadioButtonListTile.dart';

class MenuAvailableLanguageDialog extends StatefulWidget {
  final Function onLanguageSelected;
  final LanguageModel preSelectedLang;
  final String title ;
  final List<LanguageModel> restaurantLanguages;
  MenuAvailableLanguageDialog(
      {this.onLanguageSelected,
        this.title ,
      this.preSelectedLang,
      this.restaurantLanguages});

  @override
  _MenuAvailableLanguageState createState() => _MenuAvailableLanguageState();
}

class _MenuAvailableLanguageState extends State<MenuAvailableLanguageDialog> {

  String value ;
  LanguageModel menuLanguage;

  @override
  void initState() {
    super.initState();
    menuLanguage = widget.preSelectedLang;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.title ?? '',
              textScaleFactor: 1,
            ),
            SizedBox(
              height: 10,
            ),
            ...getLanguagesList(widget.restaurantLanguages),
          ],
        ),
      ),
    );
  }

  Widget languageRow(LanguageModel langModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RadioButtonListTile(
        key: GlobalKey(),
        activeColor: Colors.grey[900],
        title: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              child: Material(
                elevation: 5,
                child: AndeImageNetwork(
                  langModel.imageUrl,
                  height: 30,
                  width: 30,
                  constrained: true,
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              langModel.localeName,
              textScaleFactor: 1,
            ),
          ],
        ),
        value: langModel,
        onChanged: (langVal) {
            menuLanguage = langVal;
            widget.onLanguageSelected(menuLanguage);
        },
        groupValue: menuLanguage,
      ),
    );
  }

  getLanguagesList(List<LanguageModel> languagesList) {
    List<Widget> languagesRows = List();
    for (int i = 0; i < languagesList.length; i++) {
      languagesRows.add(GestureDetector(
          onTap: (){
            // Navigator.pop(context);
            widget.onLanguageSelected(menuLanguage);

          },
          child: languageRow(languagesList[i])));
    }
    return languagesRows;
  }
}
