// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/models/vendor.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  int _currentIndex = 2;

  File? _profileImageFile;
  User? _currentUser;
  List<Vendor> _allVendors = [];
  List<Vendor> _selectedVendors = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 2:
        break;
      case 0:
        Navigator.pushNamed(
          context,
          '/home',
          arguments: index,
        );
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/profile',
          arguments: index,
        );
        break;
      case 3:
        Navigator.pushNamed(
          context,
          '/vendors',
          arguments: index,
        );
        break;
    }
  }

  Future<void> _loadUserAndData() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final currentUserId = settingsProvider.currentUserId;
    if (currentUserId != null) {
      final user = await isar.users.get(currentUserId);
      if (user != null) {
        await user.vendors.load();
        setState(() {
          _currentUser = user;
          _nameController = TextEditingController(text: user.name);
          _mobileController =
              TextEditingController(text: user.mobileNumber ?? '');
          _emailController = TextEditingController(text: user.email ?? '');
          _dobController = TextEditingController(
            text: user.dob != null
                ? DateFormat('yyyy-MM-dd')
                    .format(DateTime.fromMillisecondsSinceEpoch(user.dob!))
                : '',
          );
          _selectedVendors = user.vendors.toList();
        });
      }
    } else {
      setState(() {
        _currentUser = null;
        _nameController = TextEditingController();
        _mobileController = TextEditingController();
        _emailController = TextEditingController();
        _dobController = TextEditingController();
      });
    }

    final allVendors = await isar.vendors.where().findAll();
    setState(() {
      _allVendors = allVendors;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('no_user_found'))),
      );
      return;
    }

    final updatedName = _nameController.text.trim();
    final updatedMobile = _mobileController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedDobString = _dobController.text.trim();

    int? updatedDob;
    if (updatedDobString.isNotEmpty) {
      try {
        final parsedDate = DateFormat('yyyy-MM-dd').parse(updatedDobString);
        updatedDob = parsedDate.millisecondsSinceEpoch;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('invalid_dob_format'))),
        );
        return;
      }
    }

    await isar.writeTxn(() async {
      _currentUser!
        ..name = updatedName.isNotEmpty ? updatedName : _currentUser!.name
        ..mobileNumber = updatedMobile.isNotEmpty ? updatedMobile : null
        ..email = updatedEmail.isNotEmpty ? updatedEmail : null
        ..dob = updatedDob
        ..updatedAt = DateTime.now().millisecondsSinceEpoch;

      if (_profileImageFile != null) {
        final bytes = await _profileImageFile!.readAsBytes();
        final base64Image = base64Encode(bytes);
        _currentUser!.profileImage = base64Image;
      }

      await _currentUser!.vendors.load();
      _currentUser!.vendors.clear();
      _currentUser!.vendors.addAll(_selectedVendors);
      await _currentUser!.vendors.save();
      await isar.users.put(_currentUser!);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('profile_updated_successfully'))),
    );

    Navigator.pushReplacementNamed(context, '/profile');
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          tr('edit_profile'),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: _currentUser == null
          ? Center(
              child: Text(
                tr('no_user_found'),
                style: TextStyle(fontSize: fontSize, color: textColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: _profileImageFile != null
                            ? Image.file(
                                _profileImageFile!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              )
                            : _currentUser!.profileImage != null
                                ? Image.memory(
                                    base64Decode(
                                        _currentUser!.profileImage ?? ''),
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
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: tr('name'),
                    controller: _nameController,
                    textColor: textColor,
                    fontSize: fontSize,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: tr('phone'),
                    controller: _mobileController,
                    textColor: textColor,
                    fontSize: fontSize,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: tr('email'),
                    controller: _emailController,
                    textColor: textColor,
                    fontSize: fontSize,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    label: tr('dob'),
                    controller: _dobController,
                    textColor: textColor,
                    fontSize: fontSize,
                    readOnly: true,
                    onTap: _pickDOB,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr('vendors'),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildVendorsDropdown(textColor, fontSize),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        tr('save'),
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
            icon: const Icon(Icons.edit),
            label: tr('edit_profile'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business),
            label: tr('vendors'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Color textColor,
    required double fontSize,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      style: TextStyle(fontSize: fontSize, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize, color: textColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _pickDOB() async {
    DateTime initialDate = DateTime.now();
    if (_dobController.text.isNotEmpty) {
      try {
        final parsedDate = DateFormat('yyyy-MM-dd').parse(_dobController.text);
        initialDate = parsedDate;
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildVendorsDropdown(Color textColor, double fontSize) {
    if (_allVendors.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          tr('no_vendors_attached'),
          style: TextStyle(
            fontSize: fontSize,
            color: textColor.withOpacity(0.6),
          ),
        ),
      );
    }

    return DropdownSearch<Vendor>.multiSelection(
      items: _allVendors,
      popupProps: PopupPropsMultiSelection.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          style: TextStyle(fontSize: fontSize, color: textColor),
          decoration: InputDecoration(
            hintText: tr('search_vendors'),
            hintStyle: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ),
        itemBuilder: _vendorItemBuilder,
        emptyBuilder: (context, searchEntry) => Center(
          child: Text(
            tr('no_vendors_attached'),
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ),
      ),
      compareFn: (item, selectedItem) => item.id == selectedItem.id,
      selectedItems: _selectedVendors,
      itemAsString: (Vendor v) => v.name,
      onChanged: (List<Vendor> selected) {
        setState(() {
          _selectedVendors = selected;
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: tr('vendors'),
          labelStyle: TextStyle(fontSize: fontSize, color: textColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _vendorItemBuilder(
      BuildContext context, Vendor vendor, bool isSelected) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final textColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.deepPurple;
    final fontSize = settingsProvider.fontSize;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        vendor.name,
        style: TextStyle(fontSize: fontSize, color: textColor),
      ),
    );
  }
}
