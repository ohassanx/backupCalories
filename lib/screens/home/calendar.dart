import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audio_fit/models/arguments.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:audio_fit/screens/home/home.dart' as HomePage;
import 'package:audio_fit/shared/globals.dart' as globals;

class CalendarView extends StatefulWidget {
  final String title;
  CalendarView({this.title});

  @override
  _CalendarViewState createState() => new _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarController _controller = CalendarController();
  String selectedDay = "";
  DateTime newDate;

  void initState() {
    super.initState();
    selectedDay = getCurrentDate();
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
        child: Text("Continue"),
        onPressed: () {
          setState(() {
            globals.selectedDate = selectedDay;
            globals.newDateSelected = true;
            globals.newDate = newDate;
          });
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/second",
            (r) => false,
          );
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content:
          Text("Would you like to view data you entered on ${selectedDay}?"),
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

  String getCurrentDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}/${dateParse.month}/${dateParse.year}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Calendar"),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: TableCalendar(
                  calendarController: _controller,
                  initialSelectedDay: globals.newDate,
                  availableCalendarFormats: const {
                    CalendarFormat.week: 'Two Weeks',
                    CalendarFormat.month: 'Week',
                    CalendarFormat.twoWeeks: "Month",
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (date, events, e) {
                    newDate = date;
                    selectedDay = "${date.day}/${date.month}/${date.year}";
                  },
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showAlertDialog(context);
                    },
                    child: Text("Select date"),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
