import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/screens/home/settings_widgets.dart';
import 'package:audio_fit/shared/loading.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    print(id);
    return id;
  }

  updateBoolean() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        loading = false;
      });
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
        child: Text("Confirm"),
        onPressed: () {
          //SettingsWidgets().pushChangesToDatabase();
          setState(() {});
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/second",
            (r) => false,
          );
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please confirm"),
      content: Text("Would you like to save your changes?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc(userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          var country, age, weight, intakeTarget, outputTarget;
          if (snapshot.hasData) {
            country = snapshot.data['country'];
            age = snapshot.data['age'].toDouble();
            weight = snapshot.data['weight'].toDouble();
            intakeTarget = snapshot.data['kcalIntakeTarget'].toDouble();
            outputTarget = snapshot.data['kcalOutputTarget'].toDouble();
          } else {
            country = '';
            age = 0.0;
            weight = 0.0;
          }
          if (loading) {
            return Loading();
          } else {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/second', (r) => false)),
                title: Text('Settings'),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: SettingsWidgets(
                    country: country,
                    age: age,
                    weight: weight,
                    intakeTarget: intakeTarget,
                    outputTarget: outputTarget),
                //country: country, age: age, weight: weight),
              ),
            );
          }
        });
  }
}
