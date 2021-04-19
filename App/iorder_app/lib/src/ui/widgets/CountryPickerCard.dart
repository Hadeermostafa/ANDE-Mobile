import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:flutter/material.dart';

class CountryPickerCard extends StatelessWidget {

  final Function onTap;
  final CountryModel supportedCountry ;


  CountryPickerCard({this.supportedCountry , this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top:8.0 , left:8 , right: 8, bottom: 8 ),
          child: GestureDetector(
            onTap: onTap,
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    child: Material(
                      elevation: 5,
                      child: AndeImageNetwork(
                        supportedCountry.countryIconImagePath,
                        height: 50,
                        width: 50,
                        constrained: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(supportedCountry.countryName ?? ''),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 0.5,
            color: Colors.grey.withOpacity(0.2),
          ),
        )
      ],
    );
  }
}
