import 'package:flutter/material.dart';
import 'package:mycally/src/localization/localization_service.dart';
import 'package:mycally/src/presentation/widgets/mycally_logo.dart';
import 'package:mycally/src/presentation/widgets/pull_to_refresh_wrapper.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:mycally/src/presentation/screens/login/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  late String _selectedLanguage;
  late double _selectedFontSize;
  late ThemeMode _selectedThemeMode;

  @override
  void initState() {
    super.initState();
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _selectedLanguage = settingsProvider.locale.languageCode;
    _selectedFontSize = settingsProvider.fontSize;
    _selectedThemeMode = settingsProvider.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final Size screenSize = MediaQuery.of(context).size;

    return PullToRefreshWrapper(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Scaffold(
        backgroundColor: settingsProvider.themeMode == ThemeMode.dark
            ? Colors.black
            : Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: const MycallyLogo(size: 40),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildLanguageSelector(settingsProvider),
                      _buildFontSizeSelector(settingsProvider),
                      _buildThemeSelector(settingsProvider),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.9,
                  child: ElevatedButton(
                    onPressed: () async {
                      await LocalizationService.setLanguage(
                          Locale(_selectedLanguage));
                      await LocalizationService.setFontSize(_selectedFontSize);
                      await LocalizationService.setThemeMode(
                          _selectedThemeMode == ThemeMode.dark
                              ? 'dark'
                              : 'light');

                      await LocalizationService.setLanguageSelected(true);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      tr('continue'),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(SettingsProvider settingsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('select_language'),
            style: TextStyle(
                fontSize: settingsProvider.fontSize,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _languageOption('English', 'en', settingsProvider),
              _languageOption('हिन्दी', 'hi', settingsProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageOption(
      String label, String code, SettingsProvider settingsProvider) {
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

  Widget _buildFontSizeSelector(SettingsProvider settingsProvider) {
    final enFontSizes = {
      'Small': 14.0,
      'Medium': 16.0,
      'Large': 18.0,
      'Larger': 20.0,
    };
    const hiFontSizes = {
      'छोटा': 14.0,
      'मध्यम': 16.0,
      'बड़ा': 18.0,
      'अधिक बड़ा': 20.0,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('select_font_size'),
            style: TextStyle(
                fontSize: settingsProvider.fontSize,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Wrap(
                spacing: 10,
                children: _selectedLanguage == 'hi'
                    ? [
                        ...hiFontSizes.entries.take(2).map((entry) {
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
                        }),
                      ]
                    : [
                        ...enFontSizes.entries.take(2).map((entry) {
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
                        }),
                      ]),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                  spacing: 10,
                  children: _selectedLanguage == 'hi'
                      ? [
                          ...hiFontSizes.entries.skip(2).map((entry) {
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
                          }),
                        ]
                      : [
                          ...enFontSizes.entries.skip(2).map((entry) {
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
                          }),
                        ]),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildThemeSelector(SettingsProvider settingsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('select_theme'),
            style: TextStyle(
                fontSize: settingsProvider.fontSize,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _selectedLanguage == 'hi'
                ? [
                    _themeOption('स्वत:', ThemeMode.light, settingsProvider),
                    _themeOption('अंधेरा', ThemeMode.dark, settingsProvider),
                  ]
                : [
                    _themeOption('Light', ThemeMode.light, settingsProvider),
                    _themeOption('Dark', ThemeMode.dark, settingsProvider),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _themeOption(
      String label, ThemeMode mode, SettingsProvider settingsProvider) {
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
}
