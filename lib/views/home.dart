import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/note.dart';
import 'package:safe_note/utils.dart';

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
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
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
                onPressed: () async {
                  var pass = await _storage.read(key: "pass");
                  var salt = await _storage.read(key: "salt");
                  if (Crypt.sha512(myController.text.trim(),
                              rounds: 10000, salt: salt)
                          .toString() ==
                      pass) {
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
                onPressed: () async {
                  var localSalt = generateRandomString(32);
                  var newPassword = Crypt.sha512(myController.text.trim(),
                          rounds: 10000, salt: localSalt)
                      .toString();
                  await _storage.write(key: 'pass', value: newPassword);
                  await _storage.write(key: 'salt', value: localSalt);
                  setState(() {
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
