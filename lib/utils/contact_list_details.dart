import 'package:mail/models/user.dart';
import 'package:mail/network/list_connect.dart';

class ContactListDetails  {
  ListConnect _listConnect=ListConnect();
  List<User> usersList=List<User>(), compareUsersList=List<User>();
  ContactListDetails(List<User> sentUsersList)  {
    compareUsersList=sentUsersList;
  }
  Future<List<User>> getSuggestions(String nameLetter) async {
    usersList=List<User>();
    Map<String, dynamic> mapResponse= await _listConnect.sendMailGetWithHeaders('${ListConnect.listContacts}?query=$nameLetter');
    if(mapResponse['code']==200)  {
      List<dynamic> dynamicList = mapResponse['content'] as List<dynamic>;
      //print('~~~ dynamicList: $dynamicList');
      dynamicList.map((i) => usersList.add(
          User.fromJSONAddNewContact(i))).toList();
      for(User compareUser in compareUsersList) {
        usersList.removeWhere((User user)=>user.userId==compareUser.userId);
      }
    }
    //print('~~~ usersList: ${usersList.toList()}');
    return usersList;
  }
}