import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mail/bloc_patterns/edit_profile_bloc_patterns/edit_contact_bloc.dart';
import 'package:mail/bloc_patterns/edit_profile_bloc_patterns/edit_location_bloc.dart';
import 'package:mail/models/place.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/location_details.dart';
import 'package:mail/utils/data_collection.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class EditContactPage extends StatefulWidget {
  final Map<String, dynamic> userMap;

  EditContactPage({this.userMap}) {
    //print('~~~ EditContactPage: ${userMap['alternateMobile']['mobile']}');
  }

  _EditContactPageState createState() =>
      _EditContactPageState(userMap: userMap);
}

class _EditContactPageState extends State<EditContactPage> {
  EditContactBloc _editContactBloc;
  final Map<String, dynamic> userMap;
  final GlobalKey<FormState> _formStateGlobalKey = GlobalKey<FormState>();

  _EditContactPageState({this.userMap}) {
    //print('~~~ userMap: $userMap');
    _mobileTextEditingController.text = userMap['mobile'].toString();
    _alternateMobileTextEditingController.text =
        userMap['alternateMobile']['mobile'] == null
            ? ''
            : userMap['alternateMobile']['mobile'].toString();
    _emailTextEditingController.text = '${userMap['username']}@mesbro.com';
    _alternateEmailTextEditingController.text =
        userMap['alternateEmail'] == null ? '' : userMap['alternateEmail'];
    _websiteTextEditingController.text =
        userMap['website'] == null ? '' : userMap['website'];
    _alternateWebsiteTextEditingController.text =
        userMap['alternateWebsite'] == null
            ? ''
            : userMap['alternateWebsite'].toString();
  }

  String _mobileNoPattern = '^[0-9]{10}\$',
      _emailPattern = r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp _mobileNoRegExp, _emailRegExp;
  TextEditingController _mobileTextEditingController = TextEditingController(),
      _alternateMobileTextEditingController = TextEditingController(),
      _emailTextEditingController = TextEditingController(),
      _alternateEmailTextEditingController = TextEditingController(),
      _websiteTextEditingController = TextEditingController(),
      _alternateWebsiteTextEditingController = TextEditingController();

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _editContactBloc = EditContactBloc(userMap);
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _mobileNoRegExp = RegExp(_mobileNoPattern);
    _emailRegExp = RegExp(_emailPattern);
  }

  void dispose() {
    super.dispose();
    _editContactBloc.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile Settings'),
        ),
        body: Container(
          margin:
              EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
          child: Form(
              key: _formStateGlobalKey,
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Mobile No.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(
                            transform:
                                Matrix4.translationValues(0.0, -5.0, 0.0),
                            child: TextField(
                                enabled: false,
                                controller: _mobileTextEditingController,
                                decoration: InputDecoration(
                                  hintText: 'Mobile No. ...',
                                ))),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Alternate Mobile No.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(
                            transform:
                                Matrix4.translationValues(0.0, -5.0, 0.0),
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                autovalidate: true,
                                controller:
                                    _alternateMobileTextEditingController,
                                validator: (String value) {
                                  if (value != '' &&
                                      !_mobileNoRegExp.hasMatch(value)) {
                                    return 'Invalid  Mobile No.';
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Alternate Mobile No.',
                                ))),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Email',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(
                            transform:
                                Matrix4.translationValues(0.0, -5.0, 0.0),
                            child: TextField(
                                enabled: false,
                                controller: _emailTextEditingController,
                                decoration: InputDecoration(
                                  hintText: 'Email...',
                                ))),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Alternate Email',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(
                            transform:
                                Matrix4.translationValues(0.0, -5.0, 0.0),
                            child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                autovalidate: true,
                                controller:
                                    _alternateEmailTextEditingController,
                                validator: (String value) {
                                  if (value != '' &&
                                      !_emailRegExp.hasMatch(value)) {
                                    return 'Invalid  email';
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Alternate Email...',
                                ))),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Website',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(
                            transform:
                                Matrix4.translationValues(0.0, -5.0, 0.0),
                            child: TextFormField(
                                autovalidate: true,
                                controller: _websiteTextEditingController,
                                validator: (String value) {},
                                decoration: InputDecoration(
                                  hintText: 'Website ...',
                                ))),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Alternate Website',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(
                            transform:
                                Matrix4.translationValues(0.0, -5.0, 0.0),
                            child: TextFormField(
                                autovalidate: true,
                                controller:
                                    _alternateWebsiteTextEditingController,
                                validator: (String value) {},
                                decoration: InputDecoration(
                                  hintText: 'Alternate Website...',
                                )))
                      ],
                    ),
                  ),
                  RaisedButton(
                        shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                    color: Colors.mesbroBlue,
                      child: Text(
                        'Update',
                         style: TextStyle(color: Colors.white, ),
                      ),
                      onPressed: () {
                        _widgetsCollection.showMessageDialog();
                        if (_formStateGlobalKey.currentState.validate()) {
                          _editContactBloc.updateUserContact(
                            _alternateMobileTextEditingController.text,
                            _alternateEmailTextEditingController.text,
                            _websiteTextEditingController.text,
                            _alternateWebsiteTextEditingController.text,
                          );
                        }
                      }),
                  StreamBuilder(
                      stream: _editContactBloc.editContactStream,
                      builder:
                          (BuildContext context, AsyncSnapshot asyncSnapshot) {
                        return asyncSnapshot.data == null
                            ? Container(
                                width: 0.0,
                                height: 0.0,
                              )
                            : _editContactFinished(asyncSnapshot.data);
                      }),
                ],
              )),
        ));
  }

  Widget _editContactFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _editContactBloc.editContactStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        _widgetsCollection.showToastMessage(mapResponse['message']);
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
}
