import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/gaze_point.dart';
import '../../domain/repositories/gaze_repository.dart';

class GazeRepositoryImpl implements GazeRepository {
  GazeRepositoryImpl();
  GazePoint? _latest;

  @override
  Future<Either<Failure, GazePoint>> latestPoint() async {
    final point = _latest;
    if (point == null) {
      return left(const Failure('No gaze sample is available.', code: 'GAZE_EMPTY'));
    }
    return right(point);
  }

  @override
  Stream<GazePoint> watchPoints() async* {
    if (_latest != null) yield _latest!;
  }

  void publish(GazePoint point) => _latest = point;
}
