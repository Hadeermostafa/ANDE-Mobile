import 'dart:io';

import 'package:ande_app/src/blocs/bloc/ApplicaitonDataBloc.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/blocs/events/UserEvents.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/data_providers/models/AddressToServerModel.dart';
import 'package:ande_app/src/data_providers/models/CountryModel.dart';
import 'package:ande_app/src/data_providers/models/CustomerAddressViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../../../main.dart';
import 'CityPickerScreen.dart';
import 'RegionPickerScreen.dart';

class AddNewAddressScreen extends StatefulWidget {
  final RestaurantViewModel restaurantViewModel;

  AddNewAddressScreen({this.restaurantViewModel});

  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  CustomerAddressViewModel locationModel;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bgColor = Color.fromARGB(100, 252, 252, 252);
  final greyColor = Color(0xff707070);
  final BoxShadow boxShadow = BoxShadow(
    spreadRadius: 0,
    blurRadius: 10,
    color: Colors.black45.withOpacity(.2),
  );
  static const double screenPadding = 16.0;
  TextEditingController _streetController,
      _buildingController,
      _floorController,
      _flatController,
      _additionalDirections;

  FocusNode _streetNode,
      _buildingNode,
      _floorNode,
      _flatNode,
      _additionalDirectionsNode;

  UserBloc userBloc;

  RegionViewModel regionViewModel;
  AreaViewModel areaViewModel;
  CountryModel userCountry = CountryModel();
  CustomerAddressViewModel customerAddressViewModel;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController();
    _floorController = TextEditingController();
    _buildingController = TextEditingController();
    _flatController = TextEditingController();
    _additionalDirections = TextEditingController();
    userBloc = BlocProvider.of<UserBloc>(context);
    BlocProvider.of<ApplicationDataBloc>(context).supportedCountries.forEach((element) {
      if (element.countryId == userBloc.userCountry.countryId) {
        userCountry = element;
        return;
      }
    });
    _streetNode = FocusNode();
    _buildingNode = FocusNode();
    _floorNode = FocusNode();
    _flatNode = FocusNode();
    _additionalDirectionsNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AndeAppbar(
        screenTitle: (LocalKeys.YOUR_ADDRESS).tr(),
        hasBackButton:  true,
      ),
      body: BlocConsumer(
        builder: (context, state) {
          return ModalProgressHUD(
            progressIndicator: loadingFlare,
            inAsyncCall: state is UserLoadingState,
            child: SingleChildScrollView(key: Key('address widget'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: screenPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        boxShadow,
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: getSpinnerView(userCountry.cities),
                    ),
                  ),
                  HelperWidget.verticalSpacer(heightVal: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        boxShadow,
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          HelperWidget.verticalSpacer(heightVal: 20),
                          buildSection((LocalKeys.STREET).tr(), _streetController,
                              true, _streetNode, _buildingNode, key: Key('street')),
                          buildSection(
                              (LocalKeys.BUILDING).tr(),
                              _buildingController,
                              true,
                              _buildingNode,
                              _floorNode , key: Key('building')),
                          buildSection((LocalKeys.FLOOR).tr(), _floorController,
                              true, _floorNode, _flatNode,
                              number: true , key: Key('floor')),
                          buildSection((LocalKeys.FLAT).tr(), _flatController,
                              false, _flatNode, _additionalDirectionsNode , key: Key('flat')),
                          buildSection(
                              (LocalKeys.ADDITIONAL).tr(),
                              _additionalDirections,
                              false,
                              _additionalDirectionsNode,
                              null , key: Key('address')),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ButtonTheme(
                      height: 60,
                      minWidth: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FlatButton(key: Key('save'),
                          padding: EdgeInsets.all(0),
                          onPressed: _addNewLocation,
                          color: Colors.grey[800],
                          child: Text(
                            LocalKeys.SAVE,
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ).tr(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        listener: (context, state) async{
          if (state is UserNewAddressSaved) {
            Navigator.pop(context, customerAddressViewModel);
          }
          else if (state is UserLoadingFailed) {
            if (state.error.errorCode == HttpStatus.requestTimeout) {
              HelperWidget.showNetworkErrorDialog(context);
              await Future.delayed(Duration(seconds: 2), () {});
              HelperWidget.removeNetworkErrorDialog(context);
              userBloc.add(state.event);
            } else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
              HelperWidget.showToast(
                  message: (LocalKeys.SERVER_UNREACHABLE).tr(),
                  isError: true
              );
              customerAddressViewModel = null;
            } else if (state.error.errorCode != 401) {
              HelperWidget.showToast(
                  message: state.error.errorMessage ?? '',
                  isError: true
              );
              customerAddressViewModel = null;
            }
          }
        },
        bloc: userBloc,
      ),
    );
  }

  buildSection(String sectionHeader, TextEditingController textController,
      bool isRequired, FocusNode focusNode, FocusNode nextFocusNode,
      {bool number, Key key}) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '$sectionHeader ${isRequired ? '*' : ''}',
              style: TextStyle(color: greyColor),
            ),
            SizedBox(
              height: 50,
              child: number != null && number
                  ? TextFormField(key: key,
                      focusNode: focusNode,
                      onFieldSubmitted: (text) {
                        if (nextFocusNode != null) {
                          FocusScope.of(context).requestFocus(nextFocusNode);
                        }
                      },
                      textInputAction: nextFocusNode != null
                          ? TextInputAction.next
                          : TextInputAction.done,
                      inputFormatters: [
                        new WhitelistingTextInputFormatter(RegExp("[٠-٩0-9]"))
                      ],
                      controller: textController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: greyColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: greyColor,
                          ),
                        ),
                      ),
                      validator: (inputText) {
                        if (isRequired) {
                          return inputText == null || inputText.isEmpty
                              ? (LocalKeys.EMPTY_FIELD_REQUIRED).tr()
                              : null;
                        }
                        return null;
                      },
                    )
                  : TextFormField(key: key,
                      onFieldSubmitted: (text) {
                        if (nextFocusNode != null) {
                          FocusScope.of(context).requestFocus(nextFocusNode);
                        }
                      },
                      textInputAction: nextFocusNode != null
                          ? TextInputAction.next
                          : TextInputAction.done,
                      controller: textController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: greyColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: greyColor,
                          ),
                        ),
                      ),
                      validator: (inputText) {
                        if (isRequired) {
                          return inputText == null || inputText.isEmpty
                              ? (LocalKeys.EMPTY_FIELD_REQUIRED).tr()
                              : null;
                        }
                        return null;
                      },
                    ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void _addNewLocation() {
    if (_formKey.currentState.validate() && areaViewModel != null) {
      FocusScope.of(context).unfocus();
      customerAddressViewModel = CustomerAddressViewModel(
        floor: ParseHelper.parseNumber(_floorController.text),
        countryModel: userCountry,
        regionViewModel: regionViewModel,
        areaViewModel: areaViewModel,
        buildingNumber: _buildingController.text,
        streetNumber: _streetController.text,
        flatNumber: _flatController.text,
        directions: _additionalDirections.text,
      );
      userBloc.add(SaveUserAddress(
        addressToServerModel: AddressToServerModel(
          countryId: ParseHelper.parseNumber(userBloc.userCountry.countryId),
          regionId: regionViewModel.regionId,
          areaId: areaViewModel.areaId,
          floor: ParseHelper.parseNumber(_floorController.text),
          flat:  _flatController.text,
          building: _buildingController.text,
          directions: _additionalDirections.text,
          street:  _streetController.text
        ),));
    }
  }

  Widget getSpinnerView(List<RegionViewModel> data) {
    data = data.where((element) => element.regionName != null).toList();
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            LocalKeys.ENTER_YOUR_LOCATION,
            style: TextStyle(
              color: greyColor,
            ),
          ).tr(),
          HelperWidget.verticalSpacer(heightVal: 15),
          GestureDetector(key: Key('government'),
            onTap: () async {
              RegionViewModel cityModel = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CityPickerScreen(
                      elements: data,
                      restaurantCities: widget.restaurantViewModel
                          .deliveryInformation.deliveryAreas,
                      chosenCity: regionViewModel,)));
              if (cityModel != null) {
                regionViewModel = cityModel;
                areaViewModel = null;
              }
              setState(() {});
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(width: 1.0, color: greyColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      regionViewModel == null ? (LocalKeys.SELECT_CITY).tr() : regionViewModel.regionName,
                      style: TextStyle(
                        fontSize: 17,
                        color: regionViewModel == null ? greyColor : Colors.black,
                        height: 0.8235294117647058,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
          HelperWidget.verticalSpacer(heightVal: 15),
          GestureDetector(
            onTap: regionViewModel != null
                ? () async {
                    AreaViewModel region = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => RegionPickerScreen(
                                elements: regionViewModel != null ? regionViewModel.areas : null,
                                restaurantCities: widget.restaurantViewModel
                                    .deliveryInformation.deliveryAreas,
                                chosenRegion: areaViewModel,)));
                    if (region != null) {
                      areaViewModel = region;
                    }
                    setState(() {});
                  }
                : null,
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(width: 1.0, color: greyColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      areaViewModel == null
                          ? (LocalKeys.SELECT_REGION).tr()
                          : areaViewModel.areaName,
                      style: TextStyle(
                        fontSize: 17,
                        color:
                            areaViewModel == null ? greyColor : Colors.black,
                        height: 0.8235294117647058,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 15,
                      color: regionViewModel == null ? greyColor : Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
