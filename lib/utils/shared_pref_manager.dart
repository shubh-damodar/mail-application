import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/user_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {
  static SharedPreferences _sharedPreferences = null;
  static List<User> usersList = List<User>();

  static Future<SharedPreferences> getSharedPref() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _sharedPreferences;
  }

  static Future<bool> setSavedConversation(
      String mapResponse) {

    //print('~~~ conversationEncoded: $mapResponse');
    return _sharedPreferences.setString('saved_conversation', mapResponse);
  }

  static Future<String> getConversation() async {
    return _sharedPreferences.getString('saved_conversation');
  }

  static Future<bool> setCurrentUser(User user) async {
//    //print('~~~ old: ${Connect.currentUser.userId} ${Connect.currentUser.name}');
    Connect.currentUser = user;
    //print('~~~ new: ${Connect.currentUser.userId} ${Connect.currentUser.name}');
    _sharedPreferences.setString('current_user', json.encode(user.toJSON()));
    String allUsersString = _sharedPreferences.getString('all_users');
    if (allUsersString != null) {
      LinkedHashMap usersDecoded = json.decode(allUsersString);
      usersList = List<User>();
      for (String key in usersDecoded.keys) {
        usersList.add(User.fromJSON(usersDecoded[key]));
      }
      usersList.add(user);
      Map<String, Map<String, String>> allUsersMap =
      Map<String, Map<String, String>>();
      int i = 0;
      for (User singleUser in usersList) {
        allUsersMap[i.toString()] = singleUser.toJSON();
        i++;
      }
      return _sharedPreferences.setString(
          'all_users', json.encode(allUsersMap));
    } else {
      Map<String, Map<String, String>> currentUserMap = {'0': user.toJSON()};
      return _sharedPreferences.setString(
          'all_users', json.encode(currentUserMap));
    }
  }
  static Future<bool> setCurrentUserNameProfileBannerImage(
      String updateUserId, String informationType, String information) async {
//    //print('~~~ old: ${Connect.currentUser.userId} ${Connect.currentUser.name}');

    String allUsersString = _sharedPreferences.getString('all_users');
    if (allUsersString != null) {
      LinkedHashMap usersDecoded = json.decode(allUsersString);
      usersList = List<User>();
      for (String key in usersDecoded.keys) {
        usersList.add(User.fromJSON(usersDecoded[key]));
      }
      usersList.where((User iteratingUser) {
        if(iteratingUser.userId ==updateUserId) {
          //print('~~~ where: ${iteratingUser.userId} $informationType $information');
          if(informationType=='profileImage') {
            iteratingUser.logo=information;
          } else if(informationType=='bannerImage') {
            iteratingUser.bannerImage=information;
          } else if(informationType=='username') {
            iteratingUser.username=information;
          }
        }
        return true;
      }).toList();

      Map<String, Map<String, String>> allUsersMap =
      Map<String, Map<String, String>>();
      int i = 0;
      for (User singleUser in usersList) {
        allUsersMap[i.toString()] = singleUser.toJSON();
        i++;
      }
      return _sharedPreferences.setString(
          'all_users', json.encode(allUsersMap));
    }
  }
  static Future<User> getCurrentUser() async {
    if (_sharedPreferences.getString('current_user') == null) {
      return null;
    }
    User user = User.fromJSON(
        json.decode(_sharedPreferences.getString('current_user')));
    Connect.currentUser = user;
    return user;
  }

  static Future<bool> switchCurrentUser(User user) async {
    //print('~~~ old: ${Connect.currentUser.userId} ${Connect.currentUser.name}');
    Connect.currentUser = user;
    //print('~~~ new: ${Connect.currentUser.userId} ${Connect.currentUser.name}');

    setSavedConversation(null);
    return _sharedPreferences.setString(
        'current_user', json.encode(user.toJSON()));
  }

  static Future<List<User>> getAllUsers() async {
    String allUsersString = _sharedPreferences.getString('all_users');
    if (allUsersString != null) {
      LinkedHashMap usersDecoded = json.decode(allUsersString);
      usersList = List<User>();
      for (String key in usersDecoded.keys) {
        usersList.add(User.fromJSON(usersDecoded[key]));
      }
    }
    return usersList;
  }

  static Future<bool> removeAll() async {
    usersList = List<User>();
    _sharedPreferences.setString('all_users', '');
    return _sharedPreferences.clear();
  }
}
