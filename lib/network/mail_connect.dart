import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mail/network/user_connect.dart';

class MailConnect  {
//  String _mailBaseUrl = 'http://services.simplifying.world/apis/v1.0.1/';
  String _mailBaseUrl = 'https://mail.mesbro.com/apis/v1.0.1/';

  static String viewMail='view/mail',
      signatureGet='signature/get',
      signatureSave='signature/save',
      a = '';

  Future<Map<String, dynamic>> sendMailPost(
      Map<String, dynamic> mapBody, String url) async {
    //print(
   //     '~~~ sendMailPost: $_mailBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token} $mapBody');
    http.Response response = await http
        .post('$_mailBaseUrl$url', body: json.encode(mapBody), headers: {
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
    //print('~~~ sendMailPostWithHeaders: $_mailBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse('$_mailBaseUrl$url'));
    request.headers.add('au', Connect.currentUser.au);
    request.headers.add('ut-${Connect.currentUser.au}', '${Connect.currentUser.token}');
    request.add(utf8.encode(json.encode(mapBody)));
    HttpClientResponse httpClientResponse = await request.close();
    String response = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = jsonDecode(response);
    //print('~~~ sendMailPostWithHeaders: $response');
    return map;
  }

  Future<Map<String, dynamic>> sendMailGet(String url) async {
    //print('~~~ sendMailGet: $_mailBaseUrl$url');
    http.Response response = await http.get('$_mailBaseUrl$url');
    //print('~~~ sendMailGet: ${response.body}');
    Map<String, dynamic> map = json.decode(response.body);
    return map;
  }
  Future<Map<String, dynamic>> sendMailGetWithHeaders(
      String url) async {
    //print('~~~ sendMailPostWithHeaders: $_mailBaseUrl$url ${Connect.currentUser.au} ${Connect.currentUser.token}');
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse('$_mailBaseUrl$url'));
    request.headers.add('au', Connect.currentUser.au);
    request.headers.add('ut-${Connect.currentUser.au}', '${Connect.currentUser.token}');
    HttpClientResponse httpClientResponse = await request.close();
    String response = await httpClientResponse.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> map = jsonDecode(response);
    //print('~~~ sendMailPostWithHeaders: $response');
    return map;
  }
}