// ignore_for_file: deprecated_member_use
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycally/src/data/models/vendor.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  List<Vendor> _vendors = [];
  String _searchQuery = '';
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final vendors = await isar.vendors.where().anyId().findAll();

    setState(() {
      _vendors = vendors;
    });
  }

  List<Vendor> get _filteredVendors {
    if (_searchQuery.isEmpty) return _vendors;

    return _vendors.where((vendor) {
      final query = _searchQuery.toLowerCase();
      return vendor.name.toLowerCase().contains(query) ||
          vendor.mobileNumber.toLowerCase().contains(query);
    }).toList();
  }

  void _createVendor() {
    Navigator.pushNamed(context, '/edit_vendor').then((_) => _loadVendors());
  }

  void _editVendor(Vendor vendor) {
    debugPrint('${vendor.id} vendor id');
    Navigator.pushNamed(
      context,
      '/edit_vendor',
      arguments: vendor.id,
    ).then((_) => _loadVendors());
  }

  Future<void> _deleteVendor(Vendor vendor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('delete_vendor')),
        content: Text(tr('confirm_delete_vendor')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await isar.writeTxn(() async {
        await isar.vendors.delete(vendor.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('vendor_deleted_successfully'))),
      );
      _loadVendors();
    }
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
      case 0 || 3:
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          tr('vendors'),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVendors,
            tooltip: tr('refresh'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createVendor,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(fontSize: fontSize, color: textColor),
              decoration: InputDecoration(
                labelText: tr('search_vendors'),
                labelStyle: TextStyle(fontSize: fontSize, color: textColor),
                prefixIcon: Icon(Icons.search, color: textColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _filteredVendors.isEmpty
                ? Center(
                    child: Text(
                      tr('no_vendors_available'),
                      style: TextStyle(fontSize: fontSize, color: textColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredVendors.length,
                    itemBuilder: (context, index) {
                      final vendor = _filteredVendors[index];
                      return ListTile(
                        title: Text(
                          vendor.name,
                          style:
                              TextStyle(fontSize: fontSize, color: textColor),
                        ),
                        subtitle: Text(
                          vendor.mobileNumber,
                          style: TextStyle(
                              fontSize: fontSize - 2,
                              color: textColor.withValues(alpha: 0.7)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: textColor,
                              onPressed: () => _editVendor(vendor),
                              tooltip: tr('edit'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: textColor,
                              onPressed: () => _deleteVendor(vendor),
                              tooltip: tr('delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: textColor.withValues(alpha: 0.6),
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
    );
  }
}
