import 'package:flutter/material.dart';
import 'dart:async';
import '../server/sensor_server.dart';
import '../utils/network_utils.dart';
// Import other necessary modules like domain/sensor_data.dart if needed for display

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SensorServer? _sensorServer;
  String _serverStatus = "Server starting...";
  String _ipAddress = "Determining IP...";
  String _lastApiRequestMessage = "No API requests yet.";
  int? _serverPort;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _updateIpAddress();
    _sensorServer = SensorServer(
      onApiRequest: (message) {
        if (mounted) {
          setState(() {
            _lastApiRequestMessage = message;
          });
        }
      },
    );
    try {
      await _sensorServer!.start(
        (status) {
          if (mounted) {
            setState(() {
              _serverStatus = status;
            });
          }
        },
        (port) {
          if (mounted) {
            setState(() {
              _serverPort = port;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverStatus = "Error starting server: $e";
        });
      }
    }
  }

  Future<void> _updateIpAddress() async {
    String ip = "Could not determine IP";
    try {
      ip = await NetworkUtils.getIpAddress();
    } catch (e) {
      ip = "Error getting IP: $e";
    }
    if (mounted) {
      setState(() {
        _ipAddress = ip;
      });
    }
  }

  @override
  void dispose() {
    _sensorServer?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Server Status:', style: Theme.of(context).textTheme.titleLarge),
              Text('$_ipAddress:${_serverPort ?? "N/A"}', style: Theme.of(context).textTheme.bodyLarge),
              Text(_serverStatus, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text('Last API Request:', style: Theme.of(context).textTheme.titleLarge),
              Text(_lastApiRequestMessage, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text('Sensor Data Status:', style: Theme.of(context).textTheme.titleMedium),
              Text(' (Data is fetched on-demand per API request)', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
