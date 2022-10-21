import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Safe note'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _storage = const FlutterSecureStorage();

  bool _isSet = false;

  @override
  void initState() {
    super.initState();
    getPass();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future getPass() async {
    String? password = await _storage.read(key: 'pass');
    if (password == null) {
      _isSet = false;
    } else {
      _isSet = true;
    }
    setState(() {});
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.all(16));

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (_isSet) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter p@\$\$w0rd',
              ),
              controller: myController,
            ),
          ),
          ElevatedButton(
              style: style,
              child: const Text('Log in'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    if (myController.text == "p@\$\$w0rd") {
                      return const AlertDialog(
                        content: Text("Correct password"),
                      );
                    } else {
                      return const AlertDialog(
                        content: Text("Wrong password"),
                      );
                    }
                  },
                );
              })
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Set p@\$\$w0rd',
              ),
              controller: myController,
            ),
          ),
          ElevatedButton(
              style: style,
              child: const Text('Set password'),
              onPressed: () {
                _storage.write(key: 'pass', value: myController.text);
                setState(() {
                  _isSet = true;
                });
              }),
        ],
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
