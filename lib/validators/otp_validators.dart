import 'dart:async';

class OtpValidators {
  StreamTransformer otpStreamTransformer=StreamTransformer<String, String>.fromHandlers(
    handleData: (String otp, EventSink<String> eventSink) {
      String _otpPattern='^[0-9]{6}\$';
      RegExp _regExp=RegExp(_otpPattern);
      if(_regExp.hasMatch(otp) && otp.length==6) {
        eventSink.add(otp);
      } else  {
        eventSink.addError('OTP should contain exactly 6 digits');
      }
    }
  );
}