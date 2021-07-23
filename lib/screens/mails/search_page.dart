import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mail/bloc_patterns/mails/search_bloc.dart';
import 'package:mail/models/email.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/screens/mails/thread_mail_page.dart';
import 'package:mail/utils/date_category.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class SearchPage extends StatefulWidget {
  List<Email> emailsList = List<Email>();
  String mailType;
  Map jsonMap ;

  SearchPage({this.emailsList, this.mailType, this.jsonMap});

  _SearchPageState createState() => _SearchPageState(jsonMap : this.jsonMap);
}

class _SearchPageState extends State<SearchPage> {
  final Map jsonMap;
  _SearchPageState({this.jsonMap});
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  DateCategory _dateCategory = DateCategory();
  SearchBloc _searchBloc;
  final ScrollController _scrollController=ScrollController();
  bool _isMessageRead;

  void _onWillPop() async {
    _navigationActions.closeDialog();
  }

  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _searchBloc = SearchBloc(mailsList: widget.emailsList);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _searchBloc.mailsList.length % 20 == 0) {
        //print('~~~ _scrollController');
      }
    });
  }

  void dispose() {
    super.dispose();
    _searchBloc.dispose();
    _scrollController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        title: StreamBuilder(
            stream: _searchBloc.mailSubjectShortTextStream,
            builder:
                (BuildContext context, AsyncSnapshot<String> asyncSnapshot) {
              return Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: TextField(
                    autofocus: true,
                    onChanged: (String value) {
                      _searchBloc.searchBox(value , jsonMap);
                    },
                    decoration: InputDecoration(
                      prefix: Container(
                          transform: Matrix4.translationValues(0.0, 10.0, 0.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: _onWillPop,
                          )),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.15),
                      )),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.15),
                      hintText: 'Search....',
                    ),
                  ));
            }),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 1.0),
        child: StreamBuilder(
            stream: _searchBloc.emailsFoundStream,
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
                      ? Center(
                          child: Text(
                          'No messages yet...',
                          style: TextStyle(),
                        ))
                      : ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(
                                color: Colors.black54,
                              ),
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: asyncSnapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            _isMessageRead =
                                asyncSnapshot.data[index].status == 'READ';

                            return Container(
                              // color: _getListTileIndex(
                              //     asyncSnapshot.data[index].conversationId) ==
                              //     -1
                              //     ? Colors.white
                              //     : Colors.grey.withOpacity(0.2),
                              child: ListTile(
                                selected: true,
                                leading: asyncSnapshot
                                            .data[index].fromUser.logo.length >
                                        2
                                    ? Container(
                                        width: 40.0,
                                        height: 40.0,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                                            color:
                                                Theme.of(context).accentColor,
                                            child: Center(
                                                child: Text(
                                              asyncSnapshot
                                                  .data[index].fromUser.logo,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      '${_dateCategory.MMMMddDateFormat.format(DateTime.fromMillisecondsSinceEpoch(asyncSnapshot.data[index].date))}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _navigationActions.navigateToScreenWidget(
                                      ThreadMailPage(
                                          subject:
                                              asyncSnapshot.data[index].subject,
                                          conversationId: asyncSnapshot
                                              .data[index].conversationId,
                                          type: widget.mailType));
                                },
                              ),
                            );
                          });
            }),
      ),
    );
  }
}
