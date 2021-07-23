import 'dart:async';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/password_crypto.dart';
import 'package:mail/validators/otp_validators.dart';
import 'package:rxdart/rxdart.dart';

class RegisterVerifyMobileNumberBloc with OtpValidators {
  StreamController<Map<String, dynamic>> _verifyStreamController = StreamController<Map<String, dynamic>>();

  StreamSink<Map<String, dynamic>> get verifyStreamSink=>_verifyStreamController.sink;

  Stream<Map<String, dynamic>> get verifyStream=>_verifyStreamController.stream;

  void verifyMobileNumber(String otpToken, String otp) async {
    Map<String, String> mapBody=Map<String, String>();
    mapBody['otpToken']=otpToken;
    mapBody['otp']=await PasswordCrypto().generateMd5(otp);
    Connect _connect=Connect();
    _connect.sendPost(mapBody, Connect.otpValidate).then((Map<String, dynamic> mapResponse)  {
      verifyStreamSink.add(mapResponse);
    });
  }
  Future<String> generateOTP(String userId) async {
    Map<String, String> mapBody=Map<String, String>();
    mapBody['userId']=userId;
    mapBody['type']='register';
    Connect _connect=Connect();
    Map<String, dynamic> mapResponse= await _connect.sendPost(mapBody, Connect.otpGenerate);
    if(mapResponse['code']==200)  {
      return mapResponse['content']['otpToken'];
    } else  {
      return '';
    }
  }

  void resendOTP(String otpToken) async {
    Map<String, String> mapBody=Map<String, String>();
    mapBody['otpToken']=otpToken;
    Connect _connect=Connect();
    _connect.sendGet('${Connect.otpResend}$otpToken').then((Map<String, dynamic> mapResponse)  {
    });
  }
  void dispose()  {
    _verifyStreamController.close();
  }
}