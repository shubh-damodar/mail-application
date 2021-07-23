import 'dart:async';

mixin LoginValidators {
  StreamTransformer usernameStreamTransformer=StreamTransformer<String, String>.fromHandlers(
    handleData: (String username, EventSink<String> eventSink) {
      String _usernamePattern="^[A-Za-z0-9._]*\$";
      RegExp _regExp=RegExp(_usernamePattern);
      if(username.length<3 || username.length>20) {
        eventSink.addError('Username should have characters between 3 and 20');
      }
      else if(_regExp.hasMatch(username))  {
        eventSink.add(username);
      } else  {
        eventSink.addError('Username can have alphabets, numbers, . and _ only');
      }
    }
  );
  StreamTransformer passwordStreamTransformer=StreamTransformer<String, String>.fromHandlers(
    handleData: (String password, EventSink<String> eventSink)  {
      if(password.length>7 && password.length<33) {
        eventSink.add(password);
      } else  {
        eventSink.addError('Password should have characters between 8 and 32');
      }
    }
  );
}