import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mail/screens/idm/forgot_password_page.dart';
import 'package:mail/screens/home_page.dart';
import 'package:mail/screens/idm/login_page.dart';
import 'package:mail/screens/mails/archive_page.dart';
import 'package:mail/screens/mails/draft_page.dart';
import 'package:mail/screens/mails/inbox_page.dart';
import 'package:mail/screens/mails/sent_box_page.dart';
import 'package:mail/screens/mails/signature_page.dart';
import 'package:mail/screens/mails/spam_page.dart';
import 'package:mail/screens/mails/starred_page.dart';
import 'package:mail/screens/mails/trash_page.dart';
import 'package:mail/screens/profile_screens/edit_profile_screens/profile_page.dart';
import 'package:mail/screens/idm/register_page.dart';
import 'package:mail/utils/network_connectivity.dart';
import 'package:mail/utils/shared_pref_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mail/screens/mails/compose_page.dart';

import 'models/user.dart';
import 'network/user_connect.dart';
import 'package:flutter_stetho/flutter_stetho.dart';

void main() {
  Stetho.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPrefManager.getSharedPref().then((SharedPreferences sharedPreferences) {
    SharedPrefManager.getCurrentUser().then((User user) {
      SharedPrefManager.getAllUsers();
      if (user != null) {
        Connect.currentUser = user;
      }
      runApp(MyApp());
    });
  });
}

class MyApp extends StatelessWidget {
//  static GlobalKey<NavigatorState> navigatorStateGlobalKey=GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NetworkConnectivity(
        widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mesbro Mail',
            theme: ThemeData(
                accentColor: Colors.mesbroBlue,
                primarySwatch: Colors.mesbroBlue,
                fontFamily: 'Poppins'
                ),
            home: Connect.currentUser == null
                ? LoginPage(previousScreen: '')
                : InboxPage(),
            routes: <String, WidgetBuilder>{
          '/login_page': (BuildContext context) =>
              LoginPage(previousScreen: ''),
          '/register_page': (BuildContext context) => RegisterPage(),
          '/home_page': (BuildContext context) => HomePage(),
          '/forgot_password_page': (BuildContext context) =>
              ForgotPasswordPage(),
          '/profile_page': (BuildContext context) => ProfilePage(),
          '/inbox_page': (BuildContext context) => InboxPage(),
          '/sent_box_page': (BuildContext context) => SentBoxPage(),
          '/home_page': (BuildContext context) => HomePage(),
          '/draft_page': (BuildContext context) => DraftPage(),
          '/archive_page': (BuildContext context) => ArchivePage(),
          '/signature_page': (BuildContext context) => SignaturePage(),
          '/spam_page': (BuildContext context) => SpamPage(),
          '/trash_page': (BuildContext context) => TrashPage(),
          '/compose_page': (BuildContext context) => ComposePage(),
          '/starred_page': (BuildContext context) => StarredPage(),
          '/signature_page': (BuildContext context) => SignaturePage(),
        }));
  }
}
