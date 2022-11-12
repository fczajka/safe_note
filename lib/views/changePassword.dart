import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/utils.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ChangePassword extends StatefulWidget {
  final String pass;
  const ChangePassword({super.key, required this.pass});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _storage = const FlutterSecureStorage();
  final _passwordControllerFirst = TextEditingController();
  final _passwordControllerSecond = TextEditingController();
  final _passwordControllerThird = TextEditingController();

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
                  controller: _passwordControllerThird,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter your old password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  obscureText: true,
                  controller: _passwordControllerSecond,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter your new password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  obscureText: true,
                  controller: _passwordControllerFirst,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Reenter new password',
                  ),
                ),
              ),
              ElevatedButton(
                style: style,
                onPressed: () async {
                  var salt = await _storage.read(key: "salt");
                  var key = utf8.encode(salt!);
                  var bytes = utf8.encode(_passwordControllerThird.text.trim());
                  var hmacSha256 = Hmac(sha256, key);
                  var digest = hmacSha256.convert(bytes);
                  var password = widget.pass;

                  if (digest.toString() == password) {
                    if (_passwordControllerFirst.text ==
                        _passwordControllerSecond.text) {
                      var note = await _storage.read(key: 'note');
                      var iv = await _storage.read(key: 'iv');
                      final cipherKey = encrypt.Key.fromBase16(password);
                      final encrypter =
                          encrypt.Encrypter(encrypt.AES(cipherKey));

                      final decrypted = encrypter.decrypt(
                          encrypt.Encrypted.fromBase64(note!),
                          iv: encrypt.IV.fromBase64(iv!));

                      var salt = generateRandomString(32);
                      var key = utf8.encode(salt);
                      var bytes =
                          utf8.encode(_passwordControllerSecond.text.trim());
                      var hmacSha256 = Hmac(sha256, key);
                      var digest = hmacSha256.convert(bytes);
                      var newPassword = digest.toString();

                      await _storage.write(key: 'salt', value: salt);
                      final newCipherKey = encrypt.Key.fromBase16(newPassword);
                      final newIv = encrypt.IV.fromSecureRandom(16);
                      final noteEncrypter =
                          encrypt.Encrypter(encrypt.AES(newCipherKey));
                      final encrypted =
                          noteEncrypter.encrypt(decrypted, iv: newIv);

                      await _storage.write(
                          key: "note", value: encrypted.base64);
                      await _storage.write(key: "iv", value: newIv.base64);

                      setState(() {});
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                              content: Text("Passwords do not match!"),
                            );
                          });
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text("Old password is not correct!"),
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
