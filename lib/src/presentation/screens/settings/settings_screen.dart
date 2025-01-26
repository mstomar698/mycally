import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/localization/localization_service.dart';
import 'package:mycally/src/presentation/widgets/pull_to_refresh_wrapper.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.isLatestVersion = true,
  });

  final bool isLatestVersion;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Fetching...';

  late String _selectedLanguage;
  late double _selectedFontSize;
  late ThemeMode _selectedThemeMode;

  final Map<String, double> enFontSizes = {
    'Small': 14.0,
    'Medium': 16.0,
    'Large': 18.0,
    'Larger': 20.0,
  };

  final Map<String, double> hiFontSizes = {
    'छोटा': 14.0,
    'मध्यम': 16.0,
    'बड़ा': 18.0,
    'अधिक बड़ा': 20.0,
  };

  @override
  void initState() {
    super.initState();
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _selectedLanguage = settingsProvider.locale.languageCode;
    _selectedFontSize = settingsProvider.fontSize;
    _selectedThemeMode = settingsProvider.themeMode;
    _fetchAppVersion();
  }

  Future<void> _fetchAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Unavailable';
      });
      debugPrint('Error fetching app version: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((_) async {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
    });
  }

  Future<void> _reloadData(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    await LocalizationService.loadPreferences(context);

    _fetchAppVersion();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // Clear current user ID from SharedPreferences
    await LocalizationService.removeCurrentUserId();

    // Clear current user ID from SettingsProvider
    settingsProvider.clearCurrentUserId();

    // Optionally, show a confirmation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('logged_out'))),
    );

    // Navigate to LoginScreen
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Delete Account Functionality
  Future<void> _handleDeleteAccount(BuildContext context) async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final currentUserId = settingsProvider.currentUserId;

    if (currentUserId == null) {
      // No user to delete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('no_user_to_delete'))),
      );
      return;
    }

    // Confirm Deletion
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('delete_account')),
        content: Text(tr('confirm_delete_account')),
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

    if (confirm != true) return;

    try {
      await isar.writeTxn(() async {
        await isar.users.delete(currentUserId);
      });

      // Clear current user ID from SharedPreferences
      await LocalizationService.removeCurrentUserId();

      // Clear current user ID from SettingsProvider
      settingsProvider.clearCurrentUserId();

      // Optionally, show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('account_deleted'))),
      );

      // Navigate to LoginScreen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('error_deleting_account'))),
      );
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

    final currentUserId = settingsProvider.currentUserId;
    final isLoggedIn = currentUserId != null;

    return PullToRefreshWrapper(
      onRefresh: () => _reloadData(context),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          iconTheme: IconThemeData(color: textColor),
          elevation: 0,
          title: Text(
            tr('settings'),
            style: TextStyle(
              fontSize: fontSize + 2,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              _buildSectionHeader(
                title: tr('general'),
                textColor: textColor,
                fontSize: fontSize,
              ),
              _buildLanguageTile(settingsProvider, textColor, fontSize),
              _buildFontSizeTile(settingsProvider, textColor, fontSize),
              _buildThemeTile(settingsProvider, textColor, fontSize),
              const SizedBox(height: 20),
              _buildSectionHeader(
                title: tr('legal'),
                textColor: textColor,
                fontSize: fontSize,
              ),
              _buildLegalTile(
                label: tr('privacy_policy'),
                textColor: textColor,
                fontSize: fontSize,
                onTap: () => _launchURL('https://example.com/privacy'),
              ),
              _buildLegalTile(
                label: tr('terms_conditions'),
                textColor: textColor,
                fontSize: fontSize,
                onTap: () => _launchURL('https://example.com/terms'),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(
                title: tr('account'),
                textColor: textColor,
                fontSize: fontSize,
              ),
              if (isLoggedIn) ...[
                _buildAccountTile(
                  label: tr('logout'),
                  textColor: textColor,
                  fontSize: fontSize,
                  onTap: () => _handleLogout(context),
                ),
                _buildAccountTile(
                  label: tr('delete_account'),
                  textColor: textColor,
                  fontSize: fontSize,
                  onTap: () => _handleDeleteAccount(context),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    tr('not_logged_in'),
                    style: TextStyle(
                      fontSize: fontSize,
                      // ignore: deprecated_member_use
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildSectionHeader(
                title: tr('app_info'),
                textColor: textColor,
                fontSize: fontSize,
              ),
              _buildAppVersionTile(
                versionLabel: 'v1.0.0',
                textColor: textColor,
                fontSize: fontSize,
                isLatestVersion: widget.isLatestVersion,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    SettingsProvider settingsProvider,
    Color textColor,
    double fontSize,
  ) {
    return ListTile(
      title: Text(
        tr('select_language'),
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _languageChip('English', 'en', settingsProvider),
          const SizedBox(width: 10),
          _languageChip('हिन्दी', 'hi', settingsProvider),
        ],
      ),
    );
  }

  Widget _languageChip(
    String label,
    String code,
    SettingsProvider settingsProvider,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedLanguage == code,
      onSelected: (_) {
        setState(() {
          _selectedLanguage = code;
        });
        context.setLocale(Locale(code));
        settingsProvider.setLocale(Locale(code));
        LocalizationService.setLanguage(Locale(code));
      },
    );
  }

  Widget _buildFontSizeTile(
    SettingsProvider settingsProvider,
    Color textColor,
    double fontSize,
  ) {
    final isHindi = _selectedLanguage == 'hi';
    final sizesMap = isHindi ? hiFontSizes : enFontSizes;

    return ListTile(
      title: Text(
        tr('select_font_size'),
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Wrap(
        spacing: 8,
        children: sizesMap.entries.map((entry) {
          return ChoiceChip(
            label: Text(
              entry.key,
              style: TextStyle(fontSize: entry.value),
            ),
            selected: _selectedFontSize == entry.value,
            onSelected: (_) {
              setState(() {
                _selectedFontSize = entry.value;
              });
              settingsProvider.setFontSize(entry.value);
              LocalizationService.setFontSize(entry.value);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeTile(
    SettingsProvider settingsProvider,
    Color textColor,
    double fontSize,
  ) {
    return ListTile(
      title: Text(
        tr('select_theme'),
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          _themeOption(
            label: _selectedLanguage == 'hi' ? 'स्वत:' : 'Light',
            mode: ThemeMode.light,
            settingsProvider: settingsProvider,
          ),
          const SizedBox(width: 10),
          _themeOption(
            label: _selectedLanguage == 'hi' ? 'अंधेरा' : 'Dark',
            mode: ThemeMode.dark,
            settingsProvider: settingsProvider,
          ),
        ],
      ),
    );
  }

  Widget _themeOption({
    required String label,
    required ThemeMode mode,
    required SettingsProvider settingsProvider,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedThemeMode == mode,
      onSelected: (_) {
        setState(() {
          _selectedThemeMode = mode;
        });
        settingsProvider.setThemeMode(mode);
        LocalizationService.setThemeMode(
            mode == ThemeMode.dark ? 'dark' : 'light');
      },
    );
  }

  Widget _buildLegalTile({
    required String label,
    required Color textColor,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAccountTile({
    required String label,
    required Color textColor,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAppVersionTile({
    required String versionLabel,
    required Color textColor,
    required double fontSize,
    required bool isLatestVersion,
  }) {
    return ListTile(
      title: Text(
        '${tr('app_version')}: $_appVersion',
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: !isLatestVersion
          ? Text(
              tr('update_available'),
              style: TextStyle(
                fontSize: fontSize - 2,
                // ignore: deprecated_member_use
                color: textColor.withOpacity(0.8),
              ),
            )
          : null,
      trailing: !isLatestVersion
          ? ElevatedButton(
              onPressed: () {},
              child: Text(
                tr('update_now'),
                style: TextStyle(fontSize: fontSize - 2),
              ),
            )
          : null,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required Color textColor,
    required double fontSize,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize - 2,
          // ignore: deprecated_member_use
          color: textColor.withOpacity(0.7),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
