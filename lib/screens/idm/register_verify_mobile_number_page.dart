import 'package:flutter/material.dart';
import 'package:mail/bloc_patterns/idm_bloc_patterns/verify_mobile_number_bloc.dart';
import 'package:mail/models/user.dart';
import 'package:mail/bloc_patterns/idm_bloc_patterns/register_verify_mobile_number_bloc.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/shared_pref_manager.dart';
import 'package:mail/utils/widgets_collection.dart';

import 'package:mail/screens/idm/change_password_page.dart';

class RegisterVerifyMobileNumberPage extends StatefulWidget {
  final String userId, mobileNo, previousScreen;

  RegisterVerifyMobileNumberPage(
      {this.userId, this.mobileNo, this.previousScreen});

  _RegisterVerifyMobileNumberPageState createState() =>
      _RegisterVerifyMobileNumberPageState();
}

class _RegisterVerifyMobileNumberPageState
    extends State<RegisterVerifyMobileNumberPage> {
  final RegisterVerifyMobileNumberBloc _registerVerifyMobileNumberBloc =
      RegisterVerifyMobileNumberBloc();
  TextEditingController _mobileTextEditingController = TextEditingController(),
      _otpTextEditingController = TextEditingController();

  String otpToken = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _getOTPToken();
    _mobileTextEditingController.text = widget.mobileNo;
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void _getOTPToken() async {
    otpToken = await _registerVerifyMobileNumberBloc.generateOTP(widget.userId);
    //print('~~~ 1st _getOTPToken: $otpToken');
  }

  void dispose() {
    super.dispose();
    _registerVerifyMobileNumberBloc.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Verify mobile number',
            style: TextStyle(),
          ),
        ),
        body: Container(
            margin: EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
            child: Form(
                key: _formKey,
                child: ListView(children: <Widget>[
                  TextField(
                    controller: _mobileTextEditingController,
                    enabled: false,
                  ),
                  TextFormField(
                    style: TextStyle(),
                    controller: _otpTextEditingController,
                    maxLength: 6,
                    validator: (String value) {
                      String _otpPattern = '^[0-9]{6}\$';
                      RegExp _regExp = RegExp(_otpPattern);
                      if (!_regExp.hasMatch(value)) {
                        return 'OTP should contain exactly 6 digits';
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Your one time password',
                      labelText: 'Enter OTP',
                    ),
                  ),
                  RaisedButton(
                        shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                      color: Colors.deepOrange,
                      child: Text(
                        'Verify Mobile number',
                        style: TextStyle(
                            color: Colors.white, ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _widgetsCollection.showMessageDialog();
                          _registerVerifyMobileNumberBloc.verifyMobileNumber(
                              otpToken, _otpTextEditingController.text);
                        }
                      }),
                  GestureDetector(
                      child: Text(
                        'Resend OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(),
                      ),
                      onTap: () {
                        //print('~~~ 2nd _getOTPToken: $otpToken');
                        if (otpToken == '') {
                          _getOTPToken();
                        } else {
                          _registerVerifyMobileNumberBloc.resendOTP(otpToken);
                        }
                      }),
                  StreamBuilder(
                      stream: _registerVerifyMobileNumberBloc.verifyStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                        return asyncSnapshot.data == null
                            ? Container()
                            : _verifyFinished(asyncSnapshot.data);
                      }),
                ]))));
  }

  Widget _verifyFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _registerVerifyMobileNumberBloc.verifyStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _navigationActions.navigateToScreenName('login_page');
//        Map<String, dynamic> userMap = mapResponse['content']['userDetails'];
//        SharedPrefManager.setCurrentUser(User(
//                userId: userMap['id'].toString(),
//                name: '${userMap['firstName']} ${userMap['lastName']}',
//                username: userMap['username'],
//            logo: userMap['profileImage'],
//                au: mapResponse['content']['au'].toString(),
//                cc: userMap['user_id'].toString()))
//            .then((value) {
//          if (widget.previousScreen == '') {
//            _navigationActions.navigateToScreenNameRoot('inbox_page');
//          } else if (widget.previousScreen == 'inbox_page') {
//            _navigationActions.navigateToScreenNameRoot('inbox_page');
//            _navigationActions.navigateToScreenName('login_page');
//          }
//        });
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container();
  }
}
