import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mail/bloc_patterns/mails/draft_bloc.dart';
import 'package:mail/bloc_patterns/mails/sent_box_bloc.dart';
import 'package:mail/models/message.dart';
import 'package:mail/models/user.dart';
import 'package:mail/utils/date_category.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/network_connectivity.dart';
import 'package:mail/utils/shared_pref_manager.dart';
import 'package:mail/utils/widgets_collection.dart';
import '../../models/email.dart';
import 'compose_page.dart';

class DraftPage extends StatefulWidget {
  _DraftPageState createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  final DraftBloc _draftBloc = DraftBloc();
  DateCategory _dateCategory = DateCategory();
  double _screenWidth, _screenHeight;
  DateTime currentBackPressDateTime;
  String _selectedMessageconversationId;
  String _lastTimeStamp;
  bool _areMessagesSelected = false;
  Color _messageListTileColor = Colors.white;
  List<String> _selectedConversationIdsList = List<String>(),  _draftActionsList = [
    'Move to Trash',
    'Select All'
  ];
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  MessagesActions _messagesActions;
  final ScrollController _scrollController = ScrollController();

  void _navigateAndRefresh(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      //print('~~~ _navigateAndRefresh');
      _draftBloc.getReceivedMails(
          'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      NetworkConnectivity.of(context).checkNetworkConnection();
      //print('~~~ scedulebind');
    });
    _getAllUsers();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _messagesActions = MessagesActions(context);
    _draftBloc.getReceivedMails(
        'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
//    _draftBloc.startFetchingMails();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _draftBloc.mailsList.length % 20 == 0) {
        _draftBloc.getFurtherMails('lastTimeStamp');
      }
    });
  }

  void dispose() {
    super.dispose();
    _draftBloc.dispose();
    _scrollController.dispose();
  }

  Future<void> _getAllUsers() async {
    await SharedPrefManager.getAllUsers().then((List<User> user) {
      setState(() {
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
                title: Text('${_selectedConversationIdsList.length} selected',
                    style: TextStyle()),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _messagesActions
                          .permanentlyDelete(_selectedConversationIdsList, 'draft')
                          .then((voidNothing) {
                        _draftBloc.getReceivedMails('lastTimeStamp',
                            DateTime.now().millisecondsSinceEpoch.toString());
                    });
                      }
                  )
//                  PopupMenuButton<String>(
//                      onSelected: (String selectedAction) {
//                        setState(() {
//                          switch (selectedAction) {
//                            case 'Move to Trash':
//                              _messagesActions
//                                  .moveToTrash(_selectedConversationIdsList, 'draft')
//                                  .then((voidNothing) {
//                                _draftBloc.getReceivedMessages('lastTimeStamp',
//                                    DateTime.now().millisecondsSinceEpoch.toString());
//                              });
//                              _areMessagesSelected = false;
//                              _selectedConversationIdsList = List<String>();
//                              break;
//                            case 'Select All':
//                              for (int i = 0;
//                              i < _draftBloc.messagesList.length;
//                              i++) {
//                                _selectedConversationIdsList.add(
//                                    _draftBloc.messagesList[i].conversationId);
//                              }
//                              _areMessagesSelected = true;
//                              break;
//                          }
//                        });
//                      }, itemBuilder: (BuildContext context) {
//                    return _draftActionsList.map((String draftAction) {
//                      return PopupMenuItem<String>(
//                        value: draftAction,
//                        child: Text(draftAction),
//                      );
//                    }).toList();
//                  })
                      ],
              )
            : AppBar(
                centerTitle: true,
                title: Text(
                  'Drafts',
                  style: TextStyle(),
                ),

              ),
        body: Container(
          // padding: EdgeInsets.all(10.0),
          margin: EdgeInsets.only(top: 1.0),
          child: StreamBuilder(
              stream: _draftBloc.messagesStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Email>> asyncSnapshot) {
                return asyncSnapshot.data == null
                    ? Center(
                        child: Text(
                          'Loading....',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : asyncSnapshot.data.length == 0
                        ? Container(child: Text('No messages yet...'))
                        : ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(
                                      color: Colors.black54,
                                    ),
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: asyncSnapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {


                              return Container(
                                color: _getListTileIndex(asyncSnapshot
                                            .data[index].conversationId) ==
                                        -1
                                    ? Colors.white
                                    : Colors.grey.withOpacity(0.3),
                                // color: _getListTileIndex(
                                //     asyncSnapshot.data[index].conversationId) ==
                                //     -1
                                //     ? Colors.white
                                //     : Colors.grey.withOpacity(0.2),
                                child: ListTile(
                                  selected: true,
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
                                            fontWeight: FontWeight.normal
                                               ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${_dateCategory.MMMMddDateFormat.format(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].date))}',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13.0),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (_areMessagesSelected) {
                                        if(_getListTileIndex(asyncSnapshot.data[index].conversationId)>-1) {
                                          _selectedConversationIdsList
                                              .removeWhere(
                                                  (String conversationId) =>
                                              conversationId ==
                                                  asyncSnapshot
                                                      .data[index]
                                                      .conversationId);
                                        } else  {
                                          _selectedConversationIdsList.add(asyncSnapshot
                                              .data[index]
                                              .conversationId);
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
                                        _navigateAndRefresh(ComposePage(
                                            conversationId: asyncSnapshot
                                                .data[index].conversationId,
                                            previousAction: 'Draft',
                                            draftId: asyncSnapshot
                                                .data[index].conversationId));
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      if (_selectedConversationIdsList.length==0) {
                                        _selectedConversationIdsList.add(
                                            asyncSnapshot.data[index]
                                                .conversationId);
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

  int _getListTileIndex(String prospectedConversationId) {
    return _selectedConversationIdsList.indexOf(prospectedConversationId);
  }
}
