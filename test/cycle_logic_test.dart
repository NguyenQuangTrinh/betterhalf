import 'package:flutter_test/flutter_test.dart';
import 'package:betterhalf/src/core/models/cycle_model.dart';
import 'package:betterhalf/src/core/utils/cycle_logic.dart';

void main() {
  group('CycleLogic Tests', () {
    test('predictNextPeriod returns today if no history', () {
      final prediction = CycleLogic.predictNextPeriod([]);
      // Just check it's close to now (within seconds)
      expect(prediction.difference(DateTime.now()).inMinutes, 0);
    });

    test('predictNextPeriod adds 28 days for single cycle', () {
      final start = DateTime(2023, 1, 1);
      final cycle = CycleModel(id: '1', startDate: start);

      final prediction = CycleLogic.predictNextPeriod([cycle]);

      // Jan 1 + 28 days = Jan 29
      expect(prediction, DateTime(2023, 1, 29));
    });

    test('predictNextPeriod calculates average correctly', () {
      // Cycle 1: Jan 1
      // Cycle 2: Jan 31 (30 days later)
      // Cycle 3: Mar 2 (30 days later, assuming non-leap year logic simplified)

      // Let's make it simple math:
      // Cycle 1: Jan 1
      // Cycle 2: Jan 29 (28 days later)
      // Cycle 3: Feb 28 (30 days later)
      // Average: (28+30)/2 = 29 days

      final c1 = CycleModel(id: '1', startDate: DateTime(2023, 1, 1)); // Oldest
      final c2 = CycleModel(id: '2', startDate: DateTime(2023, 1, 29));
      final c3 = CycleModel(
        id: '3',
        startDate: DateTime(2023, 2, 28),
      ); // Newest

      final prediction = CycleLogic.predictNextPeriod([c3, c2, c1]);

      // Next: Feb 28 + 29 days = Mar 29
      expect(prediction, DateTime(2023, 3, 29));
    });

    test('predictOvulation subtracts 14 days', () {
      final nextPeriod = DateTime(2023, 2, 14); // Valentine's Day
      final ovulation = CycleLogic.predictOvulation(nextPeriod);

      // Feb 14 - 14 days = Jan 31
      expect(ovulation, DateTime(2023, 1, 31));
    });
  });
}
