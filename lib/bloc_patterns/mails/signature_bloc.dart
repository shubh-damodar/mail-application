import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mail/network/mail_connect.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class SignatureBloc {
  MailConnect _mailConnect = MailConnect();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  BuildContext buildContext;

  SignatureBloc(BuildContext context) {
    buildContext = context;
    _widgetsCollection = WidgetsCollection(context);
    getSignature();
  }

  final StreamController<String> _composeStreamController =
          StreamController<String>(),
      _forwardStreamController = StreamController<String>.broadcast(),
      _replyStreamController = StreamController<String>.broadcast();

  StreamSink<String> get composeStreamSink => _composeStreamController.sink;
  StreamSink<String> get forwardStreamSink => _forwardStreamController.sink;
  StreamSink<String> get replyStreamSink => _replyStreamController.sink;

  Stream<String> get composeStream => _composeStreamController.stream;
  Stream<String> get forwardStream => _forwardStreamController.stream;
  Stream<String> get replyStream => _replyStreamController.stream;

  void saveSignature(String compose, String reply, String forward) async {
    Map<String, dynamic> mapBody = Map<String, dynamic>();
    mapBody['compose'] = compose;
    mapBody['forward'] = forward;
    mapBody['reply'] = reply;
    Map<String, dynamic> mapResponse = await _mailConnect.sendMailPost(
        mapBody, MailConnect.signatureSave);
    if (mapResponse['code'] == 200) {
      _widgetsCollection.showToastMessage(mapResponse['message']);
    } else {
      _widgetsCollection.showToastMessage(mapResponse['content']['message']);
    }
  }

  void getSignature() async {
    Map<String, dynamic> mapResponse = await _mailConnect
        .sendMailGetWithHeaders(MailConnect.signatureGet);
    if (mapResponse['code'] == 200) {
      if (mapResponse['content']['compose'] != null) {
        composeStreamSink.add(mapResponse['content']['compose']);
      }
      if (mapResponse['content']['reply'] != null) {
        replyStreamSink.add(mapResponse['content']['reply']);
      }
      if (mapResponse['content']['forward'] != null) {
        forwardStreamSink.add(mapResponse['content']['forward']);
      }
    }
  }

  void dispose() {
    _composeStreamController.close();
    _forwardStreamController.close();
    _replyStreamController.close();
  }
}
