// ignore_for_file: deprecated_member_use
import 'dart:convert';

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
  int _currentIndex = 1;

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

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 1:
        break;
      case 0 || 3:
        Navigator.pushNamed(
          context,
          '/home',
          arguments: index,
        );
        break;
      case 2:
        Navigator.pushNamed(
          context,
          '/vendors',
          arguments: index,
        );
        break;
    }
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
          automaticallyImplyLeading: false,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: user.profileImage != null
                              ? Image.memory(
                                  base64Decode(user.profileImage!),
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_profile.jpg',
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/default_profile.jpg',
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
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
                      const SizedBox(height: 40),
                      _buildUserField(
                          tr('name'), user.name, textColor, fontSize),
                      _buildUserField(tr('phone'), user.mobileNumber ?? '-',
                          textColor, fontSize),
                      _buildUserField(
                          tr('email'), user.email ?? '-', textColor, fontSize),
                      _buildUserField(
                          tr('dob'),
                          user.dob != null
                              ? DateFormat.yMMMd().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      user.dob!))
                              : '-',
                          textColor,
                          fontSize),
                      _buildUserField(
                        tr('vendors'),
                        user.vendors.isEmpty
                            ? tr('no_vendors_attached')
                            : user.vendors.length > 3
                                ? '${user.vendors.take(3).map((v) => v.name).join(', ')}...'
                                : user.vendors.map((v) => v.name).join(', '),
                        textColor,
                        fontSize,
                      ),
                      _buildUserField(
                          tr('joined_at'),
                          user.createdAt != null
                              ? DateFormat.yMMMd().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      user.createdAt!))
                              : '-',
                          textColor,
                          fontSize),
                      _buildUserField(
                          tr('updated_at'),
                          user.updatedAt != null
                              ? DateFormat.yMMMd().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      user.updatedAt!))
                              : '-',
                          textColor,
                          fontSize),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: backgroundColor,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: textColor.withOpacity(0.6),
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: tr('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: tr('profile'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business),
              label: tr('vendors'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: tr('settings'),
            ),
          ],
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
