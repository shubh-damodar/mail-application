import 'dart:async';

class EditProfileValidators {
  StreamTransformer middleNameStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String middleName, EventSink<String> eventSink) {
        String _middleNamePattern='^[a-zA-Z ]*\$';
        RegExp _regExp=RegExp(_middleNamePattern);
        if(middleName.length!=0 && middleName.length<2)  {
          eventSink.addError('Middle name should contain atleast 2 alphabets');
        }
        else if(_regExp.hasMatch(middleName)) {
          eventSink.add(middleName);
        } else  {
          eventSink.addError('Middle name should contain only Alphabets');
        }
      }
  );
}