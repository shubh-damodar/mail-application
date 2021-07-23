import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mail/utils/navigation_actions.dart';

class PersonalPage extends StatefulWidget {
  Map<String, dynamic> userMap;
  PersonalPage({this.userMap})  {
    //print('PersonalPage');
  }
  _PersonalPageState createState() => _PersonalPageState(userMap: userMap);
}

class _PersonalPageState extends State<PersonalPage> {
  _PersonalPageState({this.userMap});
  NavigationActions _navigationActions;
  final Map<String, dynamic> userMap;
  DateFormat _dateFormat=DateFormat('MMM dd yyyy');
  void initState()  {
    super.initState();
    _navigationActions = NavigationActions(context);
  }
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
      child: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Full Name', style: TextStyle(color: Colors.grey),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text('${userMap['firstName']} ${userMap['lastName']}')
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Gender', style: TextStyle(color: Colors.grey),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text('${userMap['gender']}')
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Date of Birth', style: TextStyle(color: Colors.grey),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text('${_dateFormat.format(DateTime.parse(userMap['dateOfBirth']))}')
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Mobile Number', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text('${userMap['countryCode']} ${userMap['mobile']}', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Email Address', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text('${userMap['username']}@mesbro.com', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Date of Joining', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text('${_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(userMap['addedAt']))}', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Last Modified On', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text('${_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(userMap['lastModifiedAt']))}', style: TextStyle())
                )
              ],),
          ),
          Container(height: 30.0,)
        ],
      ),
    );
  }
}
