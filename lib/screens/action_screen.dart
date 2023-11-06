import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionScreen extends StatelessWidget {
  const ActionScreen({super.key});

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<Map<String, String>> args =
        ModalRoute.of(context)!.settings.arguments as Set<Map<String, String>>;
    final String message =
        args.firstWhere((arg) => arg.containsKey('message'))['message']!;
    List<Widget> actionButtons = [];
    int i = 1;

    while (args.any(
        (map) => map.containsKey('label$i') && map.containsKey('link$i'))) {
      final String label =
          args.firstWhere((map) => map.containsKey('label$i'))['label$i']!;
      final String link =
          args.firstWhere((map) => map.containsKey('link$i'))['link$i']!;
      final Uri url = Uri.parse(link);
      actionButtons.add(
        ElevatedButton(
          onPressed: () async {
            await _launchInBrowser(url);
          },
          child: Text(label),
        ),
      );

      i++;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaver link tester'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Message:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ...actionButtons,
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to main screen
              },
              child: const Text('Back to Main Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
