import 'package:cupertino_setting_control/cupertino_setting_control.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/services/database.dart';

class SettingsWidgets extends StatefulWidget {
  final String country;
  final double age;
  final double weight;
  final double intakeTarget;
  final double outputTarget;
  SettingsWidgets(
      {this.country,
      this.age,
      this.weight,
      this.intakeTarget,
      this.outputTarget});

  @override
  _SettingsWidgetsState createState() => _SettingsWidgetsState();
}

class _SettingsWidgetsState extends State<SettingsWidgets> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = "";
  bool _titleOnTop = false;
  String _searchAreaResult = "";

  void initState() {
    super.initState();
    getUid();
  }

  Future<String> getUid() async {
    final User user = await auth.currentUser;
    final id = user.uid;
    setState(() {
      userId = id;
    });
    print(id);
    return id;
  }

  void onSearchAreaChange(String data) {
    setState(() {
      _searchAreaResult = data;
    });
    DatabaseService(id: userId).enterUserCountry(_searchAreaResult);
  }

  void pushChangesToDatabase() {}

  @override
  Widget build(BuildContext context) {
    final profileSettingsTile = new Material(
      color: Colors.transparent,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
              child: const Text(
                'Profile',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
          new SettingRow(
            rowData: SettingsDropDownConfig(
                title: 'User Area',
                initialKey: widget.country,
                choices: {
                  'Ireland': 'Ireland',
                  'United Kingdom': 'United Kingdom',
                }),
            onSettingDataRowChange: onSearchAreaChange,
            config: SettingsRowConfiguration(
                showAsTextField: false,
                showTitleLeft: !_titleOnTop,
                showTopTitle: _titleOnTop,
                showAsSingleSetting: false),
          ),
          SizedBox(height: _titleOnTop ? 10.0 : 0.0),
          new SettingRow(
            rowData: SettingsSliderConfig(
              title: 'Age',
              from: 18,
              to: 120,
              initialValue: widget.age,
              justIntValues: true,
              unit: ' years',
            ),
            onSettingDataRowChange: (double resultVal) {
              DatabaseService(id: userId).enterUserAge(resultVal.toInt());
            },
            config: SettingsRowConfiguration(
                showAsTextField: false,
                showTitleLeft: !_titleOnTop,
                showTopTitle: _titleOnTop,
                showAsSingleSetting: false),
          ),
          SizedBox(height: _titleOnTop ? 10.0 : 0.0),
          new SettingRow(
            rowData: SettingsSliderConfig(
              title: 'Weight',
              from: 40,
              to: 120,
              initialValue: widget.weight.toDouble(),
              justIntValues: true,
              unit: ' kg',
            ),
            onSettingDataRowChange: (double resultVal) {
              DatabaseService(id: userId).enterUserWeight(resultVal.toInt());
            },
            config: SettingsRowConfiguration(
                showAsTextField: false,
                showTitleLeft: !_titleOnTop,
                showTopTitle: _titleOnTop,
                showAsSingleSetting: false),
          ),
          SizedBox(height: _titleOnTop ? 10.0 : 0.0),
        ],
      ),
    );

    final accountSettingsTile = new Material(
      color: Colors.transparent,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
              child: const Text(
                'Account',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
          SizedBox(height: _titleOnTop ? 10.0 : 0.0),
          new SettingRow(
            rowData: SettingsSliderConfig(
              title: 'Daily Calorie Intake Target',
              from: 1500,
              to: 5000,
              initialValue: widget.intakeTarget.toDouble(),
              justIntValues: true,
              unit: ' kcal',
            ),
            onSettingDataRowChange: (double resultVal) {
              DatabaseService(id: userId)
                  .updateKcalIntakeTarget(resultVal.toInt());
            },
            config: SettingsRowConfiguration(
                showAsTextField: false,
                showTitleLeft: !_titleOnTop,
                showTopTitle: _titleOnTop,
                showAsSingleSetting: false),
          ),
          SizedBox(height: _titleOnTop ? 10.0 : 0.0),
          new SettingRow(
            rowData: SettingsSliderConfig(
              title: 'Daily Calorie Output Target',
              from: 1000,
              to: 4000,
              initialValue: widget.outputTarget.toDouble(),
              justIntValues: true,
              unit: ' kcal',
            ),
            onSettingDataRowChange: (double resultVal) {
              DatabaseService(id: userId)
                  .updateKcalOutputTarget(resultVal.toInt());
            },
            config: SettingsRowConfiguration(
                showAsTextField: false,
                showTitleLeft: !_titleOnTop,
                showTopTitle: _titleOnTop,
                showAsSingleSetting: false),
          ),
          SizedBox(height: _titleOnTop ? 10.0 : 0.0),
        ],
      ),
    );

    final modifyProfileTile = new Material(
        color: Colors.transparent,
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
                  child: const Text(
                    'Profile Options',
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  )),
              SettingRow(
                rowData: SettingsButtonConfig(
                  title: 'Delete Profile',
                  tick: true,
                  functionToCall: () {},
                ),
                style: const SettingsRowStyle(
                    backgroundColor: CupertinoColors.lightBackgroundGray),
                config: SettingsRowConfiguration(
                    showAsTextField: false,
                    showTitleLeft: !_titleOnTop,
                    showTopTitle: _titleOnTop,
                    showAsSingleSetting: false),
              )
            ]));

    final List<Widget> widgetList = [
      // titleOnTopSwitch,
      // const SizedBox(height: 15.0),
      profileSettingsTile,
      const SizedBox(height: 15.0),
      accountSettingsTile,
      // const SizedBox(height: 15.0),
      // legalStuff,
      // const SizedBox(height: 15.0),
      // Row(children: [Expanded(child: modifyProfileTile)]),
    ];

    return ListView(
        children: widgetList, physics: const AlwaysScrollableScrollPhysics());
  }
}
