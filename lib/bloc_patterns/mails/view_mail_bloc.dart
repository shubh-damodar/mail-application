import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mail/network/mail_connect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mail/models/attachment.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/action_connect.dart';
import 'package:mail/utils/date_category.dart';
import 'package:mail/utils/feature_permissions.dart';
import 'package:mail/utils/html_tags_collection.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:mail/utils/widgets_collection.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewMailBloc {
  List<User> toUserList = List<User>(),
      ccUserList = List<User>(),
      bccUserList = List<User>();
  List<Attachment> attachmentList=List<Attachment>();
  User fromUser;
  String mailId, type, subject, htmlCode;
  BuildContext _buildContext;
  MessagesActions _messagesActions;
  WidgetsCollection _widgetsCollection;
  MailConnect _mailConnect=MailConnect();
  ViewMailBloc(BuildContext context)  {
    _buildContext=context;
    _messagesActions = MessagesActions(_buildContext);
    _widgetsCollection=WidgetsCollection(_buildContext);
  }

  StreamController<Map<String, dynamic>> _viewStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  StreamController<User> _fromStreamController =
      StreamController<User>.broadcast();

  StreamController<String> _subjectStreamController =
          StreamController<String>.broadcast(),
      _dateStreamController = StreamController<String>.broadcast(),
      _htmlStreamController = StreamController<String>.broadcast();

  StreamController<List<User>> _toStreamController =
          StreamController<List<User>>.broadcast(),
      _ccStreamController = StreamController<List<User>>.broadcast(),
      _bccStreamController = StreamController<List<User>>.broadcast();

  StreamController<List<Attachment>> _attachmentsStreamController =
  StreamController<List<Attachment>>.broadcast();
  
  StreamSink<Map<String, dynamic>> get viewStreamSink =>
      _viewStreamController.sink;

  StreamSink<String> get subjectStreamSink => _subjectStreamController.sink;

  StreamSink<String> get dateStreamSink => _dateStreamController.sink;

  StreamSink<String> get htmlStreamSink => _htmlStreamController.sink;

  StreamSink<User> get fromStreamSink => _fromStreamController.sink;

  StreamSink<List<User>> get toStreamSink => _toStreamController.sink;

  StreamSink<List<User>> get ccStreamSink => _ccStreamController.sink;

  StreamSink<List<User>> get bccStreamSink => _bccStreamController.sink;
  StreamSink<List<Attachment>> get attachmentsStreamSink => _attachmentsStreamController.sink;

  Stream<Map<String, dynamic>> get viewStream => _viewStreamController.stream;

  Stream<String> get subjectStream => _subjectStreamController.stream;

  Stream<String> get dateStream => _dateStreamController.stream;

  Stream<String> get htmlStream => _htmlStreamController.stream;

  Stream<User> get fromStream => _fromStreamController.stream;

  Stream<List<User>> get toStream => _toStreamController.stream;

  Stream<List<User>> get ccStream => _ccStreamController.stream;

  Stream<List<User>> get bccStream => _bccStreamController.stream;
  Stream<List<Attachment>> get attachmentsStream => _attachmentsStreamController.stream;

  void markAsRead(String sentMailId, String sentType) async {
    _messagesActions.bulkMarkAsRead([sentMailId], sentType);
  }

  void displayMail(String sentMailId, String sentType) async {
    mailId = sentMailId;
    type = sentType;
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['mailId'] = mailId;
    mapBody['type'] = type;
    //print('~~~ displayMail: $mapBody');
    Map<String, dynamic> mapResponse = await _mailConnect.sendMailPost(
        mapBody, MailConnect.viewMail);
  //print('~~~ mapResponse: $mapResponse');
    if (mapResponse['code'] == 200) {
      subject=mapResponse['content']['items'][0]['subject'];
      subjectStreamSink.add(subject);
      htmlCode=mapResponse['content']['items'][0]['html'];
      htmlStreamSink.add(htmlCode);
      DateCategory _dateCategory = DateCategory();
      // print('~~~ _dateCategory: ${_dateCategory.EEEEMMMMdhhmmaDateFormat.format(
      //     DateTime.fromMillisecondsSinceEpoch(
      //         mapResponse['content']['items'][0]['date']))}');
      dateStreamSink.add(_dateCategory.EEEEMMMMdhhmmaDateFormat.format(
          DateTime.fromMillisecondsSinceEpoch(
              mapResponse['content']['items'][0]['date'])));
      if (mapResponse['content']['items'][0]['from'] != null) {
        fromUser = User.fromJSONViewMail(
            mapResponse['content']['items'][0]['from'][0]);
        //print('~~~ fromUser: ${fromUser.logo}');
        fromStreamSink.add(fromUser);
      }
      if (mapResponse['content']['items'][0]['to'] != null) {
        List<dynamic> dynamicList =
            mapResponse['content']['items'][0]['to'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => toUserList.add(User.fromJSONViewMail(i)))
            .toList();
        //print('~~~ toUserList len: ${toUserList.length}');
        toStreamSink.add(toUserList);
      }
      if (mapResponse['content']['items'][0]['cc'] != null) {
        List<dynamic> dynamicList =
            mapResponse['content']['items'][0]['cc'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => ccUserList.add(User.fromJSONViewMail(i)))
            .toList();
        ccStreamSink.add(ccUserList);
      }
      if (mapResponse['content']['items'][0]['bcc'] != null) {
        List<dynamic> dynamicList =
            mapResponse['content']['items'][0]['bcc'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => bccUserList.add(User.fromJSONViewMail(i)))
            .toList();
        bccStreamSink.add(bccUserList);
      }
      if(mapResponse['content']['items'][0]['attachmentsCount']>0) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'][0]['attachments'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => attachmentList.add(Attachment.fromJSON(i)))
            .toList();
        attachmentsStreamSink.add(attachmentList);
      }
    }

    viewStreamSink.add(mapResponse);
  }
  FeaturePermissions _featurePermissions=FeaturePermissions();
  bool _isPermissionGranted=false;
  void downloadAndSaveFile(String url) async {
    _isPermissionGranted= await _featurePermissions.checkPermission(PermissionGroup.storage);
      if(_isPermissionGranted) {
        await FlutterDownloader.enqueue(
            url: url,
            savedDir: await _featurePermissions.findLocalPath(),
            showNotification: true // show download progress in status bar (for Android)
        );
        _widgetsCollection.showToastMessage('Downloading...');
      } else  {
        _widgetsCollection.showToastMessage('No storage permission');
      }
  }

  void dispose() {
    _viewStreamController.close();
    _subjectStreamController.close();
    _dateStreamController.close();
    _htmlStreamController.close();
    _fromStreamController.close();
    _toStreamController.close();
    _ccStreamController.close();
    _bccStreamController.close();
    _attachmentsStreamController.close();
  }
}
