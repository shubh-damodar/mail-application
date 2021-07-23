import 'dart:async';

import 'package:mail/network/action_connect.dart';
import 'package:mail/network/list_connect.dart';

import '../../models/email.dart';

class ArchiveBloc {
  ListConnect _listConnect = ListConnect();
  ActionConnect _actionConnect = ActionConnect();
  List<Email> emailsList=List<Email>();
  int lastTimeStamp;
  StreamController<List<Email>> _emailsStreamController=StreamController<List<Email>>.broadcast();

  StreamSink<List<Email>> get emailsStreamSink=>_emailsStreamController.sink;

  Stream<List<Email>> get emailsStream=>_emailsStreamController.stream;

  void getReceivedMessages(String typeTimeStamp, String timeStamp) async {
    emailsList = List<Email>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody[typeTimeStamp] = timeStamp;
    _listConnect
        .sendMailPost(mapBody, ListConnect.listArchive)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ mapResponse ${mapResponse}');
      if (mapResponse['code'] == 200) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'] as List<dynamic>;
        dynamicList.map((i) => emailsList.add(Email.fromJSONSentBox(i))).toList();
        emailsList.sort((a, b) => b.date.compareTo(a.date));
        emailsStreamSink.add(emailsList);
        if (emailsList.isNotEmpty) {
          lastTimeStamp = emailsList[0].date;
        }
        //print('~~~ getReceivedMessages: $lastTimeStamp');
      }
    });
  }

  void getFurtherMessages(String typeTimeStamp) async {
    List<Email> newMessagesList = List<Email>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody[typeTimeStamp] = emailsList[emailsList.length - 1].date;
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
        emailsList.addAll(newMessagesList);
        emailsStreamSink.add(emailsList);
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

          //print('~~~ isNotEmpty: ${emailsList.isNotEmpty}');
          if(emailsList.isNotEmpty && newMessagesList.isNotEmpty) {
            //print('~~~ 1st startFetchingMails emailsList: ${emailsList[0].date}');
            //print('~~~ 1st startFetchingMails newMessagesList: ${newMessagesList[0].date}');
            if (emailsList[0].date != newMessagesList[0].date) {
              lastTimeStamp = newMessagesList[0].date;
              //print('~~~ 2nd newMessagesList: $lastTimeStamp');
              emailsList = newMessagesList;
              emailsStreamSink.add(emailsList);
            }
          }
        }
      });
    });
  }

  void markUnmarkFavorite(String markedMailId, String type, String action) {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['mailId']=[markedMailId];
    mapBody['type']=type;
    mapBody['action']=action;
    //print('~~~ mapBody: $mapBody ');
    _actionConnect
        .sendActionPostWithHeaders(mapBody, ActionConnect.actionMarkFavourite)
        .then((Map<String, dynamic> mapResponse) {
//      //print('~~~ type: $type action: $action mapResponse ${mapResponse}');
      if(mapResponse['code']==200)  {
        getReceivedMessages('lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
      }
    });
  }

  void dispose() {
    _emailsStreamController.close();
  }
}
