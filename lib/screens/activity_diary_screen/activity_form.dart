import 'package:cupertino_setting_control/cupertino_setting_control.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/models/activity.dart';
import 'package:audio_fit/services/database.dart';

class ActivityForm extends StatefulWidget {
  final String action;
  final Activity activity;

  ActivityForm({this.action, this.activity});
  @override
  _ActivityFormState createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  String activityType = 'Walking';
  double distance = 0;
  double duration = 0;
  double calories = 0;
  String distanceError = "";
  String durationError = "";
  String calorieError = "";
  String appBarAction = "";
  bool argsPassed = false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = "";

  void initState() {
    super.initState();
    getUid();
    if (widget.action == "Edit") {
      setState(() {
        argsPassed = true;
        activityType = widget.activity.activityType;
        distance = widget.activity.distance;
        duration = widget.activity.duration;
        calories = widget.activity.calories;
      });
    }
  }

  Future<String> getUid() async {
    final User user = auth.currentUser;
    final id = user.uid;
    setState(() {
      userId = id;
    });
    return id;
  }

  Future<String> getUserid() async {
    final User user = await auth.currentUser;
    final id = user.uid;
    return id;
  }

  void onSearchAreaChange(String data) {
    setState(() {
      activityType = data;
    });
  }

  void addActivity() async {
    String userId = await getUserid();
    DatabaseService(id: userId)
        .addActivity(activityType, distance, duration, calories);
  }

  updateActivity() async {
    String userId = await getUserid();
    DatabaseService(id: userId).updateActivity(
        widget.activity.docId, activityType, distance, duration, calories);
  }

  // void calculateCalories(){
  //   switch (activityType){
  //     case 'Walking': {
  //       break;
  //     }
  //     case 'Running': {
  //       break;
  //     }
  //     case 'Cycling': {
  //       break;
  //     }
  //     case 'Swimming': {
  //       break;
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: argsPassed
            ? Text("${widget.action} your activity")
            : Text("Log your activity"),
        actions: [
          TextButton(
            onPressed: () {
              if (distance == 0 || duration == 0 || calories == 0) {
                if (distance == 0) {
                  setState(() {
                    distanceError = "Please supply a distance.";
                  });
                }
                if (duration == 0) {
                  setState(() {
                    durationError = "Please supply a duration.";
                  });
                }
                if (calories == 0) {
                  setState(() {
                    calorieError = "Please enter the calories you burned.";
                  });
                }
              } else {
                if (widget.action == "Edit") {
                  updateActivity();
                } else {
                  addActivity();
                  Navigator.pop(context, "test");
                }
              }
            },
            child: Row(
              children: [
                Text(
                  "SAVE ",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                  size: 26.0,
                ),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      "What type of activity did you do?",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                  ),
                  SettingRow(
                    rowData: SettingsDropDownConfig(
                        title: 'Activity',
                        initialKey: activityType,
                        choices: {
                          'Walking': 'Walking',
                          'Running': 'Running',
                          'Cycling': 'Cycling',
                          'Swimming': 'Swimming',
                        }),
                    onSettingDataRowChange: onSearchAreaChange,
                    config: SettingsRowConfiguration(
                        showAsTextField: false,
                        // showTitleLeft: !_titleOnTop,
                        // showTopTitle: _titleOnTop,
                        showAsSingleSetting: false),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text(
                      "What distance did you do?",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                  ),
                  SettingRow(
                    rowData: SettingsSliderConfig(
                      title: 'Distance',
                      from: 0,
                      to: 100,
                      initialValue: distance,
                      justIntValues: true,
                      unit: ' km',
                    ),
                    onSettingDataRowChange: (double resultVal) {
                      setState(() {
                        distance = resultVal;
                      });
                    },
                    config: SettingsRowConfiguration(
                        showAsTextField: false,
                        // showTitleLeft: !_titleOnTop,
                        // showTopTitle: _titleOnTop,
                        showAsSingleSetting: false),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, top: 5.0),
                    child: Text(
                      distanceError,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                    child: Text(
                      "How long did it take you?",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                  ),
                  SettingRow(
                    rowData: SettingsSliderConfig(
                      title: 'Duration',
                      from: 0,
                      to: 120,
                      initialValue: duration,
                      justIntValues: true,
                      unit: ' minutes',
                    ),
                    onSettingDataRowChange: (double resultVal) {
                      setState(() {
                        duration = resultVal;
                      });
                    },
                    config: SettingsRowConfiguration(
                        showAsTextField: false,
                        // showTitleLeft: !_titleOnTop,
                        // showTopTitle: _titleOnTop,
                        showAsSingleSetting: false),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, top: 0.0),
                    child: Text(
                      durationError,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text(
                      "How many calories did you burn?",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                  ),
                  SettingRow(
                    rowData: SettingsSliderConfig(
                      title: 'Calories',
                      from: 0,
                      to: 1000,
                      initialValue: calories,
                      justIntValues: true,
                      unit: ' kcal',
                    ),
                    onSettingDataRowChange: (double resultVal) {
                      setState(() {
                        calories = resultVal;
                      });
                    },
                    config: SettingsRowConfiguration(
                        showAsTextField: false,
                        // showTitleLeft: !_titleOnTop,
                        // showTopTitle: _titleOnTop,
                        showAsSingleSetting: false),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, top: 0.0),
                    child: Text(
                      calorieError,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  //   child: Text(
                  //     "This value can be obtained from "
                  //     // "If you leave this field blank the calories "
                  //     //     "burned will be approximated using the distance and duration provided.",
                  //     style: TextStyle(
                  //         fontSize: 11,
                  //         color: Colors.red,
                  //         fontWeight: FontWeight.w500),
                  //   ),
                  // ),
                ]),
          ),
        ),
      ),
    );
  }
}
