import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'control_pump_page.dart';
import 'waterlevel.dart';


void main() {
  runApp(WaterPumpControlApp());
}

class WaterPumpControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Pump Control',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/AAA.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signup(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      try {
        DatabaseHelper databaseHelper = DatabaseHelper();
        User? user = await databaseHelper.getUserByUsername(username);

        if (user != null && user.password == password) {
          // Successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(username: username)),
          );
        } else {
          // Invalid credentials
          _showErrorDialog(context, 'Invalid username or password');
        }
      } catch (e) {
        // Handle database errors
        _showErrorDialog(context, 'An error occurred. Please try again later.');
      }
    }
  }
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
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
    return Form(
        key: _formKey,
        child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black),
                  errorStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), // Add space between the two TextFormField widgets
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black87),
                  hintStyle: TextStyle(color: Colors.black87),
                  errorStyle: TextStyle(color: Colors.black87),
                ),
                style: TextStyle(color: Colors.black87),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Login'),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: Colors.white, // Set the text color to white
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _usernameController.clear();
                      _passwordController.clear();
                    },
                    child: Text('Reset'),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Set the text color to white
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _signup(context),
                    child: Text('Create an account'),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Set the text color to white
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26.0),
            ]
        )
    );
  }
}

class SignupPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _createAccount(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    try {
      DatabaseHelper databaseHelper = DatabaseHelper();

      User newUser = User(username: username, password: password);
      await databaseHelper.insertUser(newUser);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _createAccount(context),
              child: Text('Create Account'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PumpControl()),
                );
              },
              child: Text('Control Pump'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: BottomAppBar(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {

                  // Add your logout functionality here
                },
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Contact Us'),
                onTap: () {
                  // Add your contact us functionality here
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Sign in with Email'),
                onTap: () {
                  // Add your sign in with email functionality here
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $username!',
              style: TextStyle(fontSize: 27.0, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PumpControl()),
                );
              },
              child: Text('Control Pump'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WaterLevel()),
                );
              },
              child: Text('Water level graph'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'user.db';
  static const String _tableName = 'users';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE $_tableName (username TEXT PRIMARY KEY, password TEXT)',
          );
        });
  }

  Future<User?> getUserByUsername(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> users = await db.query(
      _tableName,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (users.isNotEmpty) {
      return User(
        username: users[0]['username'],
        password: users[0]['password'],
      );
    }

    return null;
  }

  Future<void> insertUser(User user) async {
    Database db = await database;
    await db.insert(
      _tableName,
      {'username': user.username, 'password': user.password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}


