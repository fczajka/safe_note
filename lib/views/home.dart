import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/note.dart';

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
    getPass();
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
