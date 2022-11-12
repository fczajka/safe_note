import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/utils.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _storage = const FlutterSecureStorage();
  final _passwordControllerFirst = TextEditingController();
  final _passwordControllerSecond = TextEditingController();

  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.all(16));

  @override
  void initState() {
    super.initState();
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  obscureText: true,
                  controller: _passwordControllerFirst,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter your new password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  obscureText: true,
                  controller: _passwordControllerSecond,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Reenter new password',
                  ),
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () async {
                  if (_passwordControllerFirst.text ==
                      _passwordControllerSecond.text) {
                    var localSalt = generateRandomString(32);
                    var newPassword = Crypt.sha512(
                            _passwordControllerSecond.text.trim(),
                            rounds: 10000,
                            salt: localSalt)
                        .toString();
                    await _storage.write(key: 'pass', value: newPassword);
                    await _storage.write(key: 'salt', value: localSalt);

                    setState(() {});
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text("Passwords do not match!"),
                          );
                        });
                  }
                },
                child: const Text('Save'),
              ),
            ]),
      ),
    );
  }
}
