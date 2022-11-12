import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/note.dart';
import 'package:safe_note/utils.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _storage = const FlutterSecureStorage();
  bool _isSet = false;
  var pass = "";

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
                  var salt = await _storage.read(key: "salt");

                  var key = utf8.encode(salt!);
                  var bytes = utf8.encode(myController.text.trim());
                  try {
                    var hmacSha256 = Hmac(sha256, key);
                    var digest = hmacSha256.convert(bytes);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Note(digest: digest.toString())),
                    );
                    myController.text = "";
                  } catch (e) {
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
                  var salt = generateRandomString(32);
                  var key = utf8.encode(salt);
                  var bytes = utf8.encode(myController.text.trim());
                  var hmacSha256 = Hmac(sha256, key);
                  var digest = hmacSha256.convert(bytes);
                  var newPassword = digest.toString();
                  await _storage.write(key: 'salt', value: salt);

                  final plainText = "Enter your note here";
                  final cipherKey = encrypt.Key.fromBase16(newPassword);
                  final iv = encrypt.IV.fromSecureRandom(16);
                  final encrypter = encrypt.Encrypter(encrypt.AES(cipherKey));
                  final encrypted = encrypter.encrypt(plainText, iv: iv);

                  await _storage.write(key: "note", value: encrypted.base64);
                  await _storage.write(key: "iv", value: iv.base64);

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
