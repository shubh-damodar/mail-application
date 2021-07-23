import 'dart:async';

class EditContactValidators {
  StreamTransformer emailStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String email, EventSink<String> eventSink) {
        String _emailPattern='^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))\$';
        RegExp _regExp=RegExp(_emailPattern);
        if(email.length==0 || _regExp.hasMatch(email)) {
          eventSink.add(email);
        } else  {
          eventSink.addError('Alternate Email is Invalid');
        }
      }
  );
  StreamTransformer alternateEmailStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String alternateEmail, EventSink<String> eventSink) {
        String _emailPattern='^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))\$';
        RegExp _regExp=RegExp(_emailPattern);
        if(alternateEmail.length==0 || _regExp.hasMatch(alternateEmail)) {
          eventSink.add(alternateEmail);
        } else  {
          eventSink.addError('Alternate Email is Invalid');
        }
      }
  );
  StreamTransformer alternateMobileNoStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String alternateMobileNo, EventSink<String> eventSink) {
        String _mobileNoPattern='^[0-9]{10}\$';
        RegExp _regExp=RegExp(_mobileNoPattern);
        if(alternateMobileNo.length==0 || _regExp.hasMatch(alternateMobileNo)) {
          eventSink.add(alternateMobileNo);
        }  else  {
          eventSink.addError('Mobile No should contain exactly 10 digits');
        }
      }
  );
  StreamTransformer websiteStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String website, EventSink<String> eventSink) {
//        String _mobileNoPattern='^[0-9]{10}\$';
////        RegExp _regExp=RegExp(_mobileNoPattern);
////        if(_regExp.hasMatch(alternateMobileNo)) {
////          eventSink.add(alternateMobileNo);
////        }  else  {
////          eventSink.addError('Mobile No should contain exactly 10 digits');
////        }
        if(website.length>-1)  {
          eventSink.add(website);
        } else  {
          eventSink.addError('Website is Invalid');
        }
      }
  );
  StreamTransformer alternateWebsiteStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String alternateWebsite, EventSink<String> eventSink) {
//        String _mobileNoPattern='^[0-9]{10}\$';
////        RegExp _regExp=RegExp(_mobileNoPattern);
////        if(_regExp.hasMatch(alternateMobileNo)) {
////          eventSink.add(alternateMobileNo);
////        }  else  {
////          eventSink.addError('Mobile No should contain exactly 10 digits');
////        }
        if(alternateWebsite.length>-1)  {
          eventSink.add(alternateWebsite);
        } else  {
          eventSink.addError('Alternate Website is Invalid');
        }
      }
  );
}