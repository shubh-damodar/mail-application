import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mail/network/action_connect.dart';
import 'package:mail/utils/widgets_collection.dart';

class MessagesActions  {
  BuildContext context;
  ActionConnect _actionConnect=ActionConnect();
  WidgetsCollection _widgetsCollection;
  MessagesActions(BuildContext passedContext) {
    context=passedContext;
    _widgetsCollection=WidgetsCollection(context);
  }
  Future<void> archiveMessage(List<String> mailIdsList, String type) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    mapBody['type']=type;
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionArchive);
    _widgetsCollection.showToastMessage(mapResponse['content']['message']);
  }
  Future<void> moveToTrash(List<String> mailIdsList, String type) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    mapBody['type']=type;
    //print('~~~ deleteMessage: ${mapBody}');
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionMoveToTrash);
    _widgetsCollection.showToastMessage(mapResponse['content']['message']);
  }
  Future<void> spamMessage(List<String> mailIdsList, String type) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    mapBody['type']=type;
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionSpam);
    _widgetsCollection.showToastMessage(mapResponse['content']['message']);
  }
  Future<void> recoverFromArchiveMessage(List<String> mailIdsList) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionRecoverFromArchive);
    _widgetsCollection.showToastMessage(mapResponse['content']['message']);
  }
  Future<void> recoverFromTrash(List<String> mailIdsList) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionRecoverFromTrash);
    _widgetsCollection.showToastMessage(mapResponse['content']);
  }
  Future<void> markNotSpam(List<String> mailIdsList) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionMarkNotSpam);
    _widgetsCollection.showToastMessage(mapResponse['content']['message']);
  }
  Future<void> bulkMarkAsRead(List<String> mailIdsList, String type) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    mapBody['type']=type;
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionBulkMarkAsRead);
   //print('~~~ bulkMarkAsRead: $mapResponse');

  }
  Future<void> permanentlyDelete(List<String> mailIdsList, String type) async  {
    Map<String, dynamic> mapBody=Map<String, dynamic>();
    mapBody['mailId']=mailIdsList;
    mapBody['type']=type;
    Map<String, dynamic> mapResponse=await _actionConnect.sendActionPost(mapBody, ActionConnect.actionDelete);
    _widgetsCollection.showToastMessage(mapResponse['content']['message']);
  }
}