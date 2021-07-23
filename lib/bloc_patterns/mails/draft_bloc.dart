import 'dart:async';

import 'package:mail/network/action_connect.dart';
import 'package:mail/network/list_connect.dart';

import '../../models/email.dart';

class DraftBloc {
  ListConnect _listConnect = ListConnect();
  ActionConnect _actionConnect = ActionConnect();
  List<Email> mailsList=List<Email>();
  int lastTimeStamp;
  StreamController<List<Email>> _messagesStreamController=StreamController<List<Email>>.broadcast();

  StreamSink<List<Email>> get messagesStreamSink=>_messagesStreamController.sink;

  Stream<List<Email>> get messagesStream=>_messagesStreamController.stream;

  void getReceivedMails(String typeTimeStamp, String timeStamp) async  {
    mailsList = List<Email>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody[typeTimeStamp] = timeStamp;
    _listConnect
        .sendMailPost(mapBody, ListConnect.listDraft)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ mapResponse ${mapResponse}');
      if (mapResponse['code'] == 200) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'] as List<dynamic>;
        dynamicList.map((i) => mailsList.add(Email.fromJSONDraftList(i))).toList();
        mailsList.sort((a, b) => b.date.compareTo(a.date));
        messagesStreamSink.add(mailsList);
        if (mailsList.isNotEmpty) {
          lastTimeStamp = mailsList[0].date;
        }
        //print('~~~ getReceivedMessages: $lastTimeStamp');
      }
    });
  }

  void getFurtherMails(String typeTimeStamp) async {
    List<Email> newMailsList = List<Email>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody[typeTimeStamp] = mailsList[mailsList.length-1].date;
    _listConnect
        .sendMailPost(mapBody, ListConnect.listDraft)
        .then((Map<String, dynamic> mapResponse) {
      //print('~~~ mapResponse ${mapResponse}');
      if (mapResponse['code'] == 200) {
        List<dynamic> dynamicList =
        mapResponse['content']['items'] as List<dynamic>;
        dynamicList
            .map((i) => newMailsList.add(Email.fromJSONDraftList(i)))
            .toList();
        mailsList.addAll(newMailsList);
        messagesStreamSink.add(mailsList);
      }
    });
  }

  void startFetchingMails() async {
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      List<Email> newMailsList = List<Email>();
      Map<String, dynamic> mapBody = Map<String, dynamic>();
      int lastTimeStamp = DateTime.now().millisecondsSinceEpoch;
      mapBody['lastTimeStamp'] = lastTimeStamp;
      //print('~~~ startFetchingMails: $lastTimeStamp');
      _listConnect
          .sendMailPost(mapBody, ListConnect.listDraft)
          .then((Map<String, dynamic> mapResponse) {
        //print('~~~ mapResponse ${mapResponse}');
        if (mapResponse['code'] == 200) {
          List<dynamic> dynamicList =
          mapResponse['content']['items'] as List<dynamic>;
          dynamicList
              .map((i) => newMailsList.add(Email.fromJSONDraftList(i)))
              .toList();
          //print('~~~ 1st startFetchingMails lastTimeStamp: $lastTimeStamp');

          //print('~~~ isNotEmpty: ${mailsList.isNotEmpty}');
          if(mailsList.isNotEmpty && newMailsList.isNotEmpty) {
            //print('~~~ 1st startFetchingMails mailsList: ${mailsList[0].date}');
            //print('~~~ 1st startFetchingMails newMailsList: ${newMailsList[0].date}');
            if (mailsList[0].date != newMailsList[0].date) {
              lastTimeStamp = newMailsList[0].date;
              //print('~~~ 2nd newMailsList: $lastTimeStamp');
              mailsList = newMailsList;
              messagesStreamSink.add(mailsList);
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
