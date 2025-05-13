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
  final String _apiEndpoint = "/api/get-imu"; // Define the API endpoint

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(widget.title),
        elevation: 4.0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildInfoCard(
            context,
            title: 'Server Information',
            icon: Icons.dns_outlined,
            iconColor: Colors.blueGrey,
            children: [
              ListTile(
                leading: const Icon(Icons.public),
                title: Text('IP Address:', style: textTheme.titleMedium),
                subtitle: Text('$_ipAddress:${_serverPort ?? "N/A"}', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.power_settings_new),
                title: Text('Server Status:', style: textTheme.titleMedium),
                subtitle: Text(_serverStatus, style: textTheme.bodyLarge),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: 'API Details',
            icon: Icons.api_outlined,
            iconColor: Colors.teal,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: Text('Available Endpoint:', style: textTheme.titleMedium),
                subtitle: Text(_apiEndpoint, style: textTheme.bodyLarge?.copyWith(fontFamily: 'monospace')),
              ),
              ListTile(
                leading: const Icon(Icons.history_toggle_off),
                title: Text('Last API Request:', style: textTheme.titleMedium),
                subtitle: Text(_lastApiRequestMessage, style: textTheme.bodyLarge),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: 'Sensor Data',
            icon: Icons.sensors_outlined,
            iconColor: Colors.deepOrange,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('Fetching Mode:', style: textTheme.titleMedium),
                subtitle: Text('Data is fetched on-demand per API request.', style: textTheme.bodyLarge),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, Color? iconColor, required List<Widget> children}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(icon, size: 28, color: iconColor ?? colorScheme.primary),
                const SizedBox(width: 12),
                Text(title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}
