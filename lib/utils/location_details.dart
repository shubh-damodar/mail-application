import 'dart:async';

import 'package:mail/models/place.dart';
import 'package:mail/network/user_connect.dart';


class LocationDetails  {
  Connect _connect=Connect();
  List<Place> citiesPlacesList=List<Place>(),  countriesPlacesList=List<Place>();
  Future<List<String>> getSuggestions(String areaName, String typeOfArea) async {
    Map<String, dynamic> mapResponse= await  _connect.sendGet('${Connect.locationAutocompleteCity}$areaName&type=$typeOfArea');
    List<String> areaNamesList= List<String>();
    if(mapResponse['code']==200)  {
      List<dynamic> dynamicList = mapResponse['content'] as List<dynamic>;
      if(typeOfArea=='city') {
        dynamicList.map((i) => citiesPlacesList.add(Place.fromJSONCity(i))).toList();
        dynamicList.map((i) =>
            areaNamesList.add(Place
                .fromJSONCity(i)
                .city)).toList();
      }else if(typeOfArea=='country') {
        dynamicList.map((i) => countriesPlacesList.add(Place.fromJSONCountry(i))).toList();
        dynamicList.map((i) =>
            areaNamesList.add(Place
                .fromJSONCountry(i)
                .country)).toList();

      }
    }
    //print('~~~ areaNamesList: ${areaNamesList.toList()}');
    return areaNamesList;
  }
}