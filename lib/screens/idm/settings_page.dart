import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mail/bloc_patterns/idm_bloc_patterns/settings_bloc.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

import 'package:mail/screens/profile_screens/edit_profile_screens/edit_contact_page.dart';
import 'package:mail/screens/profile_screens/edit_profile_screens/edit_location_page.dart';
import 'package:mail/screens/profile_screens/edit_profile_screens/edit_personal_page.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> userMap;

  SettingsPage({this.userMap});
  _SettingsPageState createState() => _SettingsPageState(userMap: userMap);
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> userMap;

  _SettingsPageState({this.userMap});
  final SettingsBloc _settingsBloc=SettingsBloc();
  LinkedHashMap<String, Widget> _optionsLinkedHashMap =
  LinkedHashMap<String, Widget>();

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _modifyUserDetails();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }
  void _modifyUserDetails()  {
    _optionsLinkedHashMap['Edit Personal'] = EditPersonalPage(userMap: userMap);
    _optionsLinkedHashMap['Edit Location'] = EditLocationPage(userMap: userMap);
    _optionsLinkedHashMap['Edit Contact'] = EditContactPage(userMap: userMap);
  }
  void _navigateAndRefresh(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) async {

      userMap=await _settingsBloc.getAllUserDetails();
      //print('~~~ _navigateAndRefresh: $userMap');
      _modifyUserDetails();
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings', style: TextStyle(),),
      ),
      body: Container(
          margin:
          EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
          child: ListView.builder(
            itemCount: _optionsLinkedHashMap.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_optionsLinkedHashMap.keys.toList()[index], style: TextStyle(),),
                onTap: () {
                  _navigateAndRefresh(
                      _optionsLinkedHashMap.values.toList()[index]);
                },
              );
            },
          )),
    );
  }
}
