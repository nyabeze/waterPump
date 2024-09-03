import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ControlPumpPage extends StatefulWidget {
  @override
  _ControlPumpPageState createState() => _ControlPumpPageState();
}

class _ControlPumpPageState extends State<ControlPumpPage> {
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _characteristic;
  bool _isDeviceConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  void _initializeBluetooth() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    // Start scanning for devices
    flutterBlue.scanResults.listen((results) {
      // Do something with scan results
      for (ScanResult result in results) {
        print('${result.device.name} found! rssi: ${result.rssi}');
      }
    });

    // Check if Bluetooth is available
    bool isBluetoothAvailable = await flutterBlue.isAvailable;
    if (!isBluetoothAvailable) {
      // Bluetooth is not available on this device
      return;
    }

    // Check if Bluetooth is turned on
    bool isBluetoothOn = await flutterBlue.isOn;
    if (!isBluetoothOn) {
      // Bluetooth is not turned on
      return;
    }

    // Start scanning for devices
    flutterBlue.startScan();

    // Connect to a device
    // Replace 'deviceIdentifier' with the identifier of the desired device
    String deviceIdentifier = 'YOUR_DEVICE_IDENTIFIER';
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.id.toString() == deviceIdentifier) {
          _selectedDevice = result.device;
          break;
        }
      }
    });
    flutterBlue.stopScan();

    if (_selectedDevice != null) {
      await _selectedDevice!.connect();
      _isDeviceConnected = true;

      // Discover services and characteristics
      List<BluetoothService> services = await _selectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        List<BluetoothCharacteristic> characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics) {
          if (characteristic.uuid.toString() == 'YOUR_CHARACTERISTIC_UUID') {
            _characteristic = characteristic;
            break;
          }
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Pump'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device: ${_selectedDevice?.name ?? 'Not connected'}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_isDeviceConnected && _characteristic != null) {
                  _characteristic!.write([1], withoutResponse: true);
                }
              },
              child: Text('Turn On'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_isDeviceConnected && _characteristic != null) {
                  _characteristic!.write([0], withoutResponse: true);
                }
              },

              child: Text('Turn Off'),
            ),
          ],
        ),
      ),
    );
  }
}
