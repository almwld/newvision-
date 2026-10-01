import 'package:get_it/get_it.dart';
import '../data/repositories/gaze_repository_impl.dart';
import '../domain/repositories/gaze_repository.dart';
import '../domain/usecases/get_latest_gaze.dart';
import '../platform/eye_control_platform.dart';

final GetIt serviceLocator = GetIt.instance;

void configureDependencies() {
  if (serviceLocator.isRegistered<GazeRepository>()) return;
  serviceLocator.registerLazySingleton<EyeControlPlatform>(
    EyeControlPlatform.new,
  );
  serviceLocator.registerLazySingleton<GazeRepository>(
    GazeRepositoryImpl.new,
  );
  serviceLocator.registerFactory<GetLatestGaze>(
    () => GetLatestGaze(serviceLocator<GazeRepository>()),
  );
}
