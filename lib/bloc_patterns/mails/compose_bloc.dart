import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mail/models/attachment.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/action_connect.dart';
import 'package:mail/network/file_connect.dart';
import 'package:mail/network/mail_connect.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/html_tags_collection.dart';
import 'package:mail/utils/widgets_collection.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ComposeBloc {
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
  List<Attachment> attachmentList = List<Attachment>();
  WidgetsCollection _widgetsCollection;
  Function modifyJSFunction;
  BuildContext buildContext;
  String conversationId, type, subject = '', htmlCode, draftId, previousAction;
  bool isCCBCCOpen = false, areToVisible = false,
  areCCVisible = false,
  areBCCVisible = false;
  Connect _connect = Connect();

  ComposeBloc(BuildContext context, String sentDraftId, String sentHtmlCode,
      String sentPreviousAction) {
    buildContext = context;
    draftId = sentDraftId;
    //print('~~~ sentHtmlCode: $sentHtmlCode');
    if (sentHtmlCode == null) {
      sentHtmlCode = '';
    }
    htmlCode = sentHtmlCode;
    previousAction = sentPreviousAction.toLowerCase();
    previousAction = previousAction == 'reply all' ? 'reply' : previousAction;
    _widgetsCollection = WidgetsCollection(buildContext);
    //print('~~~ previousAction: $previousAction');
    getSignature();
  }

  int indexattachment;
  FileConnect _fileConnect = FileConnect();
  ActionConnect _actionConnect = ActionConnect();
  MailConnect _mailConnect = MailConnect();

  StreamController<List<Attachment>> _attachmentListStreamController =
      StreamController<List<Attachment>>.broadcast();

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
          StreamController<String>.broadcast(),
      _bodyStreamController = StreamController<String>.broadcast();
  StreamController<Map<String, dynamic>> _composeFinishedStreamController =
          StreamController<Map<String, dynamic>>.broadcast(),
      _draftSentFinishedStreamController =
          StreamController<Map<String, dynamic>>.broadcast(),
      _replyForwardFinishedStreamController =
          StreamController<Map<String, dynamic>>.broadcast();

  StreamSink<List<Attachment>> get attachmentStreamSink =>
      _attachmentListStreamController.sink;

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

  StreamSink<String> get bodyStreamSink => _bodyStreamController.sink;

  StreamSink<Map<String, dynamic>> get composeFinishedStreamSink =>
      _composeFinishedStreamController.sink;

  StreamSink<Map<String, dynamic>> get draftSentFinishedStreamSink =>
      _draftSentFinishedStreamController.sink;

  StreamSink<Map<String, dynamic>> get replyForwardFinishedStreamSink =>
      _replyForwardFinishedStreamController.sink;

  Stream<List<Attachment>> get attachmentListStream =>
      _attachmentListStreamController.stream;

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

  Stream<String> get bodyStream => _bodyStreamController.stream;

  Stream<Map<String, dynamic>> get composeFinishedStream =>
      _composeFinishedStreamController.stream;

  Stream<Map<String, dynamic>> get draftSentFinishedStream =>
      _draftSentFinishedStreamController.stream;

  Stream<Map<String, dynamic>> get replyForwardFinishedStream =>
      _replyForwardFinishedStreamController.stream;

  void takePicture() async  {
    File _imageFile=await ImagePicker.pickImage(source: ImageSource.camera);
    //print('~~~ takePicture: ${_imageFile.path}');
    getUploadSignedUrl('${DateTime.now().toString()}.jpg', _imageFile.path);
  }

  void getUploadSignedUrl(String key, value) async {
    int sizeOfFile = File(value).lengthSync();
    indexattachment = attachmentList
        .indexWhere((Attachment attachment) => attachment.fileName == key);
    if (sizeOfFile > 18000000) {
      _widgetsCollection.showToastMessage('File should be less than 18 MB');
    } else if (indexattachment > -1) {
      _widgetsCollection.showToastMessage('File already added');
    } else {
      String fileExtension, type, fileType;
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
      //print('~~~ selectedPathsselectedPaths: $key $value');
      attachmentList.add(Attachment(
          fileName: key,
          location: value,
          path: '',
          type: '',
          fileSize: sizeOfFile));
      attachmentStreamSink.add(attachmentList);
      fileType = type == 'general' ? type : '$type/$fileExtension';
      Map<String, dynamic> mapResponseGetDownloadUrl, mapResponseConfirm;
      mapResponseGetDownloadUrl = await _fileConnect.sendFileGet(
          '${FileConnect.uploadFileGetDownloadUrl}?type=$type&fileName=$key&fileType=$fileType');

      await _fileConnect.uploadFile(
          mapResponseGetDownloadUrl['content']['signedUrl'], fileType, value);

      mapResponseConfirm = await _fileConnect.sendFileGet(
          '${FileConnect.uploadConfirmUploadToken}${mapResponseGetDownloadUrl['content']['uploadToken']}');

      indexattachment = attachmentList
          .indexWhere((Attachment attachment) => attachment.fileName == key);

      //print('~~~ indexattachment: $indexattachment');
      if (indexattachment > -1) {
        attachmentList[indexattachment].type = type;
        attachmentList[indexattachment].contentType = fileType;
        attachmentList[indexattachment].path =
            '${Connect.filesUrl}${mapResponseConfirm['content']['accessUrl']}';
      }
      attachmentStreamSink.add(attachmentList);
      //print('~~~ len: ${attachmentList.length}');
    }
  }

  void sendBodyMessage(String subject, String bodyMessage,
      String sentActionComposeReplyForward, String conversationId) async {
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
    if (subject == '') {
      subject = 'No Subject';
    }
    mapBody['subject'] = subject;
    mapBody['html'] = bodyMessage;

    List<Map<String, dynamic>> attachmentMapList = List<Map<String, dynamic>>();
    if (attachmentList.length > 0) {
      for (Attachment attachment in attachmentList) {
        //print('~~~ for attachment: ${attachment.toJson()}');
        if (attachment.contentType != null) {
          attachmentMapList.add(attachment.toJson());
        }
      }
      mapBody['attachments'] = attachmentMapList;
      //print('~~~ attachmentMapList: ${mapBody['attachments']}');
    }
    //print('~~~ sentActionComposeReplyForward: $sentActionComposeReplyForward');
    String actionComposeReplyForward =
        sentActionComposeReplyForward == 'Compose'
            ? ActionConnect.actionCompose
            : (sentActionComposeReplyForward == 'Reply' ||
                    sentActionComposeReplyForward == 'Reply all')
                ? ActionConnect.actionReply
                : sentActionComposeReplyForward == 'Forward'
                    ? ActionConnect.actionForward
                    : ActionConnect.actionCompose;
    if (sentActionComposeReplyForward == 'Reply' ||
        sentActionComposeReplyForward == 'Reply all' ||
        sentActionComposeReplyForward == 'Forward') {
      mapBody['inReplyTo'] = conversationId;
    } else if (draftId != null) {
      mapBody['draftId'] = draftId;
    }
    //print('~~~ action: $mapBody');
    Map<String, dynamic> mapResponse =
        await _actionConnect.sendActionPost(mapBody, actionComposeReplyForward);
    composeFinishedStreamSink.add(mapResponse);
  }

  Future<String> getDraftDetails(String conversationId) async {
    MailConnect _mailConnect = MailConnect();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['mailId'] = conversationId;
    mapBody['type'] = 'draft';
    Map<String, dynamic> mapResponse = await _mailConnect.sendMailPost(
        mapBody, MailConnect.viewMail);
    //print('~~~ getDraftDetails: $mapResponse');
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
      //print('~~~ items: ${mapResponse['content']['items'][0]}');
      if (mapResponse['content']['items'][0]['cc'] != null) {
        isCCBCCOpen=true;
        areCCVisible=true;
        List<dynamic> dynamicList =
            mapResponse['content']['items'][0]['cc'] as List<dynamic>;
        //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => ccUsersList.add(User.fromJSONViewMail(i)))
            .toList();
        ccUsersListStreamSink.add(ccUsersList);
      }
      if (mapResponse['content']['items'][0]['bcc'] != null) {
        isCCBCCOpen=true;
        areBCCVisible=true;
        List<dynamic> dynamicList =
            mapResponse['content']['items'][0]['bcc'] as List<dynamic>;
        //print('~~~ bcc dynamicList: $dynamicList');
        dynamicList
            .map((i) => bccUsersList.add(User.fromJSONViewMail(i)))
            .toList();
        bccUsersListStreamSink.add(bccUsersList);
      }
      if (mapResponse['content']['items'][0]['html'] != null) {
        htmlCode = mapResponse['content']['items'][0]['html'];
        bodyStreamSink.add(htmlCode);
      }
      if (mapResponse['content']['items'][0]['hasAttachment']) {
      //print('~~~ attach: ${mapResponse['content']['items'][0]['attachments']}');
      List<dynamic> dynamicList = mapResponse['content']['items'][0]['attachments'] as List<dynamic>;
//      //print('~~~ dynamicList: $dynamicList');
        dynamicList
            .map((i) => attachmentList.add(Attachment.fromJSONDraftMail(i)))
            .toList();
        attachmentStreamSink.add(attachmentList);
      }
      return subject;
    }
  }

  Future<String> appendImage() async {
    File fileImage = await FilePicker.getFile(type: FileType.IMAGE);
    String filePath = fileImage.path, fileName, fileExtension;
    fileName = filePath.substring(
        filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.'));

    fileExtension = filePath.substring(filePath.lastIndexOf('.') + 1);
    //print('~~~ fileName: $fileName fileExtension: $fileExtension');
    Map<String, dynamic> mapResponseGetDownloadUrl, mapResponseConfirm;
    mapResponseGetDownloadUrl = await _fileConnect.sendFileGet(
        '${FileConnect.uploadFileGetDownloadUrl}?type=general&fileName=$fileName&fileType=image/$fileExtension');

    int statusCode = await _fileConnect.uploadFile(
        mapResponseGetDownloadUrl['content']['signedUrl'],
        'image/$fileExtension',
        filePath);

    mapResponseConfirm = await _fileConnect.sendFileGet(
        '${FileConnect.uploadConfirmUploadToken}${mapResponseGetDownloadUrl['content']['uploadToken']}');

    String accessUrl = '';
    if (mapResponseConfirm['code'] == 200) {
      //print('~~~ accessUrl: ${mapResponseConfirm['content']['accessUrl']}');
      accessUrl =
          await '${Connect.filesUrl}${mapResponseConfirm['content']['accessUrl']}';
//        accessUrl=await '${mapResponseConfirm['content']['accessUrl']}';
    }
    return accessUrl;
  }

  void saveInDrafts(String draftId, String subject, String bodyMessage) async {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    if (draftId != null) {
      mapBody['id'] = draftId;
    }
    //print('~~~ subject: ${subject.length}');
    mapBody['subject'] = subject.length == 0 ? 'No Subject' : subject;

    List<Map<String, String>> _recipentAddressList;
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
    mapBody['html'] = bodyMessage;

    List<Map<String, dynamic>> attachmentMapList = List<Map<String, String>>();
    //print('~~~ attachmentList len: ${attachmentList.length}');
    if (attachmentList.length > 0) {
      for (Attachment attachment in attachmentList) {
        //print('~~~ json attach: ${attachment.toJson()}');
        attachmentMapList.add(attachment.toJson());
      }
      mapBody['attachments'] = attachmentMapList;
    }
    //print('~~~ mapBody: $mapBody');
    Map<String, dynamic> mapResponse =
        await _actionConnect.sendActionPost(mapBody, ActionConnect.actionDraft);
    if(mapResponse['code']==200) {
      _widgetsCollection.showToastMessage('Saved in Drafts');
    }
    //print('~~~ saveInDrafts: $mapResponse');
  }

  void getSignature() async {
    Map<String, dynamic> mapResponse = await _mailConnect
        .sendMailGetWithHeaders(MailConnect.signatureGet);
    if (mapResponse['code'] == 200) {
      if (mapResponse['content'][previousAction.toLowerCase()] != null) {
        htmlCode = '$htmlCode<br><br>${mapResponse['content'][previousAction]}';
        bodyStreamSink.add(htmlCode);
      }
    }
  }

  void dispose() {
    _attachmentListStreamController.close();
    _toUsersListStreamController.close();
    _ccUsersListStreamController.close();
    _bccUsersListStreamController.close();
    _subjectStreamController.close();
    _bodyStreamController.close();
    _composeFinishedStreamController.close();
    _draftSentFinishedStreamController.close();
    _replyForwardFinishedStreamController.close();
    _toUsersSuggestionsListStreamController.close();
    _ccUsersSuggestionsListStreamController.close();
    _bccUsersSuggestionsListStreamController.close();
  }
}
