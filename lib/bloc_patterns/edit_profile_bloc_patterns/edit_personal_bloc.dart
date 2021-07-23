import 'dart:async';
import 'package:intl/intl.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/data_collection.dart';
import 'package:mail/validators/edit_profile_validators.dart';
import 'package:mail/validators/register_validators.dart';
import 'package:rxdart/rxdart.dart';

class EditPersonalBloc with RegisterValidators, EditProfileValidators {
  Map<String, dynamic> _userMap;
  List<String> appelationList = ['Mr', 'Mrs', 'Miss', 'Mx'];
  bool areTextFieldsValid=false;
  EditPersonalBloc(Map<String, dynamic> sentUserMap) {
    _userMap = sentUserMap;
    appelationStreamSink.add(_userMap['appelation']==null?appelationList[0]:_userMap['appelation']);
    firstNameStreamSink.add(_userMap['firstName']==null?'':_userMap['firstName']);
    middleNameStreamSink.add(_userMap['middleName']==null?'':_userMap['middleName']);
    lastNameStreamSink.add(_userMap['lastName']==null?'':_userMap['lastName']);
    birthDateStreamSink
        .add('${_userMap['dateOfBirth']}');
    genderStreamSink.add(_userMap['gender'].toString());
  }

  final BehaviorSubject<String> _appelationBehaviorSubject =
          BehaviorSubject<String>(),
      _firstNameBehaviorSubject = BehaviorSubject<String>(),
      _middleNameBehaviorSubject = BehaviorSubject<String>(),
      _lastNameBehaviorSubject = BehaviorSubject<String>(),
      _birthDateBehaviorSubject = BehaviorSubject<String>(),
      _genderBehaviorSubject = BehaviorSubject<String>();

  final StreamController<Map<String, dynamic>> _editPersonalStreamController=StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<String> get appelationStreamSink =>
      _appelationBehaviorSubject.sink;

  StreamSink<String> get firstNameStreamSink => _firstNameBehaviorSubject.sink;

  StreamSink<String> get middleNameStreamSink =>
      _middleNameBehaviorSubject.sink;

  StreamSink<String> get lastNameStreamSink => _lastNameBehaviorSubject.sink;

  StreamSink<String> get birthDateStreamSink => _birthDateBehaviorSubject.sink;

  StreamSink<String> get genderStreamSink => _genderBehaviorSubject.sink;
  StreamSink<Map<String, dynamic>> get editPersonalStreamSink => _editPersonalStreamController.sink;

  Stream<String> get appelationStream => _appelationBehaviorSubject.stream;

  Stream<String> get firstNameStream =>
      _firstNameBehaviorSubject.stream.transform(firstNameStreamTransformer);

  Stream<String> get middleNameStream =>
      _middleNameBehaviorSubject.stream.transform(middleNameStreamTransformer);

  Stream<String> get lastNameStream =>
      _lastNameBehaviorSubject.stream.transform(lastNameStreamTransformer);

  Stream<String> get birthDateStream =>
      _birthDateBehaviorSubject.stream.transform(birthDateStreamTransformer);

  Stream<String> get genderStream =>
      _genderBehaviorSubject.stream.transform(genderStreamTransformer);

  Stream<Map<String, dynamic>> get editPersonalStream => _editPersonalStreamController.stream;

  Stream<bool> get editCheckStream => Observable.combineLatest6(
      appelationStream,
      firstNameStream,
      middleNameStream,
      lastNameStream,
      birthDateStream,
      genderStream, (appelation, firstName, middleName, lastName, birthDate,  gender)=>true);

  void editPersonalProfile() async  {
    Map<String, String> mapBody=Map<String, String>();
    mapBody['appelation']=_appelationBehaviorSubject.value;
    mapBody['firstName']=_firstNameBehaviorSubject.value;
    mapBody['middleName']=_middleNameBehaviorSubject.value;
    mapBody['lastName']=_lastNameBehaviorSubject.value;
    mapBody['dateOfBirth']=_birthDateBehaviorSubject.value;
    mapBody['gender']=_genderBehaviorSubject.value;

    //print('~~~ editPersonalProfile: $mapBody');
    Connect _connect=Connect();
    _connect.sendHeadersPost(mapBody, Connect.userUpdate).then((Map<String, dynamic> mapResponse)  {
      //print('~~~ mapResponse: $mapResponse');
      editPersonalStreamSink.add(mapResponse);
    });

  }

  void dispose() {
    _appelationBehaviorSubject.close();
    _firstNameBehaviorSubject.close();
    _middleNameBehaviorSubject.close();
    _lastNameBehaviorSubject.close();
    _birthDateBehaviorSubject.close();
    _genderBehaviorSubject.close();
    _editPersonalStreamController.close();
  }
}
