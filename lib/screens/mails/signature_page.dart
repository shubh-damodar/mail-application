import 'package:flutter/material.dart';
import 'package:mail/bloc_patterns/mails/signature_bloc.dart';
import 'package:mail/utils/navigation_actions.dart';
import 'package:mail/utils/widgets_collection.dart';

class SignaturePage extends StatefulWidget {
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  SignatureBloc _signatureBloc;
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  TextEditingController _composeTextEditingController = TextEditingController(),
      _replyTextEditingController = TextEditingController(),
      _forwardTextEditingController = TextEditingController();

  void initState() {
    super.initState();
    _signatureBloc = SignatureBloc(context);
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _signatureBloc.dispose();
    _composeTextEditingController.dispose();
    _replyTextEditingController.dispose();
    _forwardTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Signature",
            style: TextStyle(),
          ),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Form(
            child: ListView(
              children: <Widget>[
                Container(
                  child: Text(
                    'While Compose',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: StreamBuilder(
                      stream: _signatureBloc.composeStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> asyncSnapshot) {
                        _composeTextEditingController.value =
                            _composeTextEditingController.value
                                .copyWith(text: asyncSnapshot.data);
                        return TextField(
                            controller: _composeTextEditingController,
                            maxLength: null,
                            maxLines: null,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'While Compose'));
                      }),
                ),
                Container(
                  child: Text(
                    'While Reply',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: StreamBuilder(
                        stream: _signatureBloc.replyStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> asyncSnapshot) {
                          _replyTextEditingController.value =
                              _replyTextEditingController.value
                                  .copyWith(text: asyncSnapshot.data);
                          return TextField(
                              controller: _replyTextEditingController,
                              maxLength: null,
                              maxLines: null,
                              decoration: InputDecoration(

                                  border: OutlineInputBorder(),
                                  hintText: 'While Reply'));
                        })),
                Container(
                  child: Text(
                    'While Forward',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: StreamBuilder(
                        stream: _signatureBloc.forwardStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> asyncSnapshot) {
                          _forwardTextEditingController.value =
                              _forwardTextEditingController.value
                                  .copyWith(text: asyncSnapshot.data);
                          return TextField(
                              controller: _forwardTextEditingController,
                              maxLength: null,
                              maxLines: null,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'While Forward'));
                        })),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    color: Colors.mesbroBlue,
                    child: Text(
                      'Save Profile',
                      style:
                          TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _signatureBloc.saveSignature(
                          _composeTextEditingController.text,
                          _replyTextEditingController.text,
                          _forwardTextEditingController.text);
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
