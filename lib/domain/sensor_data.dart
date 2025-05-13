class SensorData {
  final List<double>? accelerometer;
  final List<double>? gyroscope;
  final List<double>? magnetometer;
  final String timestamp;

  SensorData({
    this.accelerometer,
    this.gyroscope,
    this.magnetometer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'accelerometer': accelerometer,
      'gyroscope': gyroscope,
      'magnetometer': magnetometer,
      'timestamp': timestamp,
    };
  }
}
