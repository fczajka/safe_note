import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/note.dart';
import 'package:safe_note/utils.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:biometric_storage/biometric_storage.dart';

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
  bool _isDecrypted = false;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getNote();
  }

  @override
  void dispose() {
    super.dispose();
    _noteController.text = '';
    _noteController.dispose();
  }

  Future getNote() async {
    String? note = await _storage.read(key: 'note');
    if (note == null) {
      _isSet = false;
    } else {
      _isSet = true;
    }
    setState(() {});
  }

  Future saveNote() async {
    final response = await BiometricStorage().canAuthenticate();
    if (response != CanAuthenticateResponse.success) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text("Something is wrong with bio"),
            );
          });
      return;
    }

    final store = await BiometricStorage().getStorage('note');

    try {
      await store.write(_noteController.text.trim());
    } on AuthException catch (e) {
      switch (e.code) {
        case (AuthExceptionCode.userCanceled):
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text("Use your finger"),
                );
              });
          break;
        case (AuthExceptionCode.unknown):
          showDialog(
              context: context,
              builder: (context) {
                print(e.code);
                print(e.message);
                return const AlertDialog(
                  content: Text("Too many attempts, try again later"),
                );
              });
          break;
        default:
          break;
      }
      return;
    }

    await showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Note has been saved"),
          );
        });

    setState(() {
      _isDecrypted = false;
    });
  }

  Future readNote() async {
    final response = await BiometricStorage().canAuthenticate();
    if (response != CanAuthenticateResponse.success) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text("Something is wrong with bio"),
            );
          });
    }
    final store = await BiometricStorage().getStorage('note');
    final String? data;
    try {
      data = await store.read();
      _noteController.text = data as String;
    } on AuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text("Wrong password"),
            );
          });
    }
    setState(() {
      _isDecrypted = true;
    });
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.all(16));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: _isDecrypted
            ? Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(children: [
                    TextField(
                      controller: _noteController,
                      maxLines: 8,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Your note",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: ElevatedButton.icon(
                          style: style,
                          icon: const Icon(Icons.fingerprint),
                          onPressed: saveNote,
                          label: const Text('Save note'),
                        )),
                  ]),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: ElevatedButton.icon(
                        style: style,
                        icon: const Icon(Icons.fingerprint),
                        onPressed: readNote,
                        label: const Text('Log in'),
                      )),
                ),
              ));
  }
}
