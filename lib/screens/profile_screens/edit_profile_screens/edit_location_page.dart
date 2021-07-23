import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mail/bloc_patterns/edit_profile_bloc_patterns/edit_location_bloc.dart';
import 'package:mail/models/place.dart';
import 'package:mail/utils/location_details.dart';
import 'package:mail/utils/data_collection.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class EditLocationPage extends StatefulWidget {
  final Map<String, dynamic> userMap;

  EditLocationPage({this.userMap});

  _EditLocationPageState createState() =>
      _EditLocationPageState(userMap: userMap);
}

class _EditLocationPageState extends State<EditLocationPage> {
  EditLocationBloc _editLocationBloc;

  final Map<String, dynamic> userMap;

  _EditLocationPageState({this.userMap});

  TextEditingController _addressLine1TextEditingController =
          TextEditingController(),
      _addressLine2TextEditingController = TextEditingController(),
      _pinCodeTextEditingController = TextEditingController(),
      _cityTextEditingController = TextEditingController(),
      _searchLocationTypeAheadTextEditingController = TextEditingController(),
      _countryTypeAheadTextEditingController = TextEditingController(),
      _stateTextEditingController = TextEditingController(),
      _districtTextEditingController = TextEditingController();

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  LocationDetails _locationDetails = LocationDetails();

  void initState() {
    super.initState();
    _editLocationBloc = EditLocationBloc(userMap);
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _editLocationBloc.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Profile Settings',),),
        body:Container(
        margin:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
        child: ListView(children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Address Line 1',
                  style: TextStyle(color: Colors.grey,),
                ),
                StreamBuilder(
                    stream: _editLocationBloc.addressLine1Stream,
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      _addressLine1TextEditingController.value =
                          _addressLine1TextEditingController.value
                              .copyWith(text: asyncSnapshot.data);
                      return Container(
                          transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                          child: TextField(
                              controller: _addressLine1TextEditingController,
                              onChanged: (String value) {
                                setState(() {
                                  _editLocationBloc.addressLine1StreamSink
                                      .add(value);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Address Line 1...',
                                errorText: asyncSnapshot.error,
                              )));
                    }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Address Line 2',
                  style: TextStyle(color: Colors.grey,),
                ),
                StreamBuilder(
                    stream: _editLocationBloc.addressLine2Stream,
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      _addressLine2TextEditingController.value =
                          _addressLine2TextEditingController.value
                              .copyWith(text: asyncSnapshot.data);
                      return Container(
                          transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                          child: TextField(
                              controller: _addressLine2TextEditingController,
                              onChanged: (String value) {
                                setState(() {
                                  _editLocationBloc.addressLine2StreamSink
                                      .add(value);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Address Line 2...',
                                errorText: asyncSnapshot.error,
                              )));
                    }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Search Location',
                  style: TextStyle(color: Colors.grey,),
                ),
                TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(hintText: 'Search Location'),
                      controller: _searchLocationTypeAheadTextEditingController,
                    ),
                    suggestionsCallback: (pattern) {
                      return _locationDetails.getSuggestions(pattern, 'city');
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      _searchLocationTypeAheadTextEditingController.text =
                          suggestion;
                      _locationDetails.citiesPlacesList
                          .indexWhere((Place place) {
                        if (place.city == suggestion) {
                          //print(
                        //      '~~~ district: ${place.district} ${place.state}');
                          _editLocationBloc.cityStreamSink.add(place.city);
                          _editLocationBloc.districtStreamSink
                              .add(place.district);
                          _editLocationBloc.stateStreamSink.add(place.state);
                          return true;
                        }
                        return false;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Search Location';
                      }
                    },
                    onSaved: (value) {})
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'City',
                  style: TextStyle(color: Colors.grey,),
                ),
                StreamBuilder(
                    stream: _editLocationBloc.cityStream,
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      _cityTextEditingController.value =
                          _cityTextEditingController.value
                              .copyWith(text: asyncSnapshot.data);
                      return Container(
                          transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                          child: TextField(
                              controller: _cityTextEditingController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'City...',
                                errorText: asyncSnapshot.error,
                              )));
                    }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'State',
                  style: TextStyle(color: Colors.grey,),
                ),
                StreamBuilder(
                    stream: _editLocationBloc.stateStream,
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      _stateTextEditingController.value =
                          _stateTextEditingController.value
                              .copyWith(text: asyncSnapshot.data);
                      return Container(
                          transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                          child: TextField(
                              controller: _stateTextEditingController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'State...',
                                errorText: asyncSnapshot.error,
                              )));
                    }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'District',
                  style: TextStyle(color: Colors.grey,),
                ),
                StreamBuilder(
                    stream: _editLocationBloc.districtStream,
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      _districtTextEditingController.value =
                          _districtTextEditingController.value
                              .copyWith(text: asyncSnapshot.data);
                      return Container(
                          transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                          child: TextField(
                              controller: _districtTextEditingController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'District...',
                                errorText: asyncSnapshot.error,
                              )));
                    }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Pin Code',
                  style: TextStyle(color: Colors.grey,),
                ),
                StreamBuilder(
                    stream: _editLocationBloc.pinCodeStream,
                    builder:
                        (BuildContext context, AsyncSnapshot asyncSnapshot) {
                      _pinCodeTextEditingController.value =
                          _pinCodeTextEditingController.value
                              .copyWith(text: asyncSnapshot.data);
                      return Container(
                          transform: Matrix4.translationValues(0.0, -5.0, 0.0),
                          child: TextField(
                              controller: _pinCodeTextEditingController,
                              enabled: false,
                              onChanged: (String value) {
                                _editLocationBloc.pinCodeStreamSink.add(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Pin Code...',
                                errorText: asyncSnapshot.error,
                              )));
                    }),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Country',
                  style: TextStyle(color: Colors.grey,),
                ),
                TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: this._countryTypeAheadTextEditingController,
                      decoration: InputDecoration(hintText: 'Country'),
                    ),
                    suggestionsCallback: (pattern) {
                      return _locationDetails.getSuggestions(
                          pattern, 'country');
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      //print('~~~ suggestion: ${suggestion}');
                      _countryTypeAheadTextEditingController.text = suggestion;
                      _editLocationBloc.countryStreamSink.add(suggestion);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Search Country';
                      }
                    },
                    onSaved: (value) {}),
              ],
            ),
          ),
        StreamBuilder(
            stream: _editLocationBloc.editLocationCheckStream,
            builder:
                (BuildContext context, AsyncSnapshot<bool> asyncSnapshot) {
              return RaisedButton(
                color: Colors.mesbroBlue,
                  child: Text(
                    'Update', style: TextStyle(color: Colors.white),
                  ),
                  onPressed: asyncSnapshot.hasData
                      ? () {
                    _widgetsCollection.showMessageDialog();
                    _editLocationBloc.editLocationProfile();
                  }
                      : null);
            }),
          StreamBuilder(
              stream: _editLocationBloc.editLocationStream,
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                return asyncSnapshot.data == null
                    ? Container(width: 0.0, height: 0.0,)
                    : _editLocationFinished(asyncSnapshot.data);
              }),
        ])));
  }
  Widget _editLocationFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _editLocationBloc.editLocationStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _widgetsCollection.showToastMessage(
            mapResponse['message']);
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(
            mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(
            mapResponse['content']['message']);
      }
    });
    return Container(width: 0.0, height: 0.0,);
  }
}
