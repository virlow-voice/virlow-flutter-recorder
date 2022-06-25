import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virlow_flutter_recorder/auth/auth.dart';
import './screens/settings_screen.dart';
import './auth/signin.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'amplifyconfiguration.dart';

class Settings extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool signedIn = false;
  @override
  void initState() {
    super.initState();
    loadAppConfig();
  }

  Future<void> loadAppConfig() async {
    await _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    if (!Amplify.isConfigured) {
      try {
        await Amplify.addPlugin(AmplifyAuthCognito());
        await Amplify.configure(amplifyconfig);
      } on Exception catch (e) {}
    }

    try {
      final awsUser = await Amplify.Auth.getCurrentUser();
      setState(() {
        signedIn = true;
      });
    } on AuthException catch (e) {
      setState(() {
        signedIn = false;
      });
    }
  }

  void _launchUrl(url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  Future<void> getAuthStatus() async {
    if (signedIn) {
      AuthServices().signOut(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: ListView(
          children: [
            SettingsGroup(
              items: [
                // SettingsItem(
                //   onTap: () {},
                //   icons: Icons.cloud,
                //   iconStyle: IconStyle(
                //     iconsColor: Colors.white,
                //     withBackground: true,
                //     backgroundColor: Colors.red,
                //   ),
                //   title: 'Cloud Sync',
                //   subtitle: "Requires an account",
                //   trailing: Switch.adaptive(
                //     value: false,
                //     onChanged: (value) {},
                //   ),
                // ),
                SettingsItem(
                  onTap: () {
                    _launchUrl("https://virlow.com");
                  },
                  icons: Icons.info_rounded,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.red,
                  ),
                  title: 'Virlow Recorder',
                  subtitle: "v2.2.0-beta",
                ),
              ],
            ),
            // SettingsGroupSingle(
            //   settingsGroupTitle: "Account",
            //   items: [
            //     SettingsItemSingle(
            //       onTap: () {
            //         getAuthStatus();
            //       },
            //       icons: Icons.exit_to_app_rounded,
            //       title: signedIn ? "Sign Out" : "Sign In",
            //     ),
            //     SettingsItemSingle(
            //       onTap: () {},
            //       icons: Icons.delete,
            //       title: "Delete account",
            //       titleStyle: const TextStyle(color: Colors.red),
            //     ),
            //   ],
            // ),
            SettingsGroupSingle(
              settingsGroupTitle: "Misc",
              items: [
                SettingsItemSingle(
                  onTap: () {
                    _launchUrl("https://virlow.com/recorder/tos.html");
                  },
                  icons: Icons.topic,
                  title: "Terms of Service",
                ),
                SettingsItemSingle(
                    onTap: () {
                      _launchUrl(
                          "https://github.com/virlow-voice/virlow-flutter-recorder");
                    },
                    icons: Icons.workspaces,
                    title: "Open Source"),
                SettingsItemSingle(
                    onTap: () {
                      _launchUrl("https://virlow.com");
                    },
                    icons: Icons.manage_search,
                    title: "Virlow Speech-to-Text"),
                SettingsItemSingle(
                    onTap: () {
                      _launchUrl("https://forms.gle/iUKLtsR9QFU8wbnP6");
                    },
                    icons: Icons.verified,
                    title: "Feedback"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
