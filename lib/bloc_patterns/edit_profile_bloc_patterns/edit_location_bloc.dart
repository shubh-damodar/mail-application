import 'dart:async';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/validators/edit_location_validators.dart';
import 'package:rxdart/rxdart.dart';

class EditLocationBloc with EditLocationValidators {
  Map<String, dynamic> _userMap;

  EditLocationBloc(Map<String, dynamic> sentUserMap) {
    //print('~~~ EditLocationBloc: ${sentUserMap.values.toList()}');
    _userMap = sentUserMap;
    addressLine1StreamSink.add(_userMap['address']['addressLine1'] == null
        ? ''
        : _userMap['address']['addressLine1']);
    addressLine2StreamSink.add(_userMap['address']['addressLine2'] == null
        ? ''
        : _userMap['address']['addressLine2']);


    cityStreamSink.add(_userMap['address']['city'] == null
        ? ''
        : _userMap['address']['city']);

    stateStreamSink.add(_userMap['address']['state'] == null
        ? ''
        : _userMap['address']['state']);

    countryStreamSink.add(_userMap['address']['country'] == null
        ? ''
        : _userMap['address']['country']);

    districtStreamSink.add(_userMap['address']['district'] == null
        ? ''
        : _userMap['address']['district']);

    pinCodeStreamSink.add(_userMap['address']['postalCode'] == null
        ? ''
        : _userMap['address']['postalCode']);
  }

  final BehaviorSubject<String> _addressLine1BehaviorSubject =
  BehaviorSubject<String>(),
      _addressLine2BehaviorSubject = BehaviorSubject<String>(), _searchLocationBehaviorSubject =
  BehaviorSubject<String>(),
      _cityBehaviorSubject = BehaviorSubject<String>(),
      _stateBehaviorSubject = BehaviorSubject<String>(),
      _districtBehaviorSubject = BehaviorSubject<String>(),
      _pinCodeBehaviorSubject = BehaviorSubject<String>(),
      _countryBehaviorSubject = BehaviorSubject<String>();

  final StreamController<Map<String, dynamic>> _editLocationStreamController=StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<String> get addressLine1StreamSink =>
      _addressLine1BehaviorSubject.sink;

  StreamSink<String> get addressLine2StreamSink =>
      _addressLine2BehaviorSubject.sink;

  StreamSink<String> get cityStreamSink => _cityBehaviorSubject.sink;

  StreamSink<String> get stateStreamSink => _stateBehaviorSubject.sink;

  StreamSink<String> get districtStreamSink => _districtBehaviorSubject.sink;

  StreamSink<String> get pinCodeStreamSink => _pinCodeBehaviorSubject.sink;

  StreamSink<String> get countryStreamSink => _countryBehaviorSubject.sink;

  StreamSink<Map<String, dynamic>> get editLocationStreamSink => _editLocationStreamController.sink;

  Stream<String> get addressLine1Stream =>
      _addressLine1BehaviorSubject.stream
          .transform(addressLine1StreamTransformer);

  Stream<String> get addressLine2Stream =>
      _addressLine2BehaviorSubject.stream
          .transform(addressLine2StreamTransformer);

  Stream<String> get cityStream => _cityBehaviorSubject.stream;

  Stream<String> get stateStream => _stateBehaviorSubject.stream;

  Stream<String> get districtStream => _districtBehaviorSubject.stream;

  Stream<String> get pinCodeStream => _pinCodeBehaviorSubject.stream;

  Stream<String> get countryStream => _countryBehaviorSubject.stream;
  Stream<Map<String, dynamic>> get editLocationStream => _editLocationStreamController.stream;

  Observable<bool> get editLocationCheckStream =>
      Observable.combineLatest2(
            addressLine1Stream, addressLine2Stream, (addressLine1, addressLine2){
         return true;
      });

  void editLocationProfile() async  {
    Map<String, dynamic> mapBody=Map<String, Map<String, String>>();

    Map<String, String> mapAddress= Map<String, String>();
    mapAddress['addressLine1']=_addressLine1BehaviorSubject.value;
    mapAddress['addressLine2']=_addressLine2BehaviorSubject.value;
    mapAddress['city']=_cityBehaviorSubject.value;
    mapAddress['state']=_stateBehaviorSubject.value;
    mapAddress['country']=_countryBehaviorSubject.value;
    mapAddress['district']=_districtBehaviorSubject.value;
    mapAddress['postalCode']=_pinCodeBehaviorSubject.value;

    mapBody['address']=mapAddress;
    Connect _connect=Connect();
    _connect.sendHeadersPost(mapBody, Connect.userUpdate).then((Map<String, dynamic> mapResponse)  {
      editLocationStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    _addressLine1BehaviorSubject.close();
    _addressLine2BehaviorSubject.close();
    _searchLocationBehaviorSubject.close();
    _cityBehaviorSubject.close();
    _stateBehaviorSubject.close();
    _districtBehaviorSubject.close();
    _pinCodeBehaviorSubject.close();
    _countryBehaviorSubject.close();
    _editLocationStreamController.close();
  }
}
