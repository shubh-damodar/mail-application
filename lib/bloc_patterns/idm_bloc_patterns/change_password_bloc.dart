import 'dart:async';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/password_crypto.dart';

class ChangePasswordBloc {
  final StreamController<Map<String, dynamic>> _changePasswordStreamController=StreamController<Map<String, dynamic>>();

  StreamSink<Map<String, dynamic>> get changePasswordStreamSink=>_changePasswordStreamController.sink;
  Stream<Map<String, dynamic>> get changePasswordStream=>_changePasswordStreamController.stream;

  void changePassword(String password, String resetToken) async {
    Map<String, String> mapBody=Map<String, String>();
    mapBody['resetToken']=resetToken;
    mapBody['password']=await PasswordCrypto().generateMd5(password);
    Connect _connect=Connect();
    _connect.sendPost(mapBody, Connect.resetPasswordVerification).then((Map<String, dynamic> mapResponse)  {
      changePasswordStreamSink.add(mapResponse);
    });
  }
  void dispose()  {
    _changePasswordStreamController.close();
  }
}