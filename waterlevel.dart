import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WaterLevel extends StatefulWidget {
  const WaterLevel({Key? key}) : super(key: key);

  @override
  State createState() {
    return _WaterLevelState();
  }
}

class _WaterLevelState extends State<WaterLevel> {
  Map<String, dynamic> data = {'water_level': 0};

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    final channel = IOWebSocketChannel.connect('ws://localhost:3000'); //url specified and the websocket url sends a JSON encoded messageto the server requesting data
    channel.sink.add(json.encode({"command":"requestData"}));
    channel.stream.listen((message) { //listens for incoming messages from the websocket server
      setState(() {
        data = json.decode(message);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF111219),
            title: const Text(
              "WaterLevel",
              style: TextStyle(color: Colors.white),
            )),
        body: getBody());
  }

  Widget getBody() {
    return SfCartesianChart(
      title: ChartTitle(
          text: 'Water level', textStyle: const TextStyle(color: Colors.black)),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
            text: 'Water level (%)',
            textStyle: const TextStyle(color: Colors.black)),
        maximum: 100,
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        isVisible: true,
      ),
      series: <ChartSeries>[
        BarSeries<Map, String>(
            dataSource: [
              data,
            ],
            xValueMapper: (Map data, _) => '',
            yValueMapper: (Map data, _) => data['water_level'],
            trackColor: const Color(0xFFF5F5F5),
            isTrackVisible: true,
            animationDuration: 0),
      ],
      isTransposed: true,
    );
  }
}
