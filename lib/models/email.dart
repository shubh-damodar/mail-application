import 'package:mail/models/user.dart';

import 'attachment.dart';

class Email {
  List<User> toUserList = List<User>(),
      ccUserList = List<User>(),
      bccUserList = List<User>();
  List<Attachment> attachmentList = List<Attachment>();
  User fromUser;
  String conversationId,
      type,
      subject,
      html,
      text,
      inReplyTo,
      id,
      shortText,
      status;
  bool isFavourite, hasAttachment;
  int date;

  Email({
    this.toUserList,
    this.ccUserList,
    this.bccUserList,
    this.attachmentList,
    this.fromUser,
    this.conversationId,
    this.type,
    this.subject,
    this.html,
    this.inReplyTo,
    this.id,
    this.shortText,
    this.date,
    this.status,
  });

  Email.fromJSON(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    fromUser = User.fromJSONViewMail(map['from'][0]);
    date = map['date'].runtimeType == String
        ? DateTime.parse(map['date']).millisecondsSinceEpoch
        : date = map['date'];
    html = map['html'];
//    inReplyTo = map['inReplyTo']==null?'':map['inReplyTo'][0];
    type = map['type'];
    subject = map['subject'];
    if (map['to'] != null) {
      List<dynamic> dynamicList = map['to'] as List<dynamic>;
      //print('~~~ dynamicList: ${dynamicList[0]}');
      dynamicList
          .map((i) => toUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['cc'] != null) {
      List<dynamic> dynamicList = map['cc'] as List<dynamic>;
      dynamicList
          .map((i) => ccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['bcc'] != null) {
      List<dynamic> dynamicList = map['bcc'] as List<dynamic>;
      dynamicList
          .map((i) => bccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    hasAttachment = map['hasAttachment'];
    //print('~~~ hasAttachment: $hasAttachment');
    if (hasAttachment) {
      List<dynamic> dynamicList = map['attachments'] as List<dynamic>;
      //print('~~~ dynamicList: $dynamicList');
      dynamicList
          .map((i) => attachmentList.add(Attachment.fromJSONViewSingleMail(i)))
          .toList();
    }
  }

  Email.fromJSONInbox(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    fromUser = User.fromJSONViewMail(map['from'][0]);
    status = map['status'];

    date = map['date'].runtimeType == String
        ? DateTime.parse(map['date']).millisecondsSinceEpoch
        : date = map['date'];

    //print('~~~ 2nd: ${map['date']}');
    shortText = map['shortText']==null?'':map['shortText'];
    html = map['html'];
//    inReplyTo = map['inReplyTo']==null?'':map['inReplyTo'][0];
    type = map['type'];
    subject = map['subject'] == null ? '' : map['subject'];
    //print('~~~ subject: $subject');
    if (map['to'] != null) {
      List<dynamic> dynamicList = map['to'] as List<dynamic>;
      //print('~~~ dynamicList: ${dynamicList[0]}');
      dynamicList
          .map((i) => toUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['cc'] != null) {
      List<dynamic> dynamicList = map['cc'] as List<dynamic>;
      dynamicList
          .map((i) => ccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['bcc'] != null) {
      List<dynamic> dynamicList = map['bcc'] as List<dynamic>;
      dynamicList
          .map((i) => bccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    hasAttachment = map['hasAttachment'];
    isFavourite = map['isFavourite'];
    //print('~~~ hasAttachment: $hasAttachment');
  }

  Email.fromJSONStarred(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    fromUser = User.fromJSONViewMail(map['from'][0]);
    status = map['status'];
    status = map['status'];
    date = map['date'].runtimeType == String
        ? DateTime.parse(map['date']).millisecondsSinceEpoch
        : date = map['date'];
    shortText = map['shortText']==null?'':map['shortText'];
    html = map['html'];
//    inReplyTo = map['inReplyTo']==null?'':map['inReplyTo'][0];
    type = map['type'];
    subject = map['subject'] == null ? '' : map['subject'];
    //print('~~~ subject: $subject');
    if (map['to'] != null) {
      List<dynamic> dynamicList = map['to'] as List<dynamic>;
      //print('~~~ dynamicList: ${dynamicList[0]}');
      dynamicList
          .map((i) => toUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['cc'] != null) {
      List<dynamic> dynamicList = map['cc'] as List<dynamic>;
      dynamicList
          .map((i) => ccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['bcc'] != null) {
      List<dynamic> dynamicList = map['bcc'] as List<dynamic>;
      dynamicList
          .map((i) => bccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    hasAttachment = map['hasAttachment'];
    isFavourite = map['isFavourite'];
    //print('~~~ hasAttachment: $hasAttachment');
  }

  Email.fromJSONSentBox(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    id = map['id'];
    fromUser = User.fromJSONViewMail(map['from'][0]);
    status = map['status'];
    shortText = map['shortText']==null?'':map['shortText'];
    date = map['date'].runtimeType == String
        ? DateTime.parse(map['date']).millisecondsSinceEpoch
        : date = map['date'];
    html = map['html'];
//    inReplyTo = map['inReplyTo']==null?'':map['inReplyTo'][0];
    type = map['type'];
    subject = map['subject'];
    if (map['to'] != null) {
      List<dynamic> dynamicList = map['to'] as List<dynamic>;
      //print('~~~ dynamicList: ${dynamicList[0]}');
      dynamicList
          .map((i) => toUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['cc'] != null) {
      List<dynamic> dynamicList = map['cc'] as List<dynamic>;
      dynamicList
          .map((i) => ccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['bcc'] != null) {
      List<dynamic> dynamicList = map['bcc'] as List<dynamic>;
      dynamicList
          .map((i) => bccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
  }

  Email.fromJSONArchive(Map<String, dynamic> map) {
    id = map['id'];
    fromUser = User.fromJSONViewMail(map['from'][0]);
    status = map['status'];
    shortText = map['shortText']==null?'':map['shortText'];
    date = map['date'].runtimeType == String
        ? DateTime.parse(map['date']).millisecondsSinceEpoch
        : date = map['date'];
    html = map['html'];
//    inReplyTo = map['inReplyTo']==null?'':map['inReplyTo'][0];
    type = map['type'];
    subject = map['subject'];
    if (map['to'] != null) {
      List<dynamic> dynamicList = map['to'] as List<dynamic>;
      //print('~~~ dynamicList: ${dynamicList[0]}');
      dynamicList
          .map((i) => toUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['cc'] != null) {
      List<dynamic> dynamicList = map['cc'] as List<dynamic>;
      dynamicList
          .map((i) => ccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['bcc'] != null) {
      List<dynamic> dynamicList = map['bcc'] as List<dynamic>;
      dynamicList
          .map((i) => bccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
  }

  Email.fromJSONTrash(Map<String, dynamic> map) {
    conversationId = map['conversationId'];
    fromUser = User.fromJSONViewMail(map['from'][0]);
    status = map['status'];
    date = map['date'].runtimeType == String
        ? DateTime.parse(map['date']).millisecondsSinceEpoch
        : date = map['date'];
    shortText = map['shortText']==null?'':map['shortText'];
    html = map['html'];
//    inReplyTo = map['inReplyTo']==null?'':map['inReplyTo'][0];
    type = map['type'];
    subject = map['subject'] == null ? '' : map['subject'];
    //print('~~~ subject: $subject');
    if (map['to'] != null) {
      List<dynamic> dynamicList = map['to'] as List<dynamic>;
      //print('~~~ dynamicList: ${dynamicList[0]}');
      dynamicList
          .map((i) => toUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['cc'] != null) {
      List<dynamic> dynamicList = map['cc'] as List<dynamic>;
      dynamicList
          .map((i) => ccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    if (map['bcc'] != null) {
      List<dynamic> dynamicList = map['bcc'] as List<dynamic>;
      dynamicList
          .map((i) => bccUserList.add(User.fromJSONViewMailAddress(i)))
          .toList();
    }
    hasAttachment = map['hasAttachment'];
    isFavourite = map['isFavourite'];
    //print('~~~ hasAttachment: $hasAttachment');
  }

  Email.fromJSONDraftList(Map<String, dynamic> map) {
    conversationId = map['id'];
    date = map['date'].runtimeType == String
        ? DateTime.parse(map['date']).millisecondsSinceEpoch
        : date = map['date'];
    subject = map['subject'] == null ? '' : map['subject'];
    shortText = map['shortText']==null?'':map['shortText'];
//    if(map['to']!=null) {
//      List<dynamic> dynamicList = map['to'] as List<dynamic>;
//      //print('~~~ dynamicList: ${dynamicList[0]}');
//      dynamicList
//          .map((i) => toUserList.add(User.fromJSONViewMailAddress(i)))
//          .toList();
//    }
//    if(map['cc']!=null) {
//      List<dynamic> dynamicList = map['cc'] as List<dynamic>;
//      dynamicList
//          .map((i) => ccUserList.add(User.fromJSONViewMailAddress(i)))
//          .toList();
//    }
//    if(map['bcc']!=null) {
//      List<dynamic> dynamicList = map['bcc'] as List<dynamic>;
//      dynamicList
//          .map((i) => bccUserList.add(User.fromJSONViewMailAddress(i)))
//          .toList();
//    }
  }
}
