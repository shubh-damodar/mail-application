import 'dart:async';

import 'package:mail/models/email.dart';
import 'package:mail/network/list_connect.dart';
import 'package:mail/utils/mail_subject_short_text_list_details.dart';
import 'package:rxdart/rxdart.dart';

class SearchBloc {
  MailSubjectShortTextListDetails _mailSubjectShortTextListDetails;
  List<Email> mailsList = List<Email>();
  ListConnect _listConnect = ListConnect();
  List<Email> searchList = List<Email>();
  int lastTimeStamp;
  SearchBloc({this.mailsList}) {
    emailsFoundStreamSink.add(mailsList);
    _mailSubjectShortTextListDetails =
        MailSubjectShortTextListDetails(mailsList: mailsList);
  }
  final BehaviorSubject<String> _mailSubjectShortTextBehaviorSubject =
      BehaviorSubject<String>();
  final StreamController<List<Email>> _emailsFoundStreamController =
      StreamController<List<Email>>();

  StreamSink<String> get mailSubjectShortTextStreamSink =>
      _mailSubjectShortTextBehaviorSubject.sink;
  StreamSink<List<Email>> get emailsFoundStreamSink =>
      _emailsFoundStreamController.sink;

  Stream<String> get mailSubjectShortTextStream =>
      _mailSubjectShortTextBehaviorSubject.stream;
  Stream<List<Email>> get emailsFoundStream =>
      _emailsFoundStreamController.stream;

  // void searchMailSubjectShortText(String mailSubjectShortTextLetter) async {
  //   mailsList = List<Email>();
  //   mailsList = await _mailSubjectShortTextListDetails
  //       .getSuggestions(mailSubjectShortTextLetter);
  //   emailsFoundStreamSink.add(mailsList);
  // }

  void searchBox(String query, dynamic _jsonMap) async {
    searchList = List<Email>();
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    // mapBody[typeTimeStamp] = timeStamp;

    mapBody['query'] = query;
    mapBody['filters'] = _jsonMap;
    // print("-----------------------------------$mapBody");
    _listConnect
        .sendMailPost(mapBody, ListConnect.listMailSearch)
        .then((Map<String, dynamic> mapResponse) {
      // print('~~~ mapResponse ${mapResponse}');
      if (mapResponse['code'] == 200) {
        List<dynamic> dynamicList =
            mapResponse['content']['items'] as List<dynamic>;
        dynamicList.map((i) => searchList.add(Email.fromJSONInbox(i))).toList();
        searchList.sort((a, b) => b.date.compareTo(a.date));
        emailsFoundStreamSink.add(searchList);
        if (searchList.isNotEmpty) {
          lastTimeStamp = searchList[0].date;
        }
        // print('~~~ getReceivedMessages: $lastTimeStamp');
      }
    });
  }

  void dispose() {
    _mailSubjectShortTextBehaviorSubject.close();
    _emailsFoundStreamController.close();
  }
}
