import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mail/bloc_patterns/mails/view_single_mail_bloc.dart';
import 'package:mail/models/attachment.dart';
import 'package:mail/models/email.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/file_category_details.dart';
import 'package:mail/utils/messages_actions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

import 'compose_page.dart';

class ViewSingleMailPage extends StatefulWidget {
  Email email;

  ViewSingleMailPage({this.email});

  _ViewSingleMailPageState createState() => _ViewSingleMailPageState();
}

class _ViewSingleMailPageState extends State<ViewSingleMailPage> {
  IconData _fileTypeIconData;
  ViewSingleMailBloc _viewSingleMailBloc;
  MessagesActions _messagesActions;
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  FileCategoryDetails _fileCategoryDetails = FileCategoryDetails();

  @override
  void initState() {
    super.initState();
    widget.email.type =
        widget.email.type == 'input' ? 'inbox' : widget.email.type;
    //print('~~~ initState: ${widget.email.html}');
    _viewSingleMailBloc = ViewSingleMailBloc(context, widget.email);
//    _viewSingleMailBloc.markAsRead('inbox');
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
    _messagesActions = MessagesActions(context);

    Future.delayed(Duration.zero, () {
      _viewSingleMailBloc.displayMail();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _viewSingleMailBloc.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            StreamBuilder(
              stream: _viewSingleMailBloc.fromStream,
              builder:
                  (BuildContext context, AsyncSnapshot<User> asyncSnapshot) {
                //print('~~~ subjectStream: ${asyncSnapshot.data}');
                return Container(
                  padding: EdgeInsets.only(
                      top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
                  color: Colors.grey.withOpacity(0.1),
                  child: asyncSnapshot.data == null
                      ? Container(
                          width: 0.0,
                          height: 0.0,
                        )
                      : ListTile(
                          leading: asyncSnapshot.data.logo.length > 2
                              ? Container(
                                  width: 40.0,
                                  height: 40.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          '${Connect.filesUrl}${asyncSnapshot.data.logo}',
                                      placeholder:
                                          (BuildContext context, String url) {
                                        return Image.asset(
                                            'assets/images/male-avatar.png');
                                      },
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    color: Theme.of(context).accentColor,
                                    child: Center(
                                      child: Text(
                                        asyncSnapshot.data.logo,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0),
                                      ),
                                    ),
                                  ),
                                ),
                          title: Text(
                            asyncSnapshot.data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            asyncSnapshot.data.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          trailing: IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            leading: Icon(Icons.reply),
                                            title: Text('Reply'),
                                            onTap: () {
                                              _navigationActions.closeDialog();
                                              _navigationActions.navigateToScreenWidget(
                                                  ComposePage(
                                                      previousAction: 'Reply',
                                                      fromUser:
                                                          _viewSingleMailBloc
                                                              .email.fromUser,
                                                      toUserList: [
                                                        _viewSingleMailBloc
                                                            .email.fromUser
                                                      ],
                                                      attachmentList:
                                                          _viewSingleMailBloc
                                                              .email
                                                              .attachmentList,
                                                      subject:
                                                          _viewSingleMailBloc
                                                              .email.subject,
                                                      htmlCode:
                                                          _viewSingleMailBloc
                                                              .email.html,
                                                      conversationId:
                                                          _viewSingleMailBloc
                                                              .email
                                                              .conversationId));
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.reply_all),
                                            title: Text('Reply All'),
                                            onTap: () {
                                              _navigationActions.closeDialog();
                                              _navigationActions.navigateToScreenWidget(ComposePage(
                                                  previousAction: 'Reply all',
                                                  fromUser: _viewSingleMailBloc
                                                      .email.fromUser,
                                                  toUserList: _viewSingleMailBloc
                                                      .email.toUserList,
                                                  ccUserList:
                                                      _viewSingleMailBloc
                                                          .email.ccUserList,
                                                  bccUserList:
                                                      _viewSingleMailBloc
                                                          .email.bccUserList,
                                                  attachmentList:
                                                      _viewSingleMailBloc
                                                          .email.attachmentList,
                                                  subject: _viewSingleMailBloc
                                                      .email.subject,
                                                  htmlCode: _viewSingleMailBloc
                                                      .email.html,
                                                  conversationId: widget
                                                      .email.conversationId));
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.forward),
                                            title: Text('Forward'),
                                            onTap: () {
                                              _navigationActions.closeDialog();
                                              _navigationActions.navigateToScreenWidget(
                                                  ComposePage(
                                                      previousAction: 'Forward',
                                                      fromUser:
                                                          _viewSingleMailBloc
                                                              .email.fromUser,
                                                      attachmentList:
                                                          _viewSingleMailBloc
                                                              .email
                                                              .attachmentList,
                                                      subject:
                                                          _viewSingleMailBloc
                                                              .email.subject,
                                                      htmlCode:
                                                          _viewSingleMailBloc
                                                              .email.html,
                                                      conversationId:
                                                          _viewSingleMailBloc
                                                              .email
                                                              .conversationId));
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              })),
                );
              },
            ),
            StreamBuilder(
                stream: _viewSingleMailBloc.toStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<User>> asyncSnapshot) {
                  return asyncSnapshot.data == null
                      ? Container(
                          width: 0.0,
                          height: 0.0,
                        )
                      : asyncSnapshot.data.length == 0
                          ? Container(
                              width: 0.0,
                              height: 0.0,
                            )
                          : Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: Text('To :')),
                                    Expanded(
                                        child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: asyncSnapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Text(
                                          '${asyncSnapshot.data[index].address}',
                                          style: TextStyle(
                                              color: Colors.mesbroBlue),
                                        );
                                      },
                                    )),
                                  ]));
                }),
            StreamBuilder(
                stream: _viewSingleMailBloc.ccStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<User>> asyncSnapshot) {
                  return asyncSnapshot.data == null
                      ? Container(
                          width: 0.0,
                          height: 0.0,
                        )
                      : asyncSnapshot.data.length == 0
                          ? Container(
                              width: 0.0,
                              height: 0.0,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: Text('CC :')),
                                  Expanded(
                                      child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: asyncSnapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Text(
                                        '${asyncSnapshot.data[index].address}',
                                        style:
                                            TextStyle(color: Colors.mesbroBlue),
                                      );
                                    },
                                  ))
                                ]);
                }),
            StreamBuilder(
                stream: _viewSingleMailBloc.bccStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<User>> asyncSnapshot) {
                  return asyncSnapshot.data == null
                      ? Container(
                          width: 0.0,
                          height: 0.0,
                        )
                      : asyncSnapshot.data.length == 0
                          ? Container(
                              width: 0.0,
                              height: 0.0,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: Text('BCC :')),
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: asyncSnapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Text(
                                        '${asyncSnapshot.data[index].address}',
                                        style:
                                            TextStyle(color: Colors.mesbroBlue),
                                      );
                                    },
                                  )
                                ]);
                }),
            StreamBuilder(
                stream: _viewSingleMailBloc.dateStream,
                builder: (BuildContext context,
                    AsyncSnapshot<String> asyncSnapshot) {
                  return Container(
                      margin: EdgeInsets.only(left: 40.0, top: 10.0),
                      child: Text(
                        asyncSnapshot.data == null ? '' : asyncSnapshot.data,
                        style: TextStyle(color: Colors.grey),
                      ));
                }),
            StreamBuilder(
              stream: _viewSingleMailBloc.htmlStream,
              builder:
                  (BuildContext context, AsyncSnapshot<String> asyncSnapshot) {
                return Container(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 10.0, right: 5.0),
                    child: HtmlWidget(
                      asyncSnapshot.data == null ? '' : asyncSnapshot.data,
                      onTapUrl: (String url) {
                        _launchUrl(url);
                      },
                    ));
              },
            ),
            StreamBuilder(
              stream: _viewSingleMailBloc.attachmentsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Attachment>> asyncSnapshot) {
                _viewSingleMailBloc.attachmentsStreamSink
                    .add(_viewSingleMailBloc.email.attachmentList);
                //print('~~~ ${_viewSingleMailBloc.email.attachmentList.length}');
                return asyncSnapshot.data == null
                    ? Container(
                        width: 0.0,
                        height: 0.0,
                      )
                    : asyncSnapshot.data.length == 0
                        ? Container(
                            width: 0.0,
                            height: 0.0,
                          )
                        : ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                                ListTile(
                                  leading: Text('Attachments'),
                                ),
                                ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: asyncSnapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      _fileTypeIconData = asyncSnapshot
                                              .data[index].contentType
                                              .contains('image')
                                          ? FontAwesomeIcons.fileImage
                                          : asyncSnapshot
                                                  .data[index].contentType
                                                  .contains('pdf')
                                              ? FontAwesomeIcons.filePdf
                                              : asyncSnapshot
                                                      .data[index].contentType
                                                      .contains('doc')
                                                  ? FontAwesomeIcons.fileWord
                                                  : asyncSnapshot.data[index]
                                                          .contentType
                                                          .contains('video')
                                                      ? FontAwesomeIcons.video
                                                      : FontAwesomeIcons.file;
                                      return ListTile(
                                        title: Text(
                                          asyncSnapshot.data[index].fileName
                                                      .length >
                                                  18
                                              ? '${asyncSnapshot.data[index].fileName.substring(0, 18)}....'
                                              : asyncSnapshot
                                                  .data[index].fileName,
                                          style: TextStyle(fontSize: 15.0),
                                        ),
                                        leading: IconButton(
                                          icon: Icon(
                                            _fileTypeIconData,
                                            size: 18.0,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {},
                                        ),
                                        // subtitle: Text(
                                        //     '${asyncSnapshot.data[index].fileSize == null ? '' : _fileCategoryDetails.formatBytes(asyncSnapshot.data[index].fileSize)}'),
                                        trailing: IconButton(
                                            icon: Icon(
                                              Icons.file_download,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
//                                            _viewSingleMailBloc.downloadFile(
//                                                asyncSnapshot.data[index].path,
//                                                asyncSnapshot
//                                                    .data[index].fileName);

                                              _viewSingleMailBloc
                                                  .downloadAndSaveFile(
                                                      asyncSnapshot
                                                          .data[index].path);
                                            }),
                                      );
                                    })
                              ]);
              },
            ),
          ],
        ));
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _widgetsCollection.showToastMessage('Could not launch $url');
    }
  }
}
