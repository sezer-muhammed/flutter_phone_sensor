import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorFetcher {
  Future<List<double>?> getCurrentAccelerometer() async {
    final completer = Completer<List<double>?>();
    StreamSubscription? sub;
    sub = accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 100)).listen(
      (AccelerometerEvent event) {
        if (!completer.isCompleted) {
          completer.complete(<double>[event.x, event.y, event.z]);
          sub!.cancel();
        }
      },
      onError: (e, stackTrace) {
        if (!completer.isCompleted) {
          completer.complete(null);
          sub!.cancel();
        }
      },
      cancelOnError: true,
    );

    try {
      return await completer.future.timeout(const Duration(milliseconds: 500));
    } catch (e) { // TimeoutException
      if (!completer.isCompleted) {
        await sub.cancel();
      }
      return null;
    }
  }

  Future<List<double>?> getCurrentGyroscope() async {
    final completer = Completer<List<double>?>();
    StreamSubscription? sub;
    sub = gyroscopeEventStream(samplingPeriod: const Duration(milliseconds: 100)).listen(
      (GyroscopeEvent event) {
        if (!completer.isCompleted) {
          completer.complete(<double>[event.x, event.y, event.z]);
          sub!.cancel();
        }
      },
      onError: (e, stackTrace) {
        if (!completer.isCompleted) {
          completer.complete(null);
          sub!.cancel();
        }
      },
      cancelOnError: true,
    );

    try {
      return await completer.future.timeout(const Duration(milliseconds: 500));
    } catch (e) { // TimeoutException
      if (!completer.isCompleted) {
        await sub.cancel();
      }
      return null;
    }
  }

  Future<List<double>?> getCurrentMagnetometer() async {
    final completer = Completer<List<double>?>();
    StreamSubscription? sub;
    sub = magnetometerEventStream(samplingPeriod: const Duration(milliseconds: 100)).listen(
      (MagnetometerEvent event) {
        if (!completer.isCompleted) {
          completer.complete(<double>[event.x, event.y, event.z]);
          sub!.cancel();
        }
      },
      onError: (e, stackTrace) {
        if (!completer.isCompleted) {
          completer.complete(null);
          sub!.cancel();
        }
      },
      cancelOnError: true,
    );

    try {
      return await completer.future.timeout(const Duration(milliseconds: 500));
    } catch (e) { // TimeoutException
      if (!completer.isCompleted) {
        await sub.cancel();
      }
      return null;
    }
  }
}
