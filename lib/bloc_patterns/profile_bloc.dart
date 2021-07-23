import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/action_connect.dart';
import 'package:mail/network/file_connect.dart';
import 'package:mail/network/user_connect.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mail/validators/photo_validators.dart';

class ProfileBloc with PhotoValidators {
  FileConnect _fileConnect = FileConnect();
  ActionConnect _actionConnect = ActionConnect();
  Connect _connect = Connect();
  final StreamController<String> _profileImagePhotoStreamController =
          StreamController<String>.broadcast(),
      _bannerImagePhotoStreamController = StreamController<String>.broadcast(),
      _nameImagePhotoStreamController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _profileStreamController =
          StreamController<Map<String, dynamic>>.broadcast(),
      _tabProfileStreamController = StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<String> get profileImageStreamSink =>
      _profileImagePhotoStreamController.sink;

  StreamSink<String> get bannerImageStreamSink =>
      _bannerImagePhotoStreamController.sink;

  StreamSink<String> get nameImageStreamSink =>
      _nameImagePhotoStreamController.sink;

  StreamSink<Map<String, dynamic>> get tabProfileStreamSink =>
      _tabProfileStreamController.sink;

  StreamSink<Map<String, dynamic>> get profileStreamSink =>
      _profileStreamController.sink;

  Stream<String> get profileImageStream =>
      _profileImagePhotoStreamController.stream;

  Stream<String> get bannerImageStream =>
      _bannerImagePhotoStreamController.stream;

  Stream<String> get nameImageStream => _nameImagePhotoStreamController.stream;

  Stream<Map<String, dynamic>> get tabProfileStream =>
      _tabProfileStreamController.stream;

  Stream<Map<String, dynamic>> get profileStream =>
      _profileStreamController.stream;

  // void loadUserDetails() {
  //   User user = Connect.currentUser;
  //   profileImageStreamSink.add(user.profileImage);
  //   bannerImageStreamSink.add(user.bannerImage);
  //   nameImageStreamSink.add(user.name);
  // }

  void changeProfileCoverImage(String imageCategory) async {
    File fileImage = await FilePicker.getFile(type: FileType.IMAGE);
    String filePath = fileImage.path, fileName, fileExtension;
    fileName = filePath.substring(
        filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.'));

    fileExtension = filePath.substring(filePath.lastIndexOf('.') + 1);
    //print('~~~ fileName: $fileName fileExtension: $fileExtension');
    Map<String, dynamic> mapResponseGetDownloadUrl,
        mapResponseConfirm,
        updateMapResponse;
    mapResponseGetDownloadUrl = await _fileConnect.sendFileGet(
        '${FileConnect.uploadFileGetDownloadUrl}?type=general&fileName=$fileName&fileType=image/$fileExtension');

    await _fileConnect.uploadFile(
        mapResponseGetDownloadUrl['content']['signedUrl'],
        'image/$fileExtension',
        filePath);

    mapResponseConfirm = await _fileConnect.sendFileGet(
        '${FileConnect.uploadConfirmUploadToken}${mapResponseGetDownloadUrl['content']['uploadToken']}');

    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody[imageCategory] = mapResponseConfirm['content']['accessUrl'];
    updateMapResponse =
        await _connect.sendPostWithHeaders(mapBody, Connect.userUpdate);
    if (mapResponseConfirm['code'] == 200) {
      if (imageCategory == 'profileImage') {
        profileImageStreamSink
            .add(mapResponseGetDownloadUrl['content']['accessUrl']);
      } else if (imageCategory == 'bannerImage') {
        bannerImageStreamSink
            .add(mapResponseGetDownloadUrl['content']['accessUrl']);
      }
      //print(
       //   '~~~ imagelink: ${mapResponseGetDownloadUrl['content']['accessUrl']}');
    } else {}
  }

  void getAllUserDetails() {
    Connect _connect = Connect();
    _connect
        .sendGet(
            '${Connect.userPersonalProfileUsername}${Connect.currentUser.userId}')
        .then((Map<String, dynamic> mapResponse) {
      profileStreamSink.add(mapResponse);
      if (mapResponse['code'] == 200) {
        Map<String, dynamic> userMap = mapResponse['content'];
        profileImageStreamSink.add(userMap['profileImage']);
        bannerImageStreamSink.add(userMap['bannerImage']);
        Connect.currentUser.name =
            '${userMap['firstName'] == null ? '' : userMap['firstName']} ${userMap['lastName'] == null ? '' : userMap['lastName']}';
        nameImageStreamSink.add(Connect.currentUser.name);
        tabProfileStreamSink.add(userMap);
      }
    });
  }

  void dispose() {
    _profileImagePhotoStreamController.close();
    _bannerImagePhotoStreamController.close();
    _nameImagePhotoStreamController.close();
    _profileStreamController.close();
    _tabProfileStreamController.close();
  }
}
