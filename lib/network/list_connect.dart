import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mail/network/user_connect.dart';

import '../main.dart';

class ListConnect {
//  String _listBaseUrl = 'http://mail.simplifying.world/apis/v1.0.1/list/';

  String _listBaseUrl = 'https://mail.mesbro.com/apis/v1.0.1/';

  static String listInbox = 'list/inbox',
      listSent = 'list/sent',
      listDraft = 'list/draft',
      listArchive = 'list/archive',
      listTrash = 'list/trash',
      listSpam = 'list/spam',
      listContacts = 'list/contacts',
      listFavourite = 'list/favourite',
      listMailSearch = 'mail/search',
      a = '';

  Future<Map<String, dynamic>> sendMailPost(
      Map<String, dynamic> mapBody, String url) async {
//    //print('~~~ sendMailPost: $_baseUrl$url ${currentUser.au}');
    //print('~~~ sendMailPost: mapBody: $mapBody');
    //print(
  //      '~~~ sendMailPost: $_listBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');

    http.Response response =
        await http.post('$_listBaseUrl$url', body: json.encode(mapBody), headers: {
      'au': Connect.currentUser == null ? '' : Connect.currentUser.au,
      'ut-${Connect.currentUser.au}': '${Connect.currentUser.token}',
      "Content-Type": "application/json"
    });
    //print('~~~ sendMailPost: ${response.body}');
//    MyApp.alice.onHttpResponse(response);
//    MyApp.alice.showInspector();
    Map<String, dynamic> map = jsonDecode(response.body);
    return map;
  }

  Future<Map<String, dynamic>> sendMailPostWithHeaders(
      dynamic mapBody, String url) async {
    //print('~~~ sendMailPostWithHeaders: mapBody: $mapBody');
    //print(
   //    '~~~ sendMailPostWithHeaders: $_listBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse('$_listBaseUrl$url'));
    request.headers.add('au', Connect.currentUser.au);
    request.headers
        .add('ut-${Connect.currentUser.au}', '${Connect.currentUser.token}');
    request.add(utf8.encode(json.encode(mapBody)));
    HttpClientResponse httpClientResponse = await request.close();
    String response = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = jsonDecode(response);
    //print('~~~ sendMailPostWithHeaders: $response');
    return map;
  }

  Future<Map<String, dynamic>> sendMailGet(String url) async {
    //print('~~~ sendMailGet: $_listBaseUrl$url');
    http.Response response = await http.get('$_listBaseUrl$url');
    //print('~~~ sendMailGet: ${response.body}');
    Map<String, dynamic> map = json.decode(response.body);
    return map;
  }

  Future<Map<String, dynamic>> sendMailGetWithHeaders(String url) async {
    //print(
     //   '~~~ sendMailGetWithHeaders: $_listBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.getUrl(Uri.parse('$_listBaseUrl$url'));
    request.headers.add('au', Connect.currentUser.au);
    request.headers
        .add('ut-${Connect.currentUser.au}', '${Connect.currentUser.token}');
    HttpClientResponse httpClientResponse = await request.close();
    String response = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = jsonDecode(response);
    //print('~~~ sendMailPostWithHeaders: $response');
    return map;
  }
}
