import 'package:flutter/material.dart';
import 'package:mail/utils/navigation_actions.dart';

class LocationPage extends StatefulWidget {
  Map<String, dynamic> userMap;
  LocationPage({this.userMap})  {
  //print('LocationPage');
}
  _LocationPageState createState() => _LocationPageState(userMap:userMap);
}

class _LocationPageState extends State<LocationPage> {
  _LocationPageState({this.userMap});
  NavigationActions _navigationActions;
  final Map<String, dynamic> userMap;
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
                Text('Address Line 1', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text(userMap['address']['addressLine1']==null?'N/A':'${userMap['address']['addressLine1']}', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Address Line 2', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text(userMap['address']['addressLine2']==null?'N/A':'${userMap['address']['addressLine2']}', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('City', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child:Text(userMap['address']['city']==null?'N/A':'${userMap['address']['city']}', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('State', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text(userMap['address']['state']==null?'N/A':'${userMap['address']['state']}', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Country', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text(userMap['address']['country']==null?'N/A':'${userMap['address']['country']}', style: TextStyle())
                )
              ],),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Pin Code', style: TextStyle(color: Colors.grey,),),
                Container(margin: EdgeInsets.only(top: 3.0),
                    child: Text(userMap['address']['postalCode']==null?'N/A':'${userMap['address']['postalCode']}', style: TextStyle())
                )
              ],),
          ),
          Container(height: 30.0,)
        ],
      ),
    );
  }
}
