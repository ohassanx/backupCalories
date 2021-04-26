import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/models/activity.dart';
import 'package:audio_fit/screens/activity_diary_screen/activity_list.dart';

import 'package:audio_fit/services/auth.dart';
import 'package:audio_fit/services/database.dart';

import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';

import 'activity_form.dart';

class ActivityDiary extends StatefulWidget {
  @override
  _ActivityDiaryState createState() => _ActivityDiaryState();
}

class _ActivityDiaryState extends State<ActivityDiary> {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = "";
  bool loading = true;

  void initState() {
    super.initState();
    getUid();
    updateBoolean();
  }

  Future<String> getUid() async {
    final User user = auth.currentUser;
    final id = user.uid;
    setState(() {
      userId = id;
    });
    return id;
  }

  updateBoolean() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        loading = false;
      });
    });
  }

  renderActivityForm(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityForm(action: 'Log'),
        ));
    if (result.isNotEmpty) {
      setState(() {
        showSnackBar();
      });
    }
  }

  showSnackBar() {
    return Flushbar(
      duration: Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      title: 'Success',
      message: "Your activity was successfully logged!",
    )..show(context);
  }

  void addItem(BuildContext context) {
    renderActivityForm(context);
  }

  Widget build(BuildContext context) {
    return StreamProvider<List<Activity>>.value(
      value: DatabaseService(id: userId).activities,
      initialData: [],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            height: 1000,
            child: Center(
              child: Column(children: [
                Padding(padding: EdgeInsets.only(top: 30.0)),
                ActivityList(),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      addItem(context);
                      //addItem(context);
                    },
                    child: Text("Add Item"),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
