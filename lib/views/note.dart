import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/changePassword.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Note extends StatefulWidget {
  final String digest;
  const Note({super.key, required this.digest});

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
    getNote();
  }

  Future getNote() async {
    var note = await _storage.read(key: 'note');

    var iv = await _storage.read(key: 'iv');

    final cipherKey = encrypt.Key.fromBase16(widget.digest);
    final encrypter = encrypt.Encrypter(encrypt.AES(cipherKey));

    final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(note!),
        iv: encrypt.IV.fromBase64(iv!));

    _noteController.text = decrypted;
    _isSet = true;
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
            TextField(
              controller: _noteController,
              maxLines: 7,
              decoration: const InputDecoration.collapsed(
                hintText: 'Enter your note here',
              ),
            ),
            ElevatedButton(
              style: style,
              onPressed: () async {
                var iv = await _storage.read(key: 'iv');
                var password = widget.digest;

                final cipherKey = encrypt.Key.fromBase16(password);
                final encrypter = encrypt.Encrypter(encrypt.AES(cipherKey));
                final encrypted = encrypter.encrypt(_noteController.text,
                    iv: encrypt.IV.fromBase64(iv!));
                _storage.write(key: 'note', value: encrypted.base64);
                setState(() {
                  _isSet = true;
                });
              },
              child: const Text('Save!'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChangePassword(pass: widget.digest)),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
