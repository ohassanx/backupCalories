import 'package:flutter/material.dart';
import 'package:audio_fit/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<List<UserSettings>>(context);
    userSettings.forEach((settings) {
      print(settings.kcalInput.toString());
    });
    if (userSettings != null) {
      return ListView.builder(
        itemCount: userSettings.length,
        itemBuilder: (context, index) {
          return Text(userSettings[index].kcalOutput.toString());
        },
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
