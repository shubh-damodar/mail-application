import 'dart:async';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/password_crypto.dart';
import 'package:mail/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final StreamController<Map<String, dynamic>> _loginStreamController = StreamController<Map<String, dynamic>>();

  StreamSink<Map<String, dynamic>> get loginStreamSink=>_loginStreamController.sink;

  Stream<Map<String, dynamic>> get loginStream=>_loginStreamController.stream;

  void checkLogin(String username, String password) async  {
    Map<String, String> mapBody=Map<String, String>();
    mapBody['username']=username;
    mapBody['password']=await PasswordCrypto().generateMd5(password);
    Connect _connect=Connect();
    _connect.sendPost(mapBody, Connect.userLogin).then((Map<String, dynamic> mapResponse)  {
      loginStreamSink.add(mapResponse);
    });
  }

  void dispose()  {
    _loginStreamController.close();
  }
}