import 'dart:async';
import 'package:mail/network/user_connect.dart';
import 'package:mail/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';

class ForgotPasswordBloc  {
  StreamController<Map<String, dynamic>> _validateStreamController = StreamController<Map<String, dynamic>>();

  StreamSink<Map<String, dynamic>> get validateStreamSink=>_validateStreamController.sink;

  Stream<Map<String, dynamic>> get validateStream=>_validateStreamController.stream;

  void validateOTPNumber(String username)  {
    Connect _connect=Connect();
    _connect.sendGet('${Connect.forgotPassword}$username').then((Map<String, dynamic> mapResponse)  {
      validateStreamSink.add(mapResponse);
    });
  }

  void dispose()  {
    _validateStreamController.close();
  }
}