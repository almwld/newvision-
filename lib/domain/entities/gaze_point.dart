import 'package:vector_math/vector_math_64.dart';

class GazePoint {
  const GazePoint({
    required this.position,
    required this.confidence,
    required this.timestamp,
  });
  final Vector2 position;
  final double confidence;
  final DateTime timestamp;
}
