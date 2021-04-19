import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/DeliveryArea.dart';
import 'package:ande_app/src/resources/external_resource/RadioButtonListTile.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
class CityPickerScreen extends StatefulWidget {
  final List<RegionViewModel> elements;
  final List<DeliveryArea> restaurantCities;
  final RegionViewModel chosenCity;
  CityPickerScreen({this.elements, this.restaurantCities, this.chosenCity});
  @override
  _CityPickerScreenState createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  List<RegionViewModel> systemElements = List<RegionViewModel>(),
      elements = List<RegionViewModel>();
  List<DeliveryArea> restaurantCities;
  RegionViewModel _previouslySelectedCity;
  RegionViewModel _cityViewModel;

  @override
  void initState() {
    super.initState();

    this.systemElements = widget.elements;
    this.restaurantCities = widget.restaurantCities;
    if (widget.chosenCity != null) {
      _previouslySelectedCity = widget.chosenCity;
    } else {
      _previouslySelectedCity = RegionViewModel()..regionId = -1;
    }
  }

  void _checkForPreviousSelection() {
    if (_previouslySelectedCity != null && widget.elements != null && widget.elements.length > 0) {
      for (int i = 0; i < widget.elements.length; i++) {
        if (_previouslySelectedCity.regionId == widget.elements[i].regionId) {
          _cityViewModel = _previouslySelectedCity;
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (restaurantCities != null) {
      for (int i = 0; i < systemElements.length; i++) {
        if (restaurantCities.indexWhere(
                (element) => (systemElements[i].regionId == element.regionId)) >
            -1) {
          elements.add(systemElements[i]);
        }
      }
    }
    _checkForPreviousSelection();
    return Scaffold(
      appBar: AndeAppbar(
        screenTitle:(LocalKeys.SELECT_CITY).tr(),
        hasBackButton:true,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            HelperWidget.verticalSpacer(heightVal: 15),
            Expanded(
              child: ListView.builder(
                  itemCount: widget.elements.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: RadioButtonListTile<RegionViewModel>( key: Key(widget.elements[index].regionName),
                        selected: widget.elements[index].regionId == _previouslySelectedCity.regionId,
                        groupValue: _cityViewModel,
                        dense: false,
                        activeColor: Colors.black,
                        title: Expanded(
                            child: Text(widget.elements[index].regionName)),
                        onChanged: (RegionViewModel value) {
                          setState(() {
                            _cityViewModel = value;
                          });
                          Navigator.pop(context, _cityViewModel);
                        },
                        value: widget.elements[index],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
