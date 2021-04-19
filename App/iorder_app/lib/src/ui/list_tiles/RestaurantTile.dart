import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/resources/StarRating.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:flutter/material.dart';
class RestaurantTile extends StatelessWidget {

  final RestaurantListViewModel dataModel;
  final Function onRestaurantTap;
  RestaurantTile({this.dataModel, this.onRestaurantTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key(dataModel.restaurantName.toString()) ,
      onTap: onRestaurantTap,
      child: Container(
        padding: EdgeInsets.only(bottom: 8),
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
            padding: EdgeInsets.symmetric(horizontal: 10 , vertical: 8),
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
                SizedBox(
                  width: 7.5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        dataModel.restaurantName,
                        textScaleFactor: 1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        UIHelper.getCategoriesAsList(dataModel.restaurantCuisines),
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      Visibility(
                        visible: false,
                        child: StarRating(
                          alignment: MainAxisAlignment.start,
                          starCount: 5,
                          rating: 5.0,
                          size: 20.0,
                          color: Colors.amberAccent,
                        ),
                      )
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




  Widget getImage() {
    return AndeImageNetwork(dataModel.restaurantImagePath , constrained: true, height: 60, width: 60,fit: BoxFit.cover,);
  }

}
