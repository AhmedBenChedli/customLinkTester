import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zaver_test/screens/action_screen.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/message': (context) => const ActionScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _link = '';
  bool _initialized = false;
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _handleLink(Uri uri) {
    setState(() {
      _link = uri.toString();
    });

    if (uri.queryParameters.containsKey('message')) {
      Navigator.pushNamed(context, '/message', arguments: {
        uri.queryParameters,
      });
    }
  }

  Future<void> initUniLinks() async {
    // Get initial link if the app was opened with a URL
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleLink(Uri.parse(initialLink));
    }
    try {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        setState(() {
          _link = uri.toString();
        });
        if (uri!.queryParameters.containsKey('message')) {
          Navigator.pushNamed(context, '/message',
              arguments: {uri.queryParameters});
        }
      });
      // Check if the app was opened without a URL
      if (_link.isEmpty) {
        setState(() {
          _link = 'no_url';
        });
      }
    } on PlatformException {
      // Handle exception
    } finally {
      setState(() {
        _initialized = true;
      });
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaver custom URL App'),
      ),
      body: _initialized ? _buildContent() : _buildLoadingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    Widget content;
    if (_link == 'no_url') {
      // Display the main screen
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'This app is designed to handle custom URLs. '
            'You can also visit our website for more information:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final Uri url = Uri.parse('https://www.zaver.com/');
              // Open a web page
              await _launchInBrowser(url);
            },
            child: const Text('Visit Zaver.com'),
          ),
        ],
      );
    } else {
      // Display the URL
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Custom URL:',
          ),
          Text(
            _link,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    return Center(
      child: content,
    );
  }
}
