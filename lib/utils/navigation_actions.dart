import 'package:flutter/material.dart';

class NavigationActions {
  BuildContext context;
  NavigationActions(BuildContext sentContext) {
    context=sentContext;
  }
  void navigateToScreenName(String routeName) {
    Navigator.of(context, rootNavigator: false).pushNamed('/$routeName');
  }

  void navigateToScreenWidget(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget));
  }

  void navigateToScreenNameRoot(String routeName) {
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed('/$routeName');
  }

  void navigateToScreenWidgetRoot(Widget widget) {
    Navigator.of(context, rootNavigator: true)
        .pushReplacement(MaterialPageRoute(builder: (context) => widget));
  }

  void closeDialog() {
    Navigator.of(context, rootNavigator: false).pop();
  }
  void closeDialogRoot() {
    Navigator.of(context, rootNavigator: true).pop();
  }
  void previousScreenUpdate() {
    Navigator.of(context).pop(true);
  }
  void previousScreen() {
    Navigator.pop(context);
  }
}
