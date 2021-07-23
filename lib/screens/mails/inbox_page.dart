import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mail/bloc_patterns/mails/inbox_bloc.dart';
import 'package:mail/models/message.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/screens/idm/login_page.dart';
import 'package:mail/screens/mails/search_page.dart';
import 'package:mail/screens/mails/send_page.dart';
import 'package:mail/screens/mails/sent_box_page.dart';
import 'package:mail/screens/mails/signature_page.dart';
import 'package:mail/screens/mails/spam_page.dart';
import 'package:mail/screens/mails/starred_page.dart';
import 'package:mail/screens/mails/thread_mail_page.dart';
import 'package:mail/screens/mails/trash_page.dart';
import 'package:mail/screens/profile_screens/edit_profile_screens/profile_page.dart';
import 'package:mail/utils/date_category.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/network_connectivity.dart';
import 'package:mail/utils/shared_pref_manager.dart';
import 'package:mail/utils/widgets_collection.dart';
import '../../models/email.dart';
import 'archive_page.dart';
import 'compose_page.dart';
import 'package:shimmer/shimmer.dart';

import 'draft_page.dart';

class InboxPage extends StatefulWidget {
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final InboxBloc _inboxBloc = InboxBloc();
  DateCategory _dateCategory = DateCategory();
  double _screenWidth, _screenHeight;
  DateTime currentBackPressDateTime;
  String _selectedMessageconversationId;
  bool _isMessageRead, _areMessagesSelected = false;
  Color _messageListTileColor = Colors.white;
  List<User> _usersList = List<User>();
  List<String> _selectedConversationIdsList = List<String>();
  List<String> _inboxActionsList = [
    'Move to Archive',
    'Move to Trash',
    'Mark as Spam',
    'Mark as Read',
    'Select All'
  ];
  LinkedHashMap<String, String> _settingsRouteLinkedHashMap =
      LinkedHashMap<String, String>();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  MessagesActions _messagesActions;
  final ScrollController _scrollController = ScrollController();
  Map _jsonMap = {
    "type": ["INBOX"]
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
    _messagesActions = MessagesActions(context);
    _inboxBloc.getReceivedMessages(
        'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
    _inboxBloc.startFetchingMails();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _inboxBloc.emailsList.length % 20 == 0) {
        //print('~~~ _scrollController');
        _inboxBloc.getFurtherMessages('lastTimeStamp');
      }
    });
  }

  void dispose() {
    super.dispose();
    _inboxBloc.dispose();
    _scrollController.dispose();
  }

  Future<void> _getAllUsers() async {
    await SharedPrefManager.getAllUsers().then((List<User> user) {
      setState(() {
        _usersList = user;
      });
    });
  }

  void _navigateAndRefresh(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      //print('~~~ _navigateAndRefresh');
//      _inboxBloc.getReceivedMessages(
//          'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
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
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.mesbroBlue,
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  // size: 30.0,
                ),
                onPressed: () {
//                  _navigationActions.navigateToScreenWidget(ComposePage());
                  _navigationActions.navigateToScreenWidget(ComposePage(
                    previousAction: 'Compose',
                    subject: '',
                  ));
                }),
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
                    title:
                        Text('${_selectedConversationIdsList.length} selected'),
                    actions: <Widget>[
                      PopupMenuButton<String>(
                          onSelected: (String selectedAction) {
                        setState(() {
                          switch (selectedAction) {
                            case 'Move to Archive':
                              _messagesActions
                                  .archiveMessage(
                                      _selectedConversationIdsList, 'inbox')
                                  .then((void voidNothing) {
                                Future.delayed(Duration.zero, () {
                                  _inboxBloc.getReceivedMessages(
                                      'lastTimeStamp',
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString());
                                });
                              });
                              _areMessagesSelected = false;
                              _selectedConversationIdsList = List<String>();
                              break;
                            case 'Move to Trash':
                              _messagesActions
                                  .moveToTrash(
                                      _selectedConversationIdsList, 'inbox')
                                  .then((void voidNothing) {
                                Future.delayed(Duration.zero, () {
                                  _inboxBloc.getReceivedMessages(
                                      'lastTimeStamp',
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString());
                                });
                              });
                              _areMessagesSelected = false;
                              _selectedConversationIdsList = List<String>();
                              break;
                            case 'Mark as Spam':
                              _messagesActions
                                  .spamMessage(
                                      _selectedConversationIdsList, 'inbox')
                                  .then((void voidNothing) {
                                Future.delayed(Duration.zero, () {
                                  _inboxBloc.getReceivedMessages(
                                      'lastTimeStamp',
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString());
                                });
                              });
                              _areMessagesSelected = false;
                              _selectedConversationIdsList = List<String>();
                              break;
                            case 'Mark as Read':
                              _messagesActions
                                  .bulkMarkAsRead(
                                      _selectedConversationIdsList, 'inbox')
                                  .then((void voidNothing) {
                                Future.delayed(Duration.zero, () {
                                  _inboxBloc.getReceivedMessages(
                                      'lastTimeStamp',
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString());
                                });
                              });
                              _areMessagesSelected = false;
                              _selectedConversationIdsList = List<String>();
                              break;
                            case 'Select All':
                              for (int i = 0;
                                  i < _inboxBloc.emailsList.length;
                                  i++) {
                                _selectedConversationIdsList.add(
                                    _inboxBloc.emailsList[i].conversationId);
                              }
                              _areMessagesSelected = true;
                              break;
                          }
                        });
                      }, itemBuilder: (BuildContext context) {
                        return _inboxActionsList.map((String inboxAction) {
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
                    title: Text('Inbox', style: TextStyle()),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _navigationActions
                                .navigateToScreenWidget(SearchPage(
                              emailsList: _inboxBloc.emailsList,
                              mailType: 'input',
                              jsonMap: _jsonMap,
                            ));
                          });
                        },
                      ),
                    ],
                  ),
            drawer: Container(
                width: _screenWidth * 0.90,
                child: Row(children: <Widget>[
                  Flexible(
                      flex: 2,
                      child: Container(
                        color: Colors.white,
                        child: Container(
                          margin: EdgeInsets.only(top: 20.0),
                          color: Colors.grey.withOpacity(0.25),
                          child: ListView(
//                            shrinkWrap: true,
                            children: <Widget>[
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: _usersList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: _widgetsCollection
                                        .getDrawerProfileImage(
                                            45.0, _usersList[index]),
                                    onTap: () {
                                      setState(() {
                                        SharedPrefManager.switchCurrentUser(
                                                _usersList[index])
                                            .then((value) {
                                          _navigationActions
                                              .navigateToScreenWidget(
                                                  ProfilePage(
                                            userId: Connect.currentUser.userId,
                                          ));
                                        });
                                      });
                                    },
                                  );
                                },
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white)),
                                padding: EdgeInsets.all(0.5),
                                width: 45.0,
                                height: 45.0,
                                child: Center(
                                  child: ClipOval(
                                    child: IconButton(
                                        icon: Icon(Icons.person_add),
                                        onPressed: () {
//                _navigationActions.navigateToScreenName('login_page');
                                          _navigationActions
                                              .navigateToScreenWidget(LoginPage(
                                                  previousScreen:
                                                      'inbox_page'));
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Flexible(
                      flex: 7,
                      child: Drawer(
                          elevation: 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
//                        shrinkWrap: true,
                            children: <Widget>[
                              DrawerHeader(
                                child: Image.asset(
                                  'assets/images/mesbro.png',
                                  width: _screenWidth * 0.4,
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.star_border),
                                title: Text('Favourites', style: TextStyle()),
                                onTap: () {
                                  _navigationActions
                                      .navigateToScreenWidget(StarredPage());
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.archive),
                                title: Text('Archive', style: TextStyle()),
                                onTap: () {
                                  _navigationActions
                                      .navigateToScreenWidget(ArchivePage());
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.send),
                                title: Text(
                                  'Sent Mail',
                                  style: TextStyle(),
                                ),
                                onTap: () {
                                  _navigationActions
                                      .navigateToScreenWidget(SentBoxPage());
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.drafts),
                                title: Text('Drafts', style: TextStyle()),
                                onTap: () {
                                  _navigationActions
                                      .navigateToScreenWidget(DraftPage());
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.block),
                                title: Text('Spam', style: TextStyle()),
                                onTap: () {
                                  _navigationActions
                                      .navigateToScreenWidget(SpamPage());
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Trash', style: TextStyle()),
                                onTap: () {
                                  _navigationActions
                                      .navigateToScreenWidget(TrashPage());
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.fileSignature,
                                  size: 18.0,
                                ),
                                title: Text(
                                  "Signature",
                                  style: TextStyle(),
                                ),
                                onTap: () {
                                  _navigationActions
                                      .navigateToScreenWidget(SignaturePage());
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.exit_to_app),
                                title: Text('Log Out'),
                                onTap: () {
                                  SharedPrefManager.removeAll()
                                      .then((bool value) {
                                    //print('~~~ Log Out: $value');
                                    _navigationActions
                                        .navigateToScreenWidgetRoot(
                                            LoginPage());
                                  });
                                },
                              ),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Text(
                                            'Version: 0.0.8',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                            ),
                                          ))))
                            ],
                          )))
                ])),
            body: Container(
              margin: EdgeInsets.only(top: 1.0),
              child: StreamBuilder(
                  stream: _inboxBloc.emailsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Email>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Column(
                                children: [0, 1, 2, 3, 4, 5]
                                    .map((_) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 48.0,
                                                height: 48.0,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      height: 8.0,
                                                      color: Colors.white,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 2.0),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 8.0,
                                                      color: Colors.white,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 2.0),
                                                    ),
                                                    Container(
                                                      width: 40.0,
                                                      height: 8.0,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          )
                        : asyncSnapshot.data.length == 0
                            ? Container(
                                child: Center(
                                child: Text('No messages yet...'),
                              ))
                            : ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        Divider(),
                                controller: _scrollController,
                                shrinkWrap: true,
                                itemCount: asyncSnapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  _isMessageRead =
                                      asyncSnapshot.data[index].status ==
                                          'READ';
                                  //print('~~~ _isMessageRead: $_isMessageRead');
                                  return Container(
                                    // color: _getListTileIndex(asyncSnapshot
                                    //     .data[index].conversationId) ==
                                    //     -1
                                    //     ? Colors.white
                                    //     : Colors.grey.withOpacity(0.2),
                                    child: ListTile(
                                      selected: true,
                                      leading: _getListTileIndex(asyncSnapshot
                                                  .data[index]
                                                  .conversationId) ==
                                              -1
                                          ? asyncSnapshot.data[index].fromUser
                                                      .logo.length >
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
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Container(
                                                    width: 40.0,
                                                    height: 40.0,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    child: Center(
                                                      child: Text(
                                                        asyncSnapshot
                                                            .data[index]
                                                            .fromUser
                                                            .logo,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 18.0),
                                                      ),
                                                    ),
                                                  ),
                                                )
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
                                                  ),
                                                ),
                                              ),
                                            ),
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
                                          Text(
                                              asyncSnapshot
                                                  .data[index].shortText,
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
                                          Expanded(
                                              child: Container(
                                                  margin:
                                                      EdgeInsets.only(top: 7.0),
                                                  child: Text(
                                                    '${_dateCategory.MMMMddDateFormat.format(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].date))}',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10.0),
                                                  ))),
                                          Expanded(
                                            child: IconButton(
                                              padding:
                                                  EdgeInsets.only(bottom: 1),
                                              splashColor: Colors.transparent,
                                              icon: asyncSnapshot
                                                      .data[index].isFavourite
                                                  ? Icon(Icons.star,
                                                      color: Colors.yellow,
                                                      size: 20.0)
                                                  : Icon(Icons.star_border,
                                                      color: Colors.grey,
                                                      size: 20.0),
                                              onPressed: () {
                                                setState(() {
                                                  asyncSnapshot.data[index]
                                                          .isFavourite =
                                                      !asyncSnapshot.data[index]
                                                          .isFavourite;
                                                });
                                                //print(
                                                //      '~~~ conversationId: ${asyncSnapshot.data[index].conversationId}');
                                                asyncSnapshot
                                                        .data[index].isFavourite
                                                    ? _inboxBloc
                                                        .markUnmarkFavorite(
                                                            asyncSnapshot
                                                                .data[index]
                                                                .conversationId,
                                                            'favourite',
                                                            'remove')
                                                    : _inboxBloc
                                                        .markUnmarkFavorite(
                                                            asyncSnapshot
                                                                .data[index]
                                                                .conversationId,
                                                            'inbox',
                                                            'add');
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (_areMessagesSelected) {
                                            if (_getListTileIndex(asyncSnapshot
                                                    .data[index]
                                                    .conversationId) >
                                                -1) {
                                              _selectedConversationIdsList
                                                  .removeWhere(
                                                      (String conversationId) =>
                                                          conversationId ==
                                                          asyncSnapshot
                                                              .data[index]
                                                              .conversationId);
                                            } else {
                                              _selectedConversationIdsList.add(
                                                  asyncSnapshot.data[index]
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
                                            asyncSnapshot.data[index].status =
                                                'READ';
                                            _navigationActions
                                                .navigateToScreenWidget(
                                                    ThreadMailPage(
                                                        conversationId:
                                                            asyncSnapshot
                                                                .data[index]
                                                                .conversationId,
                                                        type: 'input',
                                                        subject: asyncSnapshot
                                                            .data[index]
                                                            .subject));
                                          }
                                        });
                                      },
                                      onLongPress: () {
                                        setState(() {
                                          if (_selectedConversationIdsList
                                                  .length ==
                                              0) {
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
            )));
  }

  int _getListTileIndex(String prospectedconversationId) {
    return _selectedConversationIdsList.indexOf(prospectedconversationId);
  }
}
