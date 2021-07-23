import 'package:flutter/material.dart';
import 'package:mail/bloc_patterns/mails/thread_mail_bloc.dart';
import 'package:mail/models/email.dart';
import 'package:mail/screens/mails/view_single_mail_page.dart';

class ThreadMailPage extends StatefulWidget {
  final String conversationId, type, subject;

  ThreadMailPage({this.conversationId, this.type, this.subject});

  _ThreadMailPageState createState() => _ThreadMailPageState();
}

class _ThreadMailPageState extends State<ThreadMailPage> {
  ThreadMailBloc _threadMailBloc;

  void initState() {
    super.initState();
    _threadMailBloc = ThreadMailBloc(context, widget.conversationId, widget.type);
    _threadMailBloc.markAsRead('inbox');
    Future.delayed(Duration.zero, () {
      _threadMailBloc.getThreadMessages();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          title: StreamBuilder(
              stream: _threadMailBloc.subjectStream,
              builder:
              (BuildContext context, AsyncSnapshot<String> asyncSnapshot) {
            return Text(
                asyncSnapshot.data == null
                    ? widget.subject
                    : asyncSnapshot.data,
                style: TextStyle(fontSize: 16.0));
          })),
      body: Container(
        child: StreamBuilder(
            stream: _threadMailBloc.emailStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<Email>> asyncSnapshot) {
              return asyncSnapshot.data == null
                  ? Center(child: Text('Loading ...'))
                  : asyncSnapshot.data.length == 0
                      ? Center(
                          child: Text('Loading ...',
                              style: TextStyle(fontSize: 22.0)))
                      : ListView.separated(
                          itemCount: asyncSnapshot.data.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return ViewSingleMailPage(
                                email: asyncSnapshot.data[index]);
                          });
            }),
      ),
    );
  }
}
