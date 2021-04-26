import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/screens/home/settings_page.dart';
import 'package:audio_fit/services/auth.dart';
import 'package:audio_fit/shared/ConstantVars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar.dart';
import '../food_diary_screen/foodDiary.dart';
import '../activity_diary_screen/activityDiary.dart';
import '../medication_tracker_screen/medicationTracker.dart';
import '../nutrient_screen/nutrientChecklist.dart';
import '../progress_screen/progress.dart';
import 'package:audio_fit/shared/globals.dart' as globals;

// ignore: must_be_immutable
class Home extends StatefulWidget {
  String date;
  Home({this.date});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  PageController _pageController = PageController();
  List<Widget> _screens = [
    Progress(),
    FoodDiary(),
    ActivityDiary(),
    NutrientChecklist(),
    MedicationTracker(),
  ];
  int _selectedIndex = 0;
  String selectedDate = "";
  bool newDate = false;
  String userId = "";

  void initState() {
    super.initState();
    getUid();
    print("initState date = " + widget.date.toString());
    newDate = globals.newDateSelected;
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

  int getSelectedIndex() {
    return _selectedIndex;
  }

  void _onItemTapped(int selectedIndex) {
    _pageController.jumpToPage(selectedIndex);
    setState(() {
      _selectedIndex = selectedIndex;
    });
  }

  void renderCalendar() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarView(),
        ));
    if (result.isNotEmpty) {
      setState(() {
        selectedDate = result;
        newDate = true;
        globals.selectedDate = selectedDate;
      });
    }
    //print(result);
  }

  renderSettingsPage() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsPage(),
        ));
    if (result.isNotEmpty) {
      setState(() {
        // selectedDate = result;
        // newDate = true;
        // globals.selectedDate = selectedDate;
      });
    }
  }

  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc(userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
          } else {}
          return Scaffold(
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  print("Calendar View Selected");
                  renderCalendar();
                },
                child: Icon(
                  Icons.calendar_today_outlined,
                ),
              ),
              title: newDate
                  ? new Text(globals.selectedDate)
                  : new Text(getCurrentDate()),
              centerTitle: true,
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: choiceAction,
                  itemBuilder: (BuildContext context) {
                    return ConstantVars.choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            backgroundColor: Colors.white,
            body: PageView(
              controller: _pageController,
              children: _screens,
              physics: NeverScrollableScrollPhysics(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart,
                      color:
                          getSelectedIndex() == 0 ? Colors.blue : Colors.grey),
                  label: 'Progress',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.no_food),
                  label: 'Food',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_run_outlined),
                  label: 'Activity',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wb_sunny),
                  label: 'Nutrients',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check),
                  label: 'Meds',
                ),
              ],
              currentIndex: _selectedIndex,
            ),
          );
        });
  }

  void choiceAction(String choice) {
    if (choice == ConstantVars.Settings) {
      renderSettingsPage();
      print('Settings');
    } else if (choice == ConstantVars.Subscribe) {
      print('Subscribe');
    } else if (choice == ConstantVars.SignOut) {
      _auth.signOut();
      print('SignOut');
    }
  }

  String getCurrentDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}/${dateParse.month}/${dateParse.year}";
    return formattedDate;
  }
}
