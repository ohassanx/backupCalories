import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/screens/progress_screen/calorie_count.dart';
import 'package:audio_fit/services/auth.dart';
import 'package:audio_fit/models/food.dart';
import 'package:audio_fit/services/database.dart';
import 'package:audio_fit/shared/loading.dart';
import 'package:provider/provider.dart';

class Progress extends StatefulWidget {
  @override
  _ProgressState createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = true;

  String userId = "";

  void initState() {
    super.initState();
    getUid();
    updateBoolean();
  }

  updateBoolean() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        loading = false;
      });
    });
  }

  Future<String> getUid() async {
    final User user = auth.currentUser;
    final id = user.uid;
    setState(() {
      userId = id;
    });
    return id;
  }

  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc(userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          var target;
          if (snapshot.hasData) {
            target = snapshot.data['kcalIntakeTarget'];
          } else {
            target = 2000;
          }
          return loading
              ? Loading()
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(padding: EdgeInsets.only(top: 15.0)),
                            Text(
                              "Calories Consumed",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            StreamProvider<List<Food>>.value(
                              value: DatabaseService(id: userId).allFoods,
                              initialData: [],
                              child: CalorieCount(calorieTarget: target),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(padding: EdgeInsets.only(top: 15.0)),
                            Text(
                              "Calories Burned",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            StreamProvider<List<Food>>.value(
                              value: DatabaseService(id: userId).allFoods,
                              initialData: [],
                              child: CalorieCount(calorieTarget: target),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        });
  }
}
