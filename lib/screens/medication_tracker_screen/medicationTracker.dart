import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/models/medication.dart';
import 'package:audio_fit/models/medication_checklist.dart';
import 'package:audio_fit/services/auth.dart';
import 'package:audio_fit/services/database.dart';
import 'package:provider/provider.dart';
import 'medication_list.dart';

class MedicationTracker extends StatefulWidget {
  //test comment
  @override
  _MedicationTrackerState createState() => _MedicationTrackerState();
}

class _MedicationTrackerState extends State<MedicationTracker> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  var userId;
  bool userIdSet = false;
  bool loading = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay selectedTime;
  String timeString;
  bool timeSelected = false;
  String medName;

  void initState() {
    super.initState();
    getUid();
    updateBoolean();
  }

  void selectTime(BuildContext context) async {
    //animate this?
    selectedTime = await showTimePicker(
      context: context,
      initialTime: _time,
      initialEntryMode: TimePickerEntryMode.input,
    );
    timeSelected = true;
    timeString = "${selectedTime.hour}:${selectedTime.minute}";
  }

  Future<String> addItem(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter details here:"),
            content: Container(
              height: 100,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "medication/supplement name",
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 15.0)),
                    Container(
                      child: TextButton(
                        child: Text("Select Time"),
                        onPressed: () {
                          selectTime(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Submit"),
                onPressed: () {
                  setState(() {
                    medName = nameController.text;
                  });
                  nameController.clear();
                  timeController.clear();
                  Navigator.pop(context);
                  showConfirmationDialog();

                  //updateDatabase(nameController.text, timeString);
                },
              ),
            ],
          );
        });
  }

  showConfirmationDialog() {
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
          updateDatabase(medName, timeString);
          Navigator.pop(context);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm Action"),
      content: Text(
          "Add " + medName + " to be taken at " + timeString + " to list?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future updateDatabase(String medName, String timeToTake) async {
    userId = await getUid();
    DatabaseService(id: userId).addMedication(medName, timeToTake);
  }

  Future<String> getUid() async {
    final User user = await auth.currentUser;
    final id = user.uid;
    setState(() {
      userId = id;
    });
    setState(() {
      userIdSet = true;
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

  Widget build(BuildContext context) {
    return StreamProvider<List<Medication>>.value(
      value: DatabaseService(id: userId).medications,
      initialData: [],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            height: 600,
            child: Center(
              child: Column(children: [
                Padding(padding: EdgeInsets.only(top: 30.0)),
                StreamProvider<List<MedicationChecklist>>.value(
                  value: DatabaseService(id: userId).getLoggedMedications(),
                  initialData: [],
                  child: MedicationList(),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      addItem(context);
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
