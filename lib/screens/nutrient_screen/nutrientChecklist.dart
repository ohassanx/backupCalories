import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/models/logged_nutrient.dart';
import 'package:audio_fit/models/nutrient.dart';
import 'package:audio_fit/screens/nutrient_screen/nutrient_list.dart';
import 'package:audio_fit/services/database.dart';
import 'package:provider/provider.dart';

class NutrientChecklist extends StatefulWidget {
  @override
  _NutrientChecklistState createState() => _NutrientChecklistState();
}

class _NutrientChecklistState extends State<NutrientChecklist> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var userId;

  void initState() {
    super.initState();
    getUid();
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

  Widget build(BuildContext context) {
    return StreamProvider<List<Nutrient>>.value(
      value: DatabaseService(id: userId).nutrientContent,
      initialData: [],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            height: 800,
            child: Center(
              child: Column(children: [
                Padding(padding: EdgeInsets.only(top: 30.0)),
                StreamProvider<List<LoggedNutrient>>.value(
                  value: DatabaseService(id: userId).getLoggedNutrients(),
                  initialData: [],
                  child: NutrientList(),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
