import 'dart:async';

import 'package:mail/models/user.dart';

class Message {
  bool isFavourite, hasAttachment;
  int attachmentsCount, date;
  String conversationId, subject, shortText, status;
  User sentUser;
  Message.fromJSON(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    date = map['date'];
    sentUser=User.fromJSONInbox(map['from'][0]);
    status = map['status'];
    subject = map['subject']==null?'':map['subject'];
    shortText = map['shortText'];
    isFavourite = map['isFavourite'];
    hasAttachment = map['hasAttachment'];
  }
  Message.fromJSONDraft(Map<String, dynamic> map) {
    conversationId = map['id'];
    date = map['date'];
    status = map['status'];
    subject = map['subject']==null?'':map['subject'];
    shortText = map['shortText'];
    isFavourite = map['isFavourite'];
  }
  Map<String, dynamic> toJSON() {
    return {
      "conversationId": this.conversationId,
      "date": this.date,
      "status": this.status,
      "subject": this.subject,
      "shortText": this.shortText,
      "isFavourite": this.isFavourite,
    };
  }

  Message.fromJSONSentBox(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    date = map['date'];
    sentUser=User.fromJSONSentBox(map['from'][0]);
    status = map['status'];
    subject = map['subject'];
    shortText = map['shortText'];
    isFavourite = map['isFavourite'];
  }
}
