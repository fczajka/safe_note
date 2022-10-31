import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_note/views/changePassword.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChangePassword()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
