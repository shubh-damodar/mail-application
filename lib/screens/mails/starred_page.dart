import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mail/bloc_patterns/mails/starred_bloc.dart';
import 'package:mail/models/message.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/screens/mails/search_page.dart';
import 'package:mail/utils/date_category.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/email.dart';
import 'thread_mail_page.dart';

class StarredPage extends StatefulWidget {
  _StarredPageState createState() => _StarredPageState();
}

class _StarredPageState extends State<StarredPage> {
  Future<bool> _onWillPop() async {
    _navigationActions.closeDialog();
    return false;
  }

  final StarredBloc _starredBloc = StarredBloc();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  MessagesActions _messagesActions;
  DateCategory _dateCategory = DateCategory();
  bool _isMessageRead, _areMessagesSelected = false;
  List<String> _selectedConversationIdsList = List<String>();
  List<String> _favouriteActionsList = [
    'Move to Archive',
    'Move to Trash',
    'Mark as Spam',
    'Select All'
  ];
  final ScrollController _scrollController = ScrollController();
  Map _jsonMap = {
    "type": ["STARRED"]
  };
  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _messagesActions = MessagesActions(context);
    _starredBloc.getReceivedEmails(
        'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
//    _starredBloc.startFetchingMails();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _starredBloc.emailsList.length % 20 == 0) {
        _starredBloc.getFurtherEmails('lastTimeStamp');
      }
    });
  }

  void _navigateAndRefresh(Widget widget) {
    Navigator.of(context, rootNavigator: false)
        .push(MaterialPageRoute(builder: (context) => widget))
        .then((dynamic) {
      //print('~~~ _navigateAndRefresh');
      _starredBloc.getReceivedEmails(
          'lastTimeStamp', DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                                _starredBloc.getReceivedEmails(
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
                                _starredBloc.getReceivedEmails(
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
                                _starredBloc.getReceivedEmails(
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
                                i < _starredBloc.emailsList.length;
                                i++) {
                              _selectedConversationIdsList.add(
                                  _starredBloc.emailsList[i].conversationId);
                            }
                            _areMessagesSelected = true;
                            break;
                        }
                      });
                    }, itemBuilder: (BuildContext context) {
                      return _favouriteActionsList.map((String inboxAction) {
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
                  title: Text('Favourites', style: TextStyle()),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _navigationActions.navigateToScreenWidget(SearchPage(
                            emailsList: _starredBloc.emailsList,
                            mailType: 'input',
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
                stream: _starredBloc.emailsStream,
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
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
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
                                    asyncSnapshot.data[index].status == 'READ';

                                return Container(
                                  // color: _getListTileIndex(asyncSnapshot
                                  //     .data[index].conversationId) ==
                                  //     -1
                                  //     ? Colors.white
                                  //     : Colors.grey.withOpacity(0.2),
                                  child: ListTile(
                                    selected: true,
                                    leading: _getListTileIndex(asyncSnapshot
                                                .data[index].conversationId) ==
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
                                                          fontFamily: 'Poppins',
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
                                            asyncSnapshot.data[index].shortText,
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
                                            padding: EdgeInsets.only(bottom: 1),
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
                                              //              '~~~ conversationId: ${asyncSnapshot.data[index].conversationId}');
                                              asyncSnapshot
                                                      .data[index].isFavourite
                                                  ? _starredBloc.unMarkFavorite(
                                                      asyncSnapshot.data[index]
                                                          .conversationId,
                                                      'favourite',
                                                    )
                                                  : _starredBloc.unMarkFavorite(
                                                      asyncSnapshot.data[index]
                                                          .conversationId,
                                                      'favourite',
                                                    );
                                            },
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
                                          _navigateAndRefresh(ThreadMailPage(
                                              subject: asyncSnapshot
                                                  .data[index].subject,
                                              conversationId: asyncSnapshot
                                                  .data[index].conversationId,
                                              type: 'input'));
                                        }
                                      });
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        if (_selectedConversationIdsList
                                                .length ==
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
          )),
    );
  }

  int _getListTileIndex(String prospectedConversationId) {
    return _selectedConversationIdsList.indexOf(prospectedConversationId);
  }
}
