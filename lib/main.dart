import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
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

class Note extends StatefulWidget {
  const Note({super.key});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  final _storage = const FlutterSecureStorage();
  final _noteController = TextEditingController();
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.all(16));

  bool _isSet = false;

  @override
  void initState() {
    super.initState();
    getPass();
  }

  Future getPass() async {
    String? note = await _storage.read(key: 'note');
    if (note == null) {
      _isSet = false;
    } else {
      _noteController.text = note;
      _isSet = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isSet) ...[
              TextField(
                controller: _noteController,
                maxLines: 7,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enter your note here',
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {
                  _storage.write(key: 'note', value: _noteController.text);
                  setState(() {
                    _isSet = true;
                  });
                },
                child: const Text('Save!'),
              ),
            ] else ...[
              TextField(
                controller: _noteController,
                maxLines: 7,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enter your note here',
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () {
                  _storage.write(key: 'note', value: _noteController.text);
                  setState(() {
                    _isSet = true;
                  });
                },
                child: const Text('Save!'),
              ),
            ]
          ],
        ),
      ),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  if (Crypt.sha512(myController.text.trim(),
                              rounds: 10000, salt: "BSMIsTheBest")
                          .toString() ==
                      _password) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Note()),
                    );
                    myController.text = "";
                  } else {
                    myController.text = "";
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
                  String newPassword = Crypt.sha512(myController.text.trim(),
                          rounds: 10000, salt: "BSMIsTheBest")
                      .toString();
                  _storage.write(key: 'pass', value: newPassword);
                  setState(() {
                    _password = newPassword;
                    myController.text = "";
                    _isSet = true;
                  });
                }),
          ],
        ],
      ),
    );
  }
}
