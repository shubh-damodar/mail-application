import 'dart:async';
import 'package:flutter_country_picker/flutter_country_picker.dart';

mixin RegisterValidators {
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
  StreamTransformer emailStreamTransformer=StreamTransformer<String, String>.fromHandlers(
    handleData: (String email, EventSink<String> eventSink) {
      String _emailPattern='^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))\$';
      RegExp _regExp=RegExp(_emailPattern);
      if(_regExp.hasMatch(email)) {
        eventSink.add(email);
      } else  {
        eventSink.addError('Email is Invalid');
      }
    }
  );
  StreamTransformer firstNameStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String firstName, EventSink<String> eventSink) {
        String _firstNamePattern='^[a-zA-Z ]*\$';
        RegExp _regExp=RegExp(_firstNamePattern);
        if(firstName.length<2)  {
          eventSink.addError('First name should contain atleast 1 alphabet');
        }
        else if(_regExp.hasMatch(firstName)) {
          eventSink.add(firstName);
        } else  {
          eventSink.addError('First name should contain only Alphabets');
        }
      }
  );

  StreamTransformer lastNameStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String lastName, EventSink<String> eventSink) {
        String _lastNamePattern='^[a-zA-Z]*\$';
        RegExp _regExp=RegExp(_lastNamePattern);
        if(lastName.length<2)  {
          eventSink.addError('Last name should contain atleast 1 alphabet');
        }
        else if(_regExp.hasMatch(lastName)) {
          eventSink.add(lastName);
        } else  {
          eventSink.addError('Last name should contain only Alphabets');
        }
      }
  );
  StreamTransformer genderStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String gender, EventSink<String> eventSink) {
        if(gender!='') {
          eventSink.add(gender);
        } else  {
          eventSink.addError('');
        }
      }
  );
  StreamTransformer birthDateStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String birthDate, EventSink<String> eventSink) {
        if(birthDate!='') {
          eventSink.add(birthDate);
        } else  {
          eventSink.addError('');
        }
      }
  );
  StreamTransformer countryCodeStreamTransformer=StreamTransformer<Country, Country>.fromHandlers(
      handleData: (Country countryCode, EventSink<Country> eventSink) {
        if(countryCode!=null) {
          eventSink.add(countryCode);
        }  else  {
          eventSink.addError(null);
        }
      }
  );
  StreamTransformer mobileNoStreamTransformer=StreamTransformer<String, String>.fromHandlers(
      handleData: (String mobileNo, EventSink<String> eventSink) {
        String _mobileNoPattern='^[0-9]{10}\$';
        RegExp _regExp=RegExp(_mobileNoPattern);
        if(_regExp.hasMatch(mobileNo)) {
          eventSink.add(mobileNo);
        }  else  {
          eventSink.addError('Mobile No should contain exactly 10 digits');
        }
      }
  );
}