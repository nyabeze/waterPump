import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EmailSignInPage extends StatefulWidget {
  @override
  _EmailSignInPageState createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<Database>? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = openDatabase(
      join(await getDatabasesPath(), 'email_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE emails(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _saveEmailToDatabase(BuildContext context, String email) async {
    final db = await _database; // Get the actual database instance

    await db!.insert(
      'emails',
      {'email': email},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Email Saved'),
          content: Text('The email has been saved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
                _emailController.clear(); // Clear the text field
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                await _saveEmailToDatabase(context, email); // Pass the context
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
