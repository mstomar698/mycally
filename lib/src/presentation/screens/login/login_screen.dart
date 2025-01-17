import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mycally/src/state/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final String selectedLanguage = settingsProvider.locale.languageCode;
    final double selectedFontSize = settingsProvider.fontSize;
    final ThemeMode selectedThemeMode = settingsProvider.themeMode;

    final backgroundColor =
        selectedThemeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final textColor =
        selectedThemeMode == ThemeMode.dark ? Colors.white : Colors.deepPurple;

    final bottomTextColor =
        selectedThemeMode == ThemeMode.dark ? Colors.grey[400] : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // App Name Header
            Text(
              tr('app_name'),
              style: TextStyle(
                fontSize: selectedFontSize + 6,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 40),

            // Centered Logo Image
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/login_screen_icon.png',
                  // 'assets/images/login_page_logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Bottom Buttons (Google & Guest)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Disabled Google Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null, // Disabled for now
                      icon: const Icon(Icons.g_mobiledata),
                      label: Text(
                        selectedLanguage == 'hi'
                            ? 'Google से जारी रखें'
                            : 'Continue with Google',
                        style: TextStyle(fontSize: selectedFontSize),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Continue as Guest Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        selectedLanguage == 'hi'
                            ? 'अतिथि के रूप में जारी रखें'
                            : 'Continue as Guest',
                        style: TextStyle(
                          fontSize: selectedFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Privacy Policy & Terms
                  Text.rich(
                    TextSpan(
                      text: selectedLanguage == 'hi'
                          ? 'जारी रखकर, आप हमारी '
                              'जारी रखकर, आप हमारी बात से सहमत हैं'
                          : 'By continuing, you agree to our ',
                      style: TextStyle(
                          fontSize: selectedFontSize - 2,
                          color: bottomTextColor,
                          height: 1.5,
                          letterSpacing: 0.5,
                          wordSpacing: 1.5,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: selectedLanguage == 'hi'
                              ? 'गोपनीयता नीति'
                              : 'Privacy Policy',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              decoration: TextDecoration.underline,
                              letterSpacing: 0.5,
                              wordSpacing: 1.5,
                              height: 1.5,
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchURL('https://example.com/privacy');
                            },
                        ),
                        TextSpan(
                            text: ' & ',
                            style: TextStyle(
                                fontSize: selectedFontSize - 2,
                                color: bottomTextColor,
                                height: 1.5,
                                letterSpacing: 0.5,
                                wordSpacing: 1.5,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: selectedLanguage == 'hi'
                              ? 'शर्तें'
                              : 'Terms & Conditions',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              decoration: TextDecoration.underline,
                              letterSpacing: 0.5,
                              wordSpacing: 1.5,
                              height: 1.5,
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchURL('https://example.com/terms');
                            },
                        ),
                        TextSpan(
                          text: selectedLanguage == 'hi' ? 'सहमत हैं' : '',
                          style: TextStyle(
                              color: bottomTextColor,
                              decoration: TextDecoration.underline,
                              letterSpacing: 0.5,
                              wordSpacing: 1.5,
                              height: 1.5,
                              fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchURL('https://example.com/terms');
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
