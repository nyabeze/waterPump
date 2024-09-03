import 'package:flutter/material.dart';

class PumpControlPage extends StatefulWidget {
  @override
  _PumpControlPageState createState() => _PumpControlPageState();
}

class _PumpControlPageState extends State<PumpControlPage> {
  bool isPumpOn = false;

  void _togglePump() {
    setState(() {
      isPumpOn = !isPumpOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pump Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pump Status: ${isPumpOn ? 'On' : 'Off'}',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _togglePump,
              child: Text(isPumpOn ? 'Turn Off' : 'Turn On'),
            ),
          ],
        ),
      ),
    );
  }
}
