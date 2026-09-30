import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/gaze_point.dart';
import '../repositories/gaze_repository.dart';

class GetLatestGaze {
  const GetLatestGaze(this._repository);
  final GazeRepository _repository;
  Future<Either<Failure, GazePoint>> call() => _repository.latestPoint();
}
