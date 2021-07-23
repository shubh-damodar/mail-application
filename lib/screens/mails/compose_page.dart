import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mail/models/attachment.dart';
import 'package:mail/utils/file_category_details.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:mail/bloc_patterns/mails/compose_bloc.dart';
import 'package:mail/models/attached_file.dart';
import 'package:mail/validators/validator_textfield.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mail/models/user.dart';
import 'package:mail/network/user_connect.dart';
import 'package:mail/utils/contact_list_details.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class ComposePage extends StatefulWidget {
  final String previousAction;
  String subject, htmlCode = '', conversationId, draftId = null;
  User fromUser;
  List<User> toUserList = List<User>(),
      ccUserList = List<User>(),
      bccUserList = List<User>();
  List<Attachment> attachmentList = List<Attachment>();

  ComposePage(
      {this.previousAction,
      this.fromUser,
      this.toUserList,
      this.ccUserList,
      this.bccUserList,
      this.attachmentList,
      this.subject,
      this.htmlCode,
      this.conversationId,
      this.draftId});

  _ComposePageState createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  LinkedHashMap<String, String> _paths;

  String _extension, _fileType, _screenTitle;
  String _htmlFilePath =
      'file:///android_asset/flutter_assets/assets/cks_code.html';
  bool _hasValidMime = false;
  FileType _pickingType;
  ComposeBloc _composeBloc;
  ValidatorTextField _validatorTextField = ValidatorTextField();

  List<String> _toSuggestionList = List<String>();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  ContactListDetails _contactListDetails;
  TextEditingController _toTextEditingController = TextEditingController(),
      _ccTextEditingController = TextEditingController(),
      _bccTextEditingController = TextEditingController(),
      _subjectTextEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  WebViewController _webViewController;
  IconData _fileTypeIconData;
  FileCategoryDetails _fileCategoryDetails = FileCategoryDetails();
  double _screenHeight;

  void _getPreviousScreenDetails() {
    print('~~~ _getPreviousScreenDetails');
    if (widget.toUserList != null) {
      print('~~~ toUserList: ${widget.toUserList.length}');
      _composeBloc.toUsersList = []..addAll(widget.toUserList);
      _composeBloc.toUsersListStreamSink.add(_composeBloc.toUsersList);
    }
    if (widget.ccUserList != null) {
      setState(() {
        _composeBloc.isCCBCCOpen = true;
      });
      print('~~~ ccUserList: ${widget.ccUserList.length}');
      _composeBloc.ccUsersList = []..addAll(widget.ccUserList);
      _composeBloc.ccUsersListStreamSink.add(_composeBloc.ccUsersList);
    }
    if (widget.bccUserList != null) {
      setState(() {
        _composeBloc.isCCBCCOpen = true;
      });
      print('~~~ bccUserList: ${widget.bccUserList.length}');
      _composeBloc.bccUsersList = []..addAll(widget.bccUserList);
      _composeBloc.bccUsersListStreamSink.add(_composeBloc.bccUsersList);
    }
    if (widget.attachmentList != null) {
      print('~~~ 1st ${widget.attachmentList.length}');
      if (widget.attachmentList.length > 0) {
        print('~~~ 2nd ${widget.attachmentList.length}');
        print('~~~ attachmentList: ${widget.attachmentList.length}');
        _composeBloc.attachmentList = []..addAll(widget.attachmentList);
        _composeBloc.attachmentStreamSink.add(_composeBloc.attachmentList);
      }
    }
    _composeBloc.subject = widget.subject;
    print('~~~ 0th subject: ${_composeBloc.subject}');

    if (_composeBloc.subject.contains('Re:  ')) {
      _composeBloc.subject = _composeBloc.subject.replaceAll('Re:  ', '');
    } else if (_composeBloc.subject.contains('Fwd:  ')) {
      _composeBloc.subject = _composeBloc.subject.replaceAll('Fwd:  ', '');
    }
    print(
        '~~~ bool: ${!_composeBloc.subject.contains('Re:  ')} ${!_composeBloc.subject.contains('Fwd:  ')}');

    _composeBloc.subject =
        '${(widget.previousAction == 'Reply' || widget.previousAction == 'Reply all') ? 'Re: ' : widget.previousAction == 'Forward' ? 'Fwd: ' : ''} ${_composeBloc.subject}';

    print('~~~ 1st subject: ${_composeBloc.subject}');
    _subjectTextEditingController.text = _composeBloc.subject;
    _composeBloc.subjectStreamSink.add(_composeBloc.subject);
    print('~~~ 2nd subject: ${_composeBloc.subject}');
  }

  @override
  void initState() {
    super.initState();
    _subjectTextEditingController.text = '';
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);

    _composeBloc = ComposeBloc(
        context, widget.draftId, widget.htmlCode, widget.previousAction);
    print('~~~ 1st initState');
    Future.delayed(Duration.zero, () async {
      if (widget.previousAction == 'Draft') {
        _subjectTextEditingController.text =
            await _composeBloc.getDraftDetails(widget.conversationId);
        print('~~~ 2nd initState');
        if (_composeBloc.isCCBCCOpen) {
          setState(() {
            _composeBloc.isCCBCCOpen = true;
            _composeBloc.areCCVisible = true;
            _composeBloc.areBCCVisible = true;
          });
        }
      } else if (widget.previousAction != 'Compose') {
        _getPreviousScreenDetails();
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('~~~ _scrollController');
        _composeBloc.attachmentStreamSink.add(_composeBloc.attachmentList);
      }
    });
  }

  void dispose() {
    super.dispose();
    _composeBloc.dispose();
    _toTextEditingController.dispose();
    _ccTextEditingController.dispose();
    _bccTextEditingController.dispose();
    _subjectTextEditingController.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_composeBloc.toUsersList.length > 0 ||
        _composeBloc.ccUsersList.length > 0 ||
        _composeBloc.bccUsersList.length > 0) {
      print('~~~ 1st _onWillPop');
      _composeBloc.saveInDrafts(widget.draftId,
          _subjectTextEditingController.text, _composeBloc.htmlCode);
    }
    _navigationActions.closeDialog();
    return false;
  }

  AutoCompleteTextField searchTextField;

  void _openFileExplorer() async {
    try {
      if (_pickingType != FileType.CUSTOM || _hasValidMime) {
        try {
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
//        _allPathsLinkedHashMap.addAll(_paths);
//          _composeBloc.getUploadSignedUrl(_paths);
          _composeBloc.getUploadSignedUrl(
              _paths.keys.toList()[0], _paths.values.toList()[0]);
          print(
              '~~~ paths: keys: ${_paths.keys.toList()}  values: ${_paths.values.toList()}');
          print('~~~ ${_paths}');
        } on PlatformException catch (e) {
          print("Unsupported operation" + e.toString());
        }
        if (!mounted) return;
      }
    } on PlatformException catch (e) {
      print('~~~ _openFileExplorer: $e');
    }
  }

  void _toVerification(String value) async {
    if (_validatorTextField.validateTextField(
        _validatorTextField.emailPattern, value)) {
      print('~~~ 1st value: $value');

      bool _userNotIncluded = true;
      for (User user in _composeBloc.toUsersList) {
        if (user.address == value) {
          _userNotIncluded = false;
        }
      }
      print('~~~ 2nd _userNotIncluded: $_userNotIncluded');
      if (_userNotIncluded) {
        _composeBloc.toUsersList.add(User(address: value));
        _composeBloc.toUsersListStreamSink.add(_composeBloc.toUsersList);
      }
      _toTextEditingController.text = '';
    } else {
      print('~~~ 2nd value: $value');
    }
  }

  void _ccVerification(String value) async {
    if (_validatorTextField.validateTextField(
        _validatorTextField.emailPattern, value)) {
      print('~~~ 1st value: $value');
      bool _userNotIncluded = true;
      for (User user in _composeBloc.ccUsersList) {
        if (user.address == value) {
          _userNotIncluded = false;
        }
      }
      if (_userNotIncluded) {
        _composeBloc.ccUsersList.add(User(address: value));
        _composeBloc.ccUsersListStreamSink.add(_composeBloc.ccUsersList);
      }
      _ccTextEditingController.text = '';
    } else {
      print('~~~ 2nd value: $value');
    }
  }

  void _bccVerification(String value) async {
    if (_validatorTextField.validateTextField(
        _validatorTextField.emailPattern, value)) {
      bool _userNotIncluded = true;
      for (User user in _composeBloc.bccUsersList) {
        if (user.address == value) {
          _userNotIncluded = false;
        }
      }
      if (_userNotIncluded) {
        print('~~~ 1st value: $value');

        _composeBloc.bccUsersList.add(User(address: value));
        _composeBloc.bccUsersListStreamSink.add(_composeBloc.bccUsersList);
      }
      _bccTextEditingController.text = '';
    } else {
      print('~~~ 2nd value: $value');
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _navigationActions.closeDialog();
                }),
            title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      // margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                    widget.previousAction,
                  )),
                  GestureDetector(
                    child: Text(
                      widget.previousAction == 'Reply' ||
                              widget.previousAction == 'Reply all'
                          ? widget.fromUser.address
                          : '${Connect.currentUser.username}@mesbro.com',
                      style: TextStyle(
                          fontSize: 13.0, fontWeight: FontWeight.w300),
                    ),
                    onTap: () {
                      print("tapped subtitle");
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => FilePickerDemo()),
                      // );
                    },
                  )
                ]),
            centerTitle: false,
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.camera),
                  onPressed: () {
                    _composeBloc.takePicture();
                  }),
              IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    _openFileExplorer();
                  }),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    print('~~~ currentUrl: ${_webViewController.currentUrl()}');
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    if (_composeBloc.toUsersList.length > 0 ||
                        _composeBloc.ccUsersList.length > 0 ||
                        _composeBloc.bccUsersList.length > 0) {
                      _composeBloc.sendBodyMessage(
                        _subjectTextEditingController.text,
                        _composeBloc.htmlCode,
                        widget.previousAction,
                        widget.conversationId,
                      );
                    } else {
                      _widgetsCollection
                          .showToastMessage('Select atleast 1 receipent');
                    }
                  }),
            ],
          ),
          body: Scaffold(
              body: Container(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                // List of To strat
                Container(
                  margin: EdgeInsets.only(left: 5.0, right: 7.0),
                  child: Row(children: <Widget>[
                    Expanded(
                        child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        StreamBuilder(
                          stream: _composeBloc.toUsersListStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<User>> asyncSnapshot) {
                            print(
                                '~~~ stream: ${asyncSnapshot.data == null ? 'none' : '${asyncSnapshot.data.length}'}');
                            // _composeBloc.toUsersListStreamSink.add(_composeBloc.toUsersList);
                            return asyncSnapshot.data == null
                                ? Container(
                                    width: 0.0,
                                    height: 0.0,
                                  )
                                : _composeBloc.areToVisible
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: asyncSnapshot.data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                              onTap: () {
                                                _composeBloc.toUsersList
                                                    .removeAt(index);
                                                _composeBloc
                                                    .toUsersListStreamSink
                                                    .add(_composeBloc
                                                        .toUsersList);
                                              },
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 5.0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        asyncSnapshot.data
                                                                    .length ==
                                                                0
                                                            ? Container(
                                                                width: 0.0,
                                                                height: 0.0,
                                                              )
                                                            : ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                                child: Container(
                                                                    padding: EdgeInsets.only(
                                                                        left:
                                                                            10.0,
                                                                        right:
                                                                            10.0,
                                                                        top:
                                                                            5.0,
                                                                        bottom:
                                                                            5.0),
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.3),
                                                                    child: Text(asyncSnapshot
                                                                        .data[index]
                                                                        .address)))
                                                      ])));
                                        },
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          Future.delayed(Duration.zero, () {
                                            setState(() {
                                              _ccVerification(
                                                  _ccTextEditingController
                                                      .text);
                                              _bccVerification(
                                                  _bccTextEditingController
                                                      .text);
                                              _composeBloc.areToVisible = true;
                                              _composeBloc.areCCVisible = false;
                                              _composeBloc.areBCCVisible =
                                                  false;
                                            });
                                          });
                                        },
                                        child: Container(
                                            margin:
                                                EdgeInsets.only(bottom: 5.0),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  asyncSnapshot.data.length == 0
                                                      ? Container(
                                                          width: 0.0,
                                                          height: 0.0,
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                          child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0,
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5.0),
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.3),
                                                              child: Text(
                                                                  asyncSnapshot
                                                                      .data[0]
                                                                      .address))),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Text(
                                                      asyncSnapshot
                                                                  .data.length <
                                                              2
                                                          ? ''
                                                          : '+${asyncSnapshot.data.length - 1}',
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  )
                                                ])));
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'To',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                fontFamily: 'Poppins'),
                          ),
                          controller: _toTextEditingController,
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              setState(() {
                                _contactListDetails = ContactListDetails(
                                    _composeBloc.toUsersList);
                                _toVerification(_toTextEditingController.text);
                                _ccVerification(_ccTextEditingController.text);
                                _composeBloc.areToVisible = true;
                                _composeBloc.areCCVisible = false;
                                _composeBloc.areBCCVisible = false;
                              });
                            });
                          },
                          onChanged: (String value) async {
                            if (value == '') {
                              _composeBloc.toUsersSuggestionsList =
                                  List<User>();
                            }
                            _composeBloc.toUsersSuggestionsList =
                                await _contactListDetails.getSuggestions(value);
                            _composeBloc.toUsersSuggestionsListStreamSink
                                .add(_composeBloc.toUsersSuggestionsList);
                          },
                          onSubmitted: (String value) {
                            _toVerification(value);
                          },
                        ),
                        StreamBuilder(
                          stream: _composeBloc.toUsersSuggestionsListStream,
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
                                    : Card(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                asyncSnapshot.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                  title: Text(asyncSnapshot
                                                      .data[index].name),
                                                  onTap: () {
                                                    _toTextEditingController
                                                        .text = '';

                                                    _composeBloc.toUsersList
                                                        .add(asyncSnapshot
                                                            .data[index]);
                                                    _composeBloc
                                                        .toUsersListStreamSink
                                                        .add(_composeBloc
                                                            .toUsersList);

                                                    _composeBloc
                                                            .toUsersSuggestionsList =
                                                        List<User>();
                                                    _composeBloc
                                                        .toUsersSuggestionsListStreamSink
                                                        .add(_composeBloc
                                                            .toUsersSuggestionsList);
                                                  });
                                            }));
                          },
                        )
                      ],
                    ))
                  ]),
                ),
                // list of To stop
                SizedBox(
                  height: 10.0,
                ),

                // CC/BCC start
                _composeBloc.isCCBCCOpen
                    ? Column(
                        children: <Widget>[
                          // CC start
                          Container(
                            margin: EdgeInsets.only(left: 5.0, right: 7.0),
                            child: Row(children: <Widget>[
                              Expanded(
                                  child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: _composeBloc.ccUsersListStream,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<User>>
                                            asyncSnapshot) {
                                      print(
                                          '~~~ stream: ${asyncSnapshot.data == null ? 'none' : '${asyncSnapshot.data.length}'}');
                                      // _composeBloc.ccUsersListStreamSink
                                      //     .add(_composeBloc.ccUsersList);
                                      return asyncSnapshot.data == null
                                          ? Container(
                                              width: 0.0,
                                              height: 0.0,
                                            )
                                          : _composeBloc.areCCVisible
                                              ? ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      asyncSnapshot.data.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          _composeBloc
                                                              .ccUsersList
                                                              .removeAt(index);
                                                          _composeBloc
                                                              .ccUsersListStreamSink
                                                              .add(_composeBloc
                                                                  .ccUsersList);
                                                        },
                                                        child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        5.0),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  asyncSnapshot
                                                                              .data
                                                                              .length ==
                                                                          0
                                                                      ? Container(
                                                                          width:
                                                                              0.0,
                                                                          height:
                                                                              0.0,
                                                                        )
                                                                      : ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20.0),
                                                                          child:
                                                                              Container(
                                                                            padding: EdgeInsets.only(
                                                                                left: 10.0,
                                                                                right: 10.0,
                                                                                top: 5.0,
                                                                                bottom: 5.0),
                                                                            color:
                                                                                Colors.grey.withOpacity(0.3),
                                                                            child:
                                                                                Text(asyncSnapshot.data[index].address),
                                                                                
                                                                          ),
                                                                          
                                                                        )
                                                                ])));
                                                  },
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    Future.delayed(
                                                        Duration.zero, () {
                                                      setState(() {
                                                        _composeBloc
                                                                .areToVisible =
                                                            false;
                                                        _composeBloc
                                                                .areCCVisible =
                                                            true;
                                                        _composeBloc
                                                                .areBCCVisible =
                                                            false;
                                                      });
                                                    });
                                                  },
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 5.0),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            asyncSnapshot.data
                                                                        .length ==
                                                                    0
                                                                ? Container(
                                                                    width: 0.0,
                                                                    height: 0.0,
                                                                  )
                                                                : ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                    child:
                                                                        Container(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              10.0,
                                                                          right:
                                                                              10.0,
                                                                          top:
                                                                              5.0,
                                                                          bottom:
                                                                              5.0),
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3),
                                                                      child:
                                                                          Text(
                                                                        asyncSnapshot
                                                                            .data[0]
                                                                            .address,
                                                                      ),
                                                                    ),
                                                                  ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4.0),
                                                              child: Text(
                                                                  asyncSnapshot
                                                                              .data
                                                                              .length <
                                                                          2
                                                                      ? ''
                                                                      : '+${asyncSnapshot.data.length - 1}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15)),
                                                            ),
                                                          ])));
                                    },
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                        hintText: 'Cc',
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.0,
                                            fontFamily: 'Poppins')),
                                    controller: _ccTextEditingController,
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        setState(() {
                                          _contactListDetails =
                                              ContactListDetails(
                                                  _composeBloc.ccUsersList);
                                          _toVerification(
                                              _toTextEditingController.text);
                                          _bccVerification(
                                              _bccTextEditingController.text);
                                          _composeBloc.areToVisible = false;
                                          _composeBloc.areCCVisible = true;
                                          _composeBloc.areBCCVisible = false;
                                        });
                                      });
                                    },
                                    onChanged: (String value) async {
                                      if (value == '') {
                                        _composeBloc.ccUsersSuggestionsList =
                                            List<User>();
                                      }
                                      _composeBloc.ccUsersSuggestionsList =
                                          await _contactListDetails
                                              .getSuggestions(value);
                                      _composeBloc
                                          .ccUsersSuggestionsListStreamSink
                                          .add(_composeBloc
                                              .ccUsersSuggestionsList);
                                      Future.delayed(Duration.zero, () {
                                        setState(() {
                                          _composeBloc.areToVisible = false;
                                          _composeBloc.areCCVisible = true;
                                          _composeBloc.areBCCVisible = false;
                                        });
                                      });
                                    },
                                    onSubmitted: (String value) {
                                      _ccVerification(value);
                                    },
                                  ),
                                  StreamBuilder(
                                    stream: _composeBloc
                                        .ccUsersSuggestionsListStream,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<User>>
                                            asyncSnapshot) {
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
                                              : Card(
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: asyncSnapshot
                                                          .data.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return ListTile(
                                                            title: Text(
                                                                asyncSnapshot
                                                                    .data[index]
                                                                    .name),
                                                            onTap: () {
                                                              _ccTextEditingController
                                                                  .text = '';

                                                              _composeBloc
                                                                  .ccUsersList
                                                                  .add(asyncSnapshot
                                                                          .data[
                                                                      index]);
                                                              _composeBloc
                                                                  .ccUsersListStreamSink
                                                                  .add(_composeBloc
                                                                      .ccUsersList);

                                                              _composeBloc
                                                                      .ccUsersSuggestionsList =
                                                                  List<User>();
                                                              _composeBloc
                                                                  .ccUsersSuggestionsListStreamSink
                                                                  .add(_composeBloc
                                                                      .ccUsersSuggestionsList);
                                                            });
                                                      }));
                                    },
                                  ),
                                ],
                              ))
                            ]),
                          ),
                          // CC end
                          SizedBox(
                            height: 10.0,
                          ),
                          // BCC start
                          Container(
                            margin: EdgeInsets.only(left: 5.0, right: 7.0),
                            child: Row(children: <Widget>[
                              Expanded(
                                  child: ListView(
                                shrinkWrap: true,
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: _composeBloc.bccUsersListStream,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<User>>
                                            asyncSnapshot) {
                                      _composeBloc.bccUsersListStreamSink
                                          .add(_composeBloc.bccUsersList);
                                      return asyncSnapshot.data == null
                                          ? Container(
                                              width: 0.0,
                                              height: 0.0,
                                            )
                                          : _composeBloc.areBCCVisible
                                              ? ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      asyncSnapshot.data.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          _composeBloc
                                                              .bccUsersList
                                                              .removeAt(index);
                                                          _composeBloc
                                                              .bccUsersListStreamSink
                                                              .add(_composeBloc
                                                                  .bccUsersList);
                                                        },
                                                        child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        5.0),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  asyncSnapshot
                                                                              .data
                                                                              .length ==
                                                                          0
                                                                      ? Container(
                                                                          width:
                                                                              0.0,
                                                                          height:
                                                                              0.0,
                                                                        )
                                                                      : ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                              20.0),
                                                                          child: Container(
                                                                              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                                                                              color: Colors.grey.withOpacity(0.3),
                                                                              child: Text(asyncSnapshot.data[index].address)))
                                                                ])));
                                                  },
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    Future.delayed(
                                                        Duration.zero, () {
                                                      setState(() {
                                                        _composeBloc
                                                                .areToVisible =
                                                            false;
                                                        _composeBloc
                                                                .areCCVisible =
                                                            false;
                                                        _composeBloc
                                                                .areBCCVisible =
                                                            true;
                                                      });
                                                    });
                                                  },
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 5.0),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  asyncSnapshot
                                                                              .data
                                                                              .length ==
                                                                          0
                                                                      ? Container(
                                                                          width:
                                                                              0.0,
                                                                          height:
                                                                              0.0,
                                                                        )
                                                                      : ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                              20.0),
                                                                          child: Container(
                                                                              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                                                                              color: Colors.grey.withOpacity(0.3),
                                                                              child: Text(asyncSnapshot.data[0].address)))
                                                                ]),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4.0),
                                                              child: Text(
                                                                  asyncSnapshot
                                                                              .data
                                                                              .length <
                                                                          2
                                                                      ? ''
                                                                      : '+${asyncSnapshot.data.length - 1}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15)),
                                                            )
                                                          ])));
                                    },
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                        hintText: 'Bcc',
                                        hintStyle: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400)),
                                    controller: _bccTextEditingController,
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        setState(() {
                                          _contactListDetails =
                                              ContactListDetails(
                                                  _composeBloc.bccUsersList);
                                          _toVerification(
                                              _toTextEditingController.text);
                                          _ccVerification(
                                              _ccTextEditingController.text);
                                          _composeBloc.areToVisible = false;
                                          _composeBloc.areCCVisible = false;
                                          _composeBloc.areBCCVisible = true;
                                        });
                                      });
                                    },
                                    onChanged: (String value) async {
                                      if (value == '') {
                                        _composeBloc.bccUsersSuggestionsList =
                                            List<User>();
                                      }
                                      _composeBloc.bccUsersSuggestionsList =
                                          await _contactListDetails
                                              .getSuggestions(value);
                                      _composeBloc
                                          .bccUsersSuggestionsListStreamSink
                                          .add(_composeBloc
                                              .bccUsersSuggestionsList);
                                    },
                                    onSubmitted: (String value) {
                                      _bccVerification(value);
                                    },
                                  ),
                                  StreamBuilder(
                                    stream: _composeBloc
                                        .bccUsersSuggestionsListStream,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<User>>
                                            asyncSnapshot) {
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
                                              : Card(
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: asyncSnapshot
                                                          .data.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return ListTile(
                                                            title: Text(
                                                                asyncSnapshot
                                                                    .data[index]
                                                                    .name),
                                                            onTap: () {
                                                              _bccTextEditingController
                                                                  .text = '';

                                                              _composeBloc
                                                                  .bccUsersList
                                                                  .add(asyncSnapshot
                                                                          .data[
                                                                      index]);
                                                              _composeBloc
                                                                  .bccUsersListStreamSink
                                                                  .add(_composeBloc
                                                                      .bccUsersList);

                                                              _composeBloc
                                                                      .bccUsersSuggestionsList =
                                                                  List<User>();
                                                              _composeBloc
                                                                  .bccUsersSuggestionsListStreamSink
                                                                  .add(_composeBloc
                                                                      .bccUsersSuggestionsList);
                                                            });
                                                      }));
                                    },
                                  ),
                                ],
                              ))
                            ]),
                          ),
                          // BCC ends
                        ],
                      )
                    // CC /BCC ends
                    : Container(
                        margin: EdgeInsets.only(left: 5.0, right: 7.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: TextField(
                                    decoration: InputDecoration(
                                        hintText: 'Cc/Bcc',
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.0)),
                                    onTap: () {
                                      setState(() {
                                        _composeBloc.isCCBCCOpen = true;
                                        print(
                                            '~~~ _composeBloc.isCCBCCOpen: $_composeBloc.isCCBCCOpen');
                                      });
                                    })),
                          ],
                        )),
                SizedBox(
                  height: 10.0,
                ),
                widget.previousAction == 'Reply' ||
                        widget.previousAction == 'Reply all' ||
                        widget.previousAction == 'Forward'
                    ? Container(
                        width: 0.0,
                        height: 0.0,
                      )

                    // subject Strat
                    : Container(
                        margin: EdgeInsets.only(left: 5.0, right: 7.0),
                        child: Row(
                          children: <Widget>[
                            // Container(
                            //     margin: EdgeInsets.only(right: 10.0),
                            //     child: Text(
                            //       'Subject',
                            //       style: TextStyle(
                            //           color: Colors.grey, fontSize: 15.0),
                            //     )),
                            Expanded(
                                child: TextField(
                                    decoration: InputDecoration(
                                        hintText: 'Subject',
                                        hintStyle: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400)),
                                    controller: _subjectTextEditingController,
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        setState(() {
                                          _composeBloc.areBCCVisible = false;
                                          _composeBloc.areCCVisible = false;
                                          _composeBloc.areToVisible = false;
                                        });
                                      });
                                      _toVerification(
                                          _toTextEditingController.text);
                                      _ccVerification(
                                          _ccTextEditingController.text);
                                      _bccVerification(
                                          _bccTextEditingController.text);
                                    }))
                          ],
                        )),
                // subject end
                Container(
                  margin: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                          height: 400.0,
                          margin: EdgeInsets.only(top: 50.0),
                          child: WebView(
                              initialUrl: _htmlFilePath,
                              javascriptMode: JavascriptMode.unrestricted,
                              javascriptChannels: Set.from([
                                _toasterJavascriptChannel(context),
                                customImageChannel(context),
                                ckEditorReadyChannel(context),
                                ckContentUpdate(context)
                              ]),
                              onWebViewCreated:
                                  (WebViewController webViewController) {
                                _webViewController = webViewController;
                                _loadHtmlFromAssets();
                              })),
                    ],
                  ),
                ),
                StreamBuilder(
                    stream: _composeBloc.attachmentListStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Attachment>> asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container(
                              margin: EdgeInsets.only(top: 0.0),
                              width: 0.0,
                              height: 0.0,
                            )
                          : asyncSnapshot.data.length == 0
                              ? Container(
                                  margin: EdgeInsets.only(top: 0.0),
                                  width: 0.0,
                                  height: 0.0,
                                )
                              : Container(
                                  margin: EdgeInsets.only(top: 0.0),
                                  child: ListView.separated(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: asyncSnapshot.data.length,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Divider();
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        print('~~~ compose: $_fileType');
                                        _fileType = asyncSnapshot
                                            .data[index].contentType;
                                        _fileTypeIconData = _fileType == null
                                            ? FontAwesomeIcons.file
                                            : _fileType.contains('image')
                                                ? FontAwesomeIcons.fileImage
                                                : _fileType.contains('pdf')
                                                    ? FontAwesomeIcons.filePdf
                                                    : _fileType.contains('doc')
                                                        ? FontAwesomeIcons
                                                            .fileWord
                                                        : _fileType.contains(
                                                                'video')
                                                            ? FontAwesomeIcons
                                                                .video
                                                            : FontAwesomeIcons
                                                                .file;
                                        print('~~~ type: $_fileType');

                                        return Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              margin:
                                                  EdgeInsets.only(left: 5.0),
                                              child: asyncSnapshot
                                                          .data[index].type ==
                                                      ''
                                                  ? CircularProgressIndicator()
                                                  : Icon(_fileTypeIconData),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    asyncSnapshot
                                                                .data[index]
                                                                .fileName
                                                                .length >
                                                            25
                                                        ? '${asyncSnapshot.data[index].fileName.substring(0, 25)}...'
                                                        : asyncSnapshot
                                                            .data[index]
                                                            .fileName,
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                Text(
                                                  asyncSnapshot.data[index]
                                                              .fileSize ==
                                                          null
                                                      ? ''
                                                      : _fileCategoryDetails
                                                          .formatBytes(
                                                              asyncSnapshot
                                                                  .data[index]
                                                                  .fileSize),
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                                icon: Icon(Icons.clear,
                                                    size: 18.0),
                                                onPressed: () {
                                                  _composeBloc.attachmentList
                                                      .removeAt(index);
                                                  _composeBloc
                                                      .attachmentStreamSink
                                                      .add(_composeBloc
                                                          .attachmentList);
                                                }),
                                          ],
                                        ));
                                      }));
                    }),
                StreamBuilder(
                  stream: _composeBloc.composeFinishedStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(width: 0.0, height: 0.0)
                        : asyncSnapshot.data.length == 0
                            ? Container(width: 0.0, height: 0.0)
                            : _composeFinished(asyncSnapshot.data);
                  },
                ),
                StreamBuilder(
                  stream: _composeBloc.draftSentFinishedStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(width: 0.0, height: 0.0)
                        : asyncSnapshot.data.length == 0
                            ? Container(width: 0.0, height: 0.0)
                            : _draftSentFinished(asyncSnapshot.data);
                  },
                ),
                StreamBuilder(
                  stream: _composeBloc.replyForwardFinishedStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(width: 0.0, height: 0.0)
                        : asyncSnapshot.data.length == 0
                            ? Container(width: 0.0, height: 0.0)
                            : _replyForwardFinished(asyncSnapshot.data);
                  },
                ),
                StreamBuilder(
                  stream: _composeBloc.bodyStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<String> asyncSnapshot) {
                    return asyncSnapshot.data == null
                        ? Container(width: 0.0, height: 0.0)
                        : asyncSnapshot.data.length == 0
                            ? Container(width: 0.0, height: 0.0)
                            : _messageLoadingFinished(asyncSnapshot.data);
                  },
                ),
              ],
            ),
          )),
        ));
  }

  _loadHtmlFromAssets() async {
    _webViewController.loadUrl(_htmlFilePath);
//    Future.delayed(Duration(seconds: 10), ()  {
//      print('~~~ _loadHtmlFromAssets: $htmlCode');
//
//      String newFile = "insertContent('"+htmlCode+"')";
//      _webViewController.evaluateJavascript(newFile);
//    });
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  JavascriptChannel ckEditorReadyChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'CkEditorReady',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);

          // on ck editor ready
          String newFile = 'insertContent(`' + _composeBloc.htmlCode + '`)';
          _webViewController.evaluateJavascript(newFile);
        });
  }

  JavascriptChannel ckContentUpdate(BuildContext context) {
    return JavascriptChannel(
        name: 'CkContentUpdate',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
          _composeBloc.htmlCode = message.message;
          print('~~~ CkContentUpdate: ${message.message}');
          // ck editor content
        });
  }

  JavascriptChannel customImageChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'CkImage',
        onMessageReceived: (JavascriptMessage message) async {
          print('~~~ message: ${message.message}');

          // 1. Open file manager
          // 2. select file (single, only image)
          // 3. get signed url
          // 4. upload to s3
          // 5. confirm the file
          // 6. get final url
          // 7. post full file url(with domain) to js as following:
          _webViewController.evaluateJavascript(_composeBloc.htmlCode);
          if (message.message == 'select') {
            String test, newFile;
            test = "http://files.mesbro.com/icons/mesbro-logo.png";
            test = await _composeBloc.appendImage();
            newFile = "insertImage('" + test + "')"; // url goes here
            print('~~~ newFile: $newFile');
            _webViewController.evaluateJavascript(newFile);
          }
        });
  }

  Function modifyJS(String data) {
    print('~~~ modifyJS: $data');
    _webViewController.evaluateJavascript(data);
  }

  Widget _composeFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      if (mapResponse['code'] == 200) {
        _widgetsCollection.showToastMessage(mapResponse['content']);
        _navigationActions.closeDialog();
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container(width: 0.0, height: 0.0);
  }

  Widget _draftSentFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      if (mapResponse['code'] == 200) {
        _widgetsCollection.showToastMessage(mapResponse['content']);
        _navigationActions.closeDialog();
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container(width: 0.0, height: 0.0);
  }

  Widget _replyForwardFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      if (mapResponse['code'] == 200) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
        _navigationActions.closeDialog();
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container(width: 0.0, height: 0.0);
  }

  Widget _messageLoadingFinished(String data) {
    Future.delayed(Duration.zero, () {
      _composeBloc.htmlCode = data;
    });
    return Container(width: 0.0, height: 0.0);
  }
}
