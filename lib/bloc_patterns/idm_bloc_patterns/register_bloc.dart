import 'dart:async';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/password_crypto.dart';

class RegisterBloc {
  final StreamController<Map<String, dynamic>> _registerStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<Map<String, dynamic>> get registerStreamSink =>
      _registerStreamController.sink;

  Stream<Map<String, dynamic>> get registerStream =>
      _registerStreamController.stream;

  void checkRegistration(
      String username,
      String firstName,
      String lastName,
      String mobile,
      String dateOfBirth,
      String gender,
      String countryCode,
      String password) async {
    Map<String, String> mapBody = Map<String, String>();
    mapBody['username'] = username;
    mapBody['firstName'] = firstName;
    mapBody['lastName'] = lastName;
    mapBody['mobile'] = mobile;
    mapBody['dateOfBirth'] =dateOfBirth;
    mapBody['gender'] = gender;
    mapBody['countryCode'] =countryCode;
    mapBody['password'] = await PasswordCrypto().generateMd5(password);
    Connect _connect = Connect();
    _connect
        .sendPost(mapBody, Connect.userSignUp)
        .then((Map<String, dynamic> mapResponse) {
      registerStreamSink.add(mapResponse);
    });
  }

  void dispose() {
    _registerStreamController.close();
  }
}
