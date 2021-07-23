//import 'dart:collection';
//
//import 'package:after_layout/after_layout.dart';
//import 'package:flutter/material.dart';
//import 'package:autocomplete_textfield/autocomplete_textfield.dart';
//import 'package:flutter_email_sender/flutter_email_sender.dart';
//import 'package:flutter_html/flutter_html.dart';
//import 'package:mail/bloc_patterns/mails/compose_bloc.dart';
//import 'package:mail/bloc_patterns/mails/send_bloc.dart';
//import 'package:mail/models/attached_file.dart';
//import 'package:mail/validators/validator_textfield.dart';
//import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
//
////import 'package:mail/screens/mails/file_attached.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_typeahead/flutter_typeahead.dart';
//import 'package:mail/models/user.dart';
//import 'package:mail/network/user_connect.dart';
//import 'package:mail/utils/contact_list_details.dart';
//import 'package:mail/utils/navigation_actions.dart';
//import 'package:mail/utils/widgets_collection.dart';
//
//class SendPage extends StatefulWidget {
//  final String previousAction;
//  String subject, noTagsHtmlCode, mailId;
//  User fromUser;
//  List<User> toUserList = List<User>(),
//      ccUserList = List<User>(),
//      bccUserList = List<User>();
//
//  SendPage(
//      {this.previousAction, this.fromUser, this.toUserList, this.ccUserList, this.bccUserList, this.subject, this.noTagsHtmlCode, this.mailId});
//
//  _SendPageState createState() =>
//      _SendPageState(
//          previousAction: previousAction,
//          fromUser: fromUser,
//          toUserList: toUserList,
//          ccUserList: ccUserList,
//          bccUserList: bccUserList,
//          subject: subject,
//          noTagsHtmlCode: noTagsHtmlCode,
//          mailId: mailId
//      );
//}
//
//class _SendPageState extends State<SendPage> {
//  final String previousAction;
//  User fromUser;
//  List<User> toUserList = List<User>(),
//      ccUserList = List<User>(),
//      bccUserList = List<User>();
//
//  _SendPageState(
//      {this.previousAction, this.fromUser, this.toUserList, this.ccUserList, this.bccUserList, this.subject, this.noTagsHtmlCode, this.mailId});
//
//  LinkedHashMap<String, String> _paths;
//  List<String> _urlsList = List<String>();
//
//  String _extension, subject, noTagsHtmlCode, mailId;
//  bool _hasValidMime = false;
//  FileType _pickingType;
//  SendBloc _sendBloc;
//  ValidatorTextField _validatorTextField = ValidatorTextField();
//  bool _isCCBCCOpen = false,
//      _areToVisible = false,
//      _areCCVisible = false,
//      _areBCCVisible = false;
//  bool _isBoldSelected = false,
//      _isItalicSelected = false,
//      _isHeaderSelected = false,
//      _isOrderedUnorderedSelected = false;
//  String _selectedHeader,
//      _selectedOrderedUnorderedList;
//  List<String> _toSuggestionList = List<String>();
//  NavigationActions _navigationActions;
//  WidgetsCollection _widgetsCollection;
//  ContactListDetails _contactListDetails = ContactListDetails();
//  final GlobalKey _toButtonGlobalKey = GlobalKey(),
//      _ccButtonGlobalKey = GlobalKey(),
//      _bccButtonGlobalKey = GlobalKey();
//  TextEditingController _toTextEditingController = TextEditingController(),
//      _ccTextEditingController = TextEditingController(),
//      _bccTextEditingController = TextEditingController(),
//      _subjectTextEditingController = TextEditingController(),
//      _bodyTextEditingController = TextEditingController();
//
//  FocusNode _focusNode = FocusNode(),
//      _toFocusNode = FocusNode();
//
//  double _screenHeight;
//
//  void _getPreviousScreenDetails() {
//    if (toUserList != null) {
//      //print('~~~ toUserList: ${toUserList.length}');
//      _sendBloc.toUsersList = []..addAll(toUserList);
//      _sendBloc.toUsersListStreamSink.add(_sendBloc.toUsersList);
//    }
//    if (ccUserList != null) {
//      //print('~~~ ccUserList: ${bccUserList.length}');
//      _sendBloc.ccUsersList = []..addAll(ccUserList);
//      _sendBloc.ccUsersListStreamSink.add(_sendBloc.ccUsersList);
//    }
//    if (bccUserList != null) {
//      //print('~~~ bccUserList: ${bccUserList.length}');
//      _sendBloc.bccUsersList = []..addAll(bccUserList);
//      _sendBloc.bccUsersListStreamSink.add(_sendBloc.bccUsersList);
//    }
//    //print('~~~ 1st subject: ${_sendBloc.subject}');
//    _sendBloc.subject='${(previousAction == 'Reply' || previousAction == 'Reply all')
//        ? 'Re: '
//        :
//    previousAction == 'Forward' ? 'Fwd: ' : ''} $subject';
//    _subjectTextEditingController.text =_sendBloc.subject;
//    _sendBloc.subjectStreamSink.add(_sendBloc.subject);
//    //print('~~~ 2nd subject: ${_sendBloc.subject}');
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    _navigationActions = NavigationActions(context);
//    _widgetsCollection = WidgetsCollection(context);
//    _sendBloc = SendBloc(context);
//    //print('~~~ 1st initState');
//    Future.delayed(Duration.zero, () async  {
//      if(previousAction=='Draft')  {
//        _subjectTextEditingController.text = await _sendBloc.getDraftDetails(mailId);
//        //print('~~~ 2nd initState');
//      } else if(previousAction!='Compose'){
//        _getPreviousScreenDetails();
//      }
//      if(noTagsHtmlCode!=null)  {
//        _bodyTextEditingController.text=noTagsHtmlCode;
//      }
//    });
//
//    _getAllFileExtensions();
//
//    _bodyTextEditingController.text = '';
//  }
//
//  void dispose() {
//    super.dispose();
////    _sendBloc.dispose();
//    _toTextEditingController.dispose();
//    _ccTextEditingController.dispose();
//    _bccTextEditingController.dispose();
//    _subjectTextEditingController.dispose();
//
//  }
//
//  void _getAllFileExtensions() async {}
//
//  Future<bool> _onWillPop() async {
//    _navigationActions.closeDialog();
//    return false;
//  }
//
//  AutoCompleteTextField searchTextField;
//
//  void _openFileExplorer() async {
//    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
//      try {
//        _paths = await FilePicker.getMultiFilePath(
//            type: _pickingType, fileExtension: _extension);
////        _allPathsLinkedHashMap.addAll(_paths);
//        _sendBloc.getUploadSignedUrl(_paths);
//        //print('~~~ ${_paths}');
//      } on PlatformException catch (e) {
//        //print("Unsupported operation" + e.toString());
//      }
//      if (!mounted) return;
//    }
//  }
//
//  void _focusOnTextField(FocusNode focusNode) {
//    FocusScope.of(context).requestFocus(focusNode);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    _screenHeight = MediaQuery
//        .of(context)
//        .size
//        .height;
//    return WillPopScope(
//        onWillPop: _onWillPop,
//        child: Scaffold(
//          appBar: AppBar(
//            leading: IconButton(
//                icon: Icon(Icons.clear),
//                onPressed: () {
//                  _onWillPop();
//                }),
//            title: Column(
//                mainAxisAlignment: MainAxisAlignment.start,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  Container(
//                      margin: EdgeInsets.only(top: 10.0),
//                      child: Text(
//                        previousAction,
//                      )),
//                  GestureDetector(
//                    child: Text(
//                      '${Connect.currentUser.username}@mesbro.com',
//                      style: TextStyle(
//                          fontSize: 13.0, fontWeight: FontWeight.w300),
//                    ),
//                    onTap: () {
//                      //print("tapped subtitle");
//                      // Navigator.push(
//                      //   context,
//                      //   MaterialPageRoute(builder: (context) => FilePickerDemo()),
//                      // );
//                    },
//                  )
//                ]),
//            centerTitle: false,
//            actions: <Widget>[
//              IconButton(
//                  icon: const Icon(Icons.attach_file),
//                  onPressed: () {
//                    _openFileExplorer();
//                  }),
//              IconButton(
//                  icon: const Icon(Icons.send),
//                  onPressed: () {
//                    String bodyText=_bodyTextEditingController.text;
//                    if (_sendBloc.toUsersList.length > 0 ||
//                        _sendBloc.ccUsersList.length > 0 ||
//                        _sendBloc.bccUsersList.length > 0) {
//
//                      _sendBloc.sendBodyMessage(
//                          _subjectTextEditingController.text,
//                          '$bodyText', previousAction, mailId, previousAction);
//                    } else {
//                      _widgetsCollection.showToastMessage(
//                          'Select atleast 1 receipent');
//                    }
//                  }
//              ),
//            ],
//          ),
//          body: Scaffold(
//              body: Container(
//                padding: const EdgeInsets.all(8.0),
//                child: ListView(
//                  children: <Widget>[
//
//                    Container(
//                      child: Row(children: <Widget>[
//                        Container(
//                            margin: EdgeInsets.only(right: 10.0),
//                            child: Text(
//                              'To',
//                              style: TextStyle(
//                                  color: Colors.grey, fontSize: 15.0),
//                            )),
//                        Expanded(
//                            child: ListView(
//                              shrinkWrap: true,
//                              children: <Widget>[
//                                StreamBuilder(
//                                  stream: _sendBloc.toUsersListStream,
//                                  builder: (BuildContext context,
//                                      AsyncSnapshot<List<User>> asyncSnapshot) {
//                                    return asyncSnapshot.data == null
//                                        ? Container()
//                                        : _areToVisible
//                                        ? ListView.builder(
//                                      shrinkWrap: true,
//                                      itemCount: asyncSnapshot.data.length,
//                                      itemBuilder:
//                                          (BuildContext context, int index) {
//                                        return GestureDetector(
//                                            onTap: () {
//                                              _sendBloc.toUsersList
//                                                  .removeAt(index);
//                                              _sendBloc
//                                                  .toUsersListStreamSink
//                                                  .add(_sendBloc
//                                                  .toUsersList);
//                                            },
//                                            child: Container(
//                                                margin: EdgeInsets.only(
//                                                    bottom: 5.0),
//                                                child: Row(
//                                                    mainAxisAlignment:
//                                                    MainAxisAlignment
//                                                        .start,
//                                                    crossAxisAlignment:
//                                                    CrossAxisAlignment
//                                                        .start,
//                                                    children: <Widget>[
//                                                      asyncSnapshot
//                                                          .data.length == 0
//                                                          ? Container(
//                                                        width: 0.0,
//                                                        height: 0.0,)
//                                                          : ClipRRect(
//                                                          borderRadius:
//                                                          BorderRadius
//                                                              .circular(
//                                                              20.0),
//                                                          child: Container(
//                                                              padding: EdgeInsets
//                                                                  .only(
//                                                                  left:
//                                                                  10.0,
//                                                                  right:
//                                                                  10.0,
//                                                                  top:
//                                                                  5.0,
//                                                                  bottom:
//                                                                  5.0),
//                                                              color: Colors
//                                                                  .grey
//                                                                  .withOpacity(
//                                                                  0.3),
//                                                              child: Text(
//                                                                  asyncSnapshot
//                                                                      .data[
//                                                                  index]
//                                                                      .address)))
//                                                    ])));
//                                      },
//                                    )
//                                        : GestureDetector(
//                                        onTap: () {
//                                          Future.delayed(Duration.zero, () {
//                                            setState(() {
//                                              _areToVisible = true;
//                                              _areCCVisible = false;
//                                              _areBCCVisible = false;
//                                            });
//                                          });
//                                        },
//                                        child: Container(
//                                            margin:
//                                            EdgeInsets.only(bottom: 5.0),
//                                            child: Row(
//                                                mainAxisAlignment:
//                                                MainAxisAlignment.start,
//                                                crossAxisAlignment:
//                                                CrossAxisAlignment.start,
//                                                children: <Widget>[
//                                                  Row(
//                                                      mainAxisAlignment:
//                                                      MainAxisAlignment
//                                                          .start,
//                                                      crossAxisAlignment:
//                                                      CrossAxisAlignment
//                                                          .start,
//                                                      children: <Widget>[
//                                                        asyncSnapshot
//                                                            .data.length == 0
//                                                            ? Container(
//                                                          width: 0.0,
//                                                          height: 0.0,)
//                                                            : ClipRRect(
//                                                            borderRadius:
//                                                            BorderRadius
//                                                                .circular(
//                                                                20.0),
//                                                            child: Container(
//                                                                padding: EdgeInsets
//                                                                    .only(
//                                                                    left:
//                                                                    10.0,
//                                                                    right:
//                                                                    10.0,
//                                                                    top:
//                                                                    5.0,
//                                                                    bottom:
//                                                                    5.0),
//                                                                color: Colors
//                                                                    .grey
//                                                                    .withOpacity(
//                                                                    0.3),
//                                                                child: Text(
//                                                                    asyncSnapshot
//                                                                        .data[0]
//                                                                        .address)))
//                                                      ]),
//                                                  Text(
//                                                      asyncSnapshot.data
//                                                          .length < 2
//                                                          ? ''
//                                                          : '+${asyncSnapshot
//                                                          .data.length - 1}')
//                                                ])));
//                                  },
//                                ),
//                                RawKeyboardListener(
//                                    focusNode: _toFocusNode,
//                                    onKey: (RawKeyEvent rawKeyEvent) {
//                                      //print('~~~ onKey: ${rawKeyEvent
//                                          .character} ${rawKeyEvent.data}');
//                                    },
//                                    child: TextField(
//                                      controller: _toTextEditingController,
//
//                                      onTap: () {
//                                        Future.delayed(Duration.zero, () {
//                                          setState(() {
//                                            _areToVisible = true;
//                                            _areCCVisible = false;
//                                            _areBCCVisible = false;
//                                          });
//                                        });
//                                      },
//                                      onChanged: (String value) async {
//                                        if (value == '') {
//                                          _sendBloc.toUsersSuggestionsList =
//                                              List<User>();
//                                        }
//                                        _sendBloc.toUsersSuggestionsList =
//                                        await _contactListDetails
//                                            .getSuggestions(
//                                            value);
//                                        _sendBloc
//                                            .toUsersSuggestionsListStreamSink
//                                            .add(
//                                            _sendBloc
//                                                .toUsersSuggestionsList);
//                                      },
//                                      onSubmitted: (String value) {
//                                        if (_validatorTextField
//                                            .validateTextField(
//                                            _validatorTextField.emailPattern,
//                                            value)) {
//                                          //print('~~~ 1st value: $value');
//
//                                          _sendBloc.toUsersList.add(
//                                              User(address: value));
//                                          _sendBloc.toUsersListStreamSink
//                                              .add(
//                                              _sendBloc.toUsersList);
//                                          _toTextEditingController.text =
//                                          '';
//                                        } else {
//                                          //print('~~~ 2nd value: $value');
//                                        }
//                                      },
//                                    )),
//                                StreamBuilder(
//                                  stream: _sendBloc
//                                      .toUsersSuggestionsListStream,
//                                  builder: (BuildContext context,
//                                      AsyncSnapshot<List<User>> asyncSnapshot) {
//                                    return asyncSnapshot.data == null
//                                        ? Container(width: 0.0, height: 0.0,)
//                                        : asyncSnapshot.data.length == 0
//                                        ? Container(
//                                      width: 0.0, height: 0.0,)
//                                        : Card(child: ListView.builder(
//                                        shrinkWrap: true,
//                                        itemCount: asyncSnapshot.data.length,
//                                        itemBuilder: (BuildContext context,
//                                            int index) {
//                                          return ListTile(
//                                              title: Text(
//                                                  asyncSnapshot.data[index]
//                                                      .name),
//                                              onTap: () {
//                                                _toTextEditingController.text =
//                                                '';
//
//                                                _sendBloc.toUsersList.add(
//                                                    asyncSnapshot.data[index]);
//                                                _sendBloc
//                                                    .toUsersListStreamSink
//                                                    .add(
//                                                    _sendBloc.toUsersList);
//
//                                                _sendBloc
//                                                    .toUsersSuggestionsList =
//                                                    List<User>();
//                                                _sendBloc
//                                                    .toUsersSuggestionsListStreamSink
//                                                    .add(
//                                                    _sendBloc
//                                                        .toUsersSuggestionsList);
//                                              }
//                                          );
//                                        }
//                                    ));
//                                  },
//                                )
//                              ],
//                            ))
//                      ]),
//                    ),
//                    SizedBox(
//                      height: 10.0,
//                    ),
//                    _isCCBCCOpen
//                        ? Column(
//                      children: <Widget>[
//                        Container(
//                          child: Row(children: <Widget>[
//                            Container(
//                                margin: EdgeInsets.only(right: 10.0),
//                                child: Text(
//                                  'CC',
//                                  style: TextStyle(
//                                      color: Colors.grey, fontSize: 15.0),
//                                )),
//                            Expanded(
//                                child: ListView(
//                                  shrinkWrap: true,
//                                  children: <Widget>[
//                                    StreamBuilder(
//                                      stream: _sendBloc.ccUsersListStream,
//                                      builder: (BuildContext context,
//                                          AsyncSnapshot<List<User>>
//                                          asyncSnapshot) {
//                                        return asyncSnapshot.data == null
//                                            ? Container()
//                                            : _areCCVisible
//                                            ? ListView.builder(
//                                          shrinkWrap: true,
//                                          itemCount:
//                                          asyncSnapshot.data.length,
//                                          itemBuilder:
//                                              (BuildContext context,
//                                              int index) {
//                                            return GestureDetector(
//                                                onTap: () {
//                                                  _sendBloc
//                                                      .ccUsersList
//                                                      .removeAt(index);
//                                                  _sendBloc
//                                                      .ccUsersListStreamSink
//                                                      .add(_sendBloc
//                                                      .ccUsersList);
//                                                },
//                                                child: Container(
//                                                    margin:
//                                                    EdgeInsets.only(
//                                                        bottom:
//                                                        5.0),
//                                                    child: Row(
//                                                        mainAxisAlignment:
//                                                        MainAxisAlignment
//                                                            .start,
//                                                        crossAxisAlignment:
//                                                        CrossAxisAlignment
//                                                            .start,
//                                                        children: <
//                                                            Widget>[
//                                                          Row(
//                                                              mainAxisAlignment:
//                                                              MainAxisAlignment
//                                                                  .start,
//                                                              crossAxisAlignment:
//                                                              CrossAxisAlignment
//                                                                  .start,
//                                                              children: <
//                                                                  Widget>[
//                                                                asyncSnapshot
//                                                                    .data
//                                                                    .length == 0
//                                                                    ? Container(
//                                                                  width: 0.0,
//                                                                  height: 0.0,)
//                                                                    : ClipRRect(
//                                                                    borderRadius: BorderRadius
//                                                                        .circular(
//                                                                        20.0),
//                                                                    child: Container(
//                                                                        padding: EdgeInsets
//                                                                            .only(
//                                                                            left: 10.0,
//                                                                            right: 10.0,
//                                                                            top: 5.0,
//                                                                            bottom: 5.0),
//                                                                        color: Colors
//                                                                            .grey
//                                                                            .withOpacity(
//                                                                            0.3),
//                                                                        child: Text(
//                                                                            asyncSnapshot
//                                                                                .data[index]
//                                                                                .address)))
//                                                              ])
//                                                        ])));
//                                          },
//                                        )
//                                            : GestureDetector(
//                                            onTap: () {
//                                              Future.delayed(
//                                                  Duration.zero, () {
//                                                setState(() {
//                                                  _areToVisible = false;
//                                                  _areCCVisible = true;
//                                                  _areBCCVisible = false;
//                                                });
//                                              });
//                                            },
//                                            child: Container(
//                                                margin: EdgeInsets.only(
//                                                    bottom: 5.0),
//                                                child: Row(
//                                                    mainAxisAlignment:
//                                                    MainAxisAlignment
//                                                        .start,
//                                                    crossAxisAlignment:
//                                                    CrossAxisAlignment
//                                                        .start,
//                                                    children: <Widget>[
//                                                      Row(
//                                                          mainAxisAlignment:
//                                                          MainAxisAlignment
//                                                              .start,
//                                                          crossAxisAlignment:
//                                                          CrossAxisAlignment
//                                                              .start,
//                                                          children: <
//                                                              Widget>[
//                                                            Row(
//                                                                mainAxisAlignment:
//                                                                MainAxisAlignment
//                                                                    .start,
//                                                                crossAxisAlignment:
//                                                                CrossAxisAlignment
//                                                                    .start,
//                                                                children: <
//                                                                    Widget>[
//                                                                  asyncSnapshot
//                                                                      .data
//                                                                      .length ==
//                                                                      0
//                                                                      ? Container(
//                                                                    width: 0.0,
//                                                                    height: 0.0,)
//                                                                      : ClipRRect(
//                                                                      borderRadius: BorderRadius
//                                                                          .circular(
//                                                                          20.0),
//                                                                      child: Container(
//                                                                          padding: EdgeInsets
//                                                                              .only(
//                                                                              left: 10.0,
//                                                                              right: 10.0,
//                                                                              top: 5.0,
//                                                                              bottom: 5.0),
//                                                                          color: Colors
//                                                                              .grey
//                                                                              .withOpacity(
//                                                                              0.3),
//                                                                          child: Text(
//                                                                              asyncSnapshot
//                                                                                  .data[0]
//                                                                                  .address))),
//                                                                ]),
//                                                            Text(
//                                                                asyncSnapshot
//                                                                    .data
//                                                                    .length < 2
//                                                                    ? ''
//                                                                    : '+${asyncSnapshot
//                                                                    .data
//                                                                    .length -
//                                                                    1}')
//                                                          ]),
//                                                    ])));
//                                      },
//                                    ),
//                                    TextField(
//                                      controller: _ccTextEditingController,
//                                      onTap: () {
//                                        Future.delayed(Duration.zero, () {
//                                          setState(() {
//                                            _areToVisible = false;
//                                            _areCCVisible = true;
//                                            _areBCCVisible = false;
//                                          });
//                                        });
//                                      },
//                                      onChanged: (String value) async {
//                                        if (value == '') {
//                                          _sendBloc.ccUsersSuggestionsList =
//                                              List<User>();
//                                        }
//                                        _sendBloc.ccUsersSuggestionsList =
//                                        await _contactListDetails
//                                            .getSuggestions(
//                                            value);
//                                        _sendBloc
//                                            .ccUsersSuggestionsListStreamSink
//                                            .add(
//                                            _sendBloc
//                                                .ccUsersSuggestionsList);
//                                        Future.delayed(Duration.zero, () {
//                                          setState(() {
//                                            _areToVisible = false;
//                                            _areCCVisible = true;
//                                            _areBCCVisible = false;
//                                          });
//                                        });
//                                      },
//                                      onSubmitted: (String value) {
//                                        if (_validatorTextField
//                                            .validateTextField(
//                                            _validatorTextField.emailPattern,
//                                            value)) {
//                                          //print('~~~ 1st value: $value');
//
//                                          _sendBloc.ccUsersList.add(
//                                              User(address: value));
//                                          _sendBloc.ccUsersListStreamSink
//                                              .add(_sendBloc.ccUsersList);
//                                          _ccTextEditingController.text =
//                                          '';
//                                        } else {
//                                          //print('~~~ 2nd value: $value');
//                                        }
//                                      },
//                                    ),
//                                    StreamBuilder(
//                                      stream: _sendBloc
//                                          .ccUsersSuggestionsListStream,
//                                      builder: (BuildContext context,
//                                          AsyncSnapshot<
//                                              List<User>> asyncSnapshot) {
//                                        return asyncSnapshot.data == null
//                                            ? Container(
//                                          width: 0.0, height: 0.0,)
//                                            : asyncSnapshot.data.length == 0
//                                            ? Container(
//                                          width: 0.0, height: 0.0,)
//                                            : Card(child: ListView.builder(
//                                            shrinkWrap: true,
//                                            itemCount: asyncSnapshot.data
//                                                .length,
//                                            itemBuilder: (BuildContext context,
//                                                int index) {
//                                              return ListTile(
//                                                  title: Text(
//                                                      asyncSnapshot.data[index]
//                                                          .name),
//                                                  onTap: () {
//                                                    _ccTextEditingController
//                                                        .text =
//                                                    '';
//
//                                                    _sendBloc.ccUsersList
//                                                        .add(
//                                                        asyncSnapshot
//                                                            .data[index]);
//                                                    _sendBloc
//                                                        .ccUsersListStreamSink
//                                                        .add(
//                                                        _sendBloc
//                                                            .ccUsersList);
//
//                                                    _sendBloc
//                                                        .ccUsersSuggestionsList =
//                                                        List<User>();
//                                                    _sendBloc
//                                                        .ccUsersSuggestionsListStreamSink
//                                                        .add(
//                                                        _sendBloc
//                                                            .ccUsersSuggestionsList);
//                                                  }
//                                              );
//                                            }
//                                        ));
//                                      },
//                                    ),
//                                  ],
//                                ))
//                          ]),
//                        ),
//                        SizedBox(
//                          height: 10.0,
//                        ),
//                        Container(
//                          child: Row(children: <Widget>[
//                            Container(
//                                margin: EdgeInsets.only(right: 10.0),
//                                child: Text(
//                                  'BCC',
//                                  style: TextStyle(
//                                      color: Colors.grey, fontSize: 15.0),
//                                )),
//                            Expanded(
//                                child: ListView(
//                                  shrinkWrap: true,
//                                  children: <Widget>[
//                                    StreamBuilder(
//                                      stream: _sendBloc.bccUsersListStream,
//                                      builder: (BuildContext context,
//                                          AsyncSnapshot<List<User>>
//                                          asyncSnapshot) {
//                                        return asyncSnapshot.data == null
//                                            ? Container()
//                                            : _areBCCVisible
//                                            ? ListView.builder(
//                                          shrinkWrap: true,
//                                          itemCount:
//                                          asyncSnapshot.data.length,
//                                          itemBuilder:
//                                              (BuildContext context,
//                                              int index) {
//                                            return GestureDetector(
//                                                onTap: () {
//                                                  _sendBloc
//                                                      .bccUsersList
//                                                      .removeAt(index);
//                                                  _sendBloc
//                                                      .bccUsersListStreamSink
//                                                      .add(_sendBloc
//                                                      .bccUsersList);
//                                                },
//                                                child: Container(
//                                                    margin:
//                                                    EdgeInsets.only(
//                                                        bottom:
//                                                        5.0),
//                                                    child: Row(
//                                                        mainAxisAlignment:
//                                                        MainAxisAlignment
//                                                            .start,
//                                                        crossAxisAlignment:
//                                                        CrossAxisAlignment
//                                                            .start,
//                                                        children: <
//                                                            Widget>[
//                                                          asyncSnapshot.data
//                                                              .length == 0
//                                                              ? Container(
//                                                            width: 0.0,
//                                                            height: 0.0,)
//                                                              : ClipRRect(
//                                                              borderRadius:
//                                                              BorderRadius
//                                                                  .circular(
//                                                                  20.0),
//                                                              child: Container(
//                                                                  padding: EdgeInsets
//                                                                      .only(
//                                                                      left:
//                                                                      10.0,
//                                                                      right:
//                                                                      10.0,
//                                                                      top:
//                                                                      5.0,
//                                                                      bottom:
//                                                                      5.0),
//                                                                  color: Colors
//                                                                      .grey
//                                                                      .withOpacity(
//                                                                      0.3),
//                                                                  child: Text(
//                                                                      asyncSnapshot
//                                                                          .data[index]
//                                                                          .address)))
//                                                        ])));
//                                          },
//                                        )
//                                            : GestureDetector(
//                                            onTap: () {
//                                              if (_sendBloc.toUsersList
//                                                  .length > 0) {
//                                                _sendBloc.toUsersList
//                                                    .removeAt(0);
//
//                                                _sendBloc
//                                                    .toUsersListStreamSink
//                                                    .add(_sendBloc
//                                                    .toUsersList);
//                                              }
//                                            },
//                                            child: Container(
//                                                margin: EdgeInsets.only(
//                                                    bottom: 5.0),
//                                                child: Row(
//                                                    mainAxisAlignment:
//                                                    MainAxisAlignment
//                                                        .start,
//                                                    crossAxisAlignment:
//                                                    CrossAxisAlignment
//                                                        .start,
//                                                    children: <Widget>[
//                                                      Row(
//                                                          mainAxisAlignment:
//                                                          MainAxisAlignment
//                                                              .start,
//                                                          crossAxisAlignment:
//                                                          CrossAxisAlignment
//                                                              .start,
//                                                          children: <
//                                                              Widget>[
//                                                            asyncSnapshot.data
//                                                                .length == 0
//                                                                ? Container(
//                                                              width: 0.0,
//                                                              height: 0.0,)
//                                                                : ClipRRect(
//                                                                borderRadius:
//                                                                BorderRadius
//                                                                    .circular(
//                                                                    20.0),
//                                                                child: Container(
//                                                                    padding: EdgeInsets
//                                                                        .only(
//                                                                        left:
//                                                                        10.0,
//                                                                        right:
//                                                                        10.0,
//                                                                        top:
//                                                                        5.0,
//                                                                        bottom:
//                                                                        5.0),
//                                                                    color: Colors
//                                                                        .grey
//                                                                        .withOpacity(
//                                                                        0.3),
//                                                                    child: Text(
//                                                                        asyncSnapshot
//                                                                            .data[0]
//                                                                            .address)))
//                                                          ]),
//                                                      Text(
//                                                          asyncSnapshot.data
//                                                              .length < 2
//                                                              ? ''
//                                                              : '+${asyncSnapshot
//                                                              .data.length -
//                                                              1}')
//                                                    ])));
//                                      },
//                                    ),
//                                    TextField(
//                                      controller: _bccTextEditingController,
//                                      onTap: () {
//                                        Future.delayed(Duration.zero, () {
//                                          setState(() {
//                                            _areToVisible = false;
//                                            _areCCVisible = false;
//                                            _areBCCVisible = true;
//                                          });
//                                        });
//                                      },
//                                      onChanged: (String value) async {
//                                        if (value == '') {
//                                          _sendBloc.bccUsersSuggestionsList =
//                                              List<User>();
//                                        }
//                                        _sendBloc.bccUsersSuggestionsList =
//                                        await _contactListDetails
//                                            .getSuggestions(
//                                            value);
//                                        _sendBloc
//                                            .bccUsersSuggestionsListStreamSink
//                                            .add(
//                                            _sendBloc
//                                                .bccUsersSuggestionsList);
//                                      },
//                                      onSubmitted: (String value) {
//                                        if (_validatorTextField
//                                            .validateTextField(
//                                            _validatorTextField.emailPattern,
//                                            value)) {
//                                          //print('~~~ 1st value: $value');
//
//                                          _sendBloc.bccUsersList.add(
//                                              User(address: value));
//                                          _sendBloc.bccUsersListStreamSink
//                                              .add(_sendBloc.bccUsersList);
//                                          _bccTextEditingController.text =
//                                          '';
//                                        } else {
//                                          //print('~~~ 2nd value: $value');
//                                        }
//                                      },
//                                    ),
//                                    StreamBuilder(
//                                      stream: _sendBloc
//                                          .bccUsersSuggestionsListStream,
//                                      builder: (BuildContext context,
//                                          AsyncSnapshot<
//                                              List<User>> asyncSnapshot) {
//                                        return asyncSnapshot.data == null
//                                            ? Container(
//                                          width: 0.0, height: 0.0,)
//                                            : asyncSnapshot.data.length == 0
//                                            ? Container(
//                                          width: 0.0, height: 0.0,)
//                                            : Card(child: ListView.builder(
//                                            shrinkWrap: true,
//                                            itemCount: asyncSnapshot.data
//                                                .length,
//                                            itemBuilder: (BuildContext context,
//                                                int index) {
//                                              return ListTile(
//                                                  title: Text(
//                                                      asyncSnapshot.data[index]
//                                                          .name),
//                                                  onTap: () {
//                                                    _bccTextEditingController
//                                                        .text =
//                                                    '';
//
//                                                    _sendBloc.bccUsersList
//                                                        .add(
//                                                        asyncSnapshot
//                                                            .data[index]);
//                                                    _sendBloc
//                                                        .bccUsersListStreamSink
//                                                        .add(
//                                                        _sendBloc
//                                                            .bccUsersList);
//
//                                                    _sendBloc
//                                                        .bccUsersSuggestionsList =
//                                                        List<User>();
//                                                    _sendBloc
//                                                        .bccUsersSuggestionsListStreamSink
//                                                        .add(
//                                                        _sendBloc
//                                                            .bccUsersSuggestionsList);
//                                                  }
//                                              );
//                                            }
//                                        ));
//                                      },
//                                    ),
//                                  ],
//                                ))
//                          ]),
//                        ),
//                      ],
//                    )
//                        : Row(
////                        mainAxisAlignment: MainAxisAlignment.start,
////                        crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Container(
//                            margin: EdgeInsets.only(right: 10.0),
//                            child: Text(
//                              'CC/BCC',
//                              style: TextStyle(
//                                  color: Colors.grey, fontSize: 15.0),
//                            )),
//                        Expanded(child: TextField(onTap: () {
//                          setState(() {
//                            _isCCBCCOpen = true;
//                            //print('~~~ _isCCBCCOpen: $_isCCBCCOpen');
//                          });
//                        })),
//                      ],
//                    ),
//                    SizedBox(
//                      height: 10.0,
//                    ),
//                    Row(
//                      children: <Widget>[
//                        Container(
//                            margin: EdgeInsets.only(right: 10.0),
//                            child: Text(
//                              'Subject',
//                              style: TextStyle(
//                                  color: Colors.grey, fontSize: 15.0),
//                            )),
//                        Expanded(
//                            child: TextField(
//                              controller: _subjectTextEditingController,
//                            ))
//                      ],
//                    ),
//                    Container(
//                      margin:
//                      EdgeInsets.only(
//                          left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
//                      child: ListView(
//                        shrinkWrap: true,
//                        children: <Widget>[
//
//                          Container(
//                              margin: EdgeInsets.only(top: 50.0),
//                              child: TextField(
//                                enableInteractiveSelection: true,
//                                keyboardType: TextInputType.multiline,
//                                maxLines: null,
//                                maxLength: null,
//                                textInputAction: TextInputAction.newline,
//                                controller: _bodyTextEditingController,
//                                focusNode: _focusNode,
//                              )),
//
//                          SizedBox(
//                            height: 10.0,
//                          ),
//                        ],
//                      ),
//                    ),
//
//                    StreamBuilder(
//                        stream: _sendBloc.attachedFileListStream,
//                        builder: (BuildContext context,
//                            AsyncSnapshot<List<AttachedFile>> asyncSnapshot) {
//                          return asyncSnapshot.data == null
//                              ? Container(
//                            margin: EdgeInsets.only(top: 10.0),
//                            width: 0.0,
//                            height: 0.0,
//                          )
//                              : asyncSnapshot.data.length == 0
//                              ? Container(
//                            margin: EdgeInsets.only(top: 10.0),
//                            width: 0.0,
//                            height: 0.0,
//                          )
//                              : Container(
//                              margin: EdgeInsets.only(top: 0.0),
//                              child: ListView.separated(
//                                  physics: NeverScrollableScrollPhysics(),
//                                  shrinkWrap: true,
//                                  itemCount: asyncSnapshot.data.length,
//                                  separatorBuilder:
//                                      (BuildContext context, int index) {
//                                    return Divider();
//                                  },
//                                  itemBuilder:
//                                      (BuildContext context, int index) {
//                                    return Row(
//                                      mainAxisAlignment:
//                                      MainAxisAlignment.spaceBetween,
//                                      children: <Widget>[
//                                        Container(
//                                            margin:
//                                            EdgeInsets.only(left: 10.0),
//                                            child: Text(asyncSnapshot
//                                                .data[index].fileName)),
//                                        IconButton(
//                                            icon: Icon(Icons.clear),
//                                            onPressed: () {
//                                              _sendBloc.attachedFileList
//                                                  .removeAt(index);
//                                              _sendBloc
//                                                  .attachedFileStreamSink
//                                                  .add(_sendBloc
//                                                  .attachedFileList);
//                                            })
//                                      ],
//                                    );
//                                  }));
//                        }),
//                    StreamBuilder(
//                      stream: _sendBloc.composeFinishedStream,
//                      builder: (BuildContext context,
//                          AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
//                        return asyncSnapshot.data == null ? Container(
//                            width: 0.0, height: 0.0) : asyncSnapshot.data
//                            .length == 0
//                            ? Container(width: 0.0, height: 0.0)
//                            : _composeFinished(asyncSnapshot.data);
//                      },
//                    )
//                  ],
//                ),
//              )),
//        ));
//  }
//
//  Widget _composeFinished(Map<String, dynamic> mapResponse) {
//    Future.delayed(Duration.zero, () {
//      if (mapResponse['code'] == 200) {
//        _widgetsCollection.showToastMessage(mapResponse['message']);
//        _navigationActions.closeDialog();
//      } else {
//        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
//      }
//    });
//    return Container(width: 0.0, height: 0.0);
//  }
//
//
//}
