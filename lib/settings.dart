import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  void _launchUrl(url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              'assets/virlow.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              "Virlow Recorder",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Version 1.0.2-beta",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(
              height: 60,
            ),
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Linkify(
                      onOpen: (link) => _launchUrl(link.url),
                      text:
                          "Terms of Service \nhttps://virlow.com/recorder/tos.html",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Linkify(
                      onOpen: (link) => _launchUrl(link.url),
                      text:
                          "Virlow Recorder Open Source \nhttps://github.com/virlow-voice/virlow-flutter-recorder",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Linkify(
                      onOpen: (link) => _launchUrl(link.url),
                      text: "Virlow Speech-to-Text \nhttps://virlow.com",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Linkify(
                      onOpen: (link) => _launchUrl(link.url),
                      text: "Feedback \nhttps://forms.gle/iUKLtsR9QFU8wbnP6",
                    ),
                  ],
                ))
          ],
        ));
  }
}
