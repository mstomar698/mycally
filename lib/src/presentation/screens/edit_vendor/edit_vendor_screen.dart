// ignore_for_file: deprecated_member_use
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mycally/src/data/models/vendor.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class EditVendorScreen extends StatefulWidget {
  const EditVendorScreen({super.key});

  @override
  State<EditVendorScreen> createState() => _EditVendorScreenState();
}

class _EditVendorScreenState extends State<EditVendorScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _customTypeController = TextEditingController();

  Map<String, String> _additionalInfoMap = {};

  VendorType _selectedType = VendorType.milk;

  Vendor? _editingVendor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendorIfEditing();
    });
  }

  Future<void> _loadVendorIfEditing() async {
    final id = ModalRoute.of(context)?.settings.arguments;
    print('Editing vendor ID: $id');
    if (id is int) {
      final vendor = await isar.vendors.get(id);
      if (vendor != null) {
        setState(() {
          _editingVendor = vendor;
          _nameController.text = vendor.name;
          _mobileController.text = vendor.mobileNumber;
          _selectedType = vendor.type;
          _emailController.text = vendor.email ?? '';

          if (vendor.additionalInfoJson != null &&
              vendor.additionalInfoJson!.isNotEmpty) {
            try {
              _additionalInfoMap = (jsonDecode(vendor.additionalInfoJson!)
                      as Map<String, dynamic>)
                  .map((key, value) => MapEntry(key, value.toString()));
            } catch (_) {
              _additionalInfoMap = {};
            }
          }

          if (_selectedType == VendorType.other) {
            _customTypeController.text =
                _additionalInfoMap['customVendorType'] ?? '';
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  Future<void> _saveVendor() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('vendor_name_mobile_required'))),
      );
      return;
    }

    if (_selectedType == VendorType.other &&
        _customTypeController.text.isNotEmpty) {
      _additionalInfoMap['customVendorType'] =
          _customTypeController.text.trim();
    } else {
      _additionalInfoMap.remove('customVendorType');
    }

    final additionalJson =
        _additionalInfoMap.isNotEmpty ? jsonEncode(_additionalInfoMap) : null;

    if (_editingVendor != null) {
      await isar.writeTxn(() async {
        _editingVendor!
          ..name = name
          ..mobileNumber = mobile
          ..type = _selectedType
          ..email = email.isNotEmpty ? email : null
          ..additionalInfoJson = additionalJson;
        await isar.vendors.put(_editingVendor!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('vendor_updated_successfully'))),
      );
    } else {
      final newVendor = Vendor()
        ..name = name
        ..mobileNumber = mobile
        ..type = _selectedType
        ..email = email.isNotEmpty ? email : null
        ..additionalInfoJson = additionalJson;

      await isar.writeTxn(() async {
        await isar.vendors.put(newVendor);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('vendor_created_successfully'))),
      );
    }

    Navigator.pop(context);
  }

  Future<void> _addAdditionalInfo() async {
    final keyController = TextEditingController();
    final valController = TextEditingController();

    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('add_additional_info')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: InputDecoration(labelText: tr('key')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: valController,
              decoration: InputDecoration(labelText: tr('value')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('add')),
          ),
        ],
      ),
    );

    if (res == true) {
      final k = keyController.text.trim();
      final v = valController.text.trim();
      if (k.isNotEmpty && v.isNotEmpty) {
        setState(() {
          _additionalInfoMap[k] = v;
        });
      }
    }
  }

  Future<void> _removeAdditionalInfo(String key) async {
    setState(() {
      _additionalInfoMap.remove(key);
    });
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

    final isEditing = _editingVendor != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? tr('edit_vendor') : tr('create_vendor'),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: tr('email'),
              controller: _emailController,
              textColor: textColor,
              fontSize: fontSize,
            ),
            const SizedBox(height: 10),
            _buildVendorTypeDropdown(textColor, fontSize),
            if (_selectedType == VendorType.other) ...[
              const SizedBox(height: 10),
              _buildTextField(
                label: tr('custom_vendor_type'),
                controller: _customTypeController,
                textColor: textColor,
                fontSize: fontSize,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('additional_info'),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _addAdditionalInfo,
                  icon: const Icon(Icons.add),
                  color: textColor,
                  tooltip: tr('add_additional_info'),
                ),
              ],
            ),
            if (_additionalInfoMap.isEmpty)
              Text(
                tr('no_additional_info'),
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: textColor.withOpacity(0.6),
                ),
              )
            else
              Column(
                children: _additionalInfoMap.entries.map((entry) {
                  return ListTile(
                    title: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(fontSize: fontSize, color: textColor),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: textColor,
                      onPressed: () => _removeAdditionalInfo(entry.key),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveVendor,
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
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Color textColor,
    required double fontSize,
  }) {
    return TextField(
      controller: controller,
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

  Widget _buildVendorTypeDropdown(Color textColor, double fontSize) {
    return Row(
      children: [
        Text(
          tr('vendor_type'),
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
        const SizedBox(width: 16),
        DropdownButton<VendorType>(
          value: _selectedType,
          dropdownColor: Colors.grey,
          items: VendorType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type.name,
                style: TextStyle(fontSize: fontSize, color: textColor),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedType = val;
              });
            }
          },
        )
      ],
    );
  }
}
