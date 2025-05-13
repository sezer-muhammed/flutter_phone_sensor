import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorFetcher {
  // Accelerometer state
  StreamSubscription? _accelSub;
  Timer? _accelSubTimeoutTimer;
  List<Completer<List<double>?>> _pendingAccelCompleters = [];
  bool _isAccelSubInitializing = false;

  // Gyroscope state
  StreamSubscription? _gyroSub;
  Timer? _gyroSubTimeoutTimer;
  List<Completer<List<double>?>> _pendingGyroCompleters = [];
  bool _isGyroSubInitializing = false;

  // Magnetometer state
  StreamSubscription? _magSub;
  Timer? _magSubTimeoutTimer;
  List<Completer<List<double>?>> _pendingMagCompleters = [];
  bool _isMagSubInitializing = false;

  final Duration _keepAliveDuration = const Duration(milliseconds: 50); // MODIFIED from 750ms
  final Duration _requestTimeoutDuration = const Duration(milliseconds: 40); // MODIFIED from 500ms
  final Duration _sensorSamplingPeriod = const Duration(milliseconds: 20); // MODIFIED from 100ms

  Future<List<double>?> _fetchSensorData({
    required List<Completer<List<double>?>> pendingCompleters,
    required StreamSubscription? currentSubscription,
    required bool isSubInitializing,
    required Function(StreamSubscription?) updateSubscription,
    required Function(bool) updateInitializingState,
    required Function(Timer?) updateTimeoutTimer,
    required Stream<dynamic> sensorEventStream,
    required List<double> Function(dynamic event) eventTransformer,
    required String sensorName, // For logging
  }) async {
    final completer = Completer<List<double>?>();
    pendingCompleters.add(completer);

    // Cancel and restart the idle timeout timer for the subscription
    if (sensorName == 'ACCEL') _accelSubTimeoutTimer?.cancel();
    if (sensorName == 'GYRO') _gyroSubTimeoutTimer?.cancel();
    if (sensorName == 'MAG') _magSubTimeoutTimer?.cancel();


    if (currentSubscription == null && !isSubInitializing) {
      updateInitializingState(true);
      // print('SF: $sensorName - Creating new subscription');
      currentSubscription = sensorEventStream.listen(
        (dynamic event) {
          final value = eventTransformer(event);
          // print('SF: $sensorName - Event: $value, Completers: ${pendingCompleters.length}');
          for (var c in List.from(pendingCompleters)) { // Iterate over a copy
            if (!c.isCompleted) {
              c.complete(value);
            }
          }
          pendingCompleters.clear();
        },
        onError: (e, stackTrace) {
          // print('SF: $sensorName - Error: $e');
          for (var c in List.from(pendingCompleters)) {
            if (!c.isCompleted) {
              c.complete(null);
            }
          }
          pendingCompleters.clear();
          currentSubscription?.cancel();
          updateSubscription(null);
          updateInitializingState(false);
        },
        onDone: () {
          // print('SF: $sensorName - Stream done');
          for (var c in List.from(pendingCompleters)) {
            if (!c.isCompleted) {
              c.complete(null);
            }
          }
          pendingCompleters.clear();
          updateSubscription(null);
          updateInitializingState(false);
        },
        cancelOnError: true,
      );
      updateSubscription(currentSubscription);
      updateInitializingState(false); // Done initializing
    } else {
      // print('SF: $sensorName - Subscription already active or initializing.');
    }

    Timer newTimer = Timer(_keepAliveDuration, () {
      // print('SF: $sensorName - Idle timeout, cancelling subscription.');
      currentSubscription?.cancel();
      updateSubscription(null);
      updateInitializingState(false);
      for (var c in List.from(pendingCompleters)) {
        if (!c.isCompleted) {
          c.complete(null);
        }
      }
      pendingCompleters.clear();
    });

    if (sensorName == 'ACCEL') _accelSubTimeoutTimer = newTimer;
    if (sensorName == 'GYRO') _gyroSubTimeoutTimer = newTimer;
    if (sensorName == 'MAG') _magSubTimeoutTimer = newTimer;


    return completer.future.timeout(_requestTimeoutDuration, onTimeout: () {
      // print('SF: $sensorName - Request timed out for a completer.');
      pendingCompleters.remove(completer);
      return null;
    });
  }

  Future<List<double>?> getCurrentAccelerometer() async {
    return _fetchSensorData(
      pendingCompleters: _pendingAccelCompleters,
      currentSubscription: _accelSub,
      isSubInitializing: _isAccelSubInitializing,
      updateSubscription: (sub) => _accelSub = sub,
      updateInitializingState: (state) => _isAccelSubInitializing = state,
      updateTimeoutTimer: (timer) => _accelSubTimeoutTimer = timer,
      sensorEventStream: accelerometerEventStream(samplingPeriod: _sensorSamplingPeriod),
      eventTransformer: (event) => <double>[(event as AccelerometerEvent).x, event.y, event.z],
      sensorName: 'ACCEL',
    );
  }

  Future<List<double>?> getCurrentGyroscope() async {
    return _fetchSensorData(
      pendingCompleters: _pendingGyroCompleters,
      currentSubscription: _gyroSub,
      isSubInitializing: _isGyroSubInitializing,
      updateSubscription: (sub) => _gyroSub = sub,
      updateInitializingState: (state) => _isGyroSubInitializing = state,
      updateTimeoutTimer: (timer) => _gyroSubTimeoutTimer = timer,
      sensorEventStream: gyroscopeEventStream(samplingPeriod: _sensorSamplingPeriod),
      eventTransformer: (event) => <double>[(event as GyroscopeEvent).x, event.y, event.z],
      sensorName: 'GYRO',
    );
  }

  Future<List<double>?> getCurrentMagnetometer() async {
    return _fetchSensorData(
      pendingCompleters: _pendingMagCompleters,
      currentSubscription: _magSub,
      isSubInitializing: _isMagSubInitializing,
      updateSubscription: (sub) => _magSub = sub,
      updateInitializingState: (state) => _isMagSubInitializing = state,
      updateTimeoutTimer: (timer) => _magSubTimeoutTimer = timer,
      sensorEventStream: magnetometerEventStream(samplingPeriod: _sensorSamplingPeriod),
      eventTransformer: (event) => <double>[(event as MagnetometerEvent).x, event.y, event.z],
      sensorName: 'MAG',
    );
  }

  void dispose() {
    // print('SF: Disposing SensorFetcher');
    _accelSubTimeoutTimer?.cancel();
    _accelSub?.cancel();
    _accelSub = null;
    for (var c in _pendingAccelCompleters) { if (!c.isCompleted) c.complete(null); }
    _pendingAccelCompleters.clear();

    _gyroSubTimeoutTimer?.cancel();
    _gyroSub?.cancel();
    _gyroSub = null;
    for (var c in _pendingGyroCompleters) { if (!c.isCompleted) c.complete(null); }
    _pendingGyroCompleters.clear();

    _magSubTimeoutTimer?.cancel();
    _magSub?.cancel();
    _magSub = null;
    for (var c in _pendingMagCompleters) { if (!c.isCompleted) c.complete(null); }
    _pendingMagCompleters.clear();
  }
}
