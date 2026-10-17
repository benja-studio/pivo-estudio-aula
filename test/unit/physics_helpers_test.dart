import 'package:flutter_test/flutter_test.dart';
import 'package:aula/core/utils/physics_helpers.dart';

void main() {
  group('physics_helpers', () {
    test('springFrom generates valid critically damped spring', () {
      final spring = springFrom(dampingRatio: 1.0, response: 0.4);
      expect(spring.mass, equals(1.0));
      expect(spring.stiffness, greaterThan(0));
      expect(spring.damping, greaterThan(0));
    });

    test('project projects positive and negative coordinates consistently', () {
      final projectionForward = project(1000.0);
      final projectionBackward = project(-1000.0);
      expect(projectionForward, greaterThan(0));
      expect(projectionBackward, lessThan(0));
      expect(projectionForward, closeTo(-projectionBackward, 0.001));
    });

    test('rubberband applies non-linear resistance', () {
      const dimension = 400.0;
      final smallDrag = rubberband(50.0, dimension);
      final largeDrag = rubberband(200.0, dimension);

      // Overshoot is always smaller than the unresisted displacement
      expect(smallDrag, lessThan(50.0));
      expect(largeDrag, lessThan(200.0));
      // Larger drag meets progressively higher resistance (marginal displacement decreases)
      expect(largeDrag / smallDrag, lessThan(4.0));
    });
  });
}
