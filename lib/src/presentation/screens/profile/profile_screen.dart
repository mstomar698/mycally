// ignore_for_file: deprecated_member_use
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/presentation/widgets/pull_to_refresh_wrapper.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<User?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final currentUserId = settingsProvider.currentUserId;

    if (currentUserId != null) {
      _userFuture = isar.users.get(currentUserId);
    } else {
      _userFuture = Future.value(null);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loadUser();
    });
    await _userFuture;
  }

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

    return PullToRefreshWrapper(
      onRefresh: _refresh,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          iconTheme: IconThemeData(color: textColor),
          elevation: 0,
          title: Text(
            tr('profile'),
            style: TextStyle(
              fontSize: fontSize + 2,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FutureBuilder<User?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    tr('error_loading_profile'),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.red,
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Text(
                    tr('no_user_found'),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                );
              } else {
                final user = snapshot.data!;
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: fontSize + 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '#${user.id}',
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildUserField(
                          tr('name'), user.name, textColor, fontSize),
                      // _buildUserField(tr('email'), user.email, textColor, fontSize),
                      // _buildUserField(tr('phone'), user.phone, textColor, fontSize),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/edit_profile');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            tr('edit_profile'),
                            style: TextStyle(
                              fontSize: fontSize + 2,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/vendors');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            tr('vendors'),
                            style: TextStyle(
                              fontSize: fontSize + 2,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserField(
      String label, String value, Color textColor, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: fontSize,
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
