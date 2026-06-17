import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mycally/src/data/models/user.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:mycally/src/presentation/widgets/mycally_logo.dart';
import 'package:mycally/src/localization/localization_service.dart';
import 'package:mycally/src/presentation/screens/home/home_screen.dart';
import 'package:mycally/src/presentation/screens/language_selector/language_selector_screen.dart';
import 'package:mycally/src/presentation/screens/login/login_screen.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLanguageSet = false;
  bool _isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    Provider.of<SettingsProvider>(context, listen: false);

    await LocalizationService.loadPreferences(context);

    _isLanguageSet = await LocalizationService.isLanguageSelected();

    final currentUserId = await LocalizationService.getCurrentUserId();

    User? currentUser;

    if (currentUserId != null) {
      currentUser = await isar.users.get(currentUserId);
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();

    setState(() => _isLoadingPrefs = false);
    await Future.delayed(const Duration(seconds: 2));

    if (currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      if (_isLanguageSet) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  void _onGetStartedPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LanguageSelectorScreen()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final Size screenSize = MediaQuery.of(context).size;

    final backgroundColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.black
        : Colors.white;

    final textColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.deepPurple;

    final subtitleColor = settingsProvider.themeMode == ThemeMode.dark
        ? Colors.grey[400]
        : Colors.grey;

    if (_isLoadingPrefs) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLanguageSet) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MycallyLogo(size: 150),
                const SizedBox(height: 20),
                Text(
                  tr('app_name'),
                  style: TextStyle(
                    fontSize: settingsProvider.fontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MycallyLogo(size: 150),
                    const SizedBox(height: 20),
                    Text(
                      tr('app_name'),
                      style: TextStyle(
                        fontSize: settingsProvider.fontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr('welcome'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: settingsProvider.fontSize - 2,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton(
                  onPressed: _onGetStartedPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    tr('get_started'),
                    style: TextStyle(
                      fontSize: settingsProvider.fontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
