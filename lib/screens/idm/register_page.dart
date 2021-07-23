import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:mail/bloc_patterns/idm_bloc_patterns/register_bloc.dart';
import 'package:mail/screens/idm/register_verify_mobile_number_page.dart';

import 'package:mail/utils/data_collection.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class RegisterPage extends StatefulWidget {
  final String previousScreen;

  RegisterPage({this.previousScreen});

  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterBloc _registerBloc = RegisterBloc();
  DataCollection _dataCollection = DataCollection();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _minimumDateTime, dateOfBirthDateTime;
  DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  bool _doesPasswordMatches = false, _isPasswordError = false;

  bool _isPasswordVisible = true, _isConfirmPasswordVisible = true;
  Country _country;
  String _namePattern = '^[a-zA-Z ]*\$';
  RegExp _nameRegExp;
  String userId = '',
      _passwordText = '',
      _confirmPasswordText = '',
      _selectedGender,
      _dateOfBirth;
  TextEditingController usernameTextEditingController = TextEditingController(),
      firstNameTextEditingController = TextEditingController(),
      lastNameTextEditingController = TextEditingController(),
      mobileTextEditingController = TextEditingController(),
      dateOfBirthTextEditingController = TextEditingController(),
      genderTextEditingController = TextEditingController(),
      countryCodeTextEditingController = TextEditingController(),
      passwordTextEditingController = TextEditingController(),
      confirmPasswordTextEditingController = TextEditingController();

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _selectedGender = null;
    _country = Country.IN;

    _minimumDateTime = DateTime(DateTime.now().year - 18, 1, 1);
    dateOfBirthDateTime = _minimumDateTime;
    //print(
      //  '~~~ _minimumDateTime: ${_minimumDateTime.year} ${_minimumDateTime.month} ${_minimumDateTime.day}');

    dateOfBirthTextEditingController.text =
        _dateFormat.format(dateOfBirthDateTime);
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _nameRegExp = RegExp(_namePattern);
  }

  void dispose() {
    super.dispose();
    _registerBloc.dispose();
    usernameTextEditingController.dispose();
    firstNameTextEditingController.dispose();
    lastNameTextEditingController.dispose();
    mobileTextEditingController.dispose();
    dateOfBirthTextEditingController.dispose();
    genderTextEditingController.dispose();
    countryCodeTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Join Now',
          style: TextStyle(),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin:
            EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0, bottom: 10.0),
        child: Form(
            autovalidate: false,
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      validator: (String value) {
                        String _usernamePattern = "^[A-Za-z0-9._]*\$";
                        RegExp _regExp = RegExp(_usernamePattern);
                        if (value.length < 3 || value.length > 20) {
                          return 'Username should have characters between 3 and 20';
                        } else if (!_regExp.hasMatch(value)) {
                          return 'Username can have alphabets, numbers, . and _ only';
                        }
                      },
                      controller: usernameTextEditingController,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Container(
                            transform:
                                Matrix4.translationValues(0.0, 20.0, 0.0),
                            child: Text(
                              '@mesbro.com',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0,
                                  color: Colors.black),
                            )),
                        labelText: 'Username',
                        hintText: 'Username',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                            ),
                      ),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 00.0, bottom: 0.0),
                    child: DropdownButton<String>(
                        hint: Text(
                          'Select a gender',
                          style: TextStyle(),
                        ),
                        value: _selectedGender,
                        items: _dataCollection.gendersList.map((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String selectedValue) {
                          setState(() {
                            _selectedGender = selectedValue;
                          });
                        })),
                Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: firstNameTextEditingController,
                      validator: (String value) {
                        if (!_nameRegExp.hasMatch(value)) {
                          return 'First name should contain only Alphabets';
                        } else if (value.length < 2) {
                          return 'First name should contain atleast 2 alphabet';
                        }
                      },
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'First name',
                        hintText: 'First name',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                            ),
                      ),
                    )),
                Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: lastNameTextEditingController,
                      validator: (String value) {
                        if (!_nameRegExp.hasMatch(value)) {
                          return 'Last name should contain only Alphabets';
                        } else if (value.length < 2) {
                          return 'Last name should contain atleast 2 alphabet';
                        }
                      },
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Last name',
                        hintText: 'Last name',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                            ),
                      ),
                    )),
                Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: passwordTextEditingController,
                      obscureText: _isPasswordVisible,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye, color: _isPasswordVisible
                              ? Colors.grey:Colors.deepOrange),
                              onPressed: () {
                                Future.delayed(Duration.zero, () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                });
                              }),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              ),
                          hintText: 'Password'),
                      validator: (String value) {
                        Future.delayed(Duration.zero, () {
                          _passwordText = value;
                          if (_passwordText.length < 8 ||
                              _passwordText.length > 32) {
//                          setState(() {
                            _isPasswordError = true;
//                          });
                            return 'Password should have characters between 8 and 32';
                          } else {
                            setState(() {
                              _isPasswordError = false;
                            });
                            if (_confirmPasswordText != '' &&
                                _passwordText == _confirmPasswordText) {
                              setState(() {
                                _doesPasswordMatches = true;
                              });
                            } else {
                              setState(() {
                                _doesPasswordMatches = false;
                              });
                              return 'Password doesn\'t matches';
                            }
                          }
                        });
                      },
                    )),
                Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                        style: TextStyle(),
                        controller: confirmPasswordTextEditingController,
                        obscureText: _isConfirmPasswordVisible,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye, color: _isConfirmPasswordVisible
                                    ? Colors.grey:Colors.deepOrange),
                                onPressed: () {
                                  Future.delayed(Duration.zero, () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  });
                                }),
                            labelText: 'Confirm password',
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.0,
                                ),
                            hintText: 'Confirm Password'),
                        validator: (String value) {
                          Future.delayed(Duration.zero, () {
                            _confirmPasswordText = value;
                            if (_confirmPasswordText != '' &&
                                _passwordText == _confirmPasswordText) {
                              setState(() {
                                _doesPasswordMatches = true;
                              });
                            } else {
                              setState(() {
                                _doesPasswordMatches = false;
                                return 'Password doesn\'t matches';
                              });
                            }
                          });
                        })),
                Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: TextFormField(
                      controller: dateOfBirthTextEditingController,
                      decoration: InputDecoration(
                          enabled: true,
                          labelText: 'Date Of Birth',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              ),
                          hintText: 'Date Of Birth',
                          suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () {
                                _selectBirthDate();
                              })),
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.black),
                    )),
                Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: CountryPicker(
                        dense: false,
                        showFlag: true,
                        showDialingCode: true,
                        showName: true,
                        onChanged: (Country selectedCountry) {
                          setState(() {
                            _country = selectedCountry;
                          });
                        },
                        selectedCountry: _country)),
                Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: mobileTextEditingController,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.black),
                      validator: (String value) {
                        String _mobileNoPattern = '^[0-9]{10}\$';
                        RegExp _regExp = RegExp(_mobileNoPattern);
                        if (!_regExp.hasMatch(value)) {
                          return 'Mobile No should contain exactly 10 digits';
                        }
                      },
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Mobile No',
                        hintText: 'Mobile No',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                            ),
                      ),
                    )),
                RaisedButton(
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                    disabledColor: Colors.deepOrange,
                    color: Colors.deepOrange,
                    child: Text(
                      'Sign Up Securely',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate() &&
                          _selectedGender != null) {
                        _widgetsCollection.showMessageDialog();
                        _registerBloc.checkRegistration(
                          usernameTextEditingController.text,
                          firstNameTextEditingController.text,
                          lastNameTextEditingController.text,
                          mobileTextEditingController.text,
                          dateOfBirthTextEditingController.text,
                          _selectedGender,
                          _country.dialingCode,
                          passwordTextEditingController.text,
                        );
                      }
                    }),
                StreamBuilder(
                  stream: _registerBloc.registerStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(
                            width: 0.0,
                            height: 0.0,
                          )
                        : _registrationFinished(asyncSnapshot.data);
                  },
                )
              ],
            )),
      ),
    );
  }

  Widget _registrationFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _registerBloc.registerStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        userId = mapResponse['content']['userId'];
        _navigationActions.navigateToScreenWidgetRoot(
            RegisterVerifyMobileNumberPage(
                userId: userId,
                mobileNo: mobileTextEditingController.text,
                previousScreen: widget.previousScreen));
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  void _selectBirthDate() async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(1900, 1, 1),
        maxTime: _minimumDateTime,
        onChanged: (date) {}, onConfirm: (DateTime date) {
      dateOfBirthDateTime = date;
      dateOfBirthTextEditingController.text = _dateFormat.format(date);
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }
}
