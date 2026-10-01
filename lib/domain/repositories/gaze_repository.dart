import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/gaze_point.dart';

abstract interface class GazeRepository {
  Future<Either<Failure, GazePoint>> latestPoint();
  Stream<GazePoint> watchPoints();
}
