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

class Note extends StatelessWidget {
  const Note({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Note'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
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
  String _password = "";

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
      _password = password;
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
                if (myController.text == _password) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Note()),
                  );
                } else {
                  print(_password);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Text("Wrong password"),
                        );
                      });
                }
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
                  _password = myController.text;
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
