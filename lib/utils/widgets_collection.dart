import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/user_connect.dart';

class WidgetsCollection {
  BuildContext context;

  WidgetsCollection(BuildContext sentContext) {
    context = sentContext;
  }

  Widget getRaisedButton(String text, VoidCallback voidCallback) {
    return RaisedButton(
      color: Colors.deepOrange,
      child: Text(text, style: TextStyle(color: Colors.white),),
      onPressed: voidCallback,
    );
  }

  Widget getDrawerProfileImage1(widthHeight, User user) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: user.userId == Connect.currentUser.userId
                    ? Colors.mesbroBlue
                    : Colors.white)),
        padding: EdgeInsets.all(0.5),
        width: widthHeight,
        height: widthHeight,
        child: Center(
            child: ClipOval(
                child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: '${Connect.filesUrl}${user.logo}',
          placeholder: (BuildContext context, String url) {
            return Image.asset('assets/images/male-avatar.png');
          },
        ))));
  }

  Widget getDrawerProfileImage2(widthHeight, User user) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: user.userId == Connect.currentUser.userId
                    ? Colors.mesbroBlue
                    : Colors.white)),
        padding: EdgeInsets.all(0.5),
        width: widthHeight,
        height: widthHeight,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage('${Connect.filesUrl}${user.logo}'),
        ));
  }

  Widget getDrawerProfileImage(widthHeight, User user) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: user.userId == Connect.currentUser.userId
                    ? Colors.mesbroBlue
                    : Colors.white)),
        padding: EdgeInsets.all(0.5),
        width: widthHeight,
        height: widthHeight,
        child: Center(
          child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('${Connect.filesUrl}${user.logo}')),
        ));
  }

  Widget getSearchProfileImage(widthHeight, User user) {
    return Container(
//        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: user.userId == Connect.currentUser.userId
                    ? Colors.blue
                    : Colors.white)),
        padding: EdgeInsets.all(0.5),
        width: widthHeight,
        height: widthHeight,
        child: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: '${Connect.filesUrl}${user.logo}',
                  placeholder: (BuildContext context, String url) {
                    return Image.asset('assets/images/male-avatar.png');
                  },
                ))));
  }

  void showMessageDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[Center(child: CircularProgressIndicator())],
          );
        });
  }

  void showActionDialog(String message, VoidCallback yesVoidCallback,
      VoidCallback noVoidCallback) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200.0),
              child: AlertDialog(
                title: Text(''),
                content: Center(child: Text(message)),
                actions: <Widget>[
                  FlatButton(child: Text('Yes'), onPressed: yesVoidCallback),
                  FlatButton(child: Text('No'), onPressed: noVoidCallback),
                ],
              ));
        });
  }

  void showToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_LONG, fontSize: 16.0);
  }
}
