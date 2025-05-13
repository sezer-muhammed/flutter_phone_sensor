import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'dart:convert';
import '../data/sensor_fetcher.dart';
import '../domain/sensor_data.dart';

class ApiRoutes {
  final SensorFetcher sensorFetcher;
  final Function(String message) onApiRequest;

  ApiRoutes(this.sensorFetcher, this.onApiRequest);

  shelf_router.Router get router {
    final appRouter = shelf_router.Router();

    appRouter.get('/api/get-imu', _handleGetImu);
    appRouter.get('/', (shelf.Request request) {
      return shelf.Response.ok('Hello from Flutter! Visit /api/get-imu for sensor data.');
    });

    return appRouter;
  }

  Future<shelf.Response> _handleGetImu(shelf.Request request) async {
    final accelData = await sensorFetcher.getCurrentAccelerometer();
    final gyroData = await sensorFetcher.getCurrentGyroscope();
    final magData = await sensorFetcher.getCurrentMagnetometer();

    final sensorData = SensorData(
      accelerometer: accelData,
      gyroscope: gyroData,
      magnetometer: magData,
      timestamp: DateTime.now().toIso8601String(),
    );
    
    onApiRequest("GET /api/get-imu received at \${DateTime.now().toLocal().toIso8601String()}");

    return shelf.Response.ok(
      jsonEncode(sensorData.toJson()),
      headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    );
  }
}
