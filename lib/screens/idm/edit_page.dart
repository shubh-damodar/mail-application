import 'package:flutter/material.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

import 'package:mail/screens/profile_screens/edit_profile_screens/edit_contact_page.dart';
import 'package:mail/screens/profile_screens/edit_profile_screens/edit_location_page.dart';
import 'package:mail/screens/profile_screens/edit_profile_screens/edit_personal_page.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic> userMap;

  EditPage({this.userMap});

  _EditPageState createState() => _EditPageState(userMap: userMap);
}

class _EditPageState extends State<EditPage>
    with SingleTickerProviderStateMixin {
  final Map<String, dynamic> userMap;

  _EditPageState({this.userMap});

  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  TabController _tabController;

  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Edit'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'Personal',
                ),
                Tab(
                  text: 'Location',
                ),
                Tab(
                  text: 'Contact',
                )
              ],
            )),
        body: userMap == null
            ? TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Center(child: Text('No service')),
                  Center(child: Text('No service')),
                  Center(child: Text('No service')),
                ],
              )
            : TabBarView(
                controller: _tabController,
                children: <Widget>[
                  EditPersonalPage(userMap: userMap),
                  EditLocationPage(userMap: userMap),
                  EditContactPage(userMap: userMap),
                ],
              ));
  }
}
