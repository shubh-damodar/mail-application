import 'package:flutter/material.dart';
import 'package:mail/bloc_patterns/idm_bloc_patterns/forgot_password_bloc.dart';
import 'package:mail/screens/idm/verify_mobile_number_page.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

import 'package:mail/screens/idm/change_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String previousScreen;
  ForgotPasswordPage({this.previousScreen});
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final ForgotPasswordBloc _forgotPasswordBloc = ForgotPasswordBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  TextEditingController _usernameTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _forgotPasswordBloc.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Forgot password',
          ),
          centerTitle: true,
          backgroundColor: Colors.deepOrange,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(50.0),
                  ),
                  ListTile(
                    title: new Center(
                      child: new Text(
                        "Forget your password?",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                  ),
                  TextFormField(
                    controller: _usernameTextEditingController,
                    validator: (String value) {
                      String _usernamePattern = "^[A-Za-z0-9._]*\$";
                      RegExp _regExp = RegExp(_usernamePattern);
                      if (value.length < 3 || value.length > 20) {
                        return 'Username should have characters between 3 and 20';
                      } else if (!_regExp.hasMatch(value)) {
                        return 'Username can have alphabets, numbers, . and _ only';
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter username',
                      hintText: 'Username',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                  ),
                  RaisedButton(
                    
                      child: Text(
                        'Validate OTP number',
                        style: TextStyle(
                            color: Colors.white,),
                      ),
                      color: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _widgetsCollection.showMessageDialog();
                          _forgotPasswordBloc.validateOTPNumber(
                              _usernameTextEditingController.text);
                        }
                      }),
                  StreamBuilder(
                    stream: _forgotPasswordBloc.validateStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container()
                          : _validateFinished(asyncSnapshot.data);
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _validateFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _forgotPasswordBloc.validateStreamSink.add(null);
      if (mapResponse['code'] == 200) {
        //print('~~~ widget.previousScreen: ${widget.previousScreen}');
        _navigationActions.navigateToScreenWidget(VerifyMobileNumberPage(
          otpToken: mapResponse['content']['otpToken'],
          mobile: mapResponse['content']['mobile'],
          previousScreen: widget.previousScreen,
        ));
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container();
  }
}
