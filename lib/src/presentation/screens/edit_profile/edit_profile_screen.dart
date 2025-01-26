import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final backgroundColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.black
        : Colors.white;
    final textColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.deepPurple;
    final fontSize = settingsProvider.fontSize;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          tr('edit_profile'),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          tr('edit_profile_screen'),
          style: TextStyle(
            fontSize: fontSize + 2,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
