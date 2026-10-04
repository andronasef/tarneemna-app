import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/audio/domain/services/ab_repeat_controller.dart';
import 'package:tarneemna/features/audio/domain/services/sleep_timer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SleepTimer & ABRepeat Tests', () {
    test('SleepTimerState correctly reports active status and remaining time', () {
      var state = const SleepTimerState();
      expect(state.isActive, false);

      state = state.copyWith(
        mode: SleepTimerMode.minutes,
        remainingTime: const Duration(minutes: 15),
        initialMinutes: 15,
      );
      expect(state.isActive, true);
      expect(state.remainingTime?.inMinutes, 15);
      expect(state.initialMinutes, 15);
    });

    test('SleepTimerNotifier sets minutes and cancels', () {
      final handler = TarneemnaAudioHandler();
      final notifier = SleepTimerNotifier(handler);

      notifier.setTimerMinutes(30);
      expect(notifier.state.isActive, true);
      expect(notifier.state.initialMinutes, 30);
      expect(notifier.state.mode, SleepTimerMode.minutes);

      notifier.cancelTimer();
      expect(notifier.state.isActive, false);
      expect(notifier.state.mode, SleepTimerMode.none);
      expect(notifier.state.remainingTime, isNull);
    });

    test('AbRepeatNotifier enforces point B after point A and clear resets', () {
      final handler = TarneemnaAudioHandler();
      final notifier = AbRepeatNotifier(handler);

      // Set Point A at 10s
      notifier.setPointA(const Duration(seconds: 10));
      expect(notifier.state.hasPointA, true);
      expect(notifier.state.isActive, false);
      expect(notifier.state.pointA, const Duration(seconds: 10));

      // Attempting to set Point B at 5s (before A) is ignored
      notifier.setPointB(const Duration(seconds: 5));
      expect(notifier.state.isActive, false);
      expect(notifier.state.pointB, isNull);

      // Setting Point B at 25s succeeds and activates loop
      notifier.setPointB(const Duration(seconds: 25));
      expect(notifier.state.isActive, true);
      expect(notifier.state.pointB, const Duration(seconds: 25));

      // Clear resets all points
      notifier.clear();
      expect(notifier.state.isActive, false);
      expect(notifier.state.hasPointA, false);
      expect(notifier.state.pointA, isNull);
      expect(notifier.state.pointB, isNull);
    });
  });
}
