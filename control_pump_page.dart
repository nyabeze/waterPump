import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class PumpControl extends StatefulWidget {
  const PumpControl({Key? key}) : super(key: key);

  @override
  State createState() {
    return _PumpControlState();
  }
}

class _PumpControlState extends State<PumpControl> {
  late IOWebSocketChannel channel;
  bool isPumpOn = false;

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    channel = IOWebSocketChannel.connect('ws://localhost:3000');
    channel.sink.add(json.encode({"command":"requestData"}));
    channel.stream.listen((message) {
      // Handle incoming messages if required
    });
  }

  void _sendPumpCommand(bool pumpState) {
    final command = {
      'command': pumpState ? 'on' : 'off',
    };
    channel.sink.add(json.encode(command));
    setState(() {
      isPumpOn = pumpState;
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pump Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isPumpOn ? null : () => _sendPumpCommand(true),
              child: const Text('Turn On'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isPumpOn ? () => _sendPumpCommand(false) : null,
              child: const Text('Turn Off'),
            ),
          ],
        ),
      ),
    );
  }
}
