import 'package:flutter/material.dart';
import 'package:mycally/src/presentation/screens/home/home_screen.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:mycally/src/presentation/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
