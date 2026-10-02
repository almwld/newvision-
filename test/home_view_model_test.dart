import 'package:flutter_test/flutter_test.dart';
import 'package:eye_control/presentation/home/home_view_model.dart';

void main() {
  test('toggles camera state', () {
    final model = HomeViewModel();
    expect(model.cameraEnabled, isFalse);
    model.setCameraEnabled(true);
    expect(model.cameraEnabled, isTrue);
  });
}
