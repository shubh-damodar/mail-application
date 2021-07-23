import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mail/bloc_patterns/idm_bloc_patterns/login_bloc.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/screens/idm/register_page.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/shared_pref_manager.dart';
import 'package:mail/utils/widgets_collection.dart';

import 'forgot_password_page.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  final String previousScreen;

  LoginPage({this.previousScreen});

  _LoginPageState createState() =>
      _LoginPageState(previousScreen: previousScreen);
}

class _LoginPageState extends State<LoginPage> {
  final String previousScreen;

  _LoginPageState({this.previousScreen});

  final LoginBloc _loginBloc = LoginBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _usernameTextEditingController =
          TextEditingController(),
      _passwordTextEditingController = TextEditingController();
  bool _isPasswordVisible = true;

  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _usernameTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _loginBloc.dispose();
  }

  Future<bool> _onWillPop() async {
    //print('~~~ 1st previousScreen: $previousScreen');
    if (previousScreen == 'inbox_page') {
      //print('~~~ 2nd previousScreen: $previousScreen');
      return true;
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          // appBar: AppBar(
          //   title: Text('Login'),
          // ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(left: 25.0, right: 25.0),
            child: Form(
              autovalidate: false,
              key: _formKey,
              child: Center(
                child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(60.0),
                  ),
                  Image(
                    image: AssetImage("assets/images/mesbro.png"),
                    width: 150.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  ListTile(
                    title: Text(
                      "Search, Share and Save Anything,",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                          color: Colors.black26),
                    ),
                    subtitle: Text(
                      "Communicate Freely and Grow Exponentially",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                          color: Colors.black26),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                        top: 30.0,
                      ),
                      child: TextFormField(
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
                          labelText: 'Username',
                          hintText: 'Username',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,),
                        ),
                      )),
                  Container(
                      margin: EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: TextFormField(
                        controller: _passwordTextEditingController,
                        validator: (String value) {
                          if (value.length < 8 || value.length > 32) {
                            return 'Password should have characters between 8 and 32';
                          }
                        },
                        obscureText: _isPasswordVisible,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye,
                                  color: _isPasswordVisible
                                      ? Colors.grey
                                      : Colors.deepOrange),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              }),
                          labelText: 'Password',
                          hintText: 'Password',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  ButtonTheme(
                      height: 40.0,
                      minWidth: 350.0,
                      child: RaisedButton(
                          color: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _widgetsCollection.showMessageDialog();
                              _loginBloc.checkLogin(
                                  _usernameTextEditingController.text,
                                  _passwordTextEditingController.text);
                            }
                          })),
                  StreamBuilder(
                      stream: _loginBloc.loginStream,
                      builder:
                          (BuildContext context, AsyncSnapshot asyncSnapshot) {
                        return asyncSnapshot.data == null
                            ? Container(
                                width: 0.0,
                                height: 0.0,
                              )
                            : _loginFinished(asyncSnapshot.data);
                      }),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 18.0),
                      ),
                      new GestureDetector(
                        child: Container(
                            margin: EdgeInsets.only(top: 20.0),
                            child: Text('Forgot Password?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.0,
                                    color: Colors.black38))),
                        onTap: () {
                          //print(
                           //   '~~~ widget.previousScreen: ${widget.previousScreen}');
                          _navigationActions
                              .navigateToScreenWidget(ForgotPasswordPage(
                            previousScreen: widget.previousScreen,
                          ));
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  new GestureDetector(
                    onTap: () {
                      //print("Register");
                    },
                    child: new RichText(
                      text: new TextSpan(
                        children: [
                          new TextSpan(
                            text: 'New To Mesbro, ',
                            style: new TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w400),
                          ),
                          new TextSpan(
                            text: 'Join Now',
                            style: new TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                _navigationActions
                                    .navigateToScreenWidget(RegisterPage(
                                  previousScreen: widget.previousScreen,
                                ));
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ));
  }

  Widget _loginFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialog();
      _loginBloc.loginStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        Map<String, dynamic> userMap = mapResponse['content']['userDetails'];
        //print(
      //      '~~~ 1st usersList: ${SharedPrefManager.usersList.length} ${Connect.currentUser}');//
        //print('~~~ bannerImage: ${userMap['bannerImage'].toString()}');
        //print('~~~ 1st usersList: ${SharedPrefManager.usersList.length}');
        if (SharedPrefManager.usersList.length > 0 &&
            widget.previousScreen == 'inbox_page') {
          bool _isAlreadyLoggedIn = false;
          //print('~~~ 1st usersList: ${SharedPrefManager.usersList.length}');

          for(User user in SharedPrefManager.usersList) {
            if (user.userId == userMap['id']) {
              //print('~~~ 3rd user: ${user.name}');
              _widgetsCollection.showToastMessage('User already logged In');
              _isAlreadyLoggedIn=true;
            }
          }

          if (!_isAlreadyLoggedIn) {
            SharedPrefManager.setCurrentUser(User(
              userId: userMap['id'].toString(),
              username: userMap['username'].toString(),
              name:
                  '${userMap['firstName'].toString()} ${userMap['lastName'].toString()}',
              logo: userMap['profileImage'].toString(),
              au: mapResponse['content']['au'].toString(),
              token: mapResponse['content']['token'].toString(),
              cc: userMap['countryCode'].toString(),
              bannerImage: userMap['bannerImage'].toString(),
            )).then((value) {
              _navigationActions.navigateToScreenNameRoot('inbox_page');
            });
          }
        } else {
          SharedPrefManager.setCurrentUser(User(
            userId: userMap['id'].toString(),
            username: userMap['username'].toString(),
            name:
                '${userMap['firstName'].toString()} ${userMap['lastName'].toString()}',
            logo: userMap['profileImage'].toString(),
            au: mapResponse['content']['au'].toString(),
            token: mapResponse['content']['token'].toString(),
            cc: userMap['countryCode'].toString(),
            bannerImage: userMap['bannerImage'].toString(),
          )).then((value) {
            _navigationActions.navigateToScreenNameRoot('inbox_page');
          });
        }
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }
}
