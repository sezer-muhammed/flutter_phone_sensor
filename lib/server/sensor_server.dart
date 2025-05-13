import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'routes.dart';
import '../data/sensor_fetcher.dart'; // Required for ApiRoutes

class SensorServer {
  HttpServer? _server;
  final SensorFetcher _sensorFetcher = SensorFetcher(); // Instantiate SensorFetcher
  final Function(String message) onApiRequest;


  SensorServer({required this.onApiRequest});

  Future<void> start(
      Function(String) onStatusUpdate, Function(int?) onPortUpdate) async {
    final apiRoutes = ApiRoutes(_sensorFetcher, onApiRequest); // Pass SensorFetcher
    final router = apiRoutes.router;

    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(router);

    try {
      _server = await io.serve(handler, '0.0.0.0', 8080);
      onStatusUpdate("Server running on port \${_server!.port}");
      onPortUpdate(_server!.port);
    } catch (e) {
      onStatusUpdate("Error starting server: $e");
      throw e; // Re-throw to be caught by HomePage
    }
  }

  void close() {
    _server?.close(force: true).then((_) {
      // print("Server closed");
    }).catchError((e) {
      // print("Error closing server: $e");
    });
  }

  int? get port => _server?.port;
}
