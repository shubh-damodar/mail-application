import 'dart:convert';

class User {
  String userId, username, name, address, logo, au, cc, token, bannerImage;

  User(
      {this.userId,
      this.username,
      this.name,
      this.address,
      this.logo,
      this.au,
      this.cc,
      this.token,
      this.bannerImage});

  User.fromJSON(Map<String, dynamic> map) {
    userId = map['userId'];
    username = map['username'];
    name = map['name'];
    logo = map['logo'];
    au = map['au'];
    cc = map['cc'];
    token = map['token'];
    bannerImage = map['bannerImage'];
  }

  Map<String, String> toJSON() {
    return {
      "userId": this.userId,
      "username": this.username,
      "name": this.name,
      "logo": this.logo,
      "au": this.au,
      "cc": this.cc,
      "token": this.token,
      "bannerImage": this.bannerImage,
    };
  }
  int lastNameIndex;
  String tempName;
  User.fromJSONInbox(Map<String, dynamic> map) {
    address = map['address'];
    name = map['name'] == null || map['name'] == '' ? address : map['name'];
//    logo = (map['logo'] == null ||
//            map['logo'] == 'male-avatar.png' ||
//            map['logo'] == 'female-avatar.png' ||  map['logo'] == '')
//        ?  name.indexOf(' ') > -1
//            ? '${name.split(' ')[0].substring(0,1).toUpperCase()}'
//            : '${name.substring(0,1).toUpperCase()}'
//        : map['logo'];

    logo = (map['logo'] == null ||
        map['logo'] == 'male-avatar.png' ||
        map['logo'] == 'female-avatar.png' ||  map['logo'] == '')
        ? '${name.substring(0,1).toUpperCase()}'
        : map['logo'];

//    //print('~~~ logo: $logo logo: ${map['logo']}');
  }//${name.split(' ')[1].substring(0, 1).toUpperCase()}'

  User.fromJSONSentBox(Map<String, dynamic> map) {
    address = map['address'];
    name = map['name'] == null || map['name'] == '' ? address : map['name'];

//    logo = (map['logo'] == null ||
//            map['logo'] == 'male-avatar.png' ||
//            map['logo'] == 'female-avatar.png')
//        ?  name.indexOf(' ') > -1
//            ? '${name.split(' ')[0].substring(0, 1).toUpperCase()}'
//            : '${name.substring(0, 1).toUpperCase()}'
//        : map['logo'];
    logo = (map['logo'] == null ||
        map['logo'] == 'male-avatar.png' ||
        map['logo'] == 'female-avatar.png' ||  map['logo'] == '')
        ? '${name.substring(0,1).toUpperCase()}'
        : map['logo'];
  }
  User.fromJSONViewMail(Map<String, dynamic> map)  {
    address=map['address'];
    name = map['name'] == null || map['name'] == '' ? address : map['name'];
//    logo=(map['logo'] == null ||
//        map['logo'] == 'male-avatar.png' ||
//        map['logo'] == 'female-avatar.png')
//        ?  name.indexOf(' ') > -1
//        ? '${name.split(' ')[0].substring(0, 1).toUpperCase()}'
//        : '${name.substring(0, 1).toUpperCase()}'
//        : map['logo'];
    logo = (map['logo'] == null ||
        map['logo'] == 'male-avatar.png' ||
        map['logo'] == 'female-avatar.png' ||  map['logo'] == '')
        ? '${name.substring(0,1).toUpperCase()}'
        : map['logo'];
  }
  User.fromJSONViewMailAddress(Map<String, dynamic> map)  {
    address=map['address'];
  }
  User.fromJSONAddNewContact(Map<String, dynamic> map)  {
    userId=map['id'];
    name=map['name'];
    address=map['address'];
//    logo=map['logo'];
    logo = (map['logo'] == null ||
        map['logo'] == 'male-avatar.png' ||
        map['logo'] == 'female-avatar.png' ||  map['logo'] == '')
        ? '${name.substring(0,1).toUpperCase()}'
        : map['logo'];
  }
}
