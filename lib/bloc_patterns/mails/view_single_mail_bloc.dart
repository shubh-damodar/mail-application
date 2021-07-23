import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mail/models/email.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mail/models/attachment.dart';
import 'package:mail/models/user.dart';
import 'package:mail/utils/date_category.dart';
import 'package:mail/utils/feature_permissions.dart';
import 'package:mail/utils/html_tags_collection.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:mail/utils/widgets_collection.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewSingleMailBloc {
  BuildContext _buildContext;
  MessagesActions _messagesActions;
  WidgetsCollection _widgetsCollection;
  Email email;
  ViewSingleMailBloc(BuildContext context, Email sentEmail)  {
    _buildContext=context;
    _messagesActions = MessagesActions(_buildContext);
    _widgetsCollection=WidgetsCollection(_buildContext);
    email=sentEmail;
  }

  StreamController<User> _fromStreamController =
  StreamController<User>.broadcast();

  StreamController<String>  _subjectStreamController = StreamController<String>.broadcast(),
      _dateStreamController = StreamController<String>.broadcast(),
      _htmlStreamController = StreamController<String>.broadcast();

  StreamController<List<User>> _toStreamController =
  StreamController<List<User>>.broadcast(),
      _ccStreamController = StreamController<List<User>>.broadcast(),
      _bccStreamController = StreamController<List<User>>.broadcast();

  StreamController<List<Attachment>> _attachmentsStreamController =
  StreamController<List<Attachment>>.broadcast();

  StreamSink<String> get subjectStreamSink => _subjectStreamController.sink;
  StreamSink<String> get dateStreamSink => _dateStreamController.sink;

  StreamSink<String> get htmlStreamSink => _htmlStreamController.sink;

  StreamSink<User> get fromStreamSink => _fromStreamController.sink;

  StreamSink<List<User>> get toStreamSink => _toStreamController.sink;

  StreamSink<List<User>> get ccStreamSink => _ccStreamController.sink;

  StreamSink<List<User>> get bccStreamSink => _bccStreamController.sink;
  StreamSink<List<Attachment>> get attachmentsStreamSink => _attachmentsStreamController.sink;


  Stream<String> get subjectStream => _subjectStreamController.stream;
  Stream<String> get dateStream => _dateStreamController.stream;

  Stream<String> get htmlStream => _htmlStreamController.stream;

  Stream<User> get fromStream => _fromStreamController.stream;

  Stream<List<User>> get toStream => _toStreamController.stream;

  Stream<List<User>> get ccStream => _ccStreamController.stream;

  Stream<List<User>> get bccStream => _bccStreamController.stream;
  Stream<List<Attachment>> get attachmentsStream => _attachmentsStreamController.stream;

  void displayMail() async {
      subjectStreamSink.add(email.subject);
      htmlStreamSink.add(email.html);
      DateCategory _dateCategory = DateCategory();
      dateStreamSink.add(_dateCategory.EEEEMMMMdhhmmaDateFormat.format(
          DateTime.fromMillisecondsSinceEpoch(email.date)));
        fromStreamSink.add(email.fromUser);
        toStreamSink.add(email.toUserList);
        ccStreamSink.add(email.ccUserList);
        bccStreamSink.add(email.bccUserList);
        attachmentsStreamSink.add(email.attachmentList);


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
//  void markAsRead(String sentType) async {
//    _messagesActions.bulkMarkAsRead([email.conversationId], sentType);
//  }
  void dispose() {
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
