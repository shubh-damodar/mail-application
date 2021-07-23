import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:mail/models/attached_file.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/action_connect.dart';
import 'package:mail/network/file_connect.dart';
import 'package:mail/network/mail_connect.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/html_tags_collection.dart';
import 'package:mail/utils/widgets_collection.dart';

class SendBloc {
  List<String> _videoFileExtensionList = ['mp4', 'avi', 'flv', 'wmv', 'mov'],
      _docFileExtensionList = ['doc', 'docx', '.dot'],
      _imageFileExtensionList = ['jpg', 'jpeg', 'png', 'gif'],
      _generalFileExtensionList = [''];

  List<User> toUsersList = List<User>(),
      ccUsersList = List<User>(),
      bccUsersList = List<User>(),
      toUsersSuggestionsList = List<User>(),
      ccUsersSuggestionsList = List<User>(),
      bccUsersSuggestionsList = List<User>();
  List<AttachedFile> attachedFileList = List<AttachedFile>();

  SendBloc(BuildContext sentContext)  {
    buildContext=sentContext;
  }

  WidgetsCollection _widgetsCollection;
  BuildContext buildContext;
  String mailId, type, subject='', htmlCode, noTagsHtmlCode, replaceableString;
  HtmlTagsCollection _htmlTagsCollection = HtmlTagsCollection();


  ComposeBloc(BuildContext context) {
    buildContext = context;
    _widgetsCollection = WidgetsCollection(buildContext);
  }

  int indexAttachedFile;
  FileConnect _fileConnect = FileConnect();
  ActionConnect _actionConnect = ActionConnect();

  StreamController<List<AttachedFile>> _attachedFileListStreamController =
  StreamController<List<AttachedFile>>.broadcast();

  StreamController<List<User>> _toUsersListStreamController =
  StreamController<List<User>>.broadcast(),
      _ccUsersListStreamController = StreamController<List<User>>.broadcast(),
      _bccUsersListStreamController = StreamController<List<User>>.broadcast(),
      _toUsersSuggestionsListStreamController =
      StreamController<List<User>>.broadcast(),
      _ccUsersSuggestionsListStreamController =
      StreamController<List<User>>.broadcast(),
      _bccUsersSuggestionsListStreamController =
      StreamController<List<User>>.broadcast();

  StreamController<String> _subjectStreamController =
  StreamController<String>.broadcast();
  StreamController<Map<String, dynamic>> _composeFinishedStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<List<AttachedFile>> get attachedFileStreamSink =>
      _attachedFileListStreamController.sink;

  StreamSink<List<User>> get toUsersListStreamSink =>
      _toUsersListStreamController.sink;

  StreamSink<List<User>> get ccUsersListStreamSink =>
      _ccUsersListStreamController.sink;

  StreamSink<List<User>> get bccUsersListStreamSink =>
      _bccUsersListStreamController.sink;

  StreamSink<List<User>> get toUsersSuggestionsListStreamSink =>
      _toUsersSuggestionsListStreamController.sink;

  StreamSink<List<User>> get ccUsersSuggestionsListStreamSink =>
      _ccUsersSuggestionsListStreamController.sink;

  StreamSink<List<User>> get bccUsersSuggestionsListStreamSink =>
      _bccUsersSuggestionsListStreamController.sink;

  StreamSink<String> get subjectStreamSink => _subjectStreamController.sink;

  StreamSink<Map<String, dynamic>> get composeFinishedStreamSink =>
      _composeFinishedStreamController.sink;

  Stream<List<AttachedFile>> get attachedFileListStream =>
      _attachedFileListStreamController.stream;

  Stream<List<User>> get toUsersListStream =>
      _toUsersListStreamController.stream;

  Stream<List<User>> get ccUsersListStream =>
      _ccUsersListStreamController.stream;

  Stream<List<User>> get bccUsersListStream =>
      _bccUsersListStreamController.stream;

  Stream<List<User>> get toUsersSuggestionsListStream =>
      _toUsersSuggestionsListStreamController.stream;

  Stream<List<User>> get ccUsersSuggestionsListStream =>
      _ccUsersSuggestionsListStreamController.stream;

  Stream<List<User>> get bccUsersSuggestionsListStream =>
      _bccUsersSuggestionsListStreamController.stream;

  Stream<String> get subjectStream => _subjectStreamController.stream;

  Stream<Map<String, dynamic>> get composeFinishedStream =>
      _composeFinishedStreamController.stream;

  void getUploadSignedUrl(
      LinkedHashMap<String, String> selectedPathsLinkedHashMap) async {
    String fileExtension, type, fileType;
    if (selectedPathsLinkedHashMap != null) {
      selectedPathsLinkedHashMap.forEach((String key, String value) async {
        attachedFileList.add(AttachedFile(fileName: key, path: value, url: ''));
        attachedFileStreamSink.add(attachedFileList);
        fileExtension = key.substring(key.lastIndexOf('.') + 1);
        if (_videoFileExtensionList.indexOf(fileExtension) > -1) {
          type = 'video';
        } else if (_docFileExtensionList.indexOf(fileExtension) > -1) {
          type = 'doc';
        } else if (_imageFileExtensionList.indexOf(fileExtension) > -1) {
          type = 'image';
        } else if (fileExtension == 'pdf') {
          type = 'pdf';
        } else {
          type = 'general';
        }
        fileType = type == 'general' ? type : '$type/$fileExtension';
        Map<String, dynamic> mapResponseGetDownloadUrl, mapResponseConfirm;
        mapResponseGetDownloadUrl = await _fileConnect.sendFileGet(
            '${FileConnect.uploadFileGetDownloadUrl}?type=$type&fileName=$key&fileType=$fileType');



        await _fileConnect.uploadFile(
            mapResponseGetDownloadUrl['content']['signedUrl'], fileType, value);
        mapResponseConfirm = await _fileConnect.sendFileGet(
            '${FileConnect.uploadConfirmUploadToken}${mapResponseGetDownloadUrl['content']['uploadToken']}');

        indexAttachedFile = attachedFileList.indexWhere(
                (AttachedFile attachedFile) => attachedFile.fileName == key);
        if (indexAttachedFile > -1) {
          attachedFileList[indexAttachedFile].contentType = type;
          attachedFileList[indexAttachedFile].url =
          mapResponseConfirm['content']['accessUrl'];
          //print('~~~ url: ${attachedFileList[indexAttachedFile].url}');
        }
        //print('~~~ len: ${attachedFileList.length}');
      });
    }
  }

  void sendBodyMessage(String subject, String bodyMessage,
      String sentActionComposeReplyForward, String mailId, String previousAction) async {
    //print('~~~ sendBodyMessage: $subject $bodyMessage');
    List<Map<String, String>> _recipentAddressList;
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    if (toUsersList.length > 0) {
      _recipentAddressList = List<Map<String, String>>();
      for (User user in toUsersList) {
        _recipentAddressList.add({'address': user.address});
      }
      mapBody['to'] = _recipentAddressList;
    }
    if (ccUsersList.length > 0) {
      _recipentAddressList = List<Map<String, String>>();
      for (User user in ccUsersList) {
        _recipentAddressList.add({'address': user.address});
      }
      mapBody['cc'] = _recipentAddressList;
    }
    if (bccUsersList.length > 0) {
      _recipentAddressList = List<Map<String, String>>();
      for (User user in bccUsersList) {
        _recipentAddressList.add({'address': user.address});
      }
      mapBody['bcc'] = _recipentAddressList;
    }
    mapBody['subject'] = subject;
    mapBody['html'] = bodyMessage;

    List<Map<String, String>> attachedFileMapList = List<Map<String, String>>();
    if (attachedFileList.length > 0) {
      for (AttachedFile attachedFile in attachedFileList) {
        attachedFileMapList.add(attachedFile.toJson());
      }
      mapBody['attachments'] = attachedFileMapList;
    }
    String actionComposeReplyForward =
    sentActionComposeReplyForward == 'Compose'
        ? ActionConnect.actionCompose
        : (sentActionComposeReplyForward == 'Reply' ||
        sentActionComposeReplyForward == 'Reply all')
        ? ActionConnect.actionReply
        : sentActionComposeReplyForward == 'Forward'
        ? ActionConnect.actionForward
        : ActionConnect.actionDraft;
    //print('~~~ mapBody: $mapBody');
    if (sentActionComposeReplyForward == 'Reply' ||
        sentActionComposeReplyForward == 'Reply all' ||
        sentActionComposeReplyForward == 'Forward') {
      mapBody['inReplyTo'] = mailId;
    }
//    if(previousAction=='Draft') {
//      mapBody['type'] = 'draft';
//    }
    Map<String, dynamic> mapResponse =
    await _actionConnect.sendActionPost(mapBody, actionComposeReplyForward);
    composeFinishedStreamSink.add(mapResponse);
  }

  Future<String> getDraftDetails(String mailId) async {
    MailConnect _mailConnect = MailConnect();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['mailId'] = mailId;
    mapBody['type'] = 'draft';
    Map<String, dynamic> mapResponse =
    await _mailConnect.sendMailPost(mapBody, MailConnect.viewMail);

    if (mapResponse['code'] == 200) {
      subject = mapResponse['content']['items'][0]['subject'] == null
          ? ''
          : mapResponse['content']['items'][0]['subject'];
      //print('~~~ getDraftDetails subject: $subject');
      subjectStreamSink.add(subject);
      htmlCode = mapResponse['content']['items'][0]['html'];

      if (mapResponse['content']['items'][0]['to'] != null) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'][0]['to'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => toUsersList.add(User.fromJSONViewMail(i)))
            .toList();
        //print('~~~ toUserList len: ${toUsersList.length}');
        toUsersListStreamSink.add(toUsersList);
      }
      if (mapResponse['content']['items'][0]['cc'] != null) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'][0]['cc'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => ccUsersList.add(User.fromJSONViewMail(i)))
            .toList();
        ccUsersListStreamSink.add(ccUsersList);
      }
      if (mapResponse['content']['items'][0]['bcc'] != null) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'][0]['bcc'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => bccUsersList.add(User.fromJSONViewMail(i)))
            .toList();
        bccUsersListStreamSink.add(bccUsersList);
      }
      //print(
          // '~~~ 2nd tagsLinkedHashMap: ${_htmlTagsCollection.tagsLinkedHashMap.keys.toList()}');
      noTagsHtmlCode = htmlCode;
      replaceableString = '';
      _htmlTagsCollection.tagsLinkedHashMap
          .forEach((String key, List<String> value) {
        replaceableString = '';
        for (String htmlTag in value) {
          if (key == 'sameLineStartTags' &&
              htmlTag ==
                  _htmlTagsCollection.tagsLinkedHashMap['sameLineStartTags']
                  [_htmlTagsCollection.sameLineStartTagsList.length - 1]) {
            replaceableString = ' ';
          }
          noTagsHtmlCode =
              noTagsHtmlCode.replaceAll(htmlTag, replaceableString);
        }
      });
      return subject;
    }

    void dispose() {
      _attachedFileListStreamController.close();
      _toUsersListStreamController.close();
      _ccUsersListStreamController.close();
      _bccUsersListStreamController.close();
      _subjectStreamController.close();
      _composeFinishedStreamController.close();
      _toUsersSuggestionsListStreamController.close();
      _ccUsersSuggestionsListStreamController.close();
      _bccUsersSuggestionsListStreamController.close();
    }
  }
}
