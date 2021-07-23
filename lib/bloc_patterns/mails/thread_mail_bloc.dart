import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:mail/models/email.dart';
import 'package:mail/network/list_connect.dart';
import 'package:mail/network/mail_connect.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class ThreadMailBloc {
  MailConnect _mailConnect = MailConnect();
  MessagesActions _messagesActions;
  List<Email> emailList = List<Email>();
  BuildContext buildContext;
  String conversationId, type, subject;
  NavigationActions navigationActions;
  WidgetsCollection widgetsCollection;

  ThreadMailBloc(
      BuildContext context, String sentConversationId, String sentType) {
    buildContext = context;
    conversationId = sentConversationId;
    type = sentType;
    _messagesActions = MessagesActions(buildContext);
    navigationActions = NavigationActions(context);
    widgetsCollection = WidgetsCollection(context);
  }

  StreamController<List<Email>> _emailStreamController =
      StreamController<List<Email>>();
  StreamController<String> _subjectStreamController =
      StreamController<String>();

  StreamSink<List<Email>> get emailStreamSink => _emailStreamController.sink;

  StreamSink<String> get subjectStreamSink => _subjectStreamController.sink;

  Stream<List<Email>> get emailStream => _emailStreamController.stream;

  Stream<String> get subjectStream => _subjectStreamController.stream;

  void getThreadMessages() async {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['mailId'] = conversationId;
    mapBody['type'] = type;
    //print('~~~ displayMail: $mapBody');
    Map<String, dynamic> mapResponse =
        await _mailConnect.sendMailPost(mapBody, MailConnect.viewMail);
    //print('~~~ getThreadMessages: $mapResponse');
    if (mapResponse['code'] == 200) {
      List<dynamic> dynamicList =
          mapResponse['content']['items'] as List<dynamic>;
      dynamicList.map((i) => emailList.add(Email.fromJSON(i))).toList();
      emailStreamSink.add(emailList);
      subjectStreamSink.add(emailList[0].subject);
    } else {
      widgetsCollection.showToastMessage(mapResponse['content']['message']);
    }
  }

  void markAsRead(String sentType) async {
    _messagesActions.bulkMarkAsRead([conversationId], sentType);
  }
  void dispose() {
    _emailStreamController.close();
    _subjectStreamController.close();
  }
}
