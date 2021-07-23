import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
class NetworkConnectivity extends InheritedWidget {
  NetworkConnectivity({Key key, Widget widget}):super(key: key, child: widget);
  StreamSubscription _streamSubscription=null;
  static BuildContext buildContext;
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
  static NetworkConnectivity of(BuildContext context) {
    buildContext=context;
    return (context.inheritFromWidgetOfExactType(NetworkConnectivity) as NetworkConnectivity);
  }

  void checkNetworkConnection() {
    if(_streamSubscription==null) {
      _streamSubscription = Connectivity().onConnectivityChanged.listen((
          ConnectivityResult connectivityResult) {
        if (connectivityResult == ConnectivityResult.none) {
//          Scaffold.of(buildContext).showSnackBar(SnackBar(content: Text('Please connect to internet')));
          Fluttertoast.showToast(msg: "Please connect to internet", toastLength: Toast.LENGTH_SHORT, gravity:  ToastGravity.BOTTOM);
        }
        //print('~~~ connectivityResult: $connectivityResult');
      });
    }
  }
  void dispose()  {
    if(_streamSubscription!=null) {
      _streamSubscription.cancel();
    }
  }
}