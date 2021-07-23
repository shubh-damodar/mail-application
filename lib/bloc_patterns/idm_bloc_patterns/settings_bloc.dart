import 'package:mail/network/user_connect.dart';

class SettingsBloc {
  Future<Map<String, dynamic>>  getAllUserDetails() async  {
    Connect _connect = Connect();
    Map<String, dynamic> mapResponse=await _connect
        .sendGet(
        '${Connect.userPersonalProfileUsername}${Connect.currentUser.userId}');

    Map<String, dynamic> userMap = Map<String, dynamic>();

    if (mapResponse['code'] == 200) {
      userMap = mapResponse['content'];
      return userMap;
    }
    return userMap;
  }
}