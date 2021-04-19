import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data_providers/models/product/ProductListViewModel.dart';
import '../../resources/Constants.dart';

class ProductTile extends StatelessWidget {
  final ProductListViewModel dataModel;
  final String currencyName ;
  ProductTile(this.currencyName , {this.dataModel, this.onItemClicked});
  bool isPriceAvailable = false;
  Function onItemClicked;
  double width , height;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width ;
    height =size.height;
    isPriceAvailable =
        (dataModel.itemBasePrice != null && dataModel.itemBasePrice > 0.0);
    return GestureDetector(
      key: Key(dataModel.itemName.toString()) ,
      onTap: onItemClicked,
      child: Container(
        padding: EdgeInsets.only(top: 8),
        child: Material(
          elevation: 4,
          shape: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(.09),
              ),
              top: BorderSide(
                color: Colors.black.withOpacity(.09),
              )),
          shadowColor: Colors.black.withOpacity(.2),
          color: Colors.white,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.grey[200],
                        )),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: getImage(),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 7.5,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: onItemClicked,
                          child: Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: width*0.45,
                                      child: AutoSizeText(
                                        dataModel.itemName,
                                        textScaleFactor: 1,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4,),

                                    Visibility(
                                      visible: dataModel.isSpicy,
                                      child: Image.asset(
                                        'assets/images/spicy_icon.png',
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Text(
                                    dataModel.itemDescription,
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onItemClicked,
                        child: Container(
                          margin: EdgeInsetsDirectional.only(start: 8),
                          width: 85,
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPriceAvailable
                                    ? Colors.transparent
                                    : Colors.grey[400],
                                width: 1,
                              )),
                          child: Center(
                            child: getPriceView(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getPriceView(context) {
    if (isPriceAvailable == false) {
      return Text(
        (LocalKeys.PRICE_ON_SELECTION).tr(),
        textScaleFactor: 1,
        style: TextStyle(
          color: Constants.priceUnavailableColor,
          fontSize: 9,
        ),
      );
    } else {
      return Text(
        '${dataModel.itemBasePrice.toString()} ${ currencyName ??  (Constants.currentRestaurantCurrency)}',
        textScaleFactor: 1,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
      );
    }
  }

   Widget getImage() {
    return AndeImageNetwork(dataModel.itemImagePath ?? '' , height: 60, width: 60, fit: BoxFit.cover,  constrained: true,);
  }
}
