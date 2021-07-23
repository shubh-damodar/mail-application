import 'package:mail/models/email.dart';

class MailSubjectShortTextListDetails {
  List<Email> mailsList;

  MailSubjectShortTextListDetails({this.mailsList});

//  void initializeContacts(List<Email> sentConversationsList) {
//    mailsList=sentConversationsList;
//    //print('~~~ initializeContacts: ${mailsList.length}');
//  }
  Future<List<Email>> getSuggestions(String mailSubjectShortTextLetter) async {
    List<Email> matchedMailsList = List<Email>();

    for (Email email in mailsList) {
      //print(
      //    '~~~ 1st getSuggestions: $mailSubjectShortTextLetter ${email.fromUser.address} ${email.fromUser.name}');

      if ((email.subject.toLowerCase()
          .contains(mailSubjectShortTextLetter.toLowerCase())) || (email.shortText.toLowerCase()
          .contains(mailSubjectShortTextLetter.toLowerCase())) ||
          (email.fromUser.address
              .toLowerCase()
              .contains(mailSubjectShortTextLetter.toLowerCase())) ||
          (email.fromUser.name
              .toLowerCase()
              .contains(mailSubjectShortTextLetter.toLowerCase()))) {
        //print('~~~ matched ${email.fromUser.name} ');
        matchedMailsList.add(email);
      }
    }
    return matchedMailsList;
  }
}
