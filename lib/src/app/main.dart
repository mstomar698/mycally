import 'package:flutter/material.dart';
import 'package:mycally/src/presentation/screens/edit_profile/edit_profile_screen.dart';
import 'package:mycally/src/presentation/screens/edit_vendor/edit_vendor_screen.dart';
import 'package:mycally/src/presentation/screens/login/login_screen.dart';
import 'package:mycally/src/presentation/screens/profile/profile_screen.dart';
import 'package:mycally/src/presentation/screens/vendors/vendors_screen.dart';
import 'package:provider/provider.dart';
import 'package:mycally/src/data/services/database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:mycally/src/presentation/screens/home/home_screen.dart';
import 'package:mycally/src/presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await initializeIsar();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'MyCally',
      themeMode: settingsProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/vendors': (context) => const VendorsScreen(),
        '/edit_vendor': (context) => const EditVendorScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
