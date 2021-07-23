import 'dart:async';

import 'package:mail/models/message.dart';
import 'package:mail/network/action_connect.dart';
import 'package:mail/network/list_connect.dart';

import '../../models/email.dart';

class SentBoxBloc {
  ListConnect _listConnect = ListConnect();
  ActionConnect _actionConnect = ActionConnect();
  List<Email> mailsList=List<Email>();
  int lastTimeStamp;

  StreamController<List<Email>> _messagesStreamController=StreamController<List<Email>>.broadcast();
  StreamSink<List<Email>> get messagesStreamSink=>_messagesStreamController.sink;
  Stream<List<Email>> get messagesStream=>_messagesStreamController.stream;

  void getReceivedMessages(String typeTimeStamp, String timeStamp) async {
    mailsList = List<Email>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody[typeTimeStamp] = timeStamp;
    _listConnect
        .sendMailPost(mapBody, ListConnect.listSent)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ mapResponse ${mapResponse}');
      if (mapResponse['code'] == 200) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'] as List<dynamic>;
        dynamicList.map((i) => mailsList.add(Email.fromJSONSentBox(i))).toList();
        mailsList.sort((a, b) => b.date.compareTo(a.date));
        messagesStreamSink.add(mailsList);
        if (mailsList.isNotEmpty) {
          lastTimeStamp = mailsList[0].date;
        }
        //print('~~~ getReceivedMessages: $lastTimeStamp');
      }
    });
  }

  void getFurtherMessages(String typeTimeStamp) async {

    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody[typeTimeStamp] = mailsList[mailsList.length-1].date;
    List<Email> newMessagesList = List<Email>();
    _listConnect
        .sendMailPost(mapBody, ListConnect.listSent)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ mapResponse ${mapResponse}');
      if (mapResponse['code'] == 200) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'] as List<dynamic>;
        dynamicList
            .map((i) => newMessagesList.add(Email.fromJSONSentBox(i)))
            .toList();
        mailsList.addAll(newMessagesList);
        messagesStreamSink.add(mailsList);
      }
    });
  }

  void startFetchingMails() async {
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      List<Email> newMessagesList = List<Email>();
      Map<String, dynamic> mapBody = Map<String, dynamic>();
      int lastTimeStamp = DateTime.now().millisecondsSinceEpoch;
      mapBody['lastTimeStamp'] = lastTimeStamp;
      //print('~~~ startFetchingMails: $lastTimeStamp');
      _listConnect
          .sendMailPost(mapBody, ListConnect.listArchive)
          .then((Map<String, dynamic> mapResponse) {
        //print('~~~ mapResponse ${mapResponse}');
        if (mapResponse['code'] == 200) {
          List<dynamic> dynamicList =
          mapResponse['content']['items'] as List<dynamic>;
          dynamicList
              .map((i) => newMessagesList.add(Email.fromJSONSentBox(i)))
              .toList();
          //print('~~~ 1st startFetchingMails lastTimeStamp: $lastTimeStamp');

          //print('~~~ isNotEmpty: ${newMessagesList.isNotEmpty}');
          if(newMessagesList.isNotEmpty && newMessagesList.isNotEmpty) {
            //print('~~~ 1st startFetchingMails newMessagesList: ${newMessagesList[0].date}');
            //print('~~~ 1st startFetchingMails newMessagesList: ${newMessagesList[0].date}');
            if (newMessagesList[0].date != newMessagesList[0].date) {
              lastTimeStamp = newMessagesList[0].date;
              //print('~~~ 2nd newMessagesList: $lastTimeStamp');
              newMessagesList = newMessagesList;
              messagesStreamSink.add(newMessagesList);
            }
          }
        }
      });
    });
  }
  void dispose() {
    _messagesStreamController.close();
  }
}
