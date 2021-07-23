import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mail/bloc_patterns/mails/draft_bloc.dart';
import 'package:mail/bloc_patterns/mails/sent_box_bloc.dart';
import 'package:mail/bloc_patterns/mails/trash_bloc.dart';
import 'package:mail/models/message.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/screens/idm/login_page.dart';
import 'package:mail/screens/mails/search_page.dart';
import 'package:mail/utils/date_category.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/network_connectivity.dart';
import 'package:mail/utils/shared_pref_manager.dart';
import 'package:mail/utils/widgets_collection.dart';
import '../../models/email.dart';
import 'compose_page.dart';
import 'thread_mail_page.dart';

class TrashPage extends StatefulWidget {
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  final TrashBloc _trashBloc = TrashBloc();
  DateCategory _dateCategory = DateCategory();
  double _screenWidth, _screenHeight;
  DateTime currentBackPressDateTime;
  String _selectedMessageconversationId;
  String _lastTimeStamp;
  bool _isMessageRead, _areMessagesSelected = false;
  Color _messageListTileColor = Colors.white;
  List<User> _usersList = List<User>();
  List<String> _selectedConversationIdsList = List<String>(),
      _trashActionsList = ['Recover from trash', 'Permanently delete'];
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  MessagesActions _messagesActions;
  final ScrollController _scrollController = ScrollController();
  Map _jsonMap = {
    "type": ["TRASH"]
  };

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      NetworkConnectivity.of(context).checkNetworkConnection();
      //print('~~~ scedulebind');
    });
    _getAllUsers();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);

    _trashBloc.getReceivedMessages(
        'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
//    _trashBloc.startFetchingMails();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _trashBloc.emailsList.length % 20 == 0) {
        _trashBloc.getFurtherMessages('lastTimeStamp');
      }
    });
    _messagesActions = MessagesActions(context);
  }

  void dispose() {
    super.dispose();
    _trashBloc.dispose();
    _scrollController.dispose();
  }

  void _navigateAndRefresh(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      //print('~~~ _navigateAndRefresh');
      _trashBloc.getReceivedMessages(
          'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  Future<void> _getAllUsers() async {
    await SharedPrefManager.getAllUsers().then((List<User> user) {
      setState(() {
        _usersList = user;
      });
    });
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressDateTime == null ||
        now.difference(currentBackPressDateTime) > Duration(seconds: 2)) {
      currentBackPressDateTime = now;
      _widgetsCollection.showToastMessage('Press once again to exit');
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: _areMessagesSelected
            ? AppBar(
                backgroundColor: Colors.grey,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _areMessagesSelected = false;
                      _selectedConversationIdsList = List<String>();
                    });
                  },
                ),
                title: Text('${_selectedConversationIdsList.length} selected'),
                actions: <Widget>[
                  PopupMenuButton<String>(onSelected: (String selectedAction) {
                    setState(() {
                      switch (selectedAction) {
                        case 'Recover from trash':
                          _messagesActions
                              .recoverFromTrash(_selectedConversationIdsList)
                              .then((voidNothing) {
                            _trashBloc.getReceivedMessages(
                                'lastTimeStamp',
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString());
                          });
                          _areMessagesSelected = false;
                          _selectedConversationIdsList = List<String>();
                          break;
                        case 'Permanently delete':
                          _messagesActions
                              .permanentlyDelete(
                                  _selectedConversationIdsList, 'trash')
                              .then((voidNothing) {
                            _trashBloc.getReceivedMessages(
                                'lastTimeStamp',
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString());
                          });
                          _areMessagesSelected = false;
                          _selectedConversationIdsList = List<String>();
                          break;

                        case 'Select All':
                          for (int i = 0;
                              i < _trashBloc.emailsList.length;
                              i++) {
                            _selectedConversationIdsList
                                .add(_trashBloc.emailsList[i].conversationId);
                          }
                          _areMessagesSelected = true;
                          break;
                      }
                    });
                  }, itemBuilder: (BuildContext context) {
                    return _trashActionsList.map((String inboxAction) {
                      return PopupMenuItem<String>(
                        value: inboxAction,
                        child: Text(inboxAction),
                      );
                    }).toList();
                  })
                ],
              )
            : AppBar(
                centerTitle: true,
                title: Text(
                  'Trash',
                  style: TextStyle(),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _navigationActions.navigateToScreenWidget(SearchPage(
                          emailsList: _trashBloc.emailsList,
                          mailType: 'trash',
                          jsonMap: _jsonMap,
                        ));
                      });
                    },
                  ),
                ],
              ),
        body: Container(
          margin: EdgeInsets.only(top: 1.0),
          child: StreamBuilder(
              stream: _trashBloc.emailsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Email>> asyncSnapshot) {
                return asyncSnapshot.data == null
                    ? Container(
                        child: Center(
                            child: Text(
                          'Loading....',
                          textAlign: TextAlign.center,
                        )),
                      )
                    : asyncSnapshot.data.length == 0
                        ? Container(
                            child: Center(
                                child: Text(
                            'No messages yet...',
                          )))
                        : ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(),
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: asyncSnapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              _isMessageRead =
                                  asyncSnapshot.data[index].status == 'READ';

                              return Container(
                                color: _getListTileIndex(asyncSnapshot
                                            .data[index].conversationId) ==
                                        -1
                                    ? Colors.white
                                    : Colors.grey.withOpacity(0.2),
                                child: ListTile(
                                  selected: true,
                                  leading: _getListTileIndex(asyncSnapshot
                                              .data[index].conversationId) ==
                                          -1
                                      ? asyncSnapshot.data[index].fromUser.logo
                                                  .length >
                                              2
                                          ? Container(
                                              width: 40.0,
                                              height: 40.0,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl:
                                                        '${Connect.filesUrl}${asyncSnapshot.data[index].fromUser.logo}',
                                                    placeholder:
                                                        (BuildContext context,
                                                            String url) {
                                                      return Image.asset(
                                                          'assets/images/male-avatar.png');
                                                    },
                                                  )))
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                  child: Center(
                                                      child: Text(
                                                    asyncSnapshot.data[index]
                                                        .fromUser.logo,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0),
                                                  ))))
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              color: Colors.mesbroProfileBlue,
                                              child: Center(
                                                  child: Icon(
                                                Icons.check,
                                                color: Colors.mesbroBlue,
                                              )))),
                                  title: Text(
                                    asyncSnapshot.data[index].fromUser.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: _isMessageRead
                                            ? FontWeight.normal
                                            : FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        asyncSnapshot.data[index].subject,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: _isMessageRead
                                                ? FontWeight.normal
                                                : FontWeight.bold),
                                      ),
                                      Text(asyncSnapshot.data[index].shortText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          )),
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(
                                        '${_dateCategory.MMMMddDateFormat.format(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].date))}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (_areMessagesSelected) {
                                        if (_getListTileIndex(asyncSnapshot
                                                .data[index].conversationId) >
                                            -1) {
                                          _selectedConversationIdsList
                                              .removeWhere(
                                                  (String conversationId) =>
                                                      conversationId ==
                                                      asyncSnapshot.data[index]
                                                          .conversationId);
                                        } else {
                                          _selectedConversationIdsList.add(
                                              asyncSnapshot
                                                  .data[index].conversationId);
                                        }
                                        if (_selectedConversationIdsList
                                                .length ==
                                            0) {
                                          _areMessagesSelected = false;
                                        }
                                      } else if (_selectedConversationIdsList
                                              .length ==
                                          0) {
                                        _areMessagesSelected = false;
                                        _navigateAndRefresh(ThreadMailPage(
                                            subject: asyncSnapshot
                                                .data[index].subject,
                                            conversationId: asyncSnapshot
                                                .data[index].conversationId,
                                            type: 'trash'));
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      if (_selectedConversationIdsList.length ==
                                          0) {
                                        _selectedConversationIdsList.add(
                                            asyncSnapshot
                                                .data[index].conversationId);
                                        _areMessagesSelected = true;
                                      }
                                    });
                                  },
                                ),
                              );
                            });
              }),
        ));
  }

  int _getListTileIndex(String prospectedconversationId) {
    return _selectedConversationIdsList.indexOf(prospectedconversationId);
  }
}
